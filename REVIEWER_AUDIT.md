# Adversarial reviewer audit — *To Trust the Time Traveller*

*Greatest weaknesses an APSR reviewer would raise, ranked by severity, each with a concrete
solution. Empirical claims below were checked against the raw microdata (GSS `.dta`, ANES `.csv`)
in `data/raw/`; the probe results are reported inline so the solutions are grounded, not
speculative.*

**Bottom line.** Nothing here is fatal. Two issues (W1, W2) touch the central mechanism and the
central construct and must be addressed before submission; both have solutions that make the paper
*stronger*, not weaker. Two of the fixes are already evidenced in the data and can be banked now
(the within-party decomposition, W1; the rich-control behavior test, W5).

---

## TIER 1 — touches the core claim; address before submission

### W1. The mechanism is mislabeled. The amplification is **asymmetric**, not Kahan-symmetric.

**The objection.** The paper calls the mechanism "identity-protective cognition" (Kahan), which
predicts sophistication sharpens *both* poles — informed partisans on both sides move further toward
their party's position. A referee will run the obvious decomposition: estimate the
knowledge→belief slope *separately within each party*. I ran it on ANES 2024:

| Party | Belief share by knowledge (k0→k4) | Slope on knowledge (per SD) |
|---|---|---|
| **Democrats** | .23 .15 .13 .09 **.03** | **−0.049 (p < .001)** |
| **Republicans** | .52 .50 .54 .54 **.51** | +0.009 (p = .46, null) |

The "gap widens with knowledge" is carried **entirely by Democrats**. Informed Republicans do not
move at all. This is *not* symmetric identity-protective cognition; it is asymmetric. A referee will
say the paper has mislabeled congeniality-conditional updating as IPC, and that "information makes it
worse" is overstated — information does not make Republicans worse, it makes Democrats *better*,
and the gap widens as a by-product.

**Why it bites.** It is the paper's headline mechanism. The clean Kahan story ("capacity defends
identity on both sides") is contradicted by the paper's own data.

**The solution (turns the vulnerability into a theoretical win).** Reframe the mechanism as
**asymmetric / sophistication-conditional alignment**, and show the asymmetry *falls out of the
paper's own model*. In `prior = (1−g(T))f + g(T)p(s)`: for Republicans the party line coincides with
the folk default — both say "immigrants take jobs" — so `p_Rep ≈ f`, and their belief sits at ≈ f
for every level of `s` and `T` (nothing to amplify). For Democrats `p_Dem` is anti-folk, so rising
`s` and `T` move them away from `f` toward `p_Dem`. **The asymmetry is a prediction, not an
embarrassment**: it is exactly what the model implies when one party's identity prior happens to
coincide with the folk prior. Concretely:

- Add the within-party decomposition as an exhibit (table above) — transparency disarms the referee.
- Relabel: the mechanism is asymmetric motivated reasoning. Keep Kahan as *one* input but add
  **Taber & Lodge (2006)** — sophistication increases *disconfirmation bias*, and it can be
  one-sided — and the directional-vs-accuracy-motivation framing (**Druckman**). Cite the
  congeniality literature.
- State the implication crisply: *sophistication amplifies enactment of the identity prior; where
  that prior coincides with folk intuition (the in-group here), there is nothing to amplify, so the
  observable amplification is borne by the out-group converging on the experts.* This also explains
  the 98%-one-sided convergence (§6) with the **same** mechanism — currently those two results
  (asymmetric convergence; knowledge amplification) are presented separately; the model unifies them.

**Status: implementable now.** Decomposition computed; needs a table + ~2 paragraphs of reframing +
2 citations (Taber & Lodge 2006; a Druckman piece).

---

### W2. Construct validity of "the fact." *Immigrants take jobs* is not cleanly false, and the 3% benchmark is repurposed.

**The objection.** Two prongs. (a) The labor economics is genuinely contested — Borjas vs Card has
run for thirty years over whether low-skill immigration depresses native wages/employment in
affected local markets. "The fact the experts reject" overstates a real disagreement. (b) The 3%
benchmark is not a measurement: it is `1 − (panel agreement)` on a *different* question — about
green-card/skilled-immigrant *numbers* (CVI 6, the lowest of the three, visible in `tbl-gaps`). The
panel was never asked "do immigrants take jobs from natives." A labor or political-economy referee
will flag both.

**Why it bites.** The normative payload — "one party converged on the **truth**" — depends on the
benchmark being true. If the claim is merely *contested*, the story degrades to "one party adopted
the credentialed-class consensus," which is deference / cosmopolitan-class signaling, not
truth-tracking. Different, weaker paper.

**The solution.**
- **Anchor the benchmark in the authoritative consensus document**, not one repurposed IGM item:
  the **National Academies (2017)**, *The Economic and Fiscal Consequences of Immigration* (Blau &
  Mackie, eds.), which finds little-to-no effect of immigration on aggregate native employment and
  wages over the long run — supplemented by the IGM/Clark Center immigration-and-wages polls. Ground
  "≈3%" in *multiple* expert sources.
- **Distinguish aggregate from distributional claims.** Consensus is strong on the *aggregate*
  (immigrants do not reduce native employment on net); it is weaker on *distributional* effects (some
  low-skill natives, some local markets). The public item — "take jobs away from people born in
  America" — maps to the aggregate, where the benchmark is solid. Say this explicitly; it shows the
  referee you know the literature and pre-empts the Borjas cite.
- **Soften "truth" → "consensus" throughout**, and add one sentence conceding the distributional
  debate. The phenomenon (a truth-apt claim acquiring partisan structure, asymmetrically, with
  sophistication) does **not** depend on the benchmark being capital-T True — the expert benchmark
  fixes the *direction* (who moved toward whom), which is what makes the asymmetry interpretable.
  Make that logic explicit so the contribution is robust even to a referee who thinks the claim is
  "contested" rather than "false."

**Status: implementable now** (prose + 3–4 bib entries: NAS 2017; Borjas; Card; an IGM immigration
poll). No re-estimation required.

---

## TIER 2 — serious; referees will demand a response

### W3. The headline *dynamic* rests on a single issue (immigration).

**The objection.** The over-time capture is n = 1 issue. The automation/AI/immigration gradient is
*cross-sectional*, and those three claims differ in many ways besides tribalization.

**What the data allow.** I checked for a second GSS time series: `moretrde` (trade → fewer US jobs)
appears in **2008 only** — so the paper's statement that the trade analog "is not estimable" is
correct; there is no second fixed-wording fact series in the GSS.

**The solution.** (i) Reframe the package honestly: *one fully-observed trajectory + a
cross-sectional gradient across three issues + a registered prospective case* is the generality
claim, pitched at the level of the **mechanism**, not a second time series. (ii) Bring **external
published evidence** that other economic facts partisanize, as corroboration without re-estimation:
the post-2016 reversal of Republican trade attitudes; partisan economic *perceptions* under
co-partisan presidents (**Bartels 2002; Gerber & Huber 2010**). (iii) Make the **AI prospective
test** (already pre-registered) the explicit out-of-sample replication — its whole point is to
answer this objection in advance. Lead the limitations with this and the referee has nowhere to go.

**Status:** prose + 2 citations.

### W4. Verifiability (`v`) and tribalization (`T`) are confounded; the `v`-channel is not identified.

**The objection.** Every studied claim is low-`v`; the immigration claim is also high-`T`. You never
vary `v` independently, so P1/P5 (the verifiability comparative statics) are asserted, not
identified. The title foregrounds verifiability, but the empirics identify the `T` channel.

**The solution.** (i) State plainly that the paper identifies the **`T` comparative statics**
(P2–P4, P6); `v` enters as a **scope condition** certified qualitatively by the CVI, not as an
estimated moderator (P5 is openly untested). Reposition `v` as *the reason a vacuum exists for the
prior to fill* — a premise, not a regressor. (ii) **Innovative:** the AI case supplies a rare
within-claim `v` experiment over time — as AI actually deploys, its employment effects become *more*
verifiable, so `v` rises on a fixed claim. Fold a within-AI verifiability test into the
pre-registration: P5 becomes a *registered* prediction rather than an untestable one.

**Status:** theory/prose framing + one addition to `preregistration.md`.

### W5. Expressive responding — the observational defense is the *weak* version.

**The objection.** Predicting vote "net of 3-category party" does not exclude expressive responding,
because a coarse party control leaves identity largely unmodeled; the fact-belief and the vote can
both be expressive proxies for the same identity.

**What the data show (a win).** I re-ran the behavior test with progressively richer identity
controls:

| Control set | Fact → Trump-vote OR | p |
|---|---|---|
| 3-cat party (paper's spec) | 7.86 | 3×10⁻²⁷ |
| 7-pt PID (continuous) | 5.95 | 3×10⁻²⁵ |
| 7-pt PID + 7-pt ideology | 6.17 | 3×10⁻²² |
| 7-pt PID + ideology + knowledge | **5.88** | **4×10⁻²¹** |

The belief still predicts vote at OR ≈ 6 net of a *rich* identity battery. This is much harder to
dismiss as cheerleading than the 3-category version.

**The solution.** Replace/supplement `tbl-behavior` with the richer-control ladder above; it
substantially hardens the anti-expressive case while still conceding that the incentivized
experiment (Appendix E) is the decisive test.

**Status: implementable now** — numbers in hand; needs a script tweak + table.

---

## TIER 3 — methodological hardening (cheap, high credibility-per-word)

### W6. The precedence/Granger result is underpowered (11 obs) and "Granger" overclaims.
**Solution.** Supplement the asymptotic Granger *p* with an **exact permutation / randomization-
inference test** suited to a tiny, autocorrelated series: block-shuffle the elite series, recompute
the lead–lag statistic, and report the rank-based *p* against the null distribution. This is the
statistically correct move at n = 11 and pre-empts "your asymptotics are invalid." Keep the
"temporal ordering, not causation" framing.

### W7. The capstone trend is n = 5 aggregate points (r = .92, p = .03).
**Solution.** Add the rigorous middle path between the n = 5 test and the (rejected) 10⁻²⁶
individual *p*: an individual-level party×year interaction with inference by **wild cluster
bootstrap clustered on survey-year**, using **Webb six-point weights** (the recommended few-cluster
method). Report it as corroboration; it uses the individual data while respecting that the survey-
year is the unit of replication.

### W8. The theory is a heuristic framework, not a micro-founded model.
**The objection.** The convex-combination form and the comparative statics are *asserted*; there is
no objective function or equilibrium. A formal-theory referee will call it a vehicle dressed as a
model. **Solution — micro-found it** (derivation in the appendix below): a citizen choosing a stated
belief to minimize a loss that trades off accuracy against identity-congruence yields the convex
combination *as a result*, makes `w(v)` an accuracy weight that vanishes as evidence becomes
uninformative, and — critically — produces both the amplification (P6) **and the W1 asymmetry** as
consequences rather than assumptions. This upgrades the theory section from description to model.

### W9. "Exogenous" tribalization may be endogenous (elites respond to anticipated opinion).
**Solution.** Soften "exogenous" → "predetermined / not mechanically downstream of the mass belief,"
concede mutual constitution, and add a robustness check with a second elite measure (immigration
roll-call polarization from DW-NOMINATE, or party-platform immigration text) to show the precedence
pattern is not an artifact of the speech-tone measure.

### W10. GSS `immjobs` split-ballot / subsample comparability across the five waves.
**Solution.** The earlier "fusion" artifact proved ballot structure matters here. Add a short
appendix note documenting, per wave, that `immjobs` was asked of comparable random subsamples, with
effective N and design effects, closing the door on a sampling-composition reading of the trend.

---

## Priority summary

| # | Weakness | Severity | Solution | Can do now? |
|---|---|---|---|---|
| W1 | Mechanism is asymmetric, not symmetric IPC | **Existential** | Reframe + decomposition table; show asymmetry falls out of the model | **Yes** (data in hand) |
| W2 | "Fact" not cleanly false; benchmark repurposed | **Existential** | Anchor in NAS 2017 + IGM; aggregate vs distributional; "consensus" not "truth" | Yes (prose + cites) |
| W3 | Dynamic rests on one issue | Serious | Mechanism-level generality + external cites + AI prospective | Yes (prose + cites) |
| W4 | `v`/`T` confounded; `v` unidentified | Serious | `v` as scope condition; within-AI `v` test in pre-reg | Yes |
| W5 | Expressive-responding defense too weak | Serious | Rich-control behavior ladder (OR≈6 net of 7-pt PID+ideo) | **Yes** (data in hand) |
| W6 | Precedence underpowered | Hardening | Exact permutation test | Yes |
| W7 | Capstone n = 5 | Hardening | Wild cluster bootstrap (Webb weights) | Yes |
| W8 | Theory not micro-founded | Hardening | Loss-function derivation (below) | Yes |
| W9 | Tribalization endogeneity | Hardening | Reword + DW-NOMINATE robustness | Yes |
| W10 | Ballot comparability | Minor | Documentation appendix | Yes |

The two banked empirical wins (W1 decomposition; W5 rich-control behavior) should go in regardless —
they pre-empt the two probes a referee is most likely to run, and both come out in the paper's favor
once stated honestly.

---

## Appendix — a micro-foundation for the two-regime model (solution to W8, unifies W1)

Let a citizen choose a stated belief `b ∈ [0,1]` to minimize a loss that trades off **accuracy**
against **identity-congruence**:

  L(b) = α·(b − τ)² + (1 − α)·(b − pₛ)²

where `τ = E[evidence | information]` is the accuracy target (≈ the expert consensus when evidence is
informative), `pₛ` is the party's position as perceived and enacted at sophistication `s`, and
`α ∈ [0,1]` is the weight on accuracy. The first-order condition gives

  **b\* = α·τ + (1 − α)·pₛ**,

the convex-combination form — now *derived*, with `w(v) ≡ α`.

Close the model with three structural assumptions:

1. **α = α(v), α′ > 0, α(0) = 0.** When a claim is unverifiable, the evidence signal is uninformative,
   so the accuracy weight vanishes and `b\* → pₛ` (belief = prior). → **P1**.
2. **pₛ = (1 − g(T))·f + g(T)·π(s),** with `g′(T) > 0, g(0) = 0`: at low tribalization the relevant
   "party position" is undifferentiated and equals the folk default `f`; as `T` rises, a party-
   specific position `π(s)` separates out. → folk regime (no gap at low `T`) and **P3** (gap grows
   with `T`).
3. **Sophistication sharpens enactment:** `∂π/∂s` moves `π(s)` toward the party's pole, and (in the
   unverifiable regime) `s` does **not** raise `α`. The partisan gap is
   `gap = (1 − α)·g(T)·|π_R(s) − π_D(s)|`, so **∂gap/∂s > 0 at high T** and ≈ 0 at low `T`. → **P6**
   and its conditional (falsification) form.

**The W1 asymmetry is now a theorem, not a patch.** Suppose the in-party's pole coincides with the
folk default, `π_R(s) ≈ f`, while the out-party's departs from it, `π_D(s) < f`. Then Republicans
sit at `b ≈ f` for all `s` and `T` (no amplification), while Democrats move from `f` toward `π_D` as
`s` and `T` rise. The amplification is borne entirely by the out-group — which is exactly the ANES
pattern (Dem slope −0.049, p < .001; Rep slope +0.009, p = .46). The same structure generates the
98%-one-sided convergence in §6. One mechanism, both results.

This also clarifies the normative reading (W2): the model never requires `τ` to be *true*, only that
the expert benchmark fixes its *location*. What the data identify is that one party's stated belief
tracks `τ` increasingly with capacity while the other's tracks `f` — capture of a truth-apt claim by
identity, whatever the ultimate truth-value of the claim.
