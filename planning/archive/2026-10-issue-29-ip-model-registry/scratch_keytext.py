#!/usr/bin/env python3
"""keytext.py KEY [KEY...] -> pdftotext (raw and -layout) of each group-library key's PDFs into scratch txt/."""
import os, shutil, sqlite3, subprocess, sys, tempfile, time
Z = os.path.expanduser("~/Zotero/zotero.sqlite"); OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "txt")
def open_txn():
    j = Z + "-journal"
    return os.path.exists(j) and os.path.getsize(j) >= 8 and any(open(j, "rb").read(8))
def snap():
    for _ in range(6):
        st = os.stat(Z); d = tempfile.mktemp(suffix=".sqlite"); shutil.copy(Z, d); st2 = os.stat(Z)
        if (st.st_mtime, st.st_size) == (st2.st_mtime, st2.st_size) and not open_txn():
            c = sqlite3.connect(d)
            if c.execute("PRAGMA quick_check").fetchone()[0] == "ok": return c
        time.sleep(15)
    sys.exit("no consistent snapshot")
c = snap()
lib = c.execute("SELECT libraryID FROM groups WHERE groupID=4733734").fetchone()[0]
for key in sys.argv[1:]:
    rows = c.execute("""SELECT a.key, ia.path FROM items i
      JOIN itemData d ON d.itemID=i.itemID JOIN fields f ON f.fieldID=d.fieldID AND f.fieldName='citationKey'
      JOIN itemDataValues v ON v.valueID=d.valueID JOIN itemAttachments ia ON ia.parentItemID=i.itemID
      JOIN items a ON a.itemID=ia.itemID LEFT JOIN deletedItems x ON x.itemID=i.itemID LEFT JOIN deletedItems y ON y.itemID=a.itemID
      WHERE i.libraryID=? AND v.value=? AND x.itemID IS NULL AND y.itemID IS NULL AND ia.contentType='application/pdf' AND ia.path LIKE 'storage:%'""", (lib, key)).fetchall()
    if not rows: print(key, "NO PDF IN GROUP"); continue
    for n, (ak, p) in enumerate(rows):
        f = os.path.join(os.path.expanduser("~/Zotero/storage"), ak, p[len("storage:"):])
        for mode, suf in (([], ""), (["-layout"], ".layout")):
            o = os.path.join(OUT, f"{key}{'' if n == 0 else '_' + str(n)}{suf}.txt")
            subprocess.run(["pdftotext", *mode, f, o], stderr=subprocess.DEVNULL)
        print(key, ak, os.path.getsize(o), "bytes ->", o)
