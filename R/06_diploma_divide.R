# =====================================================================
# 06_diploma_divide.R — across-era sorting is identity, not composition
# Decomposition by party x education x era + the pooled interaction model
# (party x era survives controlling for education x era).
# =====================================================================
library(tidyverse)
library(haven)
library(survey)
library(broom)

raw <- "data/raw"; proc <- "data/processed"

gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  filter(!is.na(immjobs), !is.na(partyid)) |>
  transmute(
    folk = as.integer(immjobs <= 2),
    party = case_when(partyid <= 2 ~ "Dem", partyid >= 4 ~ "Rep", TRUE ~ NA_character_),
    college = as.integer(degree >= 3),
    age = age,
    era = case_when(year <= 2014 ~ "pre", year >= 2021 ~ "post", TRUE ~ NA_character_),
    wt = coalesce(wtssall, wtssps)) |>
  filter(!is.na(era))

# Decomposition table (weighted means by cell)
des <- svydesign(~1, weights = ~wt, data = gss |> drop_na(folk, party, college, wt))
decomp <- svyby(~folk, ~interaction(party, college, era), des, svymean, na.rm = TRUE)
write_csv(as.data.frame(decomp), file.path(proc, "diploma_decomposition.csv"))
print(decomp)

# Pooled interaction model
d2 <- gss |> filter(party %in% c("Dem","Rep")) |>
  mutate(rep = as.integer(party == "Rep"), post = as.integer(era == "post")) |>
  drop_na(folk, rep, college, age, wt)
m <- svyglm(folk ~ rep*post + college*post + age,
            design = svydesign(~1, weights = ~wt, data = d2),
            family = quasibinomial())
tab <- tidy(m, exponentiate = TRUE, conf.int = TRUE) |>
  filter(term %in% c("rep","post","rep:post","college","college:post","post:college"))
write_csv(tab, file.path(proc, "diploma_model.csv"))
print(tab)   # rep:post = identity sorting (expect ~3.3); college:post = diploma divide (expect ~null)

# ---------------------------------------------------------------------
# FULL composition control: education is not the composition that matters most
# for immigration. Re-estimate party x era adding race, ethnicity, nativity,
# age, and region, each interacted with era. The party x era coefficient does
# not attenuate -- it is if anything larger (log-odds +0.27 -> +0.37) -- so the
# sorting is not an artifact of the parties' changing demographics. The p-value
# widens only because GSS asks nativity/ethnicity of a subsample (n falls ~1/3).
# yr is a continuous decade trend (matches R/08); race=1 white,2 black,3 other;
# born=2 foreign-born; hispanic>1 = Hispanic.
# ---------------------------------------------------------------------
comp <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  filter(year >= 1996, !is.na(immjobs), !is.na(partyid)) |>
  transmute(
    fact = as.integer(immjobs <= 2),
    rep  = case_when(partyid <= 2 ~ 0L, partyid >= 4 ~ 1L, TRUE ~ NA_integer_),
    coll = as.integer(degree >= 3),
    blk  = as.integer(race == 2), othrace = as.integer(race == 3),
    hisp = if_else(!is.na(hispanic), as.integer(hispanic > 1), NA_integer_),
    foreign = if_else(born %in% c(1, 2), as.integer(born == 2), NA_integer_),
    agez = as.numeric(scale(age)), region = region,
    yr = (year - 2014) / 10, w = coalesce(wtssall, wtssps)) |>
  drop_na(fact, rep, yr, w)
ce <- function(formula, need) {
  s <- comp |> drop_na(all_of(need))
  m <- svyglm(as.formula(formula), design = svydesign(~1, weights = ~w, data = s), family = quasibinomial())
  ct <- summary(m)$coefficients["rep:yr", ]
  tibble(party_era_logodds = round(ct[["Estimate"]], 3), p_value = signif(ct[["Pr(>|t|)"]], 2), n = nrow(s))
}
comp_tbl <- bind_rows(
  ce("fact ~ rep*yr", c("rep")) |> mutate(model = "baseline"),
  ce("fact ~ rep*yr + coll*yr", c("coll")) |> mutate(model = "+ education x era"),
  ce("fact ~ rep*yr + coll*yr + blk*yr + othrace*yr + hisp*yr + foreign*yr",
     c("coll","blk","othrace","hisp","foreign")) |> mutate(model = "+ race, ethnicity, nativity x era"),
  ce("fact ~ rep*yr + coll*yr + blk*yr + othrace*yr + hisp*yr + foreign*yr + agez*yr + factor(region)*yr",
     c("coll","blk","othrace","hisp","foreign","agez","region")) |> mutate(model = "+ age, region x era (full)")
) |> select(model, party_era_logodds, p_value, n)
write_csv(comp_tbl, file.path(proc, "composition_controls_full.csv"))
cat("\nParty x era robust to race/ethnicity/nativity/age/region x era:\n"); print(comp_tbl)
