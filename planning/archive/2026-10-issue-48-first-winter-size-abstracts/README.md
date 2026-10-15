## Outcome

#47's searchers rated seven works useful that had no open PDF. After a manual download pass only Zabel & Achord
2004 arrived, so Al chose (2026-10-15) to let a row quote a publisher's abstract where the paper cannot be had,
flagged and checkable. The package gained `quote_source = abstract` (no page, 20-character floor; the IP registry
refuses it), `0280` checks such a quote against the Zotero item's abstract and refuses it once the group holds a
PDF for the item, and `0270` keeps CrossRef's abstract and accepts `pdf = none`. Nine rows (data rows 1137-1145):
six from the abstracts of Holtby 1988, Meyer & Griffith 1997, Brakensiek & Hankin 2007 and Bradford et al. 2001;
two from Zabel & Achord 2004; Smith & Griffith 1994 through Quinn & Peterson 1996. The Chinook rows are
counter-evidence to an absolute size floor. Connolly & Petersen 2003 has neither PDF nor abstract and stays out.
`research/thermal_requirements.md` and the CLAUDE.md drafting conventions carry the result; #48 stays open for
the papers themselves.

Two things were found along the way: `0280`'s `resolve()` had put an NA in every key's file list (standalone
PDFs have no parent; `sort()` hid it) until the abstract check counted the list; and stripping CrossRef markup on
one side of a comparison broke title matching against group items stored with `<i>` tags.

## Measurement

- Temperature store 49 -> 52 documents, 11,024 -> 11,350 chunks.
- Gate: 1,145 rows, 0 failing; 6 `verified_abstract`; thermal 50/50.
- Meaning audit: 17 findings in round 1 (one refuted), 3 in round 2, 2 in round 3; rounds 2 and 3 each found
  errors inside the previous round's fixes, and the loop ended on a sentence-by-sentence enumeration.
- Code check: 4 findings in round 1 (3 fixed, 1 accepted), 1 in round 2, 2 in round 3 (one inside a round-1 fix);
  ended on round 3's enumeration of nine facts derived twice.

## Evidence

`scripts/logs/habitat/20261015_*`; audits `audit-round{1,2,3}.md`, reviews `review-round{1,2,3}.md` here.

Closed by: PR (see #48)
