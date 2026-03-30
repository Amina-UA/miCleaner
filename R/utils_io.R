#' @importFrom stringr fixed
#' Detectar separador
#' @noRd
detect_sep <- function(file, n = 5) {
  lines <- readLines(file, n = n, warn = FALSE)
  candidates <- c(";", ",", "\t", "|")
  scores <- sapply(candidates, function(sep) {
    mean(sapply(lines, function(l) stringr::str_count(l, stringr::fixed(sep))))
  })
  names(scores)[which.max(scores)]
}


#' Normalizar a UTF-8
#' @noRd
normalize_to_utf8 <- function(x) {
  x <- as.character(x)
  x <- enc2utf8(x)
  x <- iconv(x, from = "", to = "UTF-8", sub = "")
  x[is.na(x)] <- ""
  x
}

#' Limpiar número desde texto
#' @noRd
clean_num <- function(x) {
  x2 <- stringr::str_trim(as.character(x))
  x2[x2 == ""] <- NA
  x2 <- gsub("\\.", "", x2)
  x2 <- gsub(",", ".", x2)
  suppressWarnings(as.numeric(x2))
}
