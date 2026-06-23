# =====================================================================
# setup.R — one-time environment setup with renv (run from repo root)
# =====================================================================
# Step 1: install renv if needed
if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")

# Step 2: if renv.lock already exists (you cloned a finished repo), restore it:
if (file.exists("renv.lock")) {
  renv::restore(prompt = FALSE)
  message("Environment restored from renv.lock.")
} else {
  # Step 3: first-time author setup — initialise, install deps, snapshot.
  renv::init(bare = TRUE)
  # Packages actually loaded by the pipeline (R/*.R) and the manuscript (paper/*.qmd).
  pkgs <- c("tidyverse", "janitor", "haven", "survey", "broom",
            "zoo", "scales", "knitr", "rmarkdown")
  renv::install(pkgs)
  renv::snapshot(prompt = FALSE)
  message("renv.lock created. Commit it so others can renv::restore().")
}
