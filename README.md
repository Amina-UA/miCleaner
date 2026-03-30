# miCleaner 📦 

miCleaner is an R package designed to identify and remove estimated months in the length–frequency distributions produced by SIRENO, organised by month and gear. In SIRENO's internal workflow, months with no observed length–frequency data are automatically estimated from adjacent months. While these estimated distributions are useful for reporting, they are not appropriate for applications that require raw, unaltered observations, such as growth modelling or stock synthesis analyses. The purpose of this package is to support scientists who generate length–frequency reports from SIRENO by providing tools to separate the original observed distributions from the estimated ones. For every input file, the package produces both the original report (including estimated months) and a cleaned version containing only real, non‑estimated length–frequency data. This ensures that downstream analyses can be performed using minimally processed, observation‑based information. In addition, the package automatically generates log files that document which months were removed from each report and from which specific files they were eliminated. A master log is also created when processing   entire folders, providing a clear audit trail of all removed estimated months across all processed datasets.

 ## Installation📥

You can install **miCleaner** directly from GitHub using the `remotes` package:

```r
# install.packages("remotes")   # if not already installed
remotes::install_github("Amina-UA/miCleaner")
```

If you have a local source package (e.g., miCleaner_0.1.0.tar.gz), you can install it with:

```r
install.packages("miCleaner_0.1.0.tar.gz", repos = NULL, type = "source")
This will install the package and make all functions available.
```
🔹 Load the package
```r
library(miCleaner)
```
## Usage🚀

The miCleaner package provides tools to identify and remove estimated months from length–frequency distributions produced by SIRENO.
You can process individual files or entire folders, with optional parallel execution.

🔹 Process a single file:

Use process_file() when you want to clean one specific CSV file:
```r
library(miCleaner)
result <- process_file("path/to/your/file.csv")
```
🔹 Process an entire folder:

Use process_folder() to clean all CSV files inside a directory:
```r
library(miCleaner)
res <- process_folder("path/to/folder")
```
🔹 Output structure:

After processing, you will find:
*cleaned CSV files (with estimated months removed)
*original files untouched
*per‑file logs
*a master log (when processing folders)

## Workflow Diagram🧭
```r

          ┌────────────────────┐
          │  Raw SIRENO CSVs   │
          └─────────┬──────────┘
                    │
                    ▼
          ┌────────────────────┐
          │  process_file()    │
          │  or                │
          │  process_folder()  │
          └─────────┬──────────┘
                    │
        ┌───────────┼────────────────┐
        ▼                           ▼
┌──────────────────┐       ┌──────────────────┐
│ Cleaned CSV       │       │ Log file         │
│ (no est. months)  │       │ (removed months) │
└──────────────────┘       └──────────────────┘
                    │
                    ▼
          ┌────────────────────┐
          │  Master log (opt.) │
          └────────────────────┘

```

 ## Example📚

```r
library(miCleaner)

# Process a folder with 3 workers
res <- process_folder(
  "2.4_clean_estimated_months",
  parallel = TRUE,
  workers = 3
)

# Process a single file
file_result <- process_file("2.4_clean_estimated_months/HKE_OTB_DWS_2019.CSV")
```
## License📄

This package is released under the CSIC-IEO License.

## Citation 🙌

If you use miCleaner in a report or publication, please cite:
```r
TIFOURA, A. (2026). miCleaner: Tools for cleaning estimated months in SIRENO outputs. GitHub: https://github.com/Amina-UA/miCleaner
```

