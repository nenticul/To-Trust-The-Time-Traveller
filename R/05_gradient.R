# =====================================================================
# 05_gradient.R — identity effect scales with tribalization (Table 2)
# Survey-weighted logistic regressions of the folk belief on party +
# education, for three high-CVI claims ordered by tribalization.
# =====================================================================
library(tidyverse)
library(haven)
library(survey)
library(broom)

raw <- "data/raw"; proc <- "data/processed"

fit_one <- function(des) {
  m <- svyglm(folk ~ party + college, design = des, family = quasibinomial())
  tidy(m, exponentiate = TRUE, conf.int = TRUE) |>
    filter(term %in% c("partyRep","college"))
}

## Automation 2017 (Pew W27) — untribalized
w27 <- read_sav(file.path(raw, "pew/ATP W27.sav")) |> zap_labels() |>
  filter(ROBJOB4B_W27 %in% c(1,2)) |>
  transmute(folk = as.integer(ROBJOB4B_W27 == 1),
            party = factor(recode(F_PARTYSUM_FINAL, `1`="Rep",`2`="Dem",`9`=NA_character_), c("Dem","Rep")),
            college = recode(F_EDUCCAT_FINAL, `1`=1,`2`=0,`3`=0,`99`=NA_real_),
            wt = WEIGHT_W27) |> drop_na()
res_auto <- fit_one(svydesign(~1, weights = ~wt, data = w27)) |> mutate(claim = "automation_2017")

## AI 2024 (Pew W152) — untribalized
w152 <- read_sav(file.path(raw, "pew/ATP W152.sav")) |> zap_labels() |>
  filter(AIJOBS_W152 %in% c(1,2,3)) |>
  transmute(folk = as.integer(AIJOBS_W152 == 2),
            party = factor(recode(F_PARTYSUM_FINAL, `1`="Rep",`2`="Dem",`9`=NA_character_), c("Dem","Rep")),
            college = recode(F_EDUCCAT, `1`=1,`2`=0,`3`=0,`99`=NA_real_),
            wt = WEIGHT_W152) |> drop_na()
res_ai <- fit_one(svydesign(~1, weights = ~wt, data = w152)) |> mutate(claim = "ai_2024")

## Immigration 2022-24 (GSS immjobs; the item is fielded in 2022 and 2024, not 2021) — tribalized
gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  filter(year >= 2022, !is.na(immjobs), !is.na(partyid)) |>
  transmute(folk = as.integer(immjobs <= 2),
            party = factor(case_when(partyid <= 2 ~ "Dem", partyid >= 4 ~ "Rep", TRUE ~ NA_character_), c("Dem","Rep")),
            college = as.integer(degree >= 3),
            wt = coalesce(wtssall, wtssps)) |> drop_na()
res_imm <- fit_one(svydesign(~1, weights = ~wt, data = gss)) |> mutate(claim = "immigration_2022_24")

gradient <- bind_rows(res_auto, res_ai, res_imm)
write_csv(gradient, file.path(proc, "tribalization_gradient.csv"))
print(gradient)
