# =====================================================================
# 12_convergence.R — "a fact becomes a preference," done right; + a behavior test
#
# (1) CONVERGENCE. The Republican–Democrat gap on the FACT ("immigrants take
#     jobs", immjobs) converges on the gap of the matched PREFERENCE ("reduce
#     immigration", letin1a) over 2004–2024. The fact carried essentially no
#     partisan signal in 2004 (gap ~0, ~9% of the preference's gap) and by 2024
#     sorts nearly as hard as the preference (~72%). The claim is a LEVELS
#     convergence — the fact migrating into the partisan structure the
#     preference already had — not a claim that the fact partisanized faster
#     (on the log-odds scale the preference's slope is marginally steeper).
#
# (2) BEHAVIOR (against expressive responding). The fact predicts consequential
#     behavior — 2024 presidential vote and border-wall support — net of party
#     and political knowledge (ANES 2024). A belief that independently predicts
#     vote is hard to dismiss as pure survey cheerleading (suggestive, not
#     dispositive; the clean test is the deferred experiment, Appendix E).
# =====================================================================
library(tidyverse)
library(haven)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

# ---------------------------------------------------------------------
# (1) Fact-vs-preference partisan-gap convergence (GSS)
# ---------------------------------------------------------------------
gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  transmute(year, immjobs, letin1a,
            rep = case_when(partyid <= 2 ~ 0L, partyid >= 4 ~ 1L, TRUE ~ NA_integer_),
            w   = coalesce(wtssall, wtssps))

gap_series <- function(keep, y, label) {
  gss |>
    filter(!is.na(rep), !is.na({{ keep }})) |>
    mutate(yy = as.integer({{ y }})) |>
    group_by(year, rep) |>
    summarise(m = weighted.mean(yy, w), n = n(), .groups = "drop") |>
    pivot_wider(names_from = rep, values_from = c(m, n)) |>
    filter(n_0 > 50, n_1 > 50) |>
    transmute(year, series = label, gap = m_1 - m_0)
}
conv <- bind_rows(
  gap_series(immjobs, immjobs <= 2, "fact (immigrants take jobs)"),
  gap_series(letin1a, letin1a >= 4, "preference (reduce immigration)")
) |> arrange(series, year)
write_csv(conv, file.path(proc, "fact_pref_convergence.csv"))
print(conv)

# ---------------------------------------------------------------------
# (2) Does the fact predict behavior net of party + knowledge? (ANES 2024)
# ---------------------------------------------------------------------
anes <- read_csv(file.path(raw, "anes/anes_timeseries_2024_csv_20260519.csv"),
                 show_col_types = FALSE) |>
  transmute(
    fact  = case_when(V242228 %in% c(1, 2) ~ 1, V242228 %in% c(3, 4) ~ 0, TRUE ~ NA_real_),
    rep   = case_when(V241227x %in% c(5, 6, 7) ~ 1, V241227x %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
    know  = (V241612 == 6) + (V241613 == 1) + (V241614 == 2) + (V241615 == 1),
    trump = case_when(V242096x == 2 ~ 1, V242096x == 1 ~ 0, TRUE ~ NA_real_),  # vs Harris
    wall  = case_when(V241393 == 1 ~ 1, V241393 == 2 ~ 0, TRUE ~ NA_real_),    # favor vs oppose
    pid7  = if_else(between(V241227x, 1, 7), as.numeric(V241227x), NA_real_),  # 7-pt party ID
    ideo  = if_else(between(V241177, 1, 7), as.numeric(V241177), NA_real_),    # 7-pt lib-con
    wt    = if_else(V240107b > 0, V240107b, NA_real_), psu = V240107c)
anes$knz <- as.numeric(scale(anes$know))

beh <- map_dfr(list(c("trump", "Trump vote (vs Harris)"), c("wall", "Favor border wall")),
  function(x) {
    d <- anes |> filter(!is.na(.data[[x[1]]]), !is.na(fact), !is.na(rep), !is.na(knz), !is.na(wt))
    des <- svydesign(ids = ~psu, weights = ~wt, data = d)
    m <- svyglm(as.formula(paste(x[1], "~ fact + rep + knz")), design = des, family = quasibinomial())
    ct <- summary(m)$coefficients["fact", ]
    tibble(outcome = x[2], fact_OR = round(exp(ct[["Estimate"]]), 2),
           p_value = signif(ct[["Pr(>|t|)"]], 2), n = nrow(d))
  })
write_csv(beh, file.path(proc, "anes_behavior.csv"))
print(beh)

# ---------------------------------------------------------------------
# (3) Behavior net of PROGRESSIVELY RICHER identity controls (anti-expressive).
# The sharpest expressive-responding objection is that "net of 3-category party"
# leaves identity under-modeled. We re-estimate the fact -> Trump-vote odds ratio
# adding 7-point party ID, then 7-point ideology, then knowledge. The belief still
# predicts vote at OR ~ 6 net of the full battery -- hard to read as cheerleading.
# ---------------------------------------------------------------------
ladder <- list(
  list("Party (3-cat)",                      "trump ~ fact + rep"),
  list("+ 7-pt party ID",                    "trump ~ fact + pid7"),
  list("+ 7-pt ID + ideology",               "trump ~ fact + pid7 + ideo"),
  list("+ 7-pt ID + ideology + knowledge",   "trump ~ fact + pid7 + ideo + knz"))
# Common analytic sample (complete cases on every variable used in any rung) so the
# odds-ratio decline reflects added controls, not a shifting sample across rungs.
common <- anes |> drop_na(trump, fact, rep, pid7, ideo, knz, wt, psu)
des_c <- svydesign(ids = ~psu, weights = ~wt, data = common)
beh_ctrl <- map_dfr(ladder, function(x) {
  ct <- summary(svyglm(as.formula(x[[2]]), design = des_c, family = quasibinomial()))$coefficients["fact", ]
  tibble(control_set = x[[1]], fact_OR = round(exp(ct[["Estimate"]]), 2),
         p_value = signif(ct[["Pr(>|t|)"]], 2), n = nrow(common))
})
write_csv(beh_ctrl, file.path(proc, "anes_behavior_controls.csv"))
print(beh_ctrl)
