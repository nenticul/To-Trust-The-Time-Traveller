# =====================================================================
# 18_cdf_replication.R — OUT-OF-SAMPLE replication of the mechanism.
# The headline knowledge x party interaction (R/10-11) lives in one survey
# (ANES 2024) and one sophistication measure (the 4-item behavioral battery).
# The ANES Time Series Cumulative File carries the SAME immigration "take jobs"
# fact (VCF9223; harmonized across 2004/2008/2012/2016/2020/2024) and a
# DIFFERENT sophistication measure -- the interviewer's rating of the
# respondent's general level of political information (VCF0050a) -- in earlier,
# fully in-person years. We re-estimate the party x sophistication interaction
# on the fact, out of sample in both the survey-year and the measure:
#   2004:  +0.05  (n.s.)  <- BEFORE immigration tribalized: no amplification,
#                            exactly the conditional-law prediction (P2/P3).
#   2008:  +0.39  ***      2012: +0.40 ***     2016: +0.52 ***
#   pooled 2008-2016 (year FE): +0.41, p ~ 1e-10.
# The 2024 result is thus not an artifact of one survey or one knowledge index;
# it reproduces with an observer-based measure in three independent prior years,
# and is absent in the pre-tribalization year as the model requires.
#
# Raw file: data/raw/anes/anes_timeseries_cdf_csv_20260205.csv (restricted).
# VCF0050a is an interviewer observation (in-person only), hence sparse in the
# largely-web 2020 wave, which we therefore omit.
# =====================================================================
library(tidyverse)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

cdf <- read_csv(file.path(raw, "anes/anes_timeseries_cdf_csv_20260205.csv"),
                show_col_types = FALSE) |>
  transmute(
    year = VCF0004,
    fact = case_when(VCF9223 %in% c(1, 2) ~ 1, VCF9223 %in% c(3, 4) ~ 0, TRUE ~ NA_real_),  # "likely to take jobs"
    rep  = case_when(VCF0301 %in% c(5, 6, 7) ~ 1, VCF0301 %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
    info = if_else(between(VCF0050a, 1, 5), 6 - VCF0050a, NA_real_),   # reverse so higher = more informed
    w    = if_else(VCF0009x > 0, VCF0009x, NA_real_)
  )

one_year <- function(yr) {
  d <- cdf |> filter(year == yr) |> drop_na(fact, rep, info, w) |>
    mutate(infoz = as.numeric(scale(info)))
  des <- svydesign(ids = ~1, weights = ~w, data = d)
  ct <- summary(svyglm(fact ~ rep * infoz, design = des, family = quasibinomial()))$coefficients["rep:infoz", ]
  tibble(year = as.character(yr), interaction_logodds = round(ct[["Estimate"]], 3),
         p_value = signif(ct[["Pr(>|t|)"]], 2), n = nrow(d))
}
rep_tbl <- map_dfr(c(2004, 2008, 2012, 2016), one_year)

pooled <- cdf |> filter(year %in% c(2008, 2012, 2016)) |> drop_na(fact, rep, info, w) |>
  mutate(infoz = as.numeric(scale(info)))
des_p <- svydesign(ids = ~1, weights = ~w, data = pooled)
ctp <- summary(svyglm(fact ~ rep * infoz + factor(year), design = des_p,
                      family = quasibinomial()))$coefficients["rep:infoz", ]
rep_tbl <- bind_rows(rep_tbl,
  tibble(year = "pooled 2008-2016 (yr FE)", interaction_logodds = round(ctp[["Estimate"]], 3),
         p_value = signif(ctp[["Pr(>|t|)"]], 2), n = nrow(pooled)))

write_csv(rep_tbl, file.path(proc, "anes_cdf_replication.csv"))
cat("\nOut-of-sample party x political-information interaction on the immigration fact:\n")
print(rep_tbl)
