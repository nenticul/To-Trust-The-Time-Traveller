# =====================================================================
# 02_clean_public.R
# Build public-opinion net-agreement for each matched pair, join to the
# expert measures, compute the public-expert gap (MACRO arm), and run the
# individual-level divergence model on the AI pair (MICRO arm = Gate 1 core).
#
# WHY this structure: the macro arm is descriptive context (few pairs); the
# inferential weight sits in the micro arm, where one Pew wave gives ~4,000
# weighted respondents with party ID and education to test WHO diverges from
# the expert consensus and why.
# =====================================================================

library(tidyverse)
library(haven)      # read .sav / .dta, preserves labels
library(survey)     # design-based estimation with survey weights
library(broom)

raw <- "data/raw"; proc <- "data/processed"

# Expert side: share of the panel agreeing with a claim (Likert collapsed to
# agree / not-agree; Uncertain & non-responses excluded). WHY collapse: the
# public items are coarse (agree / disagree), so we match granularity.
igm <- read_csv(file.path(proc, "igm_long.csv"))
expert_agree <- function(qid) {
  igm |>
    filter(question_id == qid,
           response %in% c("Strongly Agree","Agree","Disagree","Strongly Disagree")) |>
    summarise(p = mean(response %in% c("Strongly Agree","Agree"))) |>
    pull(p)
}

# ---------------------------------------------------------------------
# MACRO ARM — one row per matched pair
# Each "folk claim" is framed so that public agreement and expert agreement
# point the same way; gap = public_agree - expert_agree.
# ---------------------------------------------------------------------

## AI -> unemployment  (Pew W152, belief-belief, strong match)
w152 <- read_sav(file.path(raw, "pew/ATP W152.sav")) |> zap_labels()  # drop SPSS value labels so recode/compare work
ai_des <- svydesign(ids = ~1, weights = ~WEIGHT_W152,
                    data = w152 |> filter(AIJOBS_W152 %in% c(1,2,3)) |>
                      mutate(folk = as.integer(AIJOBS_W152 == 2)))   # 2 = fewer jobs
pub_ai <- coef(svymean(~folk, ai_des))[["folk"]]

## GSS trade & immigration (conceptual belief matches)
gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta"))  # haven handles encoding
gss_des <- svydesign(ids = ~1, weights = ~wtssall,
                     data = gss |> filter(!is.na(wtssall)))
# moretrde: 1-2 = agree "more trade, fewer US jobs"; immjobs: 1-2 = agree "immigrants take jobs"
pub_trade <- svymean(~I(moretrde <= 2), subset(gss_des, !is.na(moretrde)), na.rm = TRUE)[2]
pub_imm   <- svymean(~I(immjobs  <= 2), subset(gss_des, !is.na(immjobs)),  na.rm = TRUE)[2]

macro <- tribble(
  ~pair,                    ~CVI, ~public_agree,            ~expert_agree,                                ~match,
  "AI -> unemployment",       11, pub_ai,                   expert_agree("2026_05_13_ai_work_and_education_A"),  "belief-belief",
  "Trade -> job loss",        12, as.numeric(pub_trade),    expert_agree("2016_11_16_100_day_plan_A"),           "conceptual",
  "Immigration -> job loss",   6, as.numeric(pub_imm),      1 - expert_agree("2026_06_03_permanent_residency_rules_A"), "conceptual"
) |> mutate(gap = public_agree - expert_agree)

write_csv(macro, file.path(proc, "macro_gaps.csv"))
print(macro)

# ---------------------------------------------------------------------
# MICRO ARM — AI pair, individual-level (Gate 1 core)
# DV: believes "AI -> fewer jobs" = diverges from expert consensus (only ~31%
# of economists agree). WHY svyglm: design-based SEs are correct under the
# Pew weights; an unweighted logit would understate uncertainty.
# ---------------------------------------------------------------------
micro <- w152 |>
  filter(AIJOBS_W152 %in% c(1,2,3)) |>
  transmute(
    diverge = as.integer(AIJOBS_W152 == 2),
    party   = factor(recode(F_PARTYSUM_FINAL, `1`="Rep", `2`="Dem", `9`=NA_character_),
                     levels = c("Dem","Rep")),
    college = recode(F_EDUCCAT, `1`=1, `2`=0, `3`=0, `99`=NA_real_),
    ideo    = recode(F_IDEO, `1`=2, `2`=1, `3`=0, `4`=-1, `5`=-2, `99`=NA_real_),
    age     = na_if(F_AGECAT, 99),
    inc     = na_if(F_INC_TIER2, 99),
    wt      = WEIGHT_W152
  ) |> drop_na()

micro_des <- svydesign(ids = ~1, weights = ~wt, data = micro)

# H2 (identity) + H3 (education) in one model; interaction tests whether
# education's corrective pull differs by party.
m_main <- svyglm(diverge ~ party + college + ideo + factor(age) + factor(inc),
                 design = micro_des, family = quasibinomial())
m_int  <- svyglm(diverge ~ party * college, design = micro_des, family = quasibinomial())

micro_tab <- tidy(m_main, exponentiate = TRUE, conf.int = TRUE) |>
  filter(term %in% c("partyRep","college","ideo")) |>
  select(term, estimate, conf.low, conf.high, p.value)
# Companion interaction (m_int): education's corrective pull is weaker among
# Republicans (partyRep:college < 1) -- the first hint of the substitution.
# Persisted so the prose estimate has a documented home in the pipeline.
int_row <- tidy(m_int, exponentiate = TRUE, conf.int = TRUE) |>
  filter(term == "partyRep:college") |>
  select(term, estimate, conf.low, conf.high, p.value)
micro_tab <- bind_rows(micro_tab, int_row)
write_csv(micro_tab, file.path(proc, "micro_model.csv"))
print(micro_tab)
