# =====================================================================
# 13_falsification.R — the conditional law (scope test) + Table 1 descriptives
#
# (1) FALSIFICATION / SCOPE. Sophistication amplifies partisan sorting *only* where the
#     issue is tribalized. The party x education interaction on the folk belief is null at
#     low tribalization (automation), negative where education still corrects the folk error
#     (AI), and positive where the issue is tribalized (immigration). This bounds the
#     mechanism — the informed sort more only in the identity regime, not "the informed
#     polarize on everything." It is SUPPORTING / scope evidence: the education estimates
#     are individually noisy and the within-immigration amplification weakens as sorting
#     diffuses beyond graduates (see 09_mechanism); the clean primary mechanism test is the
#     ANES knowledge interaction, robust to education and ideology controls (11_robustness).
# (2) DESCRIPTIVES (Table 1): analytic N and composition by survey.
# =====================================================================
library(tidyverse)
library(haven)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

inter <- function(d) {
  d <- drop_na(d, f, rep, col, w)
  des <- svydesign(ids = ~1, weights = ~w, data = d)
  ct <- summary(svyglm(f ~ rep * col, design = des, family = quasibinomial()))$coefficients["rep:col", ]
  tibble(party_education_coef = round(ct[["Estimate"]], 3), p_value = round(ct[["Pr(>|t|)"]], 3), n = nrow(d))
}
w27 <- read_sav(file.path(raw, "pew/ATP W27.sav")) |> zap_labels() |> filter(ROBJOB4B_W27 %in% c(1, 2)) |>
  transmute(f = as.integer(ROBJOB4B_W27 == 1),
            rep = case_when(F_PARTYSUM_FINAL == 1 ~ 1, F_PARTYSUM_FINAL == 2 ~ 0, TRUE ~ NA_real_),
            col = case_when(F_EDUCCAT_FINAL == 1 ~ 1, F_EDUCCAT_FINAL %in% c(2, 3) ~ 0, TRUE ~ NA_real_),
            w = WEIGHT_W27)
w152 <- read_sav(file.path(raw, "pew/ATP W152.sav")) |> zap_labels() |> filter(AIJOBS_W152 %in% c(1, 2, 3)) |>
  transmute(f = as.integer(AIJOBS_W152 == 2),
            rep = case_when(F_PARTYSUM_FINAL == 1 ~ 1, F_PARTYSUM_FINAL == 2 ~ 0, TRUE ~ NA_real_),
            col = case_when(F_EDUCCAT == 1 ~ 1, F_EDUCCAT %in% c(2, 3) ~ 0, TRUE ~ NA_real_),
            w = WEIGHT_W152)
gimm <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |> filter(year >= 2022, !is.na(immjobs), !is.na(partyid)) |>
  transmute(f = as.integer(immjobs <= 2),
            rep = case_when(partyid <= 2 ~ 0, partyid >= 4 ~ 1, TRUE ~ NA_real_),
            col = as.integer(degree >= 3), w = coalesce(wtssall, wtssps))
fals <- bind_rows(
  inter(w27)  |> mutate(claim = "Automation (2017)",     tribalization = "low"),
  inter(w152) |> mutate(claim = "AI (2024)",             tribalization = "low-mid"),
  inter(gimm) |> mutate(claim = "Immigration (2022-24)", tribalization = "high")
) |> select(claim, tribalization, party_education_coef, p_value, n)
write_csv(fals, file.path(proc, "falsification.csv"))
print(fals)

# (2) Descriptives — % Republican among party identifiers, % college = bachelor+.
# WEIGHTED to match the table caption (Pew ATP panels skew educated unweighted; the
# unweighted W27 college share is ~53%, the weighted share ~30%, comparable to the
# other surveys). The substantive estimates throughout use these same survey weights.
desc <- function(df, rep, col, w, lab, yrs) {
  okr <- !is.na(rep) & !is.na(w); okc <- !is.na(col) & !is.na(w)
  tibble(survey = lab, years = yrs, n = nrow(df),
         pct_republican = round(weighted.mean(rep[okr] == 1, w[okr]) * 100),
         pct_college    = round(weighted.mean(col[okc],      w[okc]) * 100))
}
g2 <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  filter(!is.na(immjobs), !is.na(partyid), !is.na(coalesce(wtssall, wtssps)))
gr <- case_when(g2$partyid >= 4 ~ 1, g2$partyid <= 2 ~ 0, TRUE ~ NA_real_)
w27a  <- read_sav(file.path(raw, "pew/ATP W27.sav")) |> zap_labels() |> filter(ROBJOB4B_W27 %in% c(1, 2))
w152a <- read_sav(file.path(raw, "pew/ATP W152.sav")) |> zap_labels() |> filter(AIJOBS_W152 %in% c(1, 2, 3))
ana   <- read_csv(file.path(raw, "anes/anes_timeseries_2024_csv_20260519.csv"), show_col_types = FALSE) |>
  filter(V242228 %in% c(1, 2, 3, 4))
descr <- bind_rows(
  desc(g2, gr, as.integer(g2$degree >= 3), coalesce(g2$wtssall, g2$wtssps), "GSS (immjobs)", "1996-2024"),
  desc(w27a, case_when(w27a$F_PARTYSUM_FINAL == 1 ~ 1, w27a$F_PARTYSUM_FINAL == 2 ~ 0, TRUE ~ NA_real_),
       as.integer(w27a$F_EDUCCAT_FINAL == 1), w27a$WEIGHT_W27, "Pew ATP W27 (automation)", "2017"),
  desc(w152a, case_when(w152a$F_PARTYSUM_FINAL == 1 ~ 1, w152a$F_PARTYSUM_FINAL == 2 ~ 0, TRUE ~ NA_real_),
       as.integer(w152a$F_EDUCCAT == 1), w152a$WEIGHT_W152, "Pew ATP W152 (AI)", "2024"),
  desc(ana, as.integer(ana$V241227x %in% c(5, 6, 7)),
       as.integer(ana$V241465x %in% c(4, 5)), if_else(ana$V240107b > 0, ana$V240107b, NA_real_), "ANES 2024", "2024")
)
write_csv(descr, file.path(proc, "descriptives.csv"))
print(descr)
