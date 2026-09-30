# Draft issue for NewGraphEnvironment/cred (PUBLIC: no client or project identifiers)

**Title:** `crd_zot_src_lookup()` can resolve a citation key to the wrong library's attachment, a trashed one, or none

**If we do it:** a store built by citation key contains the PDF of the item that was asked for. **If we never do:**
on a machine with more than one Zotero library, a key-built store can silently drop an item or ingest a
different paper's PDF, and nothing in the build output says so.

## Problem

`crd_zot_src_lookup()` (and so `crd_store_build(citation_keys = )`) resolves each key across **every** library in
`zotero.sqlite`. It takes the attachment with the highest `itemID` for that key:

```sql
ORDER BY idv.value, ia.itemID DESC   -- then raw[!duplicated(raw$citation_key), ]
```

This fails in three ways, all silently:

1. **No library scope.** Better BibTeX citation keys are unique within a library, not across libraries. The same
   key can name different works in a personal library and a group library (measured on one machine: 12 of 327
   keys shared across libraries have different titles). The build can ingest the other library's paper.
2. **Trash is not excluded.** Neither the parent item nor the attachment is checked against `deletedItems`, so
   a trashed attachment can win over a live one.
3. **Dedup runs before the existence check.** When the chosen attachment's file is not on disk (a linked file
   on another machine, a group attachment not yet downloaded), the key is dropped with a warning. Another copy
   of the same key's PDF on disk is never tried.

## Proposed Solution

- Add a `library` argument (a group id, or "user"), and resolve keys within it. When it is left out, error on
  a key that resolves in more than one library, rather than picking one.
- Exclude `deletedItems` for both the item and the attachment.
- Filter to files that exist **before** deduplicating.
- Report dropped keys in the returned object, not only as a warning.

Minimal repro: a key present in two libraries, where the newer attachment is a linked file that does not exist
locally. The older, existing file is never used and the key is dropped.

Also: the lookup opens the live `zotero.sqlite` with `immutable=1`. Zotero keeps the file in exclusive locking
mode and writes to it during every sync, so an immutable read taken mid-sync can raise "database disk image is
malformed", or see a half-applied transaction. A copy checked for unchanged mtime and size, with no open journal,
is consistent.

---

# Second draft issue for NewGraphEnvironment/cred (PUBLIC)

**Title:** `crd_search()` fails on every store with ragnar 0.3.0: `cosine_distance` is a list column

**If we do it:** `crd_search()` (and so every script that queries a store) works again. **If we never do:** no
store can be queried through cred. Callers fall back to calling `ragnar::ragnar_retrieve()` directly and lose
cred's scoring.

## Problem

With cred 0.3.0 and ragnar 0.3.0, `crd_search(store, "any query")` stops with:

```
Error: 'list' object cannot be coerced to type 'double'
Calls: crd_search -> .crd_retrieval_score
```

`ragnar_retrieve()` now returns `cosine_distance` as a **list** column (one value per merged chunk).
`.crd_retrieval_score()` calls `as.numeric(res[[m]])` on it inside `suppressWarnings()`, which errors on a list.
It fails on stores built long before this (reproduced on two stores), so the cause is the ragnar version, not
the store.

## Proposed Solution

Reduce a list-valued metric per row, e.g. `vapply(v, function(x) min(unlist(x)), numeric(1))`, keeping the
best (smallest) distance of the merged chunks. Add a test with a list-column fixture.
