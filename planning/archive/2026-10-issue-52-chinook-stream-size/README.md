## Outcome

#52 asked what stream sizes juvenile Chinook are caught in, using wet's published flow on every FDIS
electrofishing visit in link's CH range, and whether small-stream CH sit near large rivers. The plan
review changed the build before any result was read:
- it found that one regulated-river survey dominated the top classes;
- it found that dropping visits with no picked flow removed side channels;
- it found that `fwa_downstreamtrace` is not a path. Distance became an explicit route-measure walk
  (`scripts/sql/ch_dist_large.sql`), and side channels took their parent line's flow.

The result is in `research/chinook_stream_size.md`, which #54 builds on to tune a rearing rule. Four code-check
rounds found the code clean every time, and every finding was in the prose: numbers that matched the outputs,
framed by words (most, smaller, better, downstream) that claimed something about a population the number did
not measure. Two of those sat inside earlier fixes. It ended when the write-up was rewritten under one rule
(every figure names its population) and enumerated line by line (`review-round5-self.md`).

## Measurement

- **Detection by MAD.** Under 0.5 m³/s MAD, the relative rate of CH detection is 0.14–0.61, after effort, data
  set, era and WSG (15,626 visits, 978 CH, 67 WSGs). From 0.5 to 10 m³/s it is 1.40–2.40. Among fish-bearing
  visits it is 0.26–0.48 under 0.5 m³/s.
- **Small streams near large rivers.** For small streams with a ≥ 10 m³/s segment within 500 m downstream,
  14.5 % of visits caught CH, against 0.8 % further away: a rate ratio of 26.7 (bootstrap 15.0–58.3; 7,319
  visits, 34 WSGs).
- **Above 30 m³/s.** The classes are 66 % and 81 % regulated visits. One 2010 Nechako survey is 432 of the 978
  detections.
- **Source sensitivity.** wet's two sources put a visit in the same class 53–67 % of the time between 0.1 and
  1 m³/s. On the balance alone, 0.5–1 m³/s reads 0.54.
- **Runtime.** The path walk ran 12,932 starts in 0.4 min on 4 workers. The first design (summing
  `fwa_downstreamtrace` rows) ran about 5 min and was wrong.
- **Wrong turns kept.**
  - The first build dropped 444 visits for null codes. They were the same side channels B2 is about, with a
    `wscode` but a NULL `localcode`.
  - 1,302 walks first read `no_parent`. They were coastal streams reaching the sea.
  - Distance was first normalised like MAD, and the 11-detection `none` class broke the other classes' lower
    bounds.

## Evidence

`scripts/logs/habitat/20261015_ch_mad_*`. The 0295 bootstrap is byte-identical on 2 and 6 workers. The
restore-the-bug run moved the ledger: the blocked-absence drop went from 389 to 0 and the duplicates from 568
to 688.

Closed by: PR for branch `52-stream-size-where-chinook-are-caught-ch`
