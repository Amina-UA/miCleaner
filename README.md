This package is designed to identify and remove estimated months in the length–frequency distributions produced by SIRENO, organised by month and gear. In SIRENO's internal workflow, months with no observed length–frequency data are automatically estimated from adjacent months. While these estimated distributions are useful for reporting, they are not appropriate for applications that require raw, unaltered observations, such as growth modelling or stock synthesis analyses. The purpose of this package is to support scientists who generate length–frequency reports from SIRENO by providing tools to separate the original observed distributions from the estimated ones. For every input file, the package produces both the original report (including estimated months) and a cleaned version containing only real, non‑estimated length–frequency data. This ensures that downstream analyses can be performed using minimally processed, observation‑based information. In addition, the package automatically generates log files that document which months were removed from each report and from which specific files they were eliminated. A master log is also created when processing   entire folders, providing a clear audit trail of all removed estimated months across all processed datasets.
## Installation

You can install **miCleaner** directly from GitHub using the `remotes` package:

```r
# install.packages("remotes")   # if not already installed
remotes::install_github("Amina-UA/miCleaner")
If you have a local source package (e.g., miCleaner_0.1.0.tar.gz), you can install it with:
install.packages("miCleaner_0.1.0.tar.gz", repos = NULL, type = "source")
This will install the package and make all functions available.
```
🔹 Load the package
```r
library(miCleaner)
```
