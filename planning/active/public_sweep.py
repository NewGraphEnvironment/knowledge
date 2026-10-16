#!/usr/bin/env python3
"""Sweep for text that must not be public (#56).

Usage: python3 planning/active/public_sweep.py [tree|github|commits|all]

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
    "project_repo": r"\b[a-z]+_[a-z_]*\d{4}_(reporting|planning)\b|fish_passage_[a-z]+_\d{4}",
    "internal_ref": r"\bdb-newgraph\b|\bcomms/|\bpoisreport\b",
    "local_path": r"airvine|/Users/|claude-50\d|~/Projects|Projects/repo",
    "template_name": r"fish[-_]passage[-_]template[-_]reporting",
}
RX = {k: re.compile(v) for k, v in PATTERNS.items()}

# Left as they are (#56): planning/ (PWF and archives), run logs, git history (not
# swept), and the literature tables' cited quotes.
EXEMPT_PREFIX = ("planning/archive/", "planning/active/", "scripts/logs/")
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


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"
    hits = []
    if mode in ("tree", "all"):
        hits += tree()
    if mode in ("github", "all"):
        hits += github()
    if mode in ("commits", "all"):
        hits += commits()
    for k, where, text in sorted(hits):
        print(f"{k:16} {where}  {text}")
    counts = {}
    for k, _, _ in hits:
        counts[k] = counts.get(k, 0) + 1
    print("--", ", ".join(f"{k} {v}" for k, v in sorted(counts.items())) or "no hits")
    sys.exit(1 if hits else 0)


if __name__ == "__main__":
    main()
