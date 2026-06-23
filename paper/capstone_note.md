# Capstone: the partisanization of a fact — methods & robustness note

*Supplementary note for the results/methods sections. All quantities reproduce from
`R/08_fusion.R` and the committed aggregates `data/processed/fact_partisan_gap.csv`
and `data/processed/fusion_coupling.csv`.*

## The claim

A truth-apt factual belief — GSS `immjobs`, "immigrants take jobs away from people
born in [country]" — acquires a partisan signature over time. The belief is coded
`fact = 1` if the respondent agrees or strongly agrees (`immjobs <= 2`). Party is the
standard three-way collapse (`partyid <= 2` Democrat, `>= 4` Republican). Estimates
use the GSS person weight (`coalesce(wtssall, wtssps)`).

## Data coverage (why the design is what it is)

`immjobs` is an ISSP/GSS item fielded in **1996, 2004, 2014, 2022, 2024**. The matched
immigration-preference items were co-administered to the *same* respondents only in
the years below — a consequence of GSS split-ballot design, which is decisive for how
the over-time analysis must be built:

| Year | `immjobs` × `letin1` (levels) | `immjobs` × `letin1a` (reduce) |
|---|---|---|
| 1996 | 1,125 | — (not fielded) |
| 2004 | 1,085 | **0 (disjoint ballots)** |
| 2014 | 1,076 | 781 |
| 2022 | — (not fielded) | 2,269 |
| 2024 | 997 | 2,154 |

## Correction to an earlier draft

An earlier version reported a cross-item correlation "rising from −0.21 (2004) to
+0.34 (2024)," read as the fact and preference *fusing* over time. That result does
not survive the data structure and is withdrawn:

1. In 2004 `immjobs` and `letin1a` were on **disjoint ballots** (zero shared
   respondents), so a within-person 2004 correlation between them is not estimable.
2. The −0.21 arose from coercing respondents who were not asked `immjobs` to
   `fact = 0` ("does not believe"); on true co-respondents no negative value exists.

Computed correctly (Result 3 below), the fact–preference coupling is **positive and
flat** across three decades. The dynamic worth reporting is therefore not the two
items converging, but the fact itself becoming partisan.

## Result 1 — the partisan gap in the fact widens (headline)

Weighted share agreeing "immigrants take jobs," by party and survey year:

| Year | Republicans | Democrats | Rep − Dem gap |
|---|---|---|---|
| 1996 | 0.46 | 0.49 | **−0.03** |
| 2004 | 0.42 | 0.41 | +0.01 |
| 2014 | 0.41 | 0.32 | +0.08 |
| 2022 | 0.34 | 0.16 | +0.18 |
| 2024 | 0.45 | 0.11 | **+0.33** |

The gap is essentially zero through the 2000s and opens monotonically thereafter,
reaching 33 points by 2024. It is driven by Democrats abandoning the belief
(0.49 → 0.11) while Republicans are roughly flat (0.46 → 0.45) — the same out-group
movement toward the expert benchmark seen on the cross-sectional exhibits.

## Inference (stated conservatively)

- **Preferred test — the over-time trend across surveys.** Regressing the partisan
  gap on year across the five survey-years: slope ≈ **+0.011/yr**, **r = 0.92**,
  **p ≈ 0.03**. The effective sample for a *trend* is the number of surveys (five),
  so this is the figure we report.
- **Individual-level confirmation.** A design-based logistic model
  (`svyglm`, `quasibinomial`) of `fact ~ party * year + college` gives a positive
  `party × year` interaction (coef ≈ **+0.054**). It is robust to dropping the
  weights (coef ≈ +0.052).
- **What we do *not* claim.** A naive frequency-weighted `glm` returns
  p ≈ 1×10⁻²⁶ for the interaction. That treats survey weights as counts and 6,457
  respondents as independent across only five surveys; it overstates precision and is
  not reported. Significance rests on the survey-year trend.

## Result 3 — fact and preference are stably coupled (secondary)

Within-year correlation between `immjobs` and the immigration-preference item, on
respondents answering **both** (no coercion):

| Year | `letin1` (levels) | `letin1a` (reduce) |
|---|---|---|
| 1996 | 0.36 | — |
| 2004 | 0.39 | — |
| 2014 | 0.34 | 0.38 |
| 2022 | — | 0.39 |
| 2024 | 0.40 | 0.44 |

Both items show a stable, moderate positive coupling (≈0.35–0.45) with no downward or
upward trend of note: the fact and the preference were fused throughout the period.

## Robustness summary

- **Weights on/off:** the interaction sign and magnitude are unchanged (≈0.054 vs 0.052).
- **Two preference operationalizations** (`letin1`, `letin1a`): both give the same
  stable-coupling conclusion; results are not an artifact of the newer item wording.
- **Missing-data handling:** all estimates use listwise-present respondents for the
  variables entering each quantity; no item is imputed or coerced to a substantive value.
- **Reproducibility:** `Rscript run_all.R` regenerates every number above; the two
  aggregate CSVs are committed so the figures rebuild without the restricted microdata.

---

# Mechanism: identity, not ignorance

*Reproduces from `R/09_mechanism.R` and `data/processed/fact_gap_by_education.csv`.*

A pure information-deficit account predicts the partisan gap on a factual belief
should be *smaller* among the educated, who are better placed to know the expert view.
Identity-protective cognition (Kahan 2012, 2013) predicts the opposite: where the issue
is identity-laden, sophistication is recruited to defend the in-group position, so the
gap should appear *first and largest* among the most sophisticated.

The data favour the identity account. Using education as the sophistication proxy, the
Republican–Democrat gap on "immigrants take jobs":

| Year | College gap | Non-college gap |
|---|---|---|
| 1996 | +0.07 | −0.05 |
| 2004 | +0.10 | −0.03 |
| 2014 | **+0.21** | +0.03 |
| 2022 | +0.11 | +0.20 |
| 2024 | +0.33 | +0.30 |

The partisan gap **emerges first among graduates** — by 2014 it is +0.21 among the
college-educated while still essentially zero among non-graduates — and only later
diffuses to the whole electorate (by 2024 both groups are near +0.30). Sorting
appearing first where the capacity to evaluate the evidence is highest is the signature
of motivated reasoning, not of an information deficit; it also mirrors the elite→public
precedence result (the sorting begins at the top and works down).

**Inference, stated conservatively.** A naive weighted logit returns a "significant"
party×education interaction (p ≈ .001), but clustering by survey-year (the appropriate unit
for an over-time pattern) gives p ≈ .28. We therefore rest the GSS claim on the *temporal
ordering* of emergence, not on a single interaction coefficient — and confirm it
directly, with proper inference, in a second survey below.

## Confirmation in ANES 2024 — knowledge, not just education

*Reproduces from `R/10_anes_knowledge.R` and `data/processed/anes_gap_by_knowledge.csv`.*

The cleanest test uses a *behavioural* measure of sophistication — a four-item
political-knowledge battery (US Senate term; lowest federal spending category;
pre-election House and Senate majorities; `V241612`–`V241615`) — in a different survey,
ANES 2024 (N = 4,402). The dependent variable is the belief that recent immigration is
"extremely" or "very" likely to "take jobs away from people already here" (`V242228`).
Estimates use the post-election design (weight `V240107b`, PSU `V240107c`, strata
`V240107d`).

| Political knowledge | Republicans | Democrats | Gap |
|---|---|---|---|
| Low (0–1 correct) | 0.51 | 0.17 | +0.34 |
| Mid (2 correct) | 0.54 | 0.13 | +0.41 |
| High (3–4 correct) | 0.53 | 0.07 | +0.46 |

The partisan gap on the factual belief **widens monotonically with knowledge**.
Republicans are flat across the knowledge range (~0.51–0.54); the movement is entirely
among Democrats, whose agreement falls from 0.17 to 0.07 as knowledge rises — the most
informed Democrats are the *most* likely to reject the folk belief. The design-based
party×knowledge interaction (knowledge standardized) is **+0.51, p < .0001** with
PSU-clustered standard errors; with many primary sampling units this is precisely
estimated, unlike the few-survey-year GSS interaction. A pure information-deficit
account predicts the gap should *shrink* with knowledge; it does the opposite — the
identity-protective-cognition signature (Kahan), now established cross-survey and
cross-measure (education in GSS, behavioural knowledge in ANES).

# Asymmetric convergence toward the experts

The widening of the partisan gap is almost entirely one-sided. From 1996 to 2024,
Democratic agreement with "immigrants take jobs" fell from 49% to 11% (−37 pts) while
Republican agreement was flat (46% → 45%, −1 pt). **98% of the gap's change is
Democratic movement** — and it is movement *toward* the expert benchmark (only ~3% of
economists endorse the claim). The in-group holding the folk belief stays put; the
out-group converges on the experts. This is the directional sharpening of the identity
regime: tribalization does not pull both parties apart symmetrically — it moves the
party for whom the expert position is congenial toward consensus, and leaves the other.

# Investigated and set aside

The "verifiability half-life" (Prediction 5) — sorting shrinking as a claim becomes
checkable — was investigated in the four available Pew ATP waves (W81, W87, W99/—,
W119). They carry the panel key (`QKEY`) but no economic *prediction* item re-asked
across waves as reality resolved (W81/W87 are COVID economic-experience and approval
items; W119 is an AI battery). The within-person half-life test is therefore not
identifiable in this data, and Prediction 5 remains theoretical. The cross-claim route
is also declined: verifiability (CVI) is confounded with tribalization across the
studied claims (immigration is *lower* CVI than AI yet sorts most), so CVI is retained
as a framing lens, not an identified moderator.
