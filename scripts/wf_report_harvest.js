export const meta = {
  name: 'report-harvest',
  description: 'Region-agnostic EcoCat report harvest for watershed groups: geo-filtered GNIS supplement + FISS-linked reports, resolve+download+verify, manifest by study-area extent',
  phases: [
    { title: 'EcoCat search', detail: 'region-unique GNIS stream names + thematic keywords (fish passage <WSG>, hab confirmation), geo-filtered' },
    { title: 'Acquire', detail: 'resolve viewReport -> direct PDF -> download -> verify (batched)' },
    { title: 'Manifest', detail: 'flatten + coverage' },
  ],
}

// args: { reports:{reportId:extent}, gnis_names:[...], region_hint:"...", region_regex:"...", harvest_dir:"..." }
const A = typeof args === 'string' ? JSON.parse(args) : (args || {})
const HARVEST = A.harvest_dir
const REGION_RE = new RegExp(A.region_regex || '.', 'i')

const GNIS_SCHEMA = { type:'object', additionalProperties:false,
  properties:{ reports:{ type:'array', items:{ type:'object', additionalProperties:false,
    properties:{ id:{type:'string'}, title:{type:'string'} }, required:['id','title'] } } }, required:['reports'] }
const ACQ_SCHEMA = { type:'object', additionalProperties:false,
  properties:{ rows:{ type:'array', items:{ type:'object', additionalProperties:false,
    properties:{ report_id:{type:'string'}, title:{type:'string'}, author:{type:'string'}, year:{type:'string'},
      pdf_url:{type:'string'}, path:{type:'string'}, http:{type:'string'}, is_pdf:{type:'boolean'} },
    required:['report_id','is_pdf'] } } }, required:['rows'] }

const chunk = (a,n) => { const o=[]; for(let i=0;i<a.length;i+=n) o.push(a.slice(i,i+n)); return o }

// ---- Phase 1: EcoCat search (GNIS stream-names + thematic keywords, GEO-FILTERED)
phase('EcoCat search')
// two search types: exact GNIS stream names + thematic keyword phrases (fish passage <WSG>,
// habitat confirmation <name>, <WSG> inventory ...). Both hit the same advancedSearch endpoint.
const searchTerms = [...(A.gnis_names || []), ...(A.keyword_queries || [])]
const gnis = searchTerms.length ? await agent(
  `Search BC EcoCat for reports using these search terms, then GEO-FILTER the results.
Region context: ${A.region_hint}
Search terms (a mix of exact stream names AND thematic phrases like "fish passage <watershed>",
"habitat confirmation <name>", "<watershed> fish passage inventory"): ${searchTerms.map(t => '"'+t+'"').join('; ')}

For each term, fetch (URL-encode; spaces -> +):
  http://a100.gov.bc.ca/pub/acat/public/advancedSearch.do?keywords=<term>&searchKeyType=searchAll&sortColumn=title
Capture each result's numeric reportId and title.

CRITICAL geo-filter: EcoCat keyword search matches same-named streams / generic terms ALL OVER BC.
INCLUDE a hit ONLY if its title/context clearly places it in the region above (the named watershed group,
its watershed code, or the stated area). EXCLUDE same-named features elsewhere (Vancouver Island,
Kootenays, Skeena, etc.). When unsure, exclude. Return the deduped, geo-filtered union with {id, title}.`,
  { schema: GNIS_SCHEMA, phase:'EcoCat search', label:'ecocat:names+keywords' }) : { reports: [] }

const known = new Set(Object.keys(A.reports))
const gnisNew = [...new Set((gnis?.reports||[])
  .filter(r => /^[0-9]+$/.test(String(r.id)) && !known.has(String(r.id)) && REGION_RE.test(r.title||''))  // regex backstop
  .map(r => String(r.id)))]
log(`EcoCat search: ${(gnis?.reports||[]).length} geo-filtered hits (${searchTerms.length} terms); ${gnisNew.length} new after region-regex backstop + dedup vs ${known.size} FISS reports`)

// ---- Phase 2: Acquire -------------------------------------------------------
phase('Acquire')
const all = [
  ...Object.entries(A.reports).map(([id,extent]) => ({ id:String(id), extent })),
  ...gnisNew.map(id => ({ id, extent:'fraser' })),   // GNIS-discovered -> region-level extent
]
const batches = chunk(all, 12)
log(`acquiring ${all.length} reports in ${batches.length} batches`)

const acquirePrompt = (b) => `Download the primary PDF for each BC EcoCat report below into ${HARVEST} (exists).
Reports (JSON {id, extent}): ${JSON.stringify(b)}
Per report id:
1. H=$(curl -sL -A "Mozilla/5.0" "https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=ID")
2. REL=$(printf '%s' "$H" | grep -oE '/pub/acat/documents/r[0-9]+/[^"]+[.]pdf' | head -1) ; full url = https://a100.gov.bc.ca$REL
3. read Title/Author/Year from the page if visible.
4. curl -sL -A "Mozilla/5.0" "<full pdf url>" -o "${HARVEST}/<extent>__<id>.pdf" -w "%{http_code}"
5. verify: file -b "<path>" contains "PDF" -> is_pdf true, else false + path="".
Do NOT upload anywhere. Return one row per report {report_id, title, author, year, pdf_url, path, http, is_pdf}.`

const acquired = await parallel(batches.map((b,i) => () =>
  agent(acquirePrompt(b), { schema: ACQ_SCHEMA, phase:'Acquire', label:`acquire:${i+1}/${batches.length}` })))

// ---- Phase 3: Manifest ------------------------------------------------------
phase('Manifest')
const rows = acquired.filter(Boolean).flatMap(r => r.rows || [])
const got = rows.filter(r => r.is_pdf)
log(`downloaded ${got.length}/${all.length} PDFs`)
return { total_targets: all.length, fiss_reports: known.size, gnis_new: gnisNew.length, downloaded: got.length, manifest: rows }
