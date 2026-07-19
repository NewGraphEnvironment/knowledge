export const meta = {
  name: 'farm-priority-tables',
  description: 'Fan out one agent per big inventory/planning PDF (Masse McGregor priority-ID, Triton TFL30/TSA24, Cascadia Indianpoint) to lift their priority / crossing tables into structured rows carrying the report\'s OWN crossing IDs (+ PSCIS ID where printed). Deterministic PSCIS reconciliation on external_crossing_reference happens downstream.',
  phases: [
    { title: 'Extract', detail: 'per PDF: pdftotext -> locate priority tables -> structured rows' },
  ],
}

const A = typeof args === 'string' ? JSON.parse(args) : (args || {})

// targets may be compact {code, report_id, kind} (+ harvest_dir) or full {code, report_id, pdf_path, hint}.
// `kind` maps to an extraction hint so the caller doesn't repeat long prose per PDF.
const HINTS = {
  crossing: 'Fish-passage culvert inventory/assessment. Farm the crossing/priority tables: report crossing id, PSCIS id if printed, stream, priority (high/moderate/low/no-fix), barrier result, Fish Barrier Score (FBS), habitat value, coords, recommendation (replace/deactivate/backwater).',
  recon: '1:20,000 Reconnaissance Fish & Fish Habitat Inventory (habitat/reach inventory, NOT a crossing table). Farm the reach/site table: capture fish-bearing vs NON-fish-bearing reach determinations, reach/site ids, stream, watershed code, species captured, gradient, and coords. table_source="habitat-inventory".',
  restoration: 'Watershed Restoration Program road-deactivation / prescription / work-completion report. Farm the stream-crossing / culvert tables: crossing/culvert id, road, action (remove/deactivate/replace/install), stream, coords, status. table_source="restoration".',
  habitat: 'Riparian / habitat / watershed-level assessment. Farm any reach- or site-level tables: reach/site id, stream, habitat or riparian condition, fish presence, coords. table_source="habitat-assessment".',
  permit: 'Scientific fish-collection permit data. Farm the sampling records: site id, stream, species captured, method, coords, date. table_source="fish-sampling".',
}
const targets = (A.targets || []).map(t => ({
  code: t.code, report_id: t.report_id,
  pdf_path: t.pdf_path || `${A.harvest_dir}/${t.code}__${t.report_id}.pdf`,
  hint: t.hint || HINTS[t.kind] || HINTS.crossing,
}))

const ROW_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    report_id: { type: 'string' },
    code: { type: 'string' },
    table_source: { type: 'string' },   // which table/appendix the rows came from
    n_rows: { type: 'integer' },
    rows: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false,
        properties: {
          report_crossing_id: { type: 'string' },   // the report's OWN id (joins PSCIS.external_crossing_reference)
          pscis_crossing_id:  { type: 'string' },    // if the report prints a PSCIS id, else ""
          stream_name:        { type: 'string' },
          priority:           { type: 'string' },    // e.g. high-known-fish / high / moderate / low / no-fix
          barrier:            { type: 'string' },    // barrier result / status
          fish_barrier_score: { type: 'string' },
          habitat_value:      { type: 'string' },
          coords:             { type: 'string' },    // "easting northing zoneNN" OR "lat lon" as printed
          upstream_fish:      { type: 'string' },    // known fish presence upstream, if stated
          recommendation:     { type: 'string' },    // fix/replace/deactivate/etc
          notes:              { type: 'string' },
        },
        required: ['report_crossing_id'],
      },
    },
  },
  required: ['report_id', 'code', 'rows'],
}

const prompt = (t) => `You are farming the PRIORITY / CROSSING tables out of one BC fish-passage inventory or planning PDF.

PDF: ${t.pdf_path}
Watershed group: ${t.code}   EcoCat reportId: ${t.report_id}
What this report is: ${t.hint}

STEPS (use bash):
1. Extract text:  pdftotext -q "${t.pdf_path}" /tmp/farm_${t.report_id}.txt   (add -layout and re-run if columns are mangled)
2. Find the priority summary tables. Look for headings like "high priority", "moderate priority",
   "low priority", "Priority Sites for Restoration", "Fish Barrier Score (FBS)", "Summary of ...
   priority crossings", and appendices of ranked crossings. grep -niE with those terms to locate line ranges,
   then sed -n 'A,Bp' to read each table block.
3. For EVERY crossing row in those tables, capture:
   - report_crossing_id: the crossing/site id AS PRINTED IN THIS REPORT (e.g. "10", "103", "BOWRON_2008_44",
     "TT1124"). This is the key that reconciles to PSCIS.external_crossing_reference downstream. REQUIRED.
   - pscis_crossing_id: only if the report explicitly prints a PSCIS id (e.g. "PSCIS 6681"), else "".
   - stream_name, priority (normalize to one of: high-known-fish / high / moderate / low / no-fix / <as-printed>),
     barrier (barrier result/status), fish_barrier_score (FBS number if present), habitat_value,
     coords (easting northing + zone, OR lat lon, exactly as printed), upstream_fish (known fish upstream?),
     recommendation (fix/replace/deactivate/backwater/no-fix), notes.
   Leave a field "" when the report doesn't give it. DO NOT invent values.

RULES:
- Transcribe verbatim; do not compute or infer barrier status or priority.
- If a table spans several pages, include all pages.
- If this report has NO crossing-priority table (it's a habitat/reach inventory), instead capture the
  fish-bearing / NON-fish-bearing reach determinations and any crossing/site ids with coords, and note
  table_source="habitat-inventory".
- Return { report_id, code, table_source, n_rows, rows:[...] }. n_rows must equal rows.length.`

phase('Extract')
const out = await parallel(targets.map(t => () =>
  agent(prompt(t), { schema: ROW_SCHEMA, phase: 'Extract', label: `farm:${t.code}:${t.report_id}` })
    .then(r => r || { report_id: t.report_id, code: t.code, table_source: 'ERROR', rows: [] })))

const flat = out.filter(Boolean)
const total = flat.reduce((s, r) => s + (r.rows ? r.rows.length : 0), 0)
for (const r of flat) log(`${r.code} ${r.report_id} (${r.table_source}): ${r.rows ? r.rows.length : 0} rows`)
log(`TOTAL farmed rows: ${total}`)
return { targets: targets.length, total_rows: total, extracts: flat }
