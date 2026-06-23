# =====================================================================
# 09_mechanism.R — is the sorting ignorance, or identity?
# Identity-protective cognition (Kahan 2012, 2013) predicts that partisan
# sorting on a belief is STRONGER, or appears FIRST, among the more
# sophisticated — because cognitive capacity is recruited to defend identity
# rather than to track evidence. A pure information-deficit account predicts
# the opposite (the educated should sort LESS). We test this on the fact
# `immjobs` using education as the sophistication proxy, and we quantify the
# asymmetric convergence of the out-group toward the expert benchmark.
#
# INFERENCE NOTE: with only a handful of survey-years a naive weighted glm
# overstates precision for the party x education interaction (p ~ .001);
# clustering by survey-year — the appropriate unit for an over-time pattern —
# gives p ~ .28. We therefore report the TEMPORAL PATTERN (sorting emerges
# first among graduates, then diffuses) as the identity-protective signature,
# not a single "significant" interaction coefficient.
# =====================================================================
library(tidyverse)
library(haven)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  transmute(
    year,
    fact    = if_else(!is.na(immjobs), as.integer(immjobs <= 2), NA_integer_),
    rep     = case_when(partyid <= 2 ~ 0L, partyid >= 4 ~ 1L, TRUE ~ NA_integer_),
    college = as.integer(degree >= 3),
    w       = coalesce(wtssall, wtssps)
  ) |>
  drop_na(fact, rep, college, w)

# ---------------------------------------------------------------------
# (1) Partisan gap in the fact, by education x survey year
# ---------------------------------------------------------------------
gap_edu <- gss |>
  group_by(year, college, rep) |>
  summarise(share = weighted.mean(fact, w), .groups = "drop") |>
  pivot_wider(names_from = rep, values_from = share, names_prefix = "p") |>
  transmute(year,
            education = if_else(college == 1, "college", "no_college"),
            dem_share = p0, rep_share = p1, gap = p1 - p0) |>
  arrange(year, education)
write_csv(gap_edu, file.path(proc, "fact_gap_by_education.csv"))
print(gap_edu)

# ---------------------------------------------------------------------
# (2) Party x education interaction on the fact (recent era), design-based.
# Reported with the caveat in the header — the temporal pattern is primary.
# ---------------------------------------------------------------------
di  <- gss |> filter(year >= 2014) |> mutate(yr = year - 2014)
des <- svydesign(ids = ~1, weights = ~w, data = di)
m   <- svyglm(fact ~ rep * college + yr, design = des, family = quasibinomial())
cat("\nparty x education interaction (design-based, 2014-2024):\n")
print(round(summary(m)$coefficients["rep:college", , drop = FALSE], 4))

# (2b) WITHIN-PARTY education slopes (the education analogue of the ANES knowledge
# decomposition). Unlike political knowledge — which moves only the out-group —
# general education corrects the folk error in BOTH parties (it acts on the shared
# folk prior f), but ~2x more among Democrats, so the gap still widens with schooling.
edu_party <- map_dfr(c("Democrats", "Republicans"), function(lab) {
  s <- filter(di, rep == as.integer(lab == "Republicans"))
  des_s <- svydesign(ids = ~1, weights = ~w, data = s)
  co <- coef(svyglm(fact ~ college, design = des_s, family = quasibinomial()))[["college"]]
  tibble(party = lab,
         share_no_college = round(weighted.mean(filter(s, college == 0)$fact, filter(s, college == 0)$w), 3),
         share_college    = round(weighted.mean(filter(s, college == 1)$fact, filter(s, college == 1)$w), 3),
         education_logodds = round(co, 3), n = nrow(s))
})
write_csv(edu_party, file.path(proc, "gss_education_by_party.csv"))
cat("\nWithin-party education slopes (GSS 2014-2024):\n"); print(edu_party)

# ---------------------------------------------------------------------
# (3) Asymmetric convergence toward the expert benchmark (~3% endorse), 1996->2024
# ---------------------------------------------------------------------
conv <- gss |> filter(year %in% c(1996, 2024)) |>
  group_by(year, rep) |>
  summarise(share = weighted.mean(fact, w), .groups = "drop") |>
  pivot_wider(names_from = rep, values_from = share, names_prefix = "p")
d96 <- conv$p0[conv$year == 1996]; d24 <- conv$p0[conv$year == 2024]
r96 <- conv$p1[conv$year == 1996]; r24 <- conv$p1[conv$year == 2024]
cat(sprintf("\nDemocrats %.0f%% -> %.0f%% (move %+0.0f pts); Republicans %.0f%% -> %.0f%% (move %+0.0f pts)\n",
            100*d96, 100*d24, 100*(d24-d96), 100*r96, 100*r24, 100*(r24-r96)))
cat(sprintf("%.0f%% of the gap change is Democratic movement toward the expert benchmark (~3%% agree).\n",
            100*abs(d24-d96)/(abs(d24-d96)+abs(r24-r96))))

# ---------------------------------------------------------------------
# (4) TRADE, A SECOND FOLK-REGIME ISSUE (P2 check). The GSS `moretrde` item is
# CATEGORICAL, not agree-disagree: 1 = "created more jobs", 2 = "about the same",
# 3 = "taken them away", 4 = "not relevant". The folk/anti-expert belief is 3.
# Education REDUCES it (Dem 0.55->0.34, Rep 0.54->0.40 in 2008), consistent with P2
# (education corrects folk error in the low-tribalization regime) and with Caplan.
# So general education tracks the experts on folk-regime claims; it is *political
# knowledge* (R/10), not education, that on the tribalized fact moves the out-group
# alone -- which is why the immigration "convergence" is party-enactment, not
# education failing to correct.
trd <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  filter(year == 2008, moretrde %in% c(1, 2, 3), !is.na(partyid)) |>
  transmute(folk = as.integer(moretrde == 3),
            party = case_when(partyid <= 2 ~ "Dem", partyid >= 4 ~ "Rep", TRUE ~ NA_character_),
            college = degree >= 3, w = coalesce(wtssall, wtssps)) |>
  drop_na()
cat("\nTrade (GSS 2008): share holding folk 'trade has taken jobs away', by party x education\n")
trd |> group_by(party, college) |>
  summarise(folk = round(weighted.mean(folk, w), 2), n = n(), .groups = "drop") |>
  arrange(party, college) |> print()
