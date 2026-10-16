export const meta = {
  name: 'peace-report-harvest',
  description: 'Harvest EcoCat report PDFs + metadata for Peace watershed groups (PCEA/PINE/PARA): GNIS-unique supplement search, resolve+download the FISS-linked reports, manifest by study-area extent',
  phases: [
    { title: 'GNIS supplement', detail: 'EcoCat search on PINE-unique stream names for non-FISS reports' },
    { title: 'Acquire', detail: 'resolve viewReport -> direct PDF -> download -> verify (batched)' },
    { title: 'Manifest', detail: 'flatten + report download coverage' },
  ],
}

// args.harvest_dir: an existing directory the PDFs are downloaded into (read below, with the other args)

const GNIS_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: { reports: { type: 'array', items: {
    type: 'object', additionalProperties: false,
    properties: { id: { type: 'string' }, title: { type: 'string' } }, required: ['id'] } } },
  required: ['reports'],
}
const ACQ_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: { rows: { type: 'array', items: {
    type: 'object', additionalProperties: false,
    properties: {
      report_id: { type: 'string' }, title: { type: 'string' }, author: { type: 'string' },
      year: { type: 'string' }, pdf_url: { type: 'string' }, path: { type: 'string' },
      http: { type: 'string' }, is_pdf: { type: 'boolean' } },
    required: ['report_id', 'is_pdf'] } } },
  required: ['rows'],
}

const chunk = (a, n) => { const o = []; for (let i = 0; i < a.length; i += n) o.push(a.slice(i, i + n)); return o }

// args may arrive as a JSON string or a parsed object — normalize.
const A = typeof args === 'string' ? JSON.parse(args) : (args || {})
const HARVEST = A.harvest_dir
if (!HARVEST) throw new Error('args.harvest_dir is required')

// ---- Phase 1: GNIS supplement (find non-FISS reports by PINE-unique stream name) ----
phase('GNIS supplement')
const names = A.pine_names || []
const gnis = await agent(
  `Search BC EcoCat for reports about these streams. All are UNIQUE to the Pine River watershed group, so every hit is Pine-relevant (no location check needed).
Streams: ${names.join('; ')}

For each stream name, run an EcoCat keyword search by fetching this URL (URL-encode the name, spaces -> +):
  http://a100.gov.bc.ca/pub/acat/public/advancedSearch.do?keywords=<name>&searchKeyType=searchAll&sortColumn=title
You may curl it and parse the HTML, or use a web fetch. Each results page lists reports; capture every result's numeric reportId and its title.
Return the UNION across all names, deduped by reportId.`,
  { schema: GNIS_SCHEMA, phase: 'GNIS supplement', label: 'gnis:pine-unique' })

const known = new Set(Object.keys(A.reports))
const gnisNew = [...new Set((gnis?.reports || []).map(r => String(r.id)).filter(id => /^[0-9]+$/.test(id) && !known.has(id)))]
log(`GNIS supplement returned ${(gnis?.reports || []).length} hits; ${gnisNew.length} are new beyond the ${known.size} FISS-linked reports`)

// ---- Phase 2: Acquire (resolve + download + verify, batched) ----
phase('Acquire')
const all = [
  ...Object.entries(A.reports).map(([id, extent]) => ({ id: String(id), extent })),
  ...gnisNew.map(id => ({ id, extent: 'PINE' })),
]
const batches = chunk(all, 12)
log(`acquiring ${all.length} reports in ${batches.length} batches`)

const acquirePrompt = (b) => `Download the primary PDF for each BC EcoCat report below into the directory ${HARVEST} (it already exists).
Reports (JSON array of {id, extent}): ${JSON.stringify(b)}

For EACH report id, run these bash steps:
1. Fetch the report page HTML:
   H=$(curl -sL -A "Mozilla/5.0" "https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=ID")
2. Extract the FIRST direct document PDF link (relative path) from the HTML:
   REL=$(printf '%s' "$H" | grep -oE '/pub/acat/documents/r[0-9]+/[^"]+[.]pdf' | head -1)
   The full URL is  https://a100.gov.bc.ca$REL
3. Best-effort read the report Title, Author(s), and Year from the page text.
4. Download into ${HARVEST} named "<extent>__<id>.pdf" (extent is given per report):
   curl -sL -A "Mozilla/5.0" "https://a100.gov.bc.ca$REL" -o "${HARVEST}/<extent>__<id>.pdf" -w "%{http_code}"
5. Verify with:  file -b "${HARVEST}/<extent>__<id>.pdf"  — set is_pdf=true ONLY if the output contains "PDF".

Notes: some reports have only maps/zip (no PDF) — set is_pdf=false and path="" for those. Do NOT upload anywhere; only download and report back.
Return one row per report: {report_id, title, author, year, pdf_url (the full url), path (absolute), http, is_pdf}.`

const acquired = await parallel(batches.map((b, i) => () =>
  agent(acquirePrompt(b), { schema: ACQ_SCHEMA, phase: 'Acquire', label: `acquire:${i + 1}/${batches.length}` })
))

// ---- Phase 3: Manifest ----
phase('Manifest')
const rows = acquired.filter(Boolean).flatMap(r => r.rows || [])
const got = rows.filter(r => r.is_pdf)
log(`downloaded ${got.length}/${all.length} PDFs (${rows.length - got.length} had no PDF / failed)`)
return {
  total_targets: all.length,
  fiss_reports: known.size,
  gnis_new: gnisNew.length,
  downloaded: got.length,
  manifest: rows,
}
