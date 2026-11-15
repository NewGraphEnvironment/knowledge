# _pkgdown.yml writes the Articles menu out by hand, because its internal section (#204) has no navbar entry and
# pkgdown would otherwise add a "More articles..." link. A hand-written menu goes stale silently, so it is held to the
# sections: every article in a section with a navbar title is in the menu under that title, and nothing else is.

test_that("the hand-written Articles menu lists exactly the navbar sections' articles", {
  skip_if_not_installed("yaml")
  f <- testthat::test_path("..", "..", "_pkgdown.yml")
  skip_if_not(file.exists(f), "no _pkgdown.yml (installed package)")
  y <- yaml::read_yaml(f)
  menu <- y$navbar$components$articles$menu
  expect_false(is.null(menu))
  texts <- vapply(menu, function(m) m$text, "")
  hrefs <- vapply(menu, function(m) if (is.null(m$href)) NA_character_ else m$href, "")
  shown <- Filter(function(s) !is.null(s$navbar), y$articles)
  expect_gt(length(shown), 0)
  # the internal section is the only one left out of the menu
  expect_identical(vapply(Filter(function(s) is.null(s$navbar), y$articles), function(s) s$title, ""), "internal")
  expect_setequal(stats::na.omit(hrefs), paste0("articles/", unlist(lapply(shown, function(s) s$contents)), ".html"))
  for (s in shown) {
    at <- match(s$navbar, texts)
    expect_false(is.na(at), info = s$navbar)
    # the section's articles follow its heading, before the next separator
    nxt <- which(texts == "-------" & seq_along(texts) > at)
    end <- if (length(nxt)) min(nxt) - 1 else length(texts)
    expect_setequal(stats::na.omit(hrefs[at:end]), paste0("articles/", s$contents, ".html"))
  }
})
