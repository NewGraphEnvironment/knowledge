"""Create the three references #89 cites in the NewGraphEnvironment group library (Web API).

Run: ZOTERO_API_KEY=... python3 -I zotero_create_89.py [--dry]; then rerun data-raw/vignette_bib.R with the
new keys cited in vignettes/chinook_rearing.Rmd. CROSSREF_MAILTO, if set, joins CrossRef's polite pool.
"""
import json, os, sys, urllib.request

key = os.environ.get("ZOTERO_API_KEY", "")
if not key:
    sys.exit("ZOTERO_API_KEY unset or empty")
UA = "knowledge-89" + (" (mailto:" + os.environ["CROSSREF_MAILTO"] + ")" if os.environ.get("CROSSREF_MAILTO") else "")

def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)

cr = get("https://api.crossref.org/works/10.1016/j.envsoft.2020.104728")["message"]
raven = {
    "itemType": "journalArticle",
    "title": cr["title"][0],
    "creators": [{"creatorType": "author", "firstName": a.get("given", ""), "lastName": a["family"]} for a in cr["author"]],
    "publicationTitle": "Environmental Modelling & Software",
    "volume": cr.get("volume", ""),
    "pages": cr.get("article-number", cr.get("page", "")),
    "date": "-".join(str(x) for x in cr["published"]["date-parts"][0]),
    "DOI": cr["DOI"],
    "ISSN": (cr.get("ISSN") or [""])[0],
    "url": "https://doi.org/" + cr["DOI"],
    "abstractNote": "",
}
vicgl = {
    "itemType": "report",
    "title": "VIC-Glacier (VIC-GL): Description of VIC model changes and upgrades",
    "creators": [{"creatorType": "author", "firstName": "Markus A.", "lastName": "Schnorbus"}],
    "seriesTitle": "VIC Generation 2 Deployment Report",
    "reportNumber": "Volume 1",
    "institution": "Pacific Climate Impacts Consortium, University of Victoria",
    "place": "Victoria, BC",
    "date": "2018-02-01",
    "url": "https://hdl.handle.net/1828/21631",
}
fork = {
    "itemType": "computerProgram",
    "title": "NewGraphEnvironment/fwapg",
    "creators": [{"creatorType": "programmer", "firstName": "Simon", "lastName": "Norris"},
                 {"creatorType": "programmer", "firstName": "Allan", "lastName": "Irvine"}],
    "date": "2026",
    "url": "https://github.com/NewGraphEnvironment/fwapg/tree/newgraph",
    "company": "New Graph Environment Ltd.",
    "programmingLanguage": "PLpgSQL",
    "rights": "MIT",
    "collections": ["U6YAVQ3G"],
}
items = [raven, vicgl, fork]
if "--dry" in sys.argv:
    print(json.dumps(items, indent=1)); sys.exit(0)
req = urllib.request.Request("https://api.zotero.org/groups/4733734/items", data=json.dumps(items).encode(),
                             headers={"Zotero-API-Key": key, "Content-Type": "application/json", "Zotero-API-Version": "3"},
                             method="POST")
with urllib.request.urlopen(req, timeout=60) as r:
    out = json.load(r)
print("successful:", {k: v["key"] for k, v in out.get("successful", {}).items()})
print("failed:", out.get("failed"))
