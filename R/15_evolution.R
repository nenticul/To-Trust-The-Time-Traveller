# =====================================================================
# 15_evolution.R — generality beyond economics (and beyond immigration).
# The same machinery — asymmetric capture of a truth-apt, unverifiable,
# elite-contested fact, amplified by sophistication — operates on a fact
# from a different domain entirely: whether human beings evolved from
# earlier species (GSS `evolved`, science module, 2006-2018). The scientific
# consensus is near-universal; the folk default is disbelief.
#   (1) the Rep-Dem gap in DISBELIEF grows from +14 (2006) to +24 (2018),
#       driven by Democrats converging on the scientific consensus while
#       Republicans anchor at the creationist default;
#   (2) the party x education interaction is positive and significant
#       (education corrects both parties, ~2x more among Democrats).
# =====================================================================
library(tidyverse)
library(haven)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  filter(evolved %in% c(1, 2), !is.na(partyid)) |>
  transmute(year,
            disbelieve = as.integer(evolved == 2),   # reject the scientific fact
            rep = case_when(partyid <= 2 ~ 0L, partyid >= 4 ~ 1L, TRUE ~ NA_integer_),
            college = as.integer(degree >= 3),
            attend = if_else(between(attend, 0, 8), attend, NA_real_),       # church attendance
            fund   = if_else(between(fund, 1, 3), fund, NA_real_),           # biblical literalism
            w = coalesce(wtssall, wtssps)) |>
  drop_na(disbelieve, rep, w)

# (1) partisan gap in disbelief, by year
gap <- gss |>
  group_by(year, rep) |>
  summarise(share = weighted.mean(disbelieve, w), .groups = "drop") |>
  pivot_wider(names_from = rep, values_from = share, names_prefix = "p") |>
  transmute(year, dem_share = p0, rep_share = p1, gap = p1 - p0) |>
  arrange(year)
write_csv(gap, file.path(proc, "evolution_partisan_gap.csv"))
print(gap)

# (2) party x education interaction, WITH AND WITHOUT religiosity controls.
# The interaction is positive without controls but does NOT survive religiosity:
# disbelief in evolution is structured by religiosity, itself party-correlated, so
# the sophistication signature on evolution is largely a religiosity story. We report
# evolution for the partisan CAPTURE (gap grows over time), not as clean sophistication
# evidence -- the clean sophistication test is the immigration knowledge result (R/11).
di  <- gss |> drop_na(college)
m0  <- svyglm(disbelieve ~ rep * college + factor(year),
              design = svydesign(ids = ~1, weights = ~w, data = di), family = quasibinomial())
dr  <- gss |> drop_na(college, attend, fund)
m1  <- svyglm(disbelieve ~ rep * college + rep * attend + rep * fund + factor(year),
              design = svydesign(ids = ~1, weights = ~w, data = dr), family = quasibinomial())
cat(sprintf("\nparty x education on disbelief: %+.3f (no controls) -> %+.3f (+ religiosity, p=%.2f)\n",
            coef(m0)[["rep:college"]], coef(m1)[["rep:college"]],
            summary(m1)$coefficients["rep:college", "Pr(>|t|)"]))
