# =====================================================================
# 07_precedence.R — elites polarized before the public sorted
# Builds the elite-polarization series from the Card et al. (2022) speech
# corpus and runs the lead-lag / Granger-style test against the GSS public
# partisan gap. Requires the speech_data.csv (see data/README.md).
# =====================================================================
library(tidyverse)
library(haven)

raw <- "data/raw"; proc <- "data/processed"

wmean <- function(x, w) { ok <- !(is.na(x) | is.na(w)); weighted.mean(x[ok], w[ok]) }

## ELITE series: Dem-Rep gap in pro-immigration speech tone, by year (5-yr smooth)
sp <- read_csv(file.path(raw, "speeches/speech_data.csv"), show_col_types = FALSE) |>
  mutate(year = as.integer(substr(as.character(date), 1, 4))) |>
  filter(party %in% c("D","R"))
elite <- sp |>
  group_by(year, party) |>
  summarise(tone = mean(tone_label_int, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = party, values_from = tone) |>
  arrange(year) |>
  mutate(polz = D - R,
         polz_s = zoo::rollapply(polz, 5, mean, partial = TRUE, align = "right", fill = NA))
write_csv(elite |> select(year, polz, polz_s), file.path(proc, "elite_polarization_series.csv"))

elite_at <- function(y) {
  e <- elite |> filter(year <= y)
  if (nrow(e) == 0) NA_real_ else tail(e$polz_s, 1)
}

## PUBLIC series: GSS letin1a partisan gap (Rep - Dem restrictionism), 2004-2024
gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  filter(!is.na(letin1a), !is.na(partyid)) |>
  mutate(restrict = as.integer(letin1a >= 4),
         w = coalesce(wtssall, wtssps),
         dem = partyid <= 2, rep = partyid >= 4)
pub <- gss |> group_by(year) |>
  summarise(public_gap = wmean(restrict[rep], w[rep]) - wmean(restrict[dem], w[dem]),
            .groups = "drop") |>
  filter(!is.na(public_gap)) |>
  mutate(elite_now   = map_dbl(year, elite_at),
         elite_lag10 = map_dbl(year, ~elite_at(.x - 10)),
         elite_lag15 = map_dbl(year, ~elite_at(.x - 15)),
         gap_lag = lag(public_gap))
write_csv(pub, file.path(proc, "precedence_series_letin1a.csv"))

# Lead-lag correlations
cat("Lead-lag correlations (n =", nrow(pub), "):\n")
for (L in c("elite_now","elite_lag10","elite_lag15"))
  cat("  ", L, ": r =", round(cor(pub$public_gap, pub[[L]], use = "complete.obs"), 3), "\n")

# Granger-style: lagged elite predicts public gap net of its own lag
gr <- pub |> drop_na(public_gap, elite_lag10, gap_lag)
m <- lm(public_gap ~ elite_lag10 + gap_lag, data = gr)
cat("\nGranger-style (n =", nrow(gr), "): elite(t-10) coef =",
    round(coef(m)[["elite_lag10"]], 3),
    " p =", round(summary(m)$coefficients["elite_lag10","Pr(>|t|)"], 3), "\n")

# Time-shift randomization inference (small-n, autocorrelation-preserving):
# correlate the public gap with the elite series shifted by an arbitrary lag tau,
# and rank the observed lag-10 correlation against the distribution over all tau.
# This gives an exact, non-asymptotic p that does not rely on n = 11 asymptotics.
elite_lookup <- setNames(elite$polz_s, elite$year)
corr_at <- function(tau) {
  e <- elite_lookup[as.character(pub$year - tau)]
  ok <- !is.na(e)
  if (sum(ok) < 8) NA_real_ else cor(pub$public_gap[ok], e[ok])
}
rs <- sapply(-25:60, corr_at); rs <- rs[!is.na(rs)]
obs <- corr_at(10); p_perm <- mean(rs >= obs)
cat("\nTime-shift randomization: lag-10 r =", round(obs, 3),
    "at the", round((1 - p_perm) * 100), "th pct of", length(rs),
    "alignments (p_perm =", round(p_perm, 3), ")\n")
