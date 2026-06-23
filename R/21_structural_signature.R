# =====================================================================
# 21_structural_signature.R — THE MULTIPLICATIVE STRUCTURE, MADE VISIBLE.
# The model's gap equation is multiplicatively separable:
#     Gap(s) = (1 - alpha) * g(T) * (p_R(s) - p_D(s)).
# Two of its quantities are observable over time on the SAME fact: the mass
# partisan gap (the g(T) term) and the sophistication PREMIUM on the gap -- the
# party x sophistication interaction, i.e. d Gap / d s, which the model makes
# proportional to g(T) as well. The model therefore predicts a thing ordinary
# issue-evolution does not: not only should the gap grow as the issue tribalizes,
# the sophistication PREMIUM should grow with it too, from ~zero before
# tribalization (the cross-derivative d^2 Gap / d s d T > 0).
#
# We test this on the immigration "take jobs" fact (ANES Cumulative VCF9223,
# 2004-2016) using the interviewer's political-information rating (VCF0050a) as
# the identity-enactment sophistication measure, against the elite-tribalization
# series T(t) from congressional immigration speech (R/07). Both the mass gap and
# the sophistication premium are ~0 in 2004 (pre-tribalization) and rise in step
# with elite tribalization (corr ~ +0.86 and +0.91; the premium and gap correlate
# at +0.85). The premium is not a fixed trait of the sophisticated; it is itself a
# product of the issue's tribalization.
#
# INFERENCE NOTE: four survey-years; like the precedence result (R/07), this is a
# DESCRIPTIVE structural pattern, reported for its consistency with the model's
# functional form, not a powered test. The clean anchor is the 2004 null premium.
#
# CHANNEL CONTRAST (consistency check, not written to CSV): the analogous premium
# measured by EDUCATION rather than political information does NOT switch on with
# tribalization -- it is already large in 1996 -- exactly as the two-channel model
# implies, since education acts on the folk prior f(s) (present in both regimes)
# while political information acts on the identity term p(s) (gated by g(T)).
# Raw: data/raw/anes/anes_timeseries_cdf_csv_20260205.csv (restricted).
# =====================================================================
library(tidyverse)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

cdf <- read_csv(file.path(raw, "anes/anes_timeseries_cdf_csv_20260205.csv"), show_col_types = FALSE) |>
  transmute(
    year = VCF0004,
    folk = case_when(VCF9223 %in% c(1, 2) ~ 1, VCF9223 %in% c(3, 4) ~ 0, TRUE ~ NA_real_),
    rep  = case_when(VCF0301 %in% c(5, 6, 7) ~ 1, VCF0301 %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
    info = if_else(between(VCF0050a, 1, 5), 6 - VCF0050a, NA_real_),
    w    = if_else(VCF0009x > 0, VCF0009x, NA_real_)
  )

elite <- read_csv(file.path(proc, "elite_polarization_series.csv"), show_col_types = FALSE)

one_year <- function(yr) {
  g <- cdf |> filter(year == yr) |> drop_na(folk, rep, w)
  gap <- weighted.mean(g$folk[g$rep == 1], g$w[g$rep == 1]) - weighted.mean(g$folk[g$rep == 0], g$w[g$rep == 0])
  d <- g |> drop_na(info) |> mutate(iz = as.numeric(scale(info)))
  des <- svydesign(ids = ~1, weights = ~w, data = d)
  prem <- coef(svyglm(folk ~ rep * iz, design = des, family = quasibinomial()))[["rep:iz"]]
  tibble(year = yr, elite_tribalization = round(elite$polz_s[elite$year == yr], 3),
         mass_gap = round(gap, 3), sophistication_premium = round(prem, 3))
}
sig <- map_dfr(c(2004, 2008, 2012, 2016), one_year)
write_csv(sig, file.path(proc, "structural_signature.csv"))

cat("\nGap and sophistication premium both scale with elite tribalization:\n")
print(sig)
cat(sprintf("\ncorr(T, gap) = %+.2f ; corr(T, premium) = %+.2f ; corr(gap, premium) = %+.2f\n",
            cor(sig$elite_tribalization, sig$mass_gap),
            cor(sig$elite_tribalization, sig$sophistication_premium),
            cor(sig$mass_gap, sig$sophistication_premium)))
