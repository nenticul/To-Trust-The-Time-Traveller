# =====================================================================
# 04_gaps.R — public-expert gap on high-CVI claims (Results Table 1)
# Requires public raw files in place (see data/README.md). Reads the
# cleaned expert long file and the public sources, computes weighted
# public agreement minus expert agreement per matched claim.
# =====================================================================
library(tidyverse)
library(haven)
library(survey)

raw <- "data/raw"; proc <- "data/processed"
igm <- read_csv(file.path(proc, "igm_long.csv"), show_col_types = FALSE)

# expert agreement = share endorsing the claim among substantive answers
expert_agree <- function(qid) {
  igm |>
    filter(question_id == qid,
           response %in% c("Strongly Agree","Agree","Disagree","Strongly Disagree")) |>
    summarise(p = mean(response %in% c("Strongly Agree","Agree"))) |>
    pull(p)
}

## AI -> unemployment (Pew W152): folk = "AI leads to fewer jobs" (AIJOBS==2)
w152 <- read_sav(file.path(raw, "pew/ATP W152.sav"))
ai_des <- svydesign(ids = ~1, weights = ~WEIGHT_W152,
  data = w152 |> filter(AIJOBS_W152 %in% c(1,2,3)) |>
    mutate(folk = as.integer(AIJOBS_W152 == 2)))
pub_ai <- coef(svymean(~folk, ai_des))[["folk"]]

## GSS trade & immigration (conceptual belief matches)
gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta"))
gss_des <- svydesign(ids = ~1, weights = ~wtssall,
  data = gss |> filter(!is.na(wtssall)))
pub_trade <- as.numeric(svymean(~I(moretrde <= 2),
  subset(gss_des, !is.na(moretrde)), na.rm = TRUE)[2])
pub_imm   <- as.numeric(svymean(~I(immjobs <= 2),
  subset(gss_des, !is.na(immjobs)), na.rm = TRUE)[2])

# NOTE: the immigration pair carries NO direct IGM expert benchmark. An earlier
# draft set it to 1 - (expert agreement that curtailing green cards reduces
# skilled-immigrant numbers) -- a non-sequitur: agreement that a policy reduces
# immigrant *numbers* says nothing about whether immigrants *take jobs*. We drop
# that inverted point estimate. The direction of the immigration claim is anchored
# instead on the National Academies' aggregate consensus (Nas 2017), which is all
# the analysis needs (the gaps are descriptive; inferential weight is on the public
# items over time). Trade and AI retain direct IGM items.
macro <- tribble(
  ~pair,                     ~CVI, ~public_agree,           ~expert_agree,
  "AI -> unemployment",        11, pub_ai,                  expert_agree("2026_05_13_ai_work_and_education_A"),
  "Trade -> job loss",         12, pub_trade,               expert_agree("2016_11_16_100_day_plan_A"),
  "Immigration -> job loss",    6, pub_imm,                 NA_real_
) |> mutate(gap = public_agree - expert_agree)

write_csv(macro, file.path(proc, "macro_gaps.csv"))
print(macro)
