#' Procesar carpeta completa
#' @param input_folder ruta a carpeta con CSV
#' @param parallel logical usar paralelización
#' @param workers número de workers (NULL detecta cores-1)
#' @export
process_folder <- function(input_folder, parallel = TRUE, workers = NULL) {

  # asegurar que la carpeta existe
  if (!dir.exists(input_folder)) {
    stop("Carpeta no encontrada: ", input_folder)
  }

  # obtener archivos CSV
  files <- list.files(input_folder, pattern = "\\.csv$", full.names = TRUE, ignore.case = TRUE)
  if (length(files) == 0) {
    stop("No se encontraron archivos .csv en la carpeta: ", input_folder)
  }

  # preparar master log
  master_log <- file.path(input_folder, "clean_months_master.log")
  cat("=== Master log iniciado:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "===\n",
      file = master_log, append = FALSE)

  # configurar workers
  if (is.null(workers)) workers <- max(1, parallel::detectCores(logical = FALSE) - 1)

  # función interna para procesar y registrar en master log
  process_and_log <- function(f) {
    res <- tryCatch(
      process_file(f),
      error = function(e) list(file = basename(f), status = "error", error = conditionMessage(e))
    )

    # escribir en master log
    log_line <- paste(
      format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      "| File:", res$file,
      "| Status:", res$status,
      "| Eliminated columns:", if (is.null(res$cols_zero) || length(res$cols_zero)==0) "none" else paste(res$cols_zero, collapse=","),
      "| Months:", if (is.null(res$months) || length(res$months)==0) "none" else paste(res$months, collapse=","),
      "\n"
    )
    cat(log_line, file = master_log, append = TRUE)

    return(res)
  }

  # ejecutar en paralelo o secuencial
  if (parallel) {
    future::plan(future::multisession, workers = workers)
    results <- future.apply::future_lapply(files, process_and_log, future.seed = TRUE)
    future::plan(future::sequential)
  } else {
    results <- lapply(files, process_and_log)
  }

  # devolver resultados
  return(results)
}
