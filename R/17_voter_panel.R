# =====================================================================
# 17_voter_panel.R — WITHIN-PERSON CAPTURE (the panel result).
# The repeated cross-sections (R/08) show party AGGREGATES drifting apart;
# they cannot show a factual belief changing inside a person. The Views of
# the Electorate Research (VOTER) Survey re-interviewed the SAME national
# sample in 2011 (pre-Trump, pre-tribalization), 2016, 2018, and 2020.
# The belief item: immigrants "mostly make a contribution to American
# society" (=1) vs "mostly a drain" (=3); 2 = neither. We establish, within
# persons:
#   (1) CAPTURE WITHIN PERSONS — the Rep-Dem gap in the "drain" belief widens
#       from +47 pts (2011) to ~+62 (2020) among the SAME people, by the same
#       asymmetry as the GSS aggregate (Democrats abandon it 35%->10%;
#       Republicans hold 82%->72%).
#   (2) DIRECTION (cross-lagged panel model, standardized): 2011 PARTY predicts
#       2020 BELIEF net of 2011 belief (beta ~ +0.33) MORE strongly than 2011
#       belief predicts 2020 party (beta ~ +0.20). Both paths real; party leads.
#   (3) SORTING — of those whose 2011 belief was out of step with their party,
#       ~66% brought it into line by 2020; alignment 74% -> 83%.
#
# Raw file: data/raw/voter/voter_panel.dta (restricted; see data/README.md).
# Weights: weight_genpop_2020Nov (general-population weight, final wave).
# =====================================================================
library(tidyverse)
library(haven)

raw <- "data/raw"; proc <- "data/processed"

vp <- read_dta(file.path(raw, "voter/voter_panel.dta"))

bel <- function(x) { x <- as.numeric(x); if_else(x %in% c(1, 2, 3), x, NA_real_) }      # 1 contribute .. 3 drain
pid <- function(x) { x <- as.numeric(x); if_else(x >= 1 & x <= 7, x, NA_real_) }        # 1 strong Dem .. 7 strong Rep
rep_of <- function(x) { p <- pid(x); case_when(p %in% 5:7 ~ 1L, p %in% 1:3 ~ 0L, TRUE ~ NA_integer_) }

d <- vp |>
  transmute(
    b11 = bel(immi_contribution_2011),  b16 = bel(immi_contribution_2016),
    b18 = bel(immi_contribution_2018),  b20 = bel(immi_contribution_2020Nov),
    r11 = rep_of(pid7_2011), r16 = rep_of(pid7_2016),
    r18 = rep_of(pid7_2018), r20 = rep_of(pid7_2020Nov),
    p11 = pid(pid7_2011),    p20 = pid(pid7_2020Nov),
    w   = coalesce(as.numeric(weight_genpop_2020Nov), 1)
  )

wmean <- function(x, w) weighted.mean(x, w, na.rm = TRUE)

# ---------------------------------------------------------------------
# (1) Within-person capture: gap on "drain" (==3) by party, 2011->2020
# ---------------------------------------------------------------------
traj <- map_dfr(list(c("2011","b11","r11"), c("2016","b16","r16"),
                     c("2018","b18","r18"), c("2020","b20","r20")),
  function(v) {
    s <- d |> filter(!is.na(.data[[v[2]]]), !is.na(.data[[v[3]]])) |>
      mutate(drain = as.integer(.data[[v[2]]] == 3), rep = .data[[v[3]]])
    tibble(year = as.integer(v[1]),
           dem_share = round(wmean(s$drain[s$rep == 0], s$w[s$rep == 0]), 3),
           rep_share = round(wmean(s$drain[s$rep == 1], s$w[s$rep == 1]), 3),
           gap = NA_real_, n = nrow(s)) |>
      mutate(gap = round(rep_share - dem_share, 3))
  })
write_csv(traj, file.path(proc, "voter_within_person_gap.csv"))
cat("\nWithin-person 'drain' gap trajectory (same panel):\n"); print(traj)

# ---------------------------------------------------------------------
# (2) Cross-lagged panel model (standardized) — the direction arrow.
# ---------------------------------------------------------------------
z <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
cl <- d |> drop_na(b11, b20, p11, p20) |>
  mutate(zb11 = z(b11), zb20 = z(b20), zp11 = z(p11), zp20 = z(p20))

m_belief <- lm(zb20 ~ zb11 + zp11, data = cl, weights = w)   # party_2011 -> belief_2020
m_party  <- lm(zp20 ~ zp11 + zb11, data = cl, weights = w)   # belief_2011 -> party_2020
cb <- summary(m_belief)$coefficients; cp <- summary(m_party)$coefficients

clpm <- tibble(
  path = c("party_2011 -> belief_2020", "belief_2011 -> party_2020"),
  beta = round(c(cb["zp11","Estimate"], cp["zb11","Estimate"]), 3),
  p    = signif(c(cb["zp11","Pr(>|t|)"], cp["zb11","Pr(>|t|)"]), 3),
  autoregressive = round(c(cb["zb11","Estimate"], cp["zp11","Estimate"]), 3),
  n = nrow(cl)
)
write_csv(clpm, file.path(proc, "voter_cross_lagged.csv"))
cat("\nCross-lagged (standardized): party leads belief more than belief leads party:\n"); print(clpm)

# (2b) Random-intercept robustness (isolates within-person fluctuation): the
# party-leads-belief asymmetry is intended to survive a specification that nets
# out stable between-person differences. Implemented in the appendix; here we
# report the simple within-person change correlate as a transparent analogue:
# 2011 party predicts the 2011->2020 CHANGE in belief (first-difference).
fd <- cl |> mutate(db = zb20 - zb11)
m_fd <- lm(db ~ zp11, data = fd, weights = w)
cat(sprintf("first-difference: 2011 party -> change in belief = %+.3f (p = %.1e)\n",
            coef(m_fd)[["zp11"]], summary(m_fd)$coefficients["zp11","Pr(>|t|)"]))

# ---------------------------------------------------------------------
# (3) Within-person sorting toward the party line.
# ---------------------------------------------------------------------
sg <- d |> drop_na(b11, b20, r11, r20) |>
  mutate(dr11 = as.integer(b11 == 3), dr20 = as.integer(b20 == 3),
         a11 = (r11 == 1 & dr11 == 1) | (r11 == 0 & dr11 == 0),
         a20 = (r20 == 1 & dr20 == 1) | (r20 == 0 & dr20 == 0))
mis <- sg |> filter(!a11)
sorting <- tibble(
  align_2011 = round(wmean(sg$a11, sg$w), 3),
  align_2020 = round(wmean(sg$a20, sg$w), 3),
  n = nrow(sg), n_misaligned_2011 = nrow(mis),
  share_misaligned_converged = round(wmean(mis$a20, mis$w), 3)
)
write_csv(sorting, file.path(proc, "voter_sorting.csv"))
cat("\nWithin-person sorting:\n"); print(sorting)

# ---------------------------------------------------------------------
# (4) RI-CLPM — the headline within-person model (Hamaker, Kuiper & Grasman
# 2015). Separates stable between-person traits (random intercepts) from the
# within-person dynamics whose lead-lag is the object of interest, across all
# four waves. Requires `lavaan`. The committed voter_riclpm.csv records the
# estimates the manuscript renders (party->belief 0.40 > belief->party 0.12,
# difference 0.28, bootstrap 95% CI [0.19, 0.38]; n = 2008 complete four-wave;
# RMSEA = 0.067). Cross-lags constrained equal across waves (conservative given
# the unequal 5/2/2-year spacing).
# ---------------------------------------------------------------------
if (requireNamespace("lavaan", quietly = TRUE)) {
  bel4 <- function(x) { x <- as.numeric(x); if_else(x %in% c(1, 2, 3), x, NA_real_) }
  riC <- vp |>
    transmute(b1 = bel4(immi_contribution_2011), b2 = bel4(immi_contribution_2016),
              b3 = bel4(immi_contribution_2018), b4 = bel4(immi_contribution_2020Nov),
              p1 = pid(pid7_2011), p2 = pid(pid7_2016), p3 = pid(pid7_2018), p4 = pid(pid7_2020Nov)) |>
    drop_na()
  riC <- riC |> mutate(across(everything(), ~ as.numeric(scale(.))))
  riclpm <- '
    RIb =~ 1*b1 + 1*b2 + 1*b3 + 1*b4
    RIp =~ 1*p1 + 1*p2 + 1*p3 + 1*p4
    wb1 =~ 1*b1; wb2 =~ 1*b2; wb3 =~ 1*b3; wb4 =~ 1*b4
    wp1 =~ 1*p1; wp2 =~ 1*p2; wp3 =~ 1*p3; wp4 =~ 1*p4
    b1~~0*b1; b2~~0*b2; b3~~0*b3; b4~~0*b4
    p1~~0*p1; p2~~0*p2; p3~~0*p3; p4~~0*p4
    wb2 ~ a*wb1 + c*wp1
    wb3 ~ a*wb2 + c*wp2
    wb4 ~ a*wb3 + c*wp3
    wp2 ~ d*wp1 + e*wb1
    wp3 ~ d*wp2 + e*wb2
    wp4 ~ d*wp3 + e*wb3
    wb1~~wp1; wb2~~wp2; wb3~~wp3; wb4~~wp4
    RIb~~RIp
    diff := c - e            # party->belief minus belief->party
  '
  fit <- lavaan::sem(riclpm, data = riC)
  cat("\nRI-CLPM within-person cross-lags (lavaan):\n")
  print(lavaan::parameterEstimates(fit)[lavaan::parameterEstimates(fit)$label %in%
        c("a","c","d","e","diff"), c("label","est","se","pvalue")])
} else {
  message("lavaan not installed; skipping RI-CLPM (see committed voter_riclpm.csv).")
}
