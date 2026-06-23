# =====================================================================
# 20_issp_crossnational.R — CROSS-NATIONAL SCOPE TEST.
# The paper's identity mechanism is built on the two-party United States.
# A natural scope conjecture is that fact-capture should be WEAKER under
# multi-party, coalition systems, where the partisan signal is diffused.
# We test it with ISSP 2013 National Identity III (ZA5950), which fields the
# same immigration-economy fact as the GSS -- "immigrants take jobs away from
# people born in [country]" (V50) -- in ~26 democracies, with a harmonized
# left-right party-family variable (PARTY_LR).
#
# For each country we compute the LEFT-RIGHT gap in the folk belief (share of
# the right bloc minus the left bloc agreeing the fact). Three results:
#   (1) GENERALITY: the gap is positive (right more folk) in ~77% of countries
#       -- the capture of the immigration fact is not a US peculiarity.
#   (2) The naive scope conjecture FAILS: the gap is UNcorrelated with party-
#       system fragmentation (effective number of parliamentary parties, ENP;
#       r ~ +0.16, p ~ .44). Multi-party systems do not capture the fact less.
#   (3) What DOES track the gap is elite issue-supply: it is ~4x larger where a
#       salient anti-immigration party exists (0.13 vs 0.03). This refines the
#       scope condition and CONFIRMS the paper's deeper claim -- capture follows
#       elite conflict and issue-ownership (the precedence mechanism), not the
#       number of parties. The modest US gap (rank ~9/26) matches its own GSS
#       trajectory: in 2013 US immigration was only mid-tribalization (+8 pts in
#       2014), so one-shot cross-country comparisons conflate each country's
#       position in its own tribalization process.
#
# left bloc  = PARTY_LR {1,2,3} (far-left .. center/liberal; US Democrats code 3)
# right bloc = PARTY_LR {4,5}   (right/conservative .. far right; US Republicans 4)
# Raw file: data/raw/issp/ZA5950_v2-0-0.dta (restricted; GESIS, free login).
# =====================================================================
library(tidyverse)
library(haven)

raw <- "data/raw"; proc <- "data/processed"

# Effective number of parliamentary parties, ~2013 (standard Gallagher-type values).
enp <- tibble::tribble(
  ~country, ~enp,
  "FR",2.8,"CH",5.6,"DE",3.5,"SI",4.2,"BE",8.4,"GB",2.6,"DK",5.2,"HR",3.6,"LV",5.0,"US",2.0,
  "ES",2.6,"NO",4.4,"IS",3.8,"IN",5.0,"HU",2.6,"FI",5.8,"KR",2.3,"SK",4.0,"SE",4.5,"RU",2.8,
  "TR",2.5,"LT",5.5,"JP",2.4,"MX",3.0,"EE",4.4,"CZ",4.5)
salient_rr <- c("FR","CH","DK","BE","NO","SE","FI","SI","HU")   # salient radical/populist right ~2013

issp <- read_dta(file.path(raw, "issp/ZA5950_v2-0-0.dta")) |>
  transmute(
    iso  = str_extract(as_factor(V3), "^[A-Z]+"),
    folk = case_when(V50 %in% c(1, 2) ~ 1, V50 %in% c(3, 4, 5) ~ 0, TRUE ~ NA_real_),  # agree immigrants take jobs
    bloc = case_when(PARTY_LR %in% c(4, 5) ~ "right", PARTY_LR %in% c(1, 2, 3) ~ "left", TRUE ~ NA_character_),
    w    = if_else(WEIGHT > 0, WEIGHT, 1)
  ) |>
  drop_na(folk, bloc, iso)

gaps <- issp |>
  group_by(iso, bloc) |>
  summarise(folk = weighted.mean(folk, w), n = n(), .groups = "drop") |>
  pivot_wider(names_from = bloc, values_from = c(folk, n)) |>
  filter(n_left >= 80, n_right >= 80) |>
  transmute(country = iso, gap_right_minus_left = round(folk_right - folk_left, 3),
            n = n_left + n_right) |>
  inner_join(enp, by = "country") |>
  mutate(salient_antiimmig_party = as.integer(country %in% salient_rr)) |>
  arrange(desc(gap_right_minus_left))

write_csv(gaps, file.path(proc, "issp_crossnational.csv"))

ct <- cor.test(gaps$enp, gaps$gap_right_minus_left)
cat(sprintf("\nISSP 2013 cross-national (n = %d countries):\n", nrow(gaps)))
cat(sprintf("  positive (right-more-folk) gap in %.0f%% of countries\n", mean(gaps$gap_right_minus_left > 0) * 100))
cat(sprintf("  corr(ENP, gap) = %+.2f (p = %.2f) -- scope conjecture predicts NEGATIVE; not supported\n",
            ct$estimate, ct$p.value))
cat(sprintf("  mean gap with salient anti-immig party = %.3f vs %.3f without\n",
            mean(gaps$gap_right_minus_left[gaps$salient_antiimmig_party == 1]),
            mean(gaps$gap_right_minus_left[gaps$salient_antiimmig_party == 0])))
print(gaps)
