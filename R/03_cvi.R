# =====================================================================
# 03_cvi.R  — Claim Verifiability Index (verification check)
# Scores each studied claim 0-3 on four dimensions (sum 0-12). Used only
# to certify the studied claims are genuinely hard to verify (the premise
# of the paper); it is NOT a regressor. See Appendix A in the manuscript.
# =====================================================================
library(tidyverse)

proc <- "data/processed"

# lag: 0 <1yr 1 1-3yr 2 3-10yr 3 >10yr | cf: counterfactual dependence
# diff: attributional diffuseness     | pers: personal unobservability
cvi <- tribble(
  ~question_id,                               ~lag, ~cf, ~diff, ~pers,
  "2012_02_07_rent_control_A",                   3,   3,    3,    3,
  "2015_09_22_15_minimum_wage_A",                2,   3,    2,    3,
  "2015_09_22_15_minimum_wage_B",                2,   3,    3,    3,
  "2016_11_16_100_day_plan_A",                   3,   3,    3,    3,
  "2016_11_16_100_day_plan_B",                   3,   3,    3,    3,
  "2021_01_13_after_brexit_A",                   3,   3,    3,    3,
  "2021_01_13_after_brexit_B",                   3,   3,    3,    3,
  "2026_01_29_aca_subsidies_A",                  1,   2,    1,    1,
  "2026_01_29_aca_subsidies_B",                  2,   3,    3,    2,
  "2026_01_29_aca_subsidies_C",                  2,   1,    2,    3,
  "2026_05_13_ai_work_and_education_A",          3,   3,    3,    2,
  "2026_05_13_ai_work_and_education_B",          3,   3,    3,    2,
  "2026_05_13_ai_work_and_education_C",          3,   2,    3,    3,
  "2026_05_22_america_versus_europe_A",          1,   1,    1,    2,
  "2026_05_22_america_versus_europe_B",          1,   1,    1,    2,
  "2026_06_03_permanent_residency_rules_A",      1,   2,    1,    2,
  "2026_06_03_permanent_residency_rules_B",      2,   2,    2,    2
) |>
  mutate(CVI = lag + cf + diff + pers)

write_csv(cvi, file.path(proc, "cvi_scores.csv"))
message("CVI range: ", min(cvi$CVI), "-", max(cvi$CVI),
        " | mean ", round(mean(cvi$CVI), 1))

# ---------------------------------------------------------------------
# Intercoder reliability: a SECOND, independent application of the rubric
# to all 17 claims (coder 2). Krippendorff's alpha is reported in Appendix A.
# ---------------------------------------------------------------------
cvi2 <- tribble(
  ~question_id,                               ~lag, ~cf, ~diff, ~pers,
  "2012_02_07_rent_control_A",                   3,   3,    2,    3,
  "2015_09_22_15_minimum_wage_A",                2,   3,    3,    3,
  "2015_09_22_15_minimum_wage_B",                2,   3,    3,    3,
  "2016_11_16_100_day_plan_A",                   3,   3,    3,    3,
  "2016_11_16_100_day_plan_B",                   3,   3,    3,    3,
  "2021_01_13_after_brexit_A",                   3,   3,    3,    3,
  "2021_01_13_after_brexit_B",                   3,   3,    3,    3,
  "2026_01_29_aca_subsidies_A",                  1,   2,    2,    1,
  "2026_01_29_aca_subsidies_B",                  2,   3,    2,    2,
  "2026_01_29_aca_subsidies_C",                  2,   2,    2,    2,
  "2026_05_13_ai_work_and_education_A",          3,   3,    3,    2,
  "2026_05_13_ai_work_and_education_B",          3,   3,    3,    2,
  "2026_05_13_ai_work_and_education_C",          3,   3,    3,    2,
  "2026_05_22_america_versus_europe_A",          1,   1,    1,    2,
  "2026_05_22_america_versus_europe_B",          1,   1,    1,    2,
  "2026_06_03_permanent_residency_rules_A",      1,   2,    1,    2,
  "2026_06_03_permanent_residency_rules_B",      2,   2,    2,    2
) |> mutate(CVI = lag + cf + diff + pers)
write_csv(
  full_join(cvi  |> rename_with(~paste0("c1_", .x), -question_id),
            cvi2 |> rename_with(~paste0("c2_", .x), -question_id), by = "question_id"),
  file.path(proc, "cvi_two_coders.csv"))

if (requireNamespace("irr", quietly = TRUE)) {
  # alpha across the 17 x 4 = 68 ordinal dimension ratings (two coders)
  m <- rbind(c(t(as.matrix(cvi[, c("lag","cf","diff","pers")]))),
             c(t(as.matrix(cvi2[, c("lag","cf","diff","pers")]))))
  a_ord <- irr::kripp.alpha(m, method = "ordinal")$value
  a_tot <- irr::kripp.alpha(rbind(cvi$CVI, cvi2$CVI), method = "interval")$value
  message(sprintf("Krippendorff alpha: dimensions (ordinal) = %.3f; CVI totals (interval) = %.3f",
                  a_ord, a_tot))
} else message("install 'irr' to compute Krippendorff's alpha")
