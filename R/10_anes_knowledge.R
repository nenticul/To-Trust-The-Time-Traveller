# =====================================================================
# 10_anes_knowledge.R — clean confirmatory test of identity-protective
# cognition in a SECOND survey (ANES 2024), with a behavioural measure of
# sophistication (a 4-item political-knowledge battery, not just education).
#
# This addresses the inference caveat in 09_mechanism.R: the GSS education
# pattern is suggestive but imprecisely estimated across few survey-years.
# ANES 2024 supplies a within-survey test with many PSUs, so the design-based
# interaction is precisely estimated.
#
# DV  V242228: "How likely is it that recent immigration levels will take
#     jobs away from people already here?" -> fact = 1 if extremely/very likely.
# Knowledge battery (each scored correct = 1):
#   V241612 PREKNOW_SENTERM  correct = 6 (years in a US Senate term)
#   V241613 PREKNOW_LEASTSP  correct = 1 (foreign aid = least federal spending)
#   V241614 PREKNOW_HSEMEM   correct = 2 (Republicans held the pre-2024 House)
#   V241615 PREKNOW_SENMEM   correct = 1 (Democrats held the pre-2024 Senate)
#   know = sum, 0-4.
# Party V241227x (1-3 Democrat, 5-7 Republican; 4 independent -> NA).
# Post-election design: weight V240107b, PSU V240107c, strata V240107d.
# Prediction (Kahan 2012, 2013): the partisan gap on the FACT WIDENS with
# knowledge — the signature of identity-protective cognition, not ignorance.
# =====================================================================
library(tidyverse)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

anes <- read_csv(file.path(raw, "anes/anes_timeseries_2024_csv_20260519.csv"),
                 show_col_types = FALSE) |>
  transmute(
    fact   = case_when(V242228 %in% c(1, 2) ~ 1,
                       V242228 %in% c(3, 4) ~ 0, TRUE ~ NA_real_),
    rep    = case_when(V241227x %in% c(5, 6, 7) ~ 1,
                       V241227x %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
    know   = (V241612 == 6) + (V241613 == 1) + (V241614 == 2) + (V241615 == 1),
    wt     = V240107b, psu = V240107c, strata = V240107d
  ) |>
  filter(!is.na(fact), !is.na(rep), !is.na(wt), wt > 0)

anes$knz <- as.numeric(scale(anes$know))
anes <- anes |>
  mutate(klev = case_when(know <= 1 ~ "low (0-1)", know == 2 ~ "mid (2)", TRUE ~ "high (3-4)"))

# Descriptive: partisan gap on the fact, by knowledge level
gap_tab <- anes |>
  group_by(klev, rep) |>
  summarise(share = weighted.mean(fact, wt), n = n(), .groups = "drop") |>
  pivot_wider(names_from = rep, values_from = c(share, n)) |>
  transmute(knowledge = klev, dem_share = share_0, rep_share = share_1,
            gap = share_1 - share_0, n = n_0 + n_1) |>
  arrange(factor(knowledge, levels = c("low (0-1)", "mid (2)", "high (3-4)")))
write_csv(gap_tab, file.path(proc, "anes_gap_by_knowledge.csv"))
print(gap_tab)

# Design-based party x knowledge interaction
des <- svydesign(ids = ~psu, strata = ~strata, weights = ~wt, data = anes, nest = TRUE)
m   <- svyglm(fact ~ rep * knz, design = des, family = quasibinomial())
cat("\nparty x knowledge interaction (ANES 2024, design-based SEs):\n")
print(round(summary(m)$coefficients["rep:knz", , drop = FALSE], 4))
cat("Positive & significant => the partisan gap on the fact widens with knowledge\n",
    "= identity-protective cognition (Kahan), not an information deficit.\n")
