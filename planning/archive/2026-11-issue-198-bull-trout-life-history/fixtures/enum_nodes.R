# Enumeration of renderer nodes: every node name cmark-gfm emits (GitHub's extensions, footnotes on) for a
# document using every construct, with how research_parse() handles it.
md <- paste(c("# ATX heading", "Setext heading", "===", "", "Para *emph* **strong** ~~strike~~ `code` <span>x</span>",
  "[link](u) ![img](i.png) <https://auto.link> www.example.org hard  ", "break\\", "soft", "line[^1]", "",
  "> quote", ">", "> - list in quote", "", "- [ ] task", "- [x] done", "1. ordered", "", "```r", "code", "```",
  "", "    indented", "", "<div>", "html block", "</div>", "", "***", "", "| a | b |", "|---|---|", "| c | d |", "",
  "[^1]: Footnote.", "", "[ref]: http://example.org \"title\"", "", "> [!NOTE]", "> An alert."), collapse = "\n")
doc <- xml2::read_xml(commonmark::markdown_xml(md, extensions = TRUE, sourcepos = TRUE, footnotes = TRUE))
xml2::xml_ns_strip(doc)
nodes <- sort(unique(xml2::xml_name(xml2::xml_find_all(doc, "//*"))))
handled <- c(
  document = "container", heading = "leaf block: read", paragraph = "leaf block: read", table_cell = "leaf block: read",
  block_quote = "container: text outside a passage, or a non-paragraph block, fails", list = "container", item = "container", tasklist = "container (task-list item: its paragraphs are read)",
  table = "container (in a block quote: fails)", table_header = "container", table_row = "container",
  fn = "container (footnote: its paragraphs are read)", code_block = "code: not a quotation (in a block quote: fails)",
  html_block = "HTML: fails if it holds a quote form", thematic_break = "no text (in a block quote: fails)",
  text = "inline: read", softbreak = "inline: line break", linebreak = "inline: line break", code = "inline: code_in_quote",
  html_inline = "inline: html_in_quote, and fails if it holds a quote form", emph = "inline: emphasis_in_quote",
  strong = "inline: emphasis_in_quote", strikethrough = "inline: emphasis_in_quote", link = "inline: link_in_quote",
  image = "inline: link_in_quote", fnref = "inline: link_in_quote")
for (n in nodes) cat(sprintf("%-15s %s\n", n, if (n %in% names(handled)) handled[[n]] else "NOT HANDLED: inline fallback reads it as HTML"))
cat(sum(!nodes %in% names(handled)), "of", length(nodes), "node names not named above\n")
