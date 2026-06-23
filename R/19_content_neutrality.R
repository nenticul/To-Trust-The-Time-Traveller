# =====================================================================
# 19_content_neutrality.R — is capture content-neutral, or is it just that
# "Democrats defer to experts"? The immigration and evolution cases both have
# Democrats moving toward the credentialed-expert position, so they cannot
# distinguish the structural claim (the converging out-group is whichever
# party departs from the FOLK default) from the simpler "Democrats are more
# expert-deferential" reading.
#
# TRADE breaks the tie. The folk-economic default on trade is protectionist
# (anti-foreign, anti-market bias; Caplan). The expert verdict is the gains
# from trade. On the ANES import-limits item (VCF9231, "favor/oppose placing
# limits on imports to protect American jobs"; 1 = favor = protectionist/folk),
# the party sitting at the protectionist default SWITCHES over time:
#   1988-2012: DEMOCRATS are the more protectionist (folk) party (gap -.03 to -.11);
#              the expert-aligned, less-protectionist side is REPUBLICAN.
#   2016:      the gap flips to +.13; 2024: +.42 -- REPUBLICANS now hold the
#              protectionist folk line and DEMOCRATS have moved to the experts.
# So before 2016 the converging-on-experts party on a market belief is the
# Republicans -- the opposite party from immigration -- which is exactly what a
# content-neutral, structural account predicts and a fixed "Democrats defer to
# experts" account cannot. (The pre-2016 era is low-tribalization, so political
# information corrects the folk error in BOTH parties, the P2 regime; the
# value-add here is the direction of the partisan gap and its flip, not a
# sophistication-amplification test, which trade cannot provide because it only
# tribalized AFTER the parties exchanged positions.)
#
# Raw file: data/raw/anes/anes_timeseries_cdf_csv_20260205.csv (restricted).
# =====================================================================
library(tidyverse)

raw <- "data/raw"; proc <- "data/processed"

cdf <- read_csv(file.path(raw, "anes/anes_timeseries_cdf_csv_20260205.csv"),
                show_col_types = FALSE) |>
  transmute(
    year = VCF0004,
    prot = case_when(VCF9231 == 1 ~ 1, VCF9231 == 2 ~ 0, TRUE ~ NA_real_),   # favor import limits = protectionist/folk
    rep  = case_when(VCF0301 %in% c(5, 6, 7) ~ 1, VCF0301 %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
    w    = if_else(VCF0009x > 0, VCF0009x, NA_real_)
  ) |>
  drop_na(prot, rep, w)

flip <- cdf |>
  filter(year %in% c(1988, 1992, 1996, 2004, 2008, 2012, 2016, 2024)) |>
  group_by(year, rep) |>
  summarise(prot = weighted.mean(prot, w), .groups = "drop") |>
  pivot_wider(names_from = rep, values_from = prot, names_prefix = "p") |>
  transmute(year, dem_protectionist = round(p0, 3), rep_protectionist = round(p1, 3),
            gap = round(p1 - p0, 3))
write_csv(flip, file.path(proc, "trade_content_neutrality.csv"))
cat("\nProtectionist (folk) share by party — the folk-default party flips D -> R across 2016:\n")
print(flip)
