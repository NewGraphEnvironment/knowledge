#!/usr/bin/env python3
"""Sweep for text that must not be public (#56).

Usage: python3 planning/active/public_sweep.py [tree|github|commits|all|history]
(history is separate: earlier revisions that need deleting in the web UI)

Tree: every tracked file except the exemptions. GitHub: issue and PR bodies,
issue/PR conversation comments and PR review comments. Prints one line per
hit and a count per pattern; exits 1 when anything is found.
"""
import json
import re
import subprocess
import sys

REPO = "NewGraphEnvironment/knowledge"

PRIVATE_REPOS = ("fish_passage_template_reporting|rtj|soul|logic|rfp|compost|kdot|sred|crate|"
                 "cyclops|rolex|compass")
PATTERNS = {
    "db": r"(?<![\d.])63333(?!\d)|host\s*=\s*\"localhost\"|user\s*=\s*\"(newgraph|postgres)\"|password\s*=\s*\"|"
          r":5432\b|port\s*=\s*5432|PG_[A-Z_]*SHARE|\bnewgraph DB\b",
    "key_path": r"\.config/newgraph|zotero-api-key",
    "password_manager": r"1Password|op://|\bop read\b",
    "host": r"\b(m1|M1|m4|M4|cypher|openclaw)\b|tailnet|Tailscale|Dropbox|OneDrive",
    "private_repo": rf"NewGraphEnvironment/({PRIVATE_REPOS})\b|\b(template|{PRIVATE_REPOS})#\d+",
    # Repo-shaped names, and the client/project slug class <client>_<region>_<year> (or hyphenated).
    "project_repo": r"\b[a-z]+_[a-z_]*\d{4}_(reporting|planning)\b|fish_passage_[a-z]+_\d{4}|\b(?!et[-_]al[-_])[a-z]+[-_][a-z]+[-_]20\d{2}\b",
    "internal_ref": r"\bdb-newgraph\b|\bcomms/|\bpoisreport\b",
    "local_path": r"airvine|/Users/|claude-50\d|~/Projects|Projects/repo",
    "template_name": r"fish[-_]passage[-_]template[-_]reporting",
}
RX = {k: re.compile(v) for k, v in PATTERNS.items()}

# Left as they are (#56): planning/ (PWF and archives), run logs, git history (not
# swept), and the literature tables' cited quotes.
EXEMPT_PREFIX = ("planning/archive/", "scripts/logs/")
# planning/active/ is the PWF in flight, which discusses the removed text by necessity; it is
# held only to the client/project and local-path classes, which no planning file may carry.
PARTIAL = {"planning/active/": ("project_repo", "local_path")}
EXEMPT_FILE = {"data/literature_evidence.csv"}
# Per-pattern exemptions for measured false positives: site labels such as M1 in
# data tables, and the model objects m1..m3 in 0297.
EXEMPT_PATTERN = {"host": lambda f: f.endswith(".csv") or f == "scripts/0297-ch-rule-tune.R"}
# Generated convention text below the marker is synced from soul, not edited here.
CLAUDE_MARKER = "# Agent Operating Rules"


def tree():
    files = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True).stdout.split("\n")
    hits = []
    for f in filter(None, files):
        if f.startswith(EXEMPT_PREFIX) or f in EXEMPT_FILE:
            continue
        try:
            raw = open(f, "rb").read()
        except (IsADirectoryError, FileNotFoundError):
            continue
        # A binary file (gpkg, png) is scanned as bytes, not skipped: a gpkg carries free-text
        # notes, and skipping it would report "no hits" over text never read.
        # Only its printable runs of 8 or more characters, as `strings` reads it: compressed bytes
        # match short patterns such as m1 by chance.
        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            text = "\n".join(m.group(0).decode("ascii") for m in re.finditer(rb"[\x20-\x7e\t]{8,}", raw))
        if f == "CLAUDE.md" and CLAUDE_MARKER in text:
            text = text.split(CLAUDE_MARKER, 1)[0]
        for n, line in enumerate(text.split("\n"), 1):
            for k, rx in RX.items():
                if k in EXEMPT_PATTERN and EXEMPT_PATTERN[k](f):
                    continue
                if any(f.startswith(pre) and k not in keep for pre, keep in PARTIAL.items()):
                    continue
                if f == "planning/active/public_sweep.py":
                    continue
                if rx.search(line):
                    hits.append((k, f"{f}:{n}", line.strip()[:160]))
    return hits


def gh(args):
    out = subprocess.run(["gh", "api", "--paginate", *args], capture_output=True, text=True)
    if out.returncode != 0:
        sys.exit(f"gh api {' '.join(args)} failed: {out.stdout or out.stderr}")
    # --paginate concatenates JSON arrays; split them apart.
    items, dec, s = [], json.JSONDecoder(), out.stdout.strip()
    i = 0
    while i < len(s):
        obj, j = dec.raw_decode(s, i)
        items.extend(obj)
        i = j
        while i < len(s) and s[i].isspace():
            i += 1
    return items


def github():
    hits = []
    sources = [
        (gh([f"repos/{REPO}/issues?state=all&per_page=100"]), "body"),
        (gh([f"repos/{REPO}/issues/comments?per_page=100"]), "body"),
        (gh([f"repos/{REPO}/pulls/comments?per_page=100"]), "body"),
    ]
    for pr in gh([f"repos/{REPO}/pulls?state=all&per_page=100"]):
        sources.append((gh([f"repos/{REPO}/pulls/{pr['number']}/reviews?per_page=100"]), "body"))
    # A retitle leaves a "renamed" entry on the page showing the old title, and it cannot be
    # deleted; editing the title does not remove what the old one said.
    renames = []
    for it in sources[0][0]:
        for ev in gh([f"repos/{REPO}/issues/{it['number']}/timeline?per_page=100"]):
            if ev.get("event") == "renamed":
                renames.append({"html_url": it["html_url"] + " (rename)",
                                "body": ev["rename"]["from"] + "\n" + ev["rename"]["to"]})
    sources.append((renames, "body"))
    for items, field in sources:
        for it in items:
            body = it.get(field) or ""
            title = it.get("title") or ""
            for k, rx in RX.items():
                for text, where in ((title, "title"), (body, "body")):
                    m = rx.search(text)
                    # The R&D tracking cross-reference in PR bodies is the one private pointer
                    # a public repo carries (feature-workflow.md); /gh-pr-push writes it.
                    if m and "/pull/" in it["html_url"] and m.group(0) == "NewGraphEnvironment/sred":
                        m = rx.search(text.replace("NewGraphEnvironment/sred", ""))
                    # issue 20 writes a formula with a term m1 (mean precipitation), not a host
                    if m and it["html_url"].endswith("/issues/20") and m.group(0) == "m1":
                        m = None
                    if m:
                        hits.append((k, f"{it['html_url']} ({where})", m.group(0)))
    return hits


# Measured hits accepted as they stand: commit messages are not rewritten.
ALLOW = {("commit 34f773c", "comms/")}  # "comms/ is removed"


def commits():
    """This branch's commit messages, which become public; earlier history is exempt."""
    out = subprocess.run(["git", "log", "--format=%h%x00%B%x01", "origin/main..HEAD"],
                         capture_output=True, text=True, check=True).stdout
    hits = []
    for rec in filter(None, (r.strip() for r in out.split("\x01"))):
        sha, msg = rec.split("\x00", 1)
        for k, rx in RX.items():
            m = rx.search(msg)
            if m and (f"commit {sha}", m.group(0)) not in ALLOW:
                hits.append((k, f"commit {sha}", m.group(0)))
    return hits


def history():
    """Every earlier revision of an issue or PR body, a comment, a PR review or a review comment
    (GraphQL userContentEdits). GitHub shows these to anyone who can read the item; only the web
    UI deletes them, so this mode lists what is still to delete rather than failing the default
    sweep. Each connection's totalCount is checked against its page, so a long thread stops the
    run instead of reading as clean."""
    E = "userContentEdits(first:100){totalCount nodes{editedAt diff}}"
    C = f"comments(first:50){{totalCount nodes{{url {E}}}}}"
    issues_q = ("query($o:String!,$r:String!,$c:String){repository(owner:$o,name:$r){"
                f"issues(first:20,after:$c){{pageInfo{{hasNextPage endCursor}} nodes{{url {E} {C}}}}}}}}}")
    R = f"reviews(first:20){{totalCount nodes{{url {E} comments(first:20){{totalCount nodes{{url {E}}}}}}}}}"
    prs_q = ("query($o:String!,$r:String!,$c:String){repository(owner:$o,name:$r){"
             f"pullRequests(first:10,after:$c){{pageInfo{{hasNextPage endCursor}} nodes{{url {E} {C} {R}}}}}}}}}")
    limits = {"comments": 50, "reviews": 20, "review comments": 20, "edits": 100}

    def full(conn, what, where):
        if conn["totalCount"] > limits[what]:
            sys.exit(f"history: {where} has {conn['totalCount']} {what}, more than one page reads")
        return conn["nodes"]

    hits = []
    owner, name = REPO.split("/")
    for query, key in ((issues_q, "issues"), (prs_q, "pullRequests")):
        cursor = None
        while True:
            args = ["graphql", "-f", f"query={query}", "-F", f"o={owner}", "-F", f"r={name}"]
            if cursor:
                args += ["-F", f"c={cursor}"]
            out = subprocess.run(["gh", "api", *args], capture_output=True, text=True)
            if out.returncode != 0:
                sys.exit(f"gh api graphql failed: {out.stdout or out.stderr}")
            page = json.loads(out.stdout)["data"]["repository"][key]
            for it in page["nodes"]:
                objs = [it] + full(it["comments"], "comments", it["url"])
                for rv in full(it["reviews"], "reviews", it["url"]) if "reviews" in it else []:
                    objs += [rv] + full(rv["comments"], "review comments", rv["url"])
                for obj in objs:
                    for ed in full(obj["userContentEdits"], "edits", obj["url"]):
                        for k, rx in RX.items():
                            m = rx.search(ed.get("diff") or "")
                            if m and not ("/pull/" in obj["url"] and m.group(0) == "NewGraphEnvironment/sred") \
                                    and not (obj["url"].endswith("/issues/20") and m.group(0) == "m1"):
                                hits.append((k, f"{obj['url']} (revision {ed['editedAt']})", m.group(0)))
            if not page["pageInfo"]["hasNextPage"]:
                break
            cursor = page["pageInfo"]["endCursor"]
    return hits


def generated():
    """CLAUDE.md below its marker: synced from soul, public in the repo though not on the site.
    Reported, not failed: a fix belongs at the source, in soul, not here."""
    text = open("CLAUDE.md", encoding="utf-8").read()
    if CLAUDE_MARKER not in text:
        return {}
    text = text.split(CLAUDE_MARKER, 1)[1]
    return {k: len(rx.findall(text)) for k, rx in RX.items() if rx.search(text)}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"
    hits = []
    if mode in ("tree", "all"):
        hits += tree()
    if mode in ("github", "all"):
        hits += github()
    if mode in ("commits", "all"):
        hits += commits()
    if mode == "history":
        hits += history()
    if mode in ("tree", "all"):
        g = generated()
        print("generated CLAUDE.md conventions (not failed; fix in soul):",
              ", ".join(f"{k} {v}" for k, v in sorted(g.items())) or "no hits")
    for k, where, text in sorted(hits):
        print(f"{k:16} {where}  {text}")
    counts = {}
    for k, _, _ in hits:
        counts[k] = counts.get(k, 0) + 1
    print("--", ", ".join(f"{k} {v}" for k, v in sorted(counts.items())) or "no hits")
    sys.exit(1 if hits else 0)


if __name__ == "__main__":
    main()
