#!/bin/bash
# #73 remaining runs, second chain. The first (20261023_chain_73.sh) stopped when link#361's provincial
# run renamed fresh_default to fresh_default_20261017 at 2026-10-23T07:41Z, after the two jobs it had
# waited on exited and before the chain's bull trout comparison connected. Every run here reads the
# archived schema by name (SCHEMA). The bull trout comparison runs beside the four-species tuning; the
# four-species comparison composes the saved bull trout tables, so it waits for both.
set -u
cd "$(dirname "$0")/../../.." || exit 1   # the repo root, three above scripts/logs/habitat
export SCHEMA=fresh_default_20261017
LOGS=scripts/logs/habitat
CHAIN=$LOGS/20261023_chain2_73.out
STAMP=$(mktemp "${TMPDIR:-/tmp}/chain2_73.XXXXXX")
say() { echo "$(date -u +%FT%TZ) $*" >> "$CHAIN"; }
say "chain2 started; SCHEMA=$SCHEMA; BT 0330 (2 workers) and GR,RB,ST,WCT 0320 (6 workers)"
SPECIES=BT WORKERS=2 Rscript scripts/0330-compare.R > $LOGS/20261023_chain2_0330-bt.out 2>&1 &
P1=$!
SPECIES=GR,RB,ST,WCT WORKERS=6 Rscript scripts/0320-tune-run.R > $LOGS/20261023_chain2_0320-gr_rb_st_wct.out 2>&1 &
P2=$!
wait "$P1"; R1=$?; say "BT 0330 exit $R1"
# 0330 names its log by date, so the four-species run would overwrite the bull trout one: keep it under -bt
for f in compare.txt compare-workers.out; do
  src=$(ls -t $LOGS/*_$f 2>/dev/null | head -1)
  if [ -n "$src" ] && [ "$src" -nt "$STAMP" ]; then
    dst="${src%.*}-bt.${src##*.}"; mv "$src" "$dst" && say "kept $dst"
  fi
done
wait "$P2"; R2=$?; say "GR,RB,ST,WCT 0320 exit $R2"
rm -f "$STAMP"
if [ "$R2" -ne 0 ]; then say "FAILED: four-species tuning exit $R2; comparison not run"; exit 1; fi
if [ "$R1" -ne 0 ]; then say "FAILED: bull trout comparison exit $R1; the four-species comparison would compose its stale tables; not run"; exit 1; fi
say "starting GR,RB,ST,WCT 0330"
SPECIES=GR,RB,ST,WCT Rscript scripts/0330-compare.R > $LOGS/20261023_chain2_0330-gr_rb_st_wct.out 2>&1
R3=$?
say "GR,RB,ST,WCT 0330 exit $R3"
say "chain2 finished (BT 0330 $R1, 0320 $R2, 0330 $R3)"
