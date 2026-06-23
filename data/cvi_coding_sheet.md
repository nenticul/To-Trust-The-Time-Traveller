# Claim Verifiability Index — independent coding sheet (Coder 2)

Please score each claim 0–3 on each of the four dimensions, **without consulting Coder 1's
scores**. We will compute Krippendorff's α from the two independent codings (target ≥ 0.67).
The full claim wordings are in `data/raw/igm/*.csv` (the question text is the column header
of each response column).

## Rubric (anchors)

| Dimension | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| **Temporal lag** — how long until the claim's truth could be observed | resolves in < 1 yr | 1–3 yr | 3–10 yr | > 10 yr |
| **Counterfactual dependence** — does confirming it require an unobservable counterfactual | direct comparison available | weak counterfactual | strong counterfactual required | inherently unobservable |
| **Attributional diffuseness** — how many causes compete for the outcome | single clear cause | few competing causes | many competing causes | causally over-determined |
| **Personal unobservability** — could an individual verify it from own experience | verifiable from own experience | partly observable | rarely observable | never personally observable |

CVI = lag + counterfactual + diffuseness + personal (range 0–12).

## Claims to score (fill the blank columns)

| question_id | topic | lag | counterfactual | diffuseness | personal |
|---|---|---|---|---|---|
| 2012_02_07_rent_control_A | rent control & affordable housing |  |  |  |  |
| 2015_09_22_15_minimum_wage_A | $15 minimum wage (employment) |  |  |  |  |
| 2015_09_22_15_minimum_wage_B | $15 minimum wage (desirability) |  |  |  |  |
| 2016_11_16_100_day_plan_A | Trump 100-day plan (middle class) |  |  |  |  |
| 2016_11_16_100_day_plan_B | Trump 100-day plan (growth) |  |  |  |  |
| 2021_01_13_after_brexit_A | Brexit economic effect (A) |  |  |  |  |
| 2021_01_13_after_brexit_B | Brexit economic effect (B) |  |  |  |  |
| 2026_01_29_aca_subsidies_A | ACA subsidies (A) |  |  |  |  |
| 2026_01_29_aca_subsidies_B | ACA subsidies (B) |  |  |  |  |
| 2026_01_29_aca_subsidies_C | ACA subsidies (C) |  |  |  |  |
| 2026_05_13_ai_work_and_education_A | AI & unemployment |  |  |  |  |
| 2026_05_13_ai_work_and_education_B | AI & work (B) |  |  |  |  |
| 2026_05_13_ai_work_and_education_C | AI & education (C) |  |  |  |  |
| 2026_05_22_america_versus_europe_A | US vs Europe living standards (A) |  |  |  |  |
| 2026_05_22_america_versus_europe_B | US vs Europe living standards (B) |  |  |  |  |
| 2026_06_03_permanent_residency_rules_A | green-card rules & skilled immigration |  |  |  |  |
| 2026_06_03_permanent_residency_rules_B | green-card rules (B) |  |  |  |  |

*After Coder 2 completes this sheet, enter the scores in `R/03_cvi.R` as a second coder block
and compute Krippendorff's α with `irr::kripp.alpha()`; report α in Appendix A.*
