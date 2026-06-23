# =====================================================================
# 08_fusion.R — CAPSTONE: the partisanization of a fact
# A truth-apt factual belief ("immigrants take jobs", GSS `immjobs`)
# acquires a partisan signature over time. We establish:
#   (1) the Republican-Democrat gap in the FACT widens from ~0 (1996) to
#       +33 pts (2024) — a monotonic partisanization of a factual claim,
#       driven by Democrats abandoning the belief;
#   (2) a design-based party x year interaction confirms it at the
#       individual level (robust to dropping weights);
#   (3) the fact and the matched immigration PREFERENCE are STABLY coupled
#       (r ~ .35-.45 across 1996-2024) — they were fused all along, so the
#       dynamic is the fact becoming partisan, not the two converging.
#
# INFERENCE NOTE: the appropriate significance test for the over-time trend
# is the survey-year regression in (1) (effective N = number of surveys, =5;
# r = .92, p ~ .03). A naive weighted glm on the 6,457 individuals returns
# p ~ 1e-26, but that treats survey weights as frequency counts and the
# respondents as independent across only five surveys — it overstates
# precision and is NOT reported as the headline. (2) is design-based.
#
# CORRECTION NOTE: an earlier draft reported a cross-item correlation
# "rising from -0.21 (2004) to +0.34 (2024)." That was an artifact:
# `immjobs` and `letin1a` were on DISJOINT GSS ballots in 2004 (zero
# shared respondents), and the negative value came from coercing
# non-respondents on `immjobs` to "does not believe." On true
# co-respondents the coupling is positive and flat — see (3).
# =====================================================================
library(tidyverse)
library(haven)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  transmute(
    year,
    immjobs, immameco, letin1, letin1a,
    fact    = if_else(!is.na(immjobs), as.integer(immjobs <= 2), NA_integer_),  # "immigrants take jobs"
    rep     = case_when(partyid <= 2 ~ 0L, partyid >= 4 ~ 1L, TRUE ~ NA_integer_),
    college = as.integer(degree >= 3),
    region  = region,
    w       = coalesce(wtssall, wtssps)
  )

# ---------------------------------------------------------------------
# (1) Partisan gap in the FACT, by survey year (immjobs: 1996-2024)
# ---------------------------------------------------------------------
gap_df <- gss |>
  filter(!is.na(fact), !is.na(rep), !is.na(w)) |>
  group_by(year, rep) |>
  summarise(share = weighted.mean(fact, w), n = n(), .groups = "drop") |>
  pivot_wider(names_from = rep, values_from = c(share, n)) |>
  transmute(year,
            dem_share = share_0, rep_share = share_1,
            gap = share_1 - share_0,
            n_dem = n_0, n_rep = n_1) |>
  arrange(year)
write_csv(gap_df, file.path(proc, "fact_partisan_gap.csv"))
print(gap_df)

# (1b) Per-year partisan gap with design-based 95% CI, for the uncertainty band on
# the headline figure. The early gaps (1996, 2004) include zero; from 2014 the gap
# is significantly positive and grows monotonically.
gap_ci <- gss |>
  filter(!is.na(fact), !is.na(rep), !is.na(w)) |>
  group_split(year) |>
  map_dfr(function(d) {
    est <- svyby(~fact, ~rep, svydesign(ids = ~1, weights = ~w, data = d), svymean)
    g <- est$fact[est$rep == 1] - est$fact[est$rep == 0]
    se <- sqrt(est$se[est$rep == 1]^2 + est$se[est$rep == 0]^2)
    tibble(year = d$year[1], gap = g, gap_lo = g - 1.96 * se, gap_hi = g + 1.96 * se, gap_se = se)
  })
write_csv(gap_ci, file.path(proc, "fact_partisan_gap_ci.csv"))
print(gap_ci)

# (1c) Wording robustness (against differential item functioning): a SECOND,
# differently worded immigration-economy fact -- "immigrants are good for America's
# economy" (immameco, fielded 1996/2004/2014/2024) -- partisanizes in lockstep with
# immjobs (r ~ .95 across the four common years), by the same one-sided Democratic move.
gap_for <- function(var, expr, label) {
  gss |> filter(!is.na(.data[[var]]), !is.na(rep), !is.na(w)) |>
    group_by(year, rep) |>
    summarise(m = weighted.mean(expr(.data[[var]]), w), n = n(), .groups = "drop") |>
    pivot_wider(names_from = rep, values_from = c(m, n)) |>
    filter(n_0 > 40, n_1 > 40) |>
    transmute(year, item = label, gap = m_1 - m_0)
}
wording <- bind_rows(
  gap_for("immjobs",  function(x) as.integer(x <= 2), "immigrants take jobs"),
  gap_for("immameco", function(x) as.integer(x >= 4), "immigrants not good for economy")
) |> arrange(item, year)
write_csv(wording, file.path(proc, "fact_wording_robustness.csv"))
print(wording)

# Pooled over-time FACT trend: regress the partisan gap on year across BOTH fact
# framings (immjobs + immameco) with an item fixed effect -- nine survey-year-item
# points across 1996-2024 rather than five, so the over-time partisanization does not
# rest on the immjobs trend alone.
wt_trend <- lm(gap ~ I((year - 2010) / 10) + item, data = wording)
cat(sprintf("\nPooled FACT trend (immjobs + immameco, %d points, item FE): %+.3f/decade, p = %.4f, R2 = %.2f\n",
            nrow(wording), coef(wt_trend)[[2]],
            summary(wt_trend)$coefficients[2, 4], summary(wt_trend)$r.squared))

# Honest trend test: regress the gap on year across the survey-years.
trend <- lm(gap ~ I(year - 2014), data = gap_df)
cat(sprintf("\nGap-trend across %d survey-years: slope = %.4f/yr, r = %.3f, p = %.4f\n",
            nrow(gap_df), coef(trend)[["I(year - 2014)"]],
            sign(coef(trend)[["I(year - 2014)"]]) * sqrt(summary(trend)$r.squared),
            summary(trend)$coefficients["I(year - 2014)", "Pr(>|t|)"]))

# ---------------------------------------------------------------------
# (2) Individual-level party x year interaction (design-based SEs).
# ---------------------------------------------------------------------
di  <- gss |> mutate(yr = year - 2014) |> drop_na(fact, rep, yr, w, college)
des <- svydesign(ids = ~1, weights = ~w, data = di)
m_int <- svyglm(fact ~ rep * yr + college, design = des, family = quasibinomial())
ct <- summary(m_int)$coefficients
cat(sprintf("party x year (design-based): coef = %.4f, SE = %.4f, p = %.3g\n",
            ct["rep:yr", "Estimate"], ct["rep:yr", "Std. Error"], ct["rep:yr", "Pr(>|t|)"]))
m_uw <- glm(fact ~ rep * yr + college, data = di, family = binomial())   # weights-off robustness
cat(sprintf("party x year (unweighted, robustness): coef = %.4f\n", coef(m_uw)[["rep:yr"]]))

# Regional macro-exposure robustness: absorb region-specific time trends
# (census-region fixed effects x year). The party x year interaction is
# essentially unchanged, so differential local labor-market trends correlated
# with party and timing do not drive the partisanization.
dr    <- di |> drop_na(region)
m_reg <- svyglm(fact ~ rep * yr + college + factor(region) * yr,
                design = svydesign(ids = ~1, weights = ~w, data = dr), family = quasibinomial())
cat(sprintf("party x year: baseline = %.4f; + region x year trends = %.4f\n",
            coef(m_int)[["rep:yr"]], coef(m_reg)[["rep:yr"]]))

# ---------------------------------------------------------------------
# (3) Fact-preference coupling on TRUE co-respondents (secondary).
#   letin1  = older 5-pt levels item (co-asked 1996/2004/2014/2024)
#   letin1a = newer "reduce" item     (co-asked 2014/2022/2024)
# ---------------------------------------------------------------------
wcorr <- function(x, y, w) {
  ok <- !(is.na(x) | is.na(y) | is.na(w)); x <- x[ok]; y <- y[ok]; w <- w[ok]
  if (length(x) < 50 || sd(x) == 0 || sd(y) == 0) return(NA_real_)
  mx <- weighted.mean(x, w); my <- weighted.mean(y, w)
  weighted.mean((x - mx) * (y - my), w) /
    sqrt(weighted.mean((x - mx)^2, w) * weighted.mean((y - my)^2, w))
}
couple <- function(pref) {
  gss |>
    filter(!is.na(immjobs), !is.na(.data[[pref]]), !is.na(w)) |>
    group_by(year) |>
    summarise(pref_item = pref,
              r = wcorr(as.integer(immjobs <= 2), as.integer(.data[[pref]] >= 4), w),
              n = n(), .groups = "drop") |>
    filter(!is.na(r))
}
coupling <- bind_rows(couple("letin1"), couple("letin1a")) |> arrange(year, pref_item)
write_csv(coupling, file.path(proc, "fusion_coupling.csv"))
print(coupling)

# ---------------------------------------------------------------------
# (4) INTERVAL-BY-INTERVAL decomposition of the gap change (against the
# endpoint-only "98% Democratic" reading). The net 1996->2024 change is ~98%
# Democratic, but the Republican share is U-shaped (45->42->41->34->45): the
# 2022->2024 interval is ~72% REPUBLICAN movement. We report each interval so
# the in-group is not described as monotonically "anchored".
# ---------------------------------------------------------------------
dec <- gap_df |> filter(year %in% c(1996, 2004, 2014, 2022, 2024)) |> arrange(year)
decomp <- map_dfr(2:nrow(dec), function(i) {
  a <- dec[i - 1, ]; b <- dec[i, ]
  dDem <- b$dem_share - a$dem_share; dRep <- b$rep_share - a$rep_share
  dgap <- (b$rep_share - b$dem_share) - (a$rep_share - a$dem_share)
  tot <- abs(dDem) + abs(dRep)
  tibble(interval = paste0(a$year, "-", b$year),
         dDem_pts = round(100 * dDem, 1), dRep_pts = round(100 * dRep, 1),
         gap_change_pts = round(100 * dgap, 1),
         pct_from_Dem = round(100 * abs(dDem) / tot), pct_from_Rep = round(100 * abs(dRep) / tot))
})
write_csv(decomp, file.path(proc, "gap_decomposition_by_interval.csv"))
cat("\nGap change decomposition by interval (2022-2024 is Republican-driven):\n"); print(decomp)
