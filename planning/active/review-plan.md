# Plan review (#67), Plan agent, spawned 2026-10-19T05:49Z

Read-only reviewer; findings returned in its reply and written here by the session. Disposition in brackets.

0. Phase 1 edits correct. Pre-existing: `tune_grid(thr[0, ])` stops for a species missing from the thresholds.
   [noted in findings; out of scope]
1. BLOCKER: `id_segment` repeats across groups (5,569,273 of 5,757,827); join on (id_segment, watershed_group_code).
   [found independently before the review landed; 0322 joins on both]
2. Segments carry no `waterbody_key`; the compare's `change` table measures against default at 5.49 %, so the band
   reasons need their own logic. [0322 classifies by edge type (stream edges 1000/1100/2000/2300, the compare's
   own `stream` test) and logs the off-stream added km by edge type]
3. Compare is ~60 min per rule; parallel runs need their own `scratch=`. [0322: clusterMap, scratch knw_gx_*]
4. Regression: the tune csv is rounded; match by rule; cross-host BLAS may differ ~1e-10; assert input md5s.
   [0322 compares with the unrounded CH_rear_score.rds by rule at tolerance 1e-8, logs the largest difference,
   and stops unless the input md5s equal 0320's log]
5. .gitignore needs recursive patterns (score, curve, grades, segments). [generalised to `**/`]
6. 0322 must never write to the top of data/tune/ (0325, thresholds table and 0330 read it). [writes only under
   grad_ext/; no grading in the score stage]
7. Region share by gradient is not stored; define it (max per-rule share) and keep a per-gradient summary for the
   article (min ddev_best with SE, any in region, summed boot_rec_share). [0322 writes CH_rear_by_grad.csv]
8. Regrading moves the 95th-percentile reference, so every segment's grade shifts. [graded km reported provisional]
9. Check fresh_default still holds the 10-17 run: regenerated default_km per group must equal 0330's. [0322 checks]
10. Cache key ignores seed, folds, n_boot, seeds_more, d_floor. [documented in @param cache_dir]
11. Article: other literals (257-258, 293) and the region text (179, 476) if a steeper rule enters. [Phase 5]
12. The extended run's own curve is not used by the compare. [said in the header]
13. research/README row describes #54's rule; NEWS top heading is the released 0.4.4; log ties per gradient.
    [Phase 4; ties logged]
