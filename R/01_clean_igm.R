# =====================================================================
# 01_clean_igm.R
# Reshape the raw Kent A. Clark Center (US/Euro EEP) survey CSVs into a
# single long-format table: one row per economist per sub-question.
#
# WHY long format: every downstream measure (consensus strength, mean
# confidence, net agreement) is a within-question aggregate over
# economists. Long format is the only shape that lets us group_by the
# question and summarise cleanly, and it mirrors the structure the
# public-opinion microdata will arrive in, so the eventual join is trivial.
# =====================================================================

library(tidyverse)
library(janitor)

raw_dir <- "data/raw/igm"          # adjust to your path
out_dir  <- "data/processed"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---------------------------------------------------------------------
# Filename -> metadata. WHY parse from the filename: the Clark Center
# encodes date, panel, and topic in a stable "YYYY-MM-DD-PANEL-EEP-Topic"
# convention, so we derive identifiers deterministically rather than
# hand-coding them (reproducible, and new surveys slot in automatically).
# ---------------------------------------------------------------------
parse_meta <- function(path) {
  fn <- basename(path)
  date  <- str_extract(fn, "^\\d{4}-\\d{2}-\\d{2}")
  panel <- if (str_detect(fn, "Euro-EEP")) "Euro" else "US"
  slug  <- fn |>
    str_remove("^\\d{4}-\\d{2}-\\d{2}-") |>
    str_remove("(US|Euro)-EEP-") |>
    str_remove("(__\\d+_)?\\.csv$") |>
    str_replace_all("-", "_") |>
    str_to_lower()
  tibble(survey_date = date, panel = panel, slug = slug)
}

# ---------------------------------------------------------------------
# Reshape one wide survey file into long rows.
# WHY positional parsing: after the two name columns the file repeats a
# fixed triple — response, confidence, explanation — once per sub-question.
# We walk those triples, tagging each with a sub-question letter (A, B, C)
# so multi-part surveys (ACA has 3) are disaggregated correctly.
# ---------------------------------------------------------------------
clean_one <- function(path) {
  meta <- parse_meta(path)

  # Read everything as character first; confidence is coerced later so a
  # stray non-numeric entry never silently drops a whole column.
  raw <- read_csv(path, col_types = cols(.default = "c"),
                  name_repair = "minimal")

  # Drop fully-empty trailing columns (the Brexit export has a dozen).
  raw <- raw[, colSums(!is.na(raw)) > 0]

  hdr <- names(raw)
  # Response columns are the ones that are neither the name fields nor a
  # confidence/explanation field. Their header text IS the question wording.
  is_conf    <- str_detect(hdr, regex("confidence", ignore_case = TRUE))
  is_explain <- str_detect(hdr, regex("explain",    ignore_case = TRUE))
  is_name    <- hdr %in% c("Last Name", "First Name")
  resp_idx   <- which(!is_conf & !is_explain & !is_name)

  # For each response column, grab the confidence column immediately to its
  # right (the survey's fixed layout guarantees this adjacency).
  letters_seq <- LETTERS[seq_along(resp_idx)]

  map2_dfr(resp_idx, letters_seq, function(ci, subq) {
    q_text <- hdr[ci]
    conf   <- if (ci + 1 <= ncol(raw) && is_conf[ci + 1]) raw[[ci + 1]] else NA
    expl   <- if (ci + 2 <= ncol(raw) && is_explain[ci + 2]) raw[[ci + 2]] else NA

    tibble(
      survey_date   = meta$survey_date,
      panel         = meta$panel,
      slug          = meta$slug,
      subquestion   = subq,
      question_id   = str_replace_all(meta$survey_date, "-", "_") |>
                        paste0("_", meta$slug, "_", subq),
      economist_last  = raw[["Last Name"]],
      economist_first = raw[["First Name"]],
      question_text = q_text,
      response      = raw[[ci]],
      confidence    = suppressWarnings(as.numeric(conf)),
      explanation   = expl
    )
  })
}

# ---------------------------------------------------------------------
# Build the corpus. WHY de-duplicate on the full path stem: the AI survey
# was uploaded twice (`...__1_.csv`); keying on the date+slug+panel signature
# removes the exact-duplicate file without risking dropping a real survey.
# ---------------------------------------------------------------------
files <- list.files(raw_dir, pattern = "EEP.*\\.csv$", full.names = TRUE)

igm_long <- files |>
  map_dfr(clean_one) |>
  # economist_id: lowercase first_last, used as the panel-member key.
  mutate(
    economist_id = str_glue("{tolower(economist_first)}_{tolower(economist_last)}") |>
      str_replace_all("[^a-z_]", ""),
    # Signed response. WHY this mapping: it preserves the 5-point Likert
    # intensity (Strongly Agree = 2) so consensus strength reflects how
    # hard the panel leans, not just direction. Non-responses become NA so
    # they are excluded from direction but can be counted separately.
    signed = recode(response,
      "Strongly Agree"    =  2,
      "Agree"             =  1,
      "Uncertain"         =  0,
      "Disagree"          = -1,
      "Strongly Disagree" = -2,
      "No Opinion"        = NA_real_,
      "Did Not Answer"    = NA_real_,
      .default            = NA_real_)
  ) |>
  distinct(question_id, economist_id, .keep_all = TRUE) |>  # kills the dup file
  relocate(economist_id, .after = economist_first)

write_csv(igm_long, file.path(out_dir, "igm_long.csv"))

# Quick integrity report (printed, not silent).
igm_long |>
  group_by(panel, slug) |>
  summarise(n_subq = n_distinct(subquestion),
            n_rows = n(),
            .groups = "drop") |>
  print(n = Inf)
