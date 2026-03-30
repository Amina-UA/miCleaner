#' Procesar un archivo CSV individual (versión robusta)
#' @export
process_file <- function(input_file, cols_after = 12, keep_table = TRUE) {

  # 0. existencia del archivo
  if (!file.exists(input_file)) {
    stop("Input file not found: ", input_file)
  }

  # 1. detectar separador (proteger errores)
  sep <- tryCatch(detect_sep(input_file), error = function(e) {
    stop("No se pudo detectar separador en: ", input_file, " | ", conditionMessage(e))
  })

  # 2. leer archivo (fallbacks)
  df <- tryCatch({
    data.table::fread(input_file, sep = sep, encoding = "UTF-8", fill = TRUE, header = FALSE, data.table = FALSE)
  }, error = function(e) {
    tryCatch({
      read.table(input_file, sep = sep, header = FALSE, stringsAsFactors = FALSE, fill = TRUE, fileEncoding = "latin1")
    }, error = function(e2) {
      read.table(input_file, sep = sep, header = FALSE, stringsAsFactors = FALSE, fill = TRUE, fileEncoding = "UTF-8")
    })
  })
  df <- as.data.frame(df, stringsAsFactors = FALSE, check.names = FALSE)

  # 3. validar contenido mínimo
  if (nrow(df) == 0 || ncol(df) < 2) {
    stop("Archivo leído pero sin contenido útil (filas<1 o columnas<2): ", input_file)
  }

  # 4. normalizar todo a UTF-8
  df[] <- lapply(df, normalize_to_utf8)

  # 5. preparar primera columna normalizada para búsquedas
  first_col_norm <- toupper(stringr::str_trim(enc2utf8(as.character(df[[1]]))))

  # 6. localizar MUESTREO REALIZADOS:
  match_idx <- which(first_col_norm == "MUESTREO REALIZADOS:")
  if (length(match_idx) == 0) {
    return(list(file = basename(input_file), status = "no_label", message = "No se encontró 'MUESTREO REALIZADOS:'"))
  }
  row_idx <- match_idx[1]

  # 7. columnas a chequear (seguras)
  start_col <- 2L
  end_col   <- min(ncol(df), start_col + as.integer(cols_after) - 1L)
  cols_to_check <- seq.int(start_col, end_col)
  if (length(cols_to_check) == 0) {
    return(list(file = basename(input_file), status = "no_columns", message = "No hay columnas para chequear"))
  }

  # 8. limpiar y convertir a numérico
  vals_raw <- as.character(df[row_idx, cols_to_check])
  vals <- clean_num(vals_raw)
  cols_zero <- cols_to_check[!is.na(vals) & vals == 0]

  # 9. mapear meses desde TALLAS (primera columna)
  tallas_idx <- which(first_col_norm == "TALLAS")
  if (length(tallas_idx) == 0) {
    month_names <- rep(NA_character_, length(cols_to_check))
  } else {
    tallas_idx <- tallas_idx[1]
    month_names_raw <- as.character(df[tallas_idx, cols_to_check])
    month_names <- stringr::str_trim(enc2utf8(month_names_raw))
    empty_idx <- which(month_names == "" | is.na(month_names))
    if (length(empty_idx) > 0L) month_names[empty_idx] <- paste0("columna_", cols_to_check[empty_idx])
  }

  # 10. construir nombres de salida
  input_dir  <- dirname(input_file)
  input_base <- tools::file_path_sans_ext(basename(input_file))
  input_ext  <- tools::file_ext(basename(input_file))
  clean_file <- file.path(input_dir, paste0(input_base, "_clean", if (nzchar(input_ext)) paste0(".", input_ext) else ""))

  # --- 10.5 LOG FILE FOR ELIMINATED MONTHS -----------------------------------
  months <- if (length(cols_zero) > 0) month_names[match(cols_zero, cols_to_check)] else character(0)

  log_file <- file.path(input_dir, paste0(input_base, "_clean_months_with_zero.log"))
  log_entry <- paste(
    format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    "| File:", basename(input_file),
    "| Eliminated columns:", if (length(cols_zero)==0) "none" else paste(cols_zero, collapse=","),
    "| Months:", if (length(months)==0) "none" else paste(months, collapse=","),
    "\n"
  )
  cat(log_entry, file = log_file, append = TRUE)
  # ---------------------------------------------------------------------------

  # 11. guardar archivo limpio (con manejo de errores)
  tryCatch({
    if (length(cols_zero) == 0) {
      write.table(df, file = clean_file, sep = sep, row.names = FALSE, col.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")
    } else {
      df_clean <- df[, -cols_zero, drop = FALSE]
      write.table(df_clean, file = clean_file, sep = sep, row.names = FALSE, col.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")
    }
  }, error = function(e) {
    stop("Error escribiendo archivo limpio: ", conditionMessage(e))
  })

  # 12. extraer y guardar subtabla TALLAS -> PESO INDIVIDUO:
  if (keep_table) {
    clean_table_file <- file.path(input_dir, paste0(input_base, "_clean_table", if (nzchar(input_ext)) paste0(".", input_ext) else ""))
    start_idx <- which(first_col_norm == "TALLAS")
    end_idx   <- which(first_col_norm == "PESO INDIVIDUO:")
    if (length(start_idx) && start_idx[1] > 0) {
      start_idx <- start_idx[1]
      if (length(end_idx) == 0) end_idx <- nrow(df) else end_idx <- end_idx[1]
      if (end_idx >= start_idx) {
        subtable <- df[start_idx:end_idx, , drop = FALSE]
        tryCatch({
          write.table(subtable, file = clean_table_file, sep = sep, row.names = FALSE, col.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")
        }, error = function(e) {
          warning("No se pudo escribir _clean_table: ", conditionMessage(e))
        })
      }
    }
  }

  # 13. preparar salida informativa
  info <- list(
    file = basename(input_file),
    status = "ok",
    cols_zero = cols_zero,
    months = months,
    clean_file = clean_file,
    n_rows = nrow(df),
    n_cols = ncol(df)
  )
  return(info)
}
