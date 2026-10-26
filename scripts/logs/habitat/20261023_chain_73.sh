#!/bin/bash
# #73 remaining runs, detached from any session. Waits for the chinook comparison
# (master R pid 39789) and the bull trout tuning (pid 46864) to exit, checks the
# tuning finished, then: bull trout comparison beside the four-species tuning,
# then the four-species comparison. Each step's stdout goes to scripts/logs/habitat/.
set -u
cd "$(dirname "$0")/../../.." || exit 1   # the repo root, three above scripts/logs/habitat
LOGS=scripts/logs/habitat
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
CHAIN=$LOGS/20261023_chain_73.out
say() { echo "$(date -u +%FT%TZ) $*" >> "$CHAIN"; }
say "chain started; waiting on pids 39789 (CH 0330) and 46864 (BT 0320)"
while kill -0 46864 2>/dev/null || kill -0 39789 2>/dev/null; do sleep 60; done
say "both exited"
BTLOG=$(ls -t $LOGS/*tune_run-bt*.txt 2>/dev/null | head -1)
if [ -z "$BTLOG" ] || ! grep -q "^Done in" "$BTLOG"; then
  say "FAILED: bull trout tuning log missing or has no 'Done in' line (${BTLOG:-none}); chain stopped"
  exit 1
fi
say "BT tuning done per $BTLOG; starting BT 0330 and GR,RB,ST,WCT 0320 (6 workers)"
SPECIES=BT Rscript scripts/0330-compare.R > $LOGS/20261023_chain_0330-bt.out 2>&1 &
P1=$!
SPECIES=GR,RB,ST,WCT WORKERS=6 Rscript scripts/0320-tune-run.R > $LOGS/20261023_chain_0320-gr_rb_st_wct.out 2>&1 &
P2=$!
wait "$P1"; R1=$?; say "BT 0330 exit $R1"
wait "$P2"; R2=$?; say "GR,RB,ST,WCT 0320 exit $R2"
if [ "$R2" -ne 0 ]; then say "FAILED: four-species tuning exit $R2; comparison not run"; exit 1; fi
say "starting GR,RB,ST,WCT 0330"
SPECIES=GR,RB,ST,WCT Rscript scripts/0330-compare.R > $LOGS/20261023_chain_0330-gr_rb_st_wct.out 2>&1
R3=$?
say "GR,RB,ST,WCT 0330 exit $R3"
say "chain finished (BT 0330 $R1, 0320 $R2, 0330 $R3)"
