# =====================================================================
# 14_benchmark.R — how sorted is the immigration FACT, in context?
# Places the 2024 Republican-Democrat gap on the factual belief "immigrants
# take jobs" alongside the gaps on canonical party-sorted GSS items — the
# immigration-restriction PREFERENCE and a set of moral/value cleavages
# (abortion, guns, the death penalty, gay rights). The point: a truth-apt
# economic FACT is now as party-sorted as the hot-button value issues.
# All gaps weighted; 95% CI from design-based (Kish effective-n) SEs.
# =====================================================================
library(tidyverse)
library(haven)
library(survey)

raw <- "data/raw"; proc <- "data/processed"

gss <- read_dta(file.path(raw, "gss/gss7224_r3.dta")) |>
  filter(year == 2024) |>
  mutate(rep = case_when(partyid <= 2 ~ 0L, partyid >= 4 ~ 1L, TRUE ~ NA_integer_),
         w = coalesce(wtssall, wtssps))

# item, recode to a 0/1 "agree" indicator, descriptive kind
items <- tribble(
  ~item,                              ~kind,           ~var,       ~code,
  "Immigrants take jobs (fact)",      "economic fact", "immjobs",  function(x) as.integer(x <= 2),
  "Reduce immigration (preference)",  "preference",    "letin1a",  function(x) as.integer(x >= 4),
  "Abortion for any reason",          "moral/value",   "abany",    function(x) as.integer(x == 1),
  "Favor gun permits",                "moral/value",   "gunlaw",   function(x) as.integer(x == 1),
  "Favor death penalty",              "moral/value",   "cappun",   function(x) as.integer(x == 1),
  "Homosexuality always wrong",       "moral/value",   "homosex",  function(x) as.integer(x == 1)
)

gap_one <- function(item, kind, var, code) {
  d <- gss |> filter(!is.na(.data[[var]]), .data[[var]] > 0, !is.na(rep), !is.na(w)) |>
    mutate(y = code(.data[[var]]))
  est <- svyby(~y, ~rep, svydesign(ids = ~1, weights = ~w, data = d), svymean)
  g <- est$y[est$rep == 1] - est$y[est$rep == 0]
  se <- sqrt(est$se[est$rep == 1]^2 + est$se[est$rep == 0]^2)
  tibble(item = item, kind = kind, abs_gap_pts = round(abs(g) * 100, 1),
         ci95_pts = round(1.96 * se * 100, 1))
}
bench <- pmap_dfr(items, gap_one) |> arrange(abs_gap_pts)
write_csv(bench, file.path(proc, "party_gap_benchmark.csv"))
print(bench)
