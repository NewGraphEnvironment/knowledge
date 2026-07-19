export const meta = {
  name: 'bowr-mcgr-report-harvest',
  description: 'Harvest EcoCat report PDFs for Bowron (BOWR) + McGregor (MCGR) watershed groups: per-group geo-filtered GNIS+keyword EcoCat search, resolve+download the FISS-linked reports, verify, manifest by extent. Feeds the fraser.duckdb ragnar store.',
  phases: [
    { title: 'EcoCat search', detail: 'per group: region-unique GNIS stream names + thematic keywords, geo-filtered' },
    { title: 'Acquire', detail: 'resolve viewReport -> direct PDF -> download -> verify (batched, parallel)' },
    { title: 'Manifest', detail: 'flatten + coverage per group' },
  ],
}

// args: { groups:[{code, reports:[ids], gnis_names:[], keyword_queries:[], region_hint, region_regex}], harvest_dir }
const A = typeof args === 'string' ? JSON.parse(args) : (args || {})
const HARVEST = A.harvest_dir

const GNIS_SCHEMA = { type:'object', additionalProperties:false,
  properties:{ reports:{ type:'array', items:{ type:'object', additionalProperties:false,
    properties:{ id:{type:'string'}, title:{type:'string'} }, required:['id','title'] } } }, required:['reports'] }
const ACQ_SCHEMA = { type:'object', additionalProperties:false,
  properties:{ rows:{ type:'array', items:{ type:'object', additionalProperties:false,
    properties:{ report_id:{type:'string'}, title:{type:'string'}, author:{type:'string'}, year:{type:'string'},
      pdf_url:{type:'string'}, path:{type:'string'}, http:{type:'string'}, is_pdf:{type:'boolean'} },
    required:['report_id','is_pdf'] } } }, required:['rows'] }

const chunk = (a,n) => { const o=[]; for(let i=0;i<a.length;i+=n) o.push(a.slice(i,i+n)); return o }

// ---- Phase 1: EcoCat search per group (GNIS names + keyword phrases, GEO-FILTERED) ----
phase('EcoCat search')
const searchPrompt = (g) => {
  const terms = [...(g.gnis_names||[]), ...(g.keyword_queries||[])]
  return `Search BC EcoCat for reports using these search terms, then GEO-FILTER the results to the ${g.code} watershed group.
Region context: ${g.region_hint}
Search terms (a mix of exact stream names AND thematic phrases): ${terms.map(t => '"'+t+'"').join('; ')}

For each term, fetch (URL-encode; spaces -> +):
  http://a100.gov.bc.ca/pub/acat/public/advancedSearch.do?keywords=<term>&searchKeyType=searchAll&sortColumn=title
You may curl and parse the HTML. Capture each result's numeric reportId and its title.

CRITICAL geo-filter: EcoCat keyword search matches same-named streams / generic terms ALL OVER BC.
INCLUDE a hit ONLY if its title/context clearly places it in the ${g.code} region above (the named watershed group,
its streams, or the stated area). EXCLUDE same-named features elsewhere (Vancouver Island, Kootenays, Skeena,
Peace, coast, etc.). When unsure, EXCLUDE. Return the deduped, geo-filtered union with {id, title}.`
}

const searched = await parallel((A.groups||[]).map(g => () =>
  agent(searchPrompt(g), { schema: GNIS_SCHEMA, phase:'EcoCat search', label:`ecocat:${g.code}` })
    .then(res => ({ g, res: res || { reports: [] } }))
))

// ---- assemble acquire list: FISS reports + geo-filtered new hits, tagged by extent ----
const acquireTargets = []   // {id, extent}
const perGroup = {}
for (const s of searched.filter(Boolean)) {
  const g = s.g
  const known = new Set((g.reports||[]).map(String))
  const RE = new RegExp(g.region_regex || '.', 'i')
  const fresh = [...new Set((s.res.reports||[])
    .filter(r => /^[0-9]+$/.test(String(r.id)) && !known.has(String(r.id)) && RE.test(r.title||''))
    .map(r => String(r.id)))]
  perGroup[g.code] = { fiss: [...known], gnis_new: fresh }
  for (const id of known) acquireTargets.push({ id, extent: g.code })
  for (const id of fresh) acquireTargets.push({ id, extent: g.code })
  log(`${g.code}: ${known.size} FISS reports + ${fresh.length} new geo-filtered EcoCat hits (from ${(s.res.reports||[]).length} raw)`)
}
// dedup identical (id,extent) pairs
const seen = new Set()
const targets = acquireTargets.filter(t => { const k = t.extent+'__'+t.id; if(seen.has(k)) return false; seen.add(k); return true })

// ---- Phase 2: Acquire (resolve + download + verify, batched parallel) ----
phase('Acquire')
const batches = chunk(targets, 12)
log(`acquiring ${targets.length} reports in ${batches.length} batches`)
const acquirePrompt = (b) => `Download the primary PDF for each BC EcoCat report below into ${HARVEST} (it already exists).
Reports (JSON {id, extent}): ${JSON.stringify(b)}
Per report id:
1. H=$(curl -sL -A "Mozilla/5.0" "https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=ID")
2. REL=$(printf '%s' "$H" | grep -oE '/pub/acat/documents/r[0-9]+/[^"]+[.]pdf' | head -1) ; full url = https://a100.gov.bc.ca$REL
3. read Title/Author/Year from the page text if visible.
4. curl -sL -A "Mozilla/5.0" "<full pdf url>" -o "${HARVEST}/<extent>__<id>.pdf" -w "%{http_code}"
5. verify: file -b "<path>" contains "PDF" -> is_pdf true, else false + path="".
Some reports have only maps/zip (no PDF) -> is_pdf=false, path="". Do NOT upload anywhere.
Return one row per report {report_id, title, author, year, pdf_url, path, http, is_pdf}.`

const acquired = await parallel(batches.map((b,i) => () =>
  agent(acquirePrompt(b), { schema: ACQ_SCHEMA, phase:'Acquire', label:`acquire:${i+1}/${batches.length}` })))

// ---- Phase 3: Manifest ----
phase('Manifest')
const rows = acquired.filter(Boolean).flatMap(r => r.rows || [])
const got = rows.filter(r => r.is_pdf)
log(`downloaded ${got.length}/${targets.length} PDFs (${rows.length - got.length} had no PDF / failed)`)
return { per_group: perGroup, total_targets: targets.length, downloaded: got.length, manifest: rows }
