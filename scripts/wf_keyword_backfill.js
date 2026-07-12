export const meta = {
  name: 'keyword-backfill',
  description: 'Backfill thematic fish-passage reports (planning / phase 1-3 / design / hab-con) missed by FISS+GNIS harvest, across watershed groups, via geo-filtered EcoCat keyword search',
  phases: [
    { title: 'Keyword search', detail: 'one agent per WSG: thematic EcoCat searches, geo-filtered, skip already-harvested' },
    { title: 'Acquire', detail: 'resolve + download + verify the new reports' },
  ],
}
const A = typeof args === 'string' ? JSON.parse(args) : (args || {})
const HARVEST = A.harvest_dir
const skip0 = new Set((A.skip_ids || []).map(String))

const SEARCH_SCHEMA = { type:'object', additionalProperties:false, properties:{ reports:{ type:'array', items:{
  type:'object', additionalProperties:false, properties:{ id:{type:'string'}, title:{type:'string'} }, required:['id','title'] } } }, required:['reports'] }
const ACQ_SCHEMA = { type:'object', additionalProperties:false, properties:{ rows:{ type:'array', items:{
  type:'object', additionalProperties:false, properties:{ report_id:{type:'string'}, title:{type:'string'}, author:{type:'string'},
    year:{type:'string'}, pdf_url:{type:'string'}, path:{type:'string'}, http:{type:'string'}, is_pdf:{type:'boolean'} },
  required:['report_id','is_pdf'] } } }, required:['rows'] }
const chunk = (a,n) => { const o=[]; for(let i=0;i<a.length;i+=n) o.push(a.slice(i,i+n)); return o }

// ---- Phase 1: per-group thematic keyword search (geo-filtered) ---------------
phase('Keyword search')
const per = await parallel((A.groups || []).map(g => () =>
  agent(`Search BC EcoCat for THEMATIC fish-passage reports about the ${g.wsg} watershed group, then GEO-FILTER.
Region: ${g.region_hint}
Search terms (thematic phrases — planning, inventory, design, habitat confirmation): ${g.keyword_queries.map(q=>'"'+q+'"').join('; ')}
For each term fetch (URL-encode; spaces -> +):
  http://a100.gov.bc.ca/pub/acat/public/advancedSearch.do?keywords=<term>&searchKeyType=searchAll&sortColumn=title
Capture each result's numeric reportId and title.
GEO-FILTER: INCLUDE a hit ONLY if its title/context clearly places it in THIS region (watershed code,
its named streams, or the stated area). EXCLUDE same-named features elsewhere in BC. When unsure, exclude.
Return the deduped, geo-filtered union with {id, title}.`,
    { schema: SEARCH_SCHEMA, phase:'Keyword search', label:`kw:${g.wsg}`, effort:'low' })
    .then(r => ({ wsg:g.wsg, region_regex:g.region_regex, reports:(r?.reports||[]) }))))

// dedup across groups + regex backstop + skip already-harvested
const seen = new Set(skip0); const toGet = []
for (const g of per.filter(Boolean)) {
  const re = new RegExp(g.region_regex, 'i')
  for (const r of g.reports) { const id = String(r.id)
    if (/^[0-9]+$/.test(id) && !seen.has(id) && re.test(r.title||'')) { seen.add(id); toGet.push({ id, extent:g.wsg }) } }
}
log(`keyword backfill: ${toGet.length} NEW region-relevant reports (skipped ${skip0.size} already-harvested)`)

// ---- Phase 2: acquire -------------------------------------------------------
phase('Acquire')
const acquirePrompt = (b) => `Download the primary PDF for each BC EcoCat report below into ${HARVEST} (exists).
Reports (JSON {id, extent}): ${JSON.stringify(b)}
Per report id:
1. H=$(curl -sL -A "Mozilla/5.0" "https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=ID")
2. REL=$(printf '%s' "$H" | grep -oE '/pub/acat/documents/r[0-9]+/[^"]+[.]pdf' | head -1) ; url = https://a100.gov.bc.ca$REL
3. read Title/Author/Year from the page.
4. curl -sL -A "Mozilla/5.0" "<url>" -o "${HARVEST}/<extent>__<id>.pdf" -w "%{http_code}"
5. verify file -b contains "PDF" -> is_pdf true else false + path="".
Do NOT upload. Return {report_id, title, author, year, pdf_url, path, http, is_pdf} per report.`
const acq = toGet.length ? await parallel(chunk(toGet,12).map((b,i) => () =>
  agent(acquirePrompt(b), { schema: ACQ_SCHEMA, phase:'Acquire', label:`acquire:${i+1}` }))) : []

const rows = acq.filter(Boolean).flatMap(r => r.rows || [])
return { found: toGet.length, downloaded: rows.filter(r=>r.is_pdf).length, manifest: rows,
         extent_map: Object.fromEntries(toGet.map(t => [t.id, t.extent])) }
