# Pre-registration: The partisanization of AI-and-employment beliefs (2025–2032)

*A prospective, pre-registered test of the forward prediction in "To Trust the Time Traveller."
For deposit on OSF prior to the publication of new AI-employment partisan-split data.*

## 1. Background and the prediction

The two-regime model of belief under unverifiability predicts that a truth-apt economic
claim acquires partisan structure as the issue tribalizes (becomes organized by elite
partisan conflict), and that this partisan structure is *amplified among the most
politically sophisticated* — the signature of identity-protective cognition. The paper
documents this retrospectively for the belief that immigrants take jobs (1996–2024).

As of the 2024 baseline, the belief that artificial intelligence will reduce employment is
only weakly tribalized: the Republican–Democrat odds ratio is ≈1.70 (vs ≈3.79 for
immigration), and political sophistication does **not** yet amplify partisan sorting on it
(the party×education interaction is null-to-negative). The model predicts that **as AI
tribalizes, the AI-and-employment belief will partisanize, and sophistication will come to
amplify the sorting.** We register this prediction in advance of the data that would test it.

## 2. Hypotheses

- **H1 (partisanization).** The Republican–Democrat gap on the belief that AI will reduce
  jobs will increase between the 2024 baseline and the next measurement wave.
- **H2 (mechanism inversion).** The party×sophistication interaction on the AI belief, null
  or negative in 2024, will become positive as AI tribalizes (sophistication shifting from a
  correcting to a defending role).
- **H3 (tribalization precedes sorting).** The increase in mass partisan sorting on the AI
  belief will be preceded by an increase in elite partisan polarization on AI (measured from
  congressional/legislative speech or party-platform text), replicating the precedence result.
- **H4 (verifiability half-life, P5).** As AI deploys and its employment effects become more
  observable — that is, as the verifiability `v` of the AI-and-employment claim rises over time on
  fixed wording — the partisan gap on the claim will contract relative to its peak, even with
  tribalization still high. The AI case is the rare instance in which `v` increases *within* a claim,
  so it supplies the within-claim variation the published paper lacks, turning the half-life
  prediction from an untestable lens into a registered test. (Disconfirmation: if `v` rises
  materially while the gap does not contract, the verifiability channel is not operative.)

## 3. Design and data

- **Belief measure.** A fixed-wording survey item on AI's effect on employment (e.g., the Pew
  ATP `AIJOBS`-family item, or an equivalently worded item fielded ≥2027), held constant
  across waves.
- **Sophistication.** A behavioral political-knowledge battery (preferred), with education as
  a secondary proxy.
- **Tribalization.** Elite polarization on AI estimated from congressional speech or party
  manifestos, analogous to the Card et al. immigration measure, by year.
- **Baseline (registered now).** 2024: AI party OR ≈ 1.70; party×education interaction
  ≈ −0.35; party×knowledge ≈ not yet positive on the AI item.

## 4. Analysis plan

- **H1:** survey-weighted logistic regression of the AI belief on party, by wave; test the
  change in the Republican–Democrat marginal gap (and the party×wave interaction) for a
  positive sign. Inference reported at the wave level where the claim is about change over time.
- **H2:** the party×knowledge (and party×education) interaction on the AI belief, design-based,
  per wave; test for a shift toward positive. Robustness via a specification curve and controls
  for party×education and party×ideology, as in the published paper.
- **H3:** lead–lag correlation and a Granger-style regression of the mass partisan gap on
  lagged elite AI-polarization.
- **Decision rules.** H1/H2 supported if the relevant coefficient is positive with the
  wave-level test at α = .05; the model is **disconfirmed** if the AI gap fails to widen, or
  if sophistication continues to *correct* (negative interaction) once elite AI-polarization
  has risen materially above its 2024 level.

## 5. What would falsify the theory

If elite polarization on AI rises but the mass partisan gap does not widen, or widens only
among the *least* sophisticated, the two-regime model's account of fact capture is wrong. We
commit in advance to reporting this outcome.
