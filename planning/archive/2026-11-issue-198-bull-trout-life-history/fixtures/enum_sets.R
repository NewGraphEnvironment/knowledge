# Enumeration of the character set, run from the repo root: is every member of each source set in research_marks?
src <- readLines("scripts/0280-literature-verify.R")
i <- grep("^RESEARCH_QM <- ", src); j <- grep("^research_stray <- local", src) - 1
k <- grep("^clean <- function", src); k2 <- k + which(src[(k + 1):length(src)] == "}")[1]
eval(parse(text = src[k:k2])); eval(parse(text = src[i:j]))
p01 <- setdiff(0x20:0x1FFFF, c(0xD800:0xDFFF, 0xFDD0:0xFDEF, 0xFFFE, 0xFFFF)); ch <- intToUtf8(p01, multiple = TRUE)
nm <- stringi::stri_trans_general(ch, "Any-Name")
sets <- list(Quotation_Mark = RESEARCH_QM,
             Pi_Pf = p01[stringi::stri_detect_regex(ch, "^[\\p{Pi}\\p{Pf}]$")],
             named_not_letter = p01[grepl(RESEARCH_QM_NAME, nm) & !stringi::stri_detect_regex(ch, "^[\\p{Lu}\\p{Ll}\\p{Lt}\\p{Lo}\\p{M}]$")],
             clean_quote = setdiff(0x20:0xFFFD, c(0xD800:0xDFFF, 0xFDD0:0xFDEF))[clean(intToUtf8(setdiff(0x20:0xFFFD, c(0xD800:0xDFFF, 0xFDD0:0xFDEF)), multiple = TRUE)) %in% c("'", "\"")])
for (n in names(sets)) cat(sprintf("%-17s %3d members, %d outside research_marks\n", n, length(sets[[n]]), length(setdiff(sets[[n]], research_marks))))
cat("research_marks:", length(research_marks), "\n")
