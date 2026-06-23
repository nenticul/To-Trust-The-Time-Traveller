# =====================================================================
# 11_robustness.R — specification-curve (multiverse) + heterogeneity for the
# capstone mechanism (ANES 2024 party x knowledge interaction).
#
# (1) MULTIVERSE: re-estimate the party x knowledge interaction across every
#     sensible combination of belief coding, party coding, controls, and
#     weighting (24 specifications). Reports the share positive / positive &
#     significant — the anti-"specification-search" defense.
# (2) HETEROGENEITY: the interaction by partisan strength and by age cohort
#     (identity-protective cognition predicts it concentrates among strong
#     identifiers).
# Variables as in 10_anes_knowledge.R; age = V241458x.
# =====================================================================
library(tidyverse)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

a <- read_csv(file.path(raw, "anes/anes_timeseries_2024_csv_20260519.csv"),
              show_col_types = FALSE) |>
  transmute(
    v   = V242228, pid = V241227x,
    know = (V241612 == 6) + (V241613 == 1) + (V241614 == 2) + (V241615 == 1),
    age = if_else(V241458x > 0, V241458x, NA_real_),
    wt  = if_else(V240107b > 0, V240107b, NA_real_), psu = V240107c
  )
a$knz <- as.numeric(scale(a$know))
a$agez <- as.numeric(scale(a$age))

fact_code <- function(v, how) {
  if (how == "very") as.integer(v %in% c(1, 2)) else as.integer(v == 1)
}
rep_code <- function(pid, how) {
  if (how == "leaners") case_when(pid %in% c(5, 6, 7) ~ 1, pid %in% c(1, 2, 3) ~ 0)
  else case_when(pid == 7 ~ 1, pid == 1 ~ 0)
}

grid <- expand_grid(pc = c("leaners","strong"), dc = c("very","extreme"),
                    ctrl = c("none","age","agesq"), wtopt = c("weighted","unweighted"))
res <- pmap_dfr(grid, function(pc, dc, ctrl, wtopt) {
  d <- a |> mutate(fact = fact_code(v, dc), rep = rep_code(pid, pc)) |>
    drop_na(fact, rep, knz)
  f <- "fact ~ rep*knz"
  if (ctrl %in% c("age","agesq")) { d <- drop_na(d, agez); f <- paste(f, "+ agez") }
  if (ctrl == "agesq") f <- paste(f, "+ I(agez^2)")
  if (wtopt == "weighted") {
    d <- drop_na(d, wt)
    des <- svydesign(ids = ~psu, weights = ~wt, data = d)
    m <- svyglm(as.formula(f), design = des, family = quasibinomial())
  } else {
    m <- glm(as.formula(f), data = d, family = binomial())
  }
  ct <- summary(m)$coefficients["rep:knz", ]
  tibble(pc, dc, ctrl, wtopt, coef = ct[["Estimate"]],
         p = ct[[grep("Pr", names(ct), value = TRUE)]])
})
write_csv(res, file.path(proc, "anes_spec_curve.csv"))
cat(sprintf("MULTIVERSE (%d specs): positive %.0f%%, positive & p<.05 %.0f%%, coef %.2f-%.2f\n",
            nrow(res), mean(res$coef > 0)*100, mean(res$coef > 0 & res$p < .05)*100,
            min(res$coef), max(res$coef)))

# (2) heterogeneity by partisan strength
het <- a |>
  mutate(fact = fact_code(v, "very"), rep = rep_code(pid, "leaners"),
         strength = case_when(pid %in% c(1,7) ~ "strong", pid %in% c(2,3,5,6) ~ "weak/lean"),
         klev = if_else(know >= 3, "high", if_else(know <= 1, "low", "mid"))) |>
  drop_na(fact, rep, wt, strength) |>
  filter(klev %in% c("low","high")) |>
  group_by(strength, klev, rep) |>
  summarise(share = weighted.mean(fact, wt), .groups = "drop")
het_gap <- het |> pivot_wider(names_from = rep, values_from = share) |>
  mutate(gap = `1` - `0`) |> select(strength, klev, gap) |> arrange(strength, desc(klev))
write_csv(het_gap, file.path(proc, "anes_het_strength.csv"))
cat("\nGap by knowledge within partisan strength (Rep - Dem):\n"); print(het_gap)

# (3) heterogeneity by age cohort: party x knowledge interaction within cohort
age_het <- tibble(cohort = c("<40", "40-64", "65+"), lo = c(0, 40, 65), hi = c(40, 65, 200)) |>
  pmap_dfr(function(cohort, lo, hi) {
    s <- a |> mutate(fact = fact_code(v, "very"), rep = rep_code(pid, "leaners")) |>
      filter(age >= lo, age < hi) |> drop_na(fact, rep, knz, wt)
    des <- svydesign(ids = ~psu, weights = ~wt, data = s)
    m <- svyglm(fact ~ rep * knz, design = des, family = quasibinomial())
    tibble(cohort, interaction = coef(m)[["rep:knz"]], n = nrow(s))
  })
write_csv(age_het, file.path(proc, "anes_het_age.csv"))
cat("\nParty x knowledge interaction by age cohort:\n"); print(age_het)

# (4) Specificity: does party x knowledge survive party x education and party x ideology?
# If knowledge is merely a proxy for education or ideology, the interaction should
# vanish once those interactions are included. It does not.
zz <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
ac <- read_csv(file.path(raw, "anes/anes_timeseries_2024_csv_20260519.csv"), show_col_types = FALSE) |>
  transmute(
    fact = case_when(V242228 %in% c(1, 2) ~ 1, V242228 %in% c(3, 4) ~ 0, TRUE ~ NA_real_),
    rep  = case_when(V241227x %in% c(5, 6, 7) ~ 1, V241227x %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
    know = (V241612 == 6) + (V241613 == 1) + (V241614 == 2) + (V241615 == 1),
    ideo = if_else(between(V241177, 1, 7), as.numeric(V241177), NA_real_),     # 7-pt lib-con
    edu  = if_else(between(V241465x, 1, 5), as.numeric(V241465x), NA_real_),   # 5-cat education
    wt = if_else(V240107b > 0, V240107b, NA_real_), psu = V240107c) |>
  mutate(knz = zz(know), eduz = zz(edu), ideoz = zz(ideo))
ctrl_one <- function(formula, need) {
  s <- ac |> drop_na(fact, rep, knz, wt, all_of(need))
  des <- svydesign(ids = ~psu, weights = ~wt, data = s)
  ct <- summary(svyglm(as.formula(formula), design = des, family = quasibinomial()))$coefficients["rep:knz", ]
  tibble(party_knowledge_coef = ct[["Estimate"]], p_value = ct[["Pr(>|t|)"]], n = nrow(s))
}
controls <- bind_rows(
  ctrl_one("fact ~ rep*knz", character(0))                         |> mutate(model = "baseline"),
  ctrl_one("fact ~ rep*knz + rep*eduz", "eduz")                    |> mutate(model = "+ party x education"),
  ctrl_one("fact ~ rep*knz + rep*ideoz", "ideoz")                  |> mutate(model = "+ party x ideology"),
  ctrl_one("fact ~ rep*knz + rep*eduz + rep*ideoz", c("eduz","ideoz")) |> mutate(model = "+ both")
) |> select(model, party_knowledge_coef, p_value, n)
write_csv(controls, file.path(proc, "anes_knowledge_controls.csv"))
cat("\nParty x knowledge net of party x education and party x ideology:\n"); print(controls)

# (5) WITHIN-PARTY decomposition of the knowledge effect (the asymmetry).
# Symmetric identity-protective cognition predicts knowledge sharpens BOTH poles.
# It does not: knowledge moves Democrats toward the experts (negative slope) while
# Republicans are flat (null). The gap widens because the OUT-GROUP converges, not
# because the in-group digs in -- asymmetric motivated reasoning, exactly what the
# model implies when the in-party line coincides with the folk default (p_Rep ~ f).
byparty <- a |>
  mutate(fact = fact_code(v, "very"),
         dem = case_when(pid %in% c(1, 2, 3) ~ 1L, pid %in% c(5, 6, 7) ~ 0L, TRUE ~ NA_integer_)) |>
  drop_na(fact, dem, knz, wt)
wp <- map_dfr(c("Democrats", "Republicans"), function(lab) {
  s <- filter(byparty, dem == as.integer(lab == "Democrats"))
  des <- svydesign(ids = ~psu, weights = ~wt, data = s)
  ct <- summary(svyglm(fact ~ knz, design = des, family = quasibinomial()))$coefficients["knz", ]
  lo <- weighted.mean(filter(s, know <= 1)$fact, filter(s, know <= 1)$wt)
  hi <- weighted.mean(filter(s, know >= 3)$fact, filter(s, know >= 3)$wt)
  tibble(party = lab, share_low_know = round(lo, 3), share_high_know = round(hi, 3),
         knowledge_logodds = round(ct[["Estimate"]], 3),
         p_value = signif(ct[["Pr(>|t|)"]], 2), n = nrow(s))
})
write_csv(wp, file.path(proc, "anes_knowledge_by_party.csv"))
cat("\nWithin-party knowledge slope (asymmetry):\n"); print(wp)

# (5b) DIRECT TEST of the asymmetry: the party x knowledge interaction IS the
# difference in within-party slopes. Reporting it turns the asymmetry from an
# eyeballed contrast (Dem -0.49 vs Rep +0.04) into a tested quantity.
bp <- byparty |> mutate(repd = as.integer(dem == 0))
des_bp <- svydesign(ids = ~psu, weights = ~wt, data = bp)
ct_d <- summary(svyglm(fact ~ repd * knz, design = des_bp, family = quasibinomial()))$coefficients["repd:knz", ]
asym <- tibble(quantity = "Rep slope - Dem slope (asymmetry test)",
               difference_logodds = round(ct_d[["Estimate"]], 3),
               p_value = signif(ct_d[["Pr(>|t|)"]], 2), n = nrow(bp))
write_csv(asym, file.path(proc, "anes_knowledge_asymmetry_test.csv"))
cat("\nDirect asymmetry test (party x knowledge interaction):\n"); print(asym)

# (8) DIVERGENT-DIETS exposure control with a CONTENT-relevant proxy (media trust),
# stronger than the generic political-attention control: does party x knowledge on
# the fact survive controlling for party x trust-in-media? It barely moves
# (0.53 -> 0.49), narrowing but not closing the selective-exposure account.
md <- read_csv(file.path(raw, "anes/anes_timeseries_2024_csv_20260519.csv"), show_col_types = FALSE) |>
  transmute(
    fact = case_when(V242228 %in% c(1, 2) ~ 1, V242228 %in% c(3, 4) ~ 0, TRUE ~ NA_real_),
    rep  = case_when(V241227x %in% c(5, 6, 7) ~ 1, V241227x %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
    know = (V241612 == 6) + (V241613 == 1) + (V241614 == 2) + (V241615 == 1),
    trustnews = if_else(between(V241335, 1, 5), 6 - V241335, NA_real_),   # higher = more trust
    trusttrad = if_else(between(V242422, 1, 4), 5 - V242422, NA_real_),
    wt = if_else(V240107b > 0, V240107b, NA_real_), psu = V240107c) |>
  mutate(knz = zz(know), trust1z = zz(trustnews), trust2z = zz(trusttrad))
mdc <- function(formula, need) {
  s <- md |> drop_na(fact, rep, knz, wt, all_of(need))
  des <- svydesign(ids = ~psu, weights = ~wt, data = s)
  ct <- summary(svyglm(as.formula(formula), design = des, family = quasibinomial()))$coefficients["rep:knz", ]
  tibble(party_knowledge_logodds = round(ct[["Estimate"]], 3), p_value = signif(ct[["Pr(>|t|)"]], 2), n = nrow(s))
}
media_controls <- bind_rows(
  mdc("fact ~ rep*knz", character(0))                          |> mutate(model = "baseline"),
  mdc("fact ~ rep*knz + rep*trust1z", "trust1z")               |> mutate(model = "+ party x trust in news media"),
  mdc("fact ~ rep*knz + rep*trust2z", "trust2z")               |> mutate(model = "+ party x trust in traditional media"),
  mdc("fact ~ rep*knz + rep*trust1z + rep*trust2z", c("trust1z","trust2z")) |> mutate(model = "+ party x both media-trust measures")
) |> select(model, party_knowledge_logodds, p_value, n)
write_csv(media_controls, file.path(proc, "anes_mediadiet_controls.csv"))
cat("\nParty x knowledge net of party x media-trust (content-relevant exposure control):\n"); print(media_controls)

# (6) Cognition vs exposure on the HEADLINE pairing (knowledge x fact): does the
# party x knowledge interaction survive controlling for party x political ATTENTION
# (V241004, a proxy for differential exposure to party-congruent information)? It
# falls only from ~+0.51 to ~+0.40 (p ~ .001): the amplification is not reducible to
# who attends to more of their own side's diet. (Direct analogue of the CES check in
# Appendix B, here on the very knowledge/fact pairing the mechanism claim is about.)
aa <- read_csv(file.path(raw, "anes/anes_timeseries_2024_csv_20260519.csv"), show_col_types = FALSE) |>
  transmute(fact = case_when(V242228 %in% c(1, 2) ~ 1, V242228 %in% c(3, 4) ~ 0, TRUE ~ NA_real_),
            rep  = case_when(V241227x %in% c(5, 6, 7) ~ 1, V241227x %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
            know = (V241612 == 6) + (V241613 == 1) + (V241614 == 2) + (V241615 == 1),
            att  = if_else(between(V241004, 1, 5), 6 - V241004, NA_real_),  # higher = more interested
            wt = if_else(V240107b > 0, V240107b, NA_real_), psu = V240107c) |>
  mutate(knz = zz(know), attz = zz(att)) |> drop_na(fact, rep, knz, attz, wt)
des_aa <- svydesign(ids = ~psu, weights = ~wt, data = aa)
b0 <- coef(svyglm(fact ~ rep * knz, design = des_aa, family = quasibinomial()))[["rep:knz"]]
b1 <- coef(svyglm(fact ~ rep * knz + rep * attz, design = des_aa, family = quasibinomial()))[["rep:knz"]]
cat(sprintf("\nparty x knowledge on fact: %+.3f (alone) -> %+.3f (net of party x attention), n = %d\n",
            b0, b1, nrow(aa)))

# (7) IDENTITY-CONFOUND control (the immigration analog of the evolution religiosity
# test). Racial resentment and authoritarianism are each correlated with both party
# and political sophistication and are the natural alternative engines of immigration
# sorting. Unlike evolution -- where party x education did NOT survive religiosity
# (R/15) -- the party x knowledge interaction on the immigration fact DOES survive
# party x racial-resentment and party x authoritarianism (4-item ANES batteries:
# racial resentment V242300-V242303; child-trait authoritarianism V242260-V242263).
rr_raw <- read_csv(file.path(raw, "anes/anes_timeseries_2024_csv_20260519.csv"), show_col_types = FALSE) |>
  transmute(
    fact = case_when(V242228 %in% c(1, 2) ~ 1, V242228 %in% c(3, 4) ~ 0, TRUE ~ NA_real_),
    rep  = case_when(V241227x %in% c(5, 6, 7) ~ 1, V241227x %in% c(1, 2, 3) ~ 0, TRUE ~ NA_real_),
    know = (V241612 == 6) + (V241613 == 1) + (V241614 == 2) + (V241615 == 1),
    # racial resentment: 1 agree strongly .. 5 disagree strongly; higher = more resentment.
    rr1 = if_else(between(V242300, 1, 5), 6 - V242300, NA_real_),   # work way up w/o favors (agree=resent)
    rr2 = if_else(between(V242301, 1, 5), as.numeric(V242301), NA_real_), # slavery makes difficult (disagree=resent)
    rr3 = if_else(between(V242302, 1, 5), as.numeric(V242302), NA_real_), # less than deserve (disagree=resent)
    rr4 = if_else(between(V242303, 1, 5), 6 - V242303, NA_real_),   # try harder (agree=resent)
    a1 = if_else(between(V242260, 1, 2), as.integer(V242260 == 2), NA_integer_), # respect>independence
    a2 = if_else(between(V242261, 1, 2), as.integer(V242261 == 2), NA_integer_), # good manners>curiosity
    a3 = if_else(between(V242262, 1, 2), as.integer(V242262 == 1), NA_integer_), # obedience>self-reliance
    a4 = if_else(between(V242263, 1, 2), as.integer(V242263 == 2), NA_integer_), # well-behaved>considerate
    wt = if_else(V240107b > 0, V240107b, NA_real_), psu = V240107c) |>
  mutate(rr = rowMeans(across(c(rr1, rr2, rr3, rr4))),
         auth = rowMeans(across(c(a1, a2, a3, a4))),
         knz = zz(know), rrz = zz(rr), authz = zz(auth))
rc <- function(formula, need) {
  s <- rr_raw |> drop_na(fact, rep, knz, wt, all_of(need))
  des <- svydesign(ids = ~psu, weights = ~wt, data = s)
  ct <- summary(svyglm(as.formula(formula), design = des, family = quasibinomial()))$coefficients["rep:knz", ]
  tibble(party_knowledge_logodds = round(ct[["Estimate"]], 3), p_value = signif(ct[["Pr(>|t|)"]], 2), n = nrow(s))
}
resent_controls <- bind_rows(
  rc("fact ~ rep*knz", character(0))                              |> mutate(model = "baseline"),
  rc("fact ~ rep*knz + rep*rrz", "rrz")                           |> mutate(model = "+ party x racial resentment"),
  rc("fact ~ rep*knz + rep*authz", "authz")                       |> mutate(model = "+ party x authoritarianism"),
  rc("fact ~ rep*knz + rep*rrz + rep*authz", c("rrz", "authz"))   |> mutate(model = "+ party x resentment + authoritarianism")
) |> select(model, party_knowledge_logodds, p_value, n)
write_csv(resent_controls, file.path(proc, "anes_resentment_controls.csv"))
cat("\nParty x knowledge net of party x racial-resentment and party x authoritarianism:\n"); print(resent_controls)
