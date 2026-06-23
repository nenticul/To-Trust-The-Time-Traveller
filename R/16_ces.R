# =====================================================================
# 16_ces.R — the mechanism at scale (Cooperative Election Study).
# The asymmetric sophistication-amplification of §7 — education widening the
# partisan gap by pulling the out-group toward openness while the in-group
# barely moves — replicates on the matched immigration *preference* in the CES
# at n ~ 38,000 per survey, across two years and three differently worded
# restrictionist items. The captured fact (which came to sort like this
# preference) is governed by the same machinery, now confirmed beyond any
# small-sample doubt (interactions +0.38 to +0.80, all p < 1e-10).
#
# Place the CES Common Content files in data/raw/ces/ to reproduce:
#   CCES22_Common_OUTPUT_vv_topost.csv  and  CCES24_Common_OUTPUT_vv_topost_final.csv
# =====================================================================
library(tidyverse)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

ces_one <- function(file, item, year, label) {
  d <- read_csv(file.path(raw, "ces", file), show_col_types = FALSE) |>
    transmute(
      restrict = case_when(.data[[item]] == 1 ~ 1, .data[[item]] == 2 ~ 0, TRUE ~ NA_real_),  # support = restrictionist
      rep = case_when(pid3 == 2 ~ 1, pid3 == 1 ~ 0, TRUE ~ NA_real_),
      col = case_when(between(educ, 5, 6) ~ 1, between(educ, 1, 4) ~ 0, TRUE ~ NA_real_),
      w = if_else(commonweight > 0, commonweight, NA_real_)) |>
    drop_na(restrict, rep, col, w)
  des <- svydesign(ids = ~1, weights = ~w, data = d)
  ct  <- summary(svyglm(restrict ~ rep * col, design = des, family = quasibinomial()))$coefficients["rep:col", ]
  cell <- function(p, c) weighted.mean(filter(d, rep == p, col == c)$restrict, filter(d, rep == p, col == c)$w)
  tibble(year = year, item = label,
         dem_noncol = round(cell(0, 0), 3), dem_col = round(cell(0, 1), 3),
         rep_noncol = round(cell(1, 0), 3), rep_col = round(cell(1, 1), 3),
         gap_noncol = round(cell(1, 0) - cell(0, 0), 3), gap_col = round(cell(1, 1) - cell(0, 1), 3),
         interaction = round(ct[["Estimate"]], 3), p = signif(ct[["Pr(>|t|)"]], 2), n = nrow(d))
}
ces <- bind_rows(
  ces_one("CCES22_Common_OUTPUT_vv_topost.csv",       "CC22_331c", "2022", "reduce legal immigration 50%"),
  ces_one("CCES24_Common_OUTPUT_vv_topost_final.csv", "CC24_323c", "2024", "build a border wall"),
  ces_one("CCES24_Common_OUTPUT_vv_topost_final.csv", "CC24_323b", "2024", "increase border patrols")
)
write_csv(ces, file.path(proc, "ces_mechanism.csv"))
print(ces)

# Cognition vs exposure (the divergent-diets alternative): does party x education
# survive controlling for party x political ATTENTION (a proxy for differential
# exposure to party-congruent information)? It halves but stays significant -- so
# the amplification is not reducible to who consumes more of their own side's diet.
ca <- read_csv(file.path(raw, "ces", "CCES22_Common_OUTPUT_vv_topost.csv"), show_col_types = FALSE) |>
  transmute(y = case_when(CC22_331c == 1 ~ 1, CC22_331c == 2 ~ 0, TRUE ~ NA_real_),
            rep = case_when(pid3 == 2 ~ 1, pid3 == 1 ~ 0, TRUE ~ NA_real_),
            col = case_when(between(educ, 5, 6) ~ 1, between(educ, 1, 4) ~ 0, TRUE ~ NA_real_),
            att = if_else(between(newsint, 1, 4), (4 - newsint) / 3, NA_real_),  # 0 = hardly ever .. 1 = most of the time
            w = if_else(commonweight > 0, commonweight, NA_real_)) |>
  drop_na()
des_a <- svydesign(ids = ~1, weights = ~w, data = ca)
m0 <- svyglm(y ~ rep * col, design = des_a, family = quasibinomial())
m1 <- svyglm(y ~ rep * col + rep * att, design = des_a, family = quasibinomial())
cat(sprintf("\nCES party x educ: %+.3f (alone) -> %+.3f (net of party x attention), n = %d\n",
            coef(m0)[["rep:col"]], coef(m1)[["rep:col"]], nrow(ca)))
