qm <- c(0x22, 0x27, 0xAB, 0xBB, 0x2018:0x201F, 0x2039, 0x203A, 0x2E42, 0x300C:0x300F,
        0x301D:0x301F, 0xFE41:0xFE44, 0xFF02, 0xFF07, 0xFF62, 0xFF63)
pos <- sprintf("QM U+%04X: the text %sopening a passage here", qm, intToUtf8(qm, multiple = TRUE))
html <- c("HTML: &quot;passage&quot;", "HTML: &#8220;passage", "HTML: &#x201C;passage", "HTML: &bdquo;passage",
          "HTML: <q>passage</q>", "<blockquote>", "HTML: &rsquo;passage")
neg <- c("NEG: link's `default`'s rule, Ford et al.'s rows, *k*'s value, (Smith 2003)'s table.",
         "NEG: the streams' banks and bull trout's range; trout’s and streams’ banks; café's.",
         "NEG: Fraley & Shepard, and a ratio 3 < 4 > 2.")
q <- "\"Like many char, the bull trout occurs as a number of life-history forms.\" (mcphail_baxter1996reviewbull, p. ii)"
bqs <- c("", paste0("> ", q, " and prose after it."), "",
         paste0("> ", q), "a lazy line that renders inside the blockquote", "",
         "> an unquoted blockquote line", "",
         "\"Like many char, the `bull trout` occurs as a number of life-history forms.\" (mcphail_baxter1996reviewbull, p. ii)", "",
         paste0("> ", q), "", q)
writeLines(c("# enumeration fixture", "", pos, "", html, "", neg, bqs), commandArgs(TRUE)[1], useBytes = FALSE)
# round 3: what a regex model of Markdown hid from the guard (each line number is printed below)
r3 <- c("", "~~~", "```", "~~~", "",
        "R3 fence: \"Bull trout never spawn in gravel at all anywhere.\" (mcphail_baxter1996reviewbull, p. ii)", "",
        "````", "```", "````", "",
        "R3 four-backtick: \"Bull trout never spawn in gravel at all anywhere.\" (mcphail_baxter1996reviewbull, p. ii)", "",
        "    ```", "",
        "R3 indented: \"Bull trout never spawn in gravel at all anywhere.\" (mcphail_baxter1996reviewbull, p. ii)", "",
        "R3 escaped backtick \\` then “Bull trout never spawn in gravel” and more \\`.", "",
        "- > Bull trout never spawn in gravel at all anywhere.", "",
        "R3 upper <Q>Bull trout never spawn</Q>.", "",
        "<div>", "&laquoBull trout never spawn&raquo", "</div>", "",
        "\"Like many char, the bull trout [never][n] occurs as a number of life-history forms.\" (mcphail_baxter1996reviewbull, p. ii)", "",
        "[n]: https://example.org", "",
        "R3 double prime ″Bull trout never spawn in gravel″.")
cat(file = commandArgs(TRUE)[1], paste0(r3, "\n"), append = TRUE, sep = "")
