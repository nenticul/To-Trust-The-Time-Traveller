# To Trust the Time Traveller
### Unverifiable beliefs, expert consensus, and the partisan sorting of economic knowledge

*Polished prose draft. Citations use `@key` (resolve against `references.bib`); exhibit
references use the `.qmd` labels (`@fig-convergence`, `@tbl-anes`, …). Drop sections into
`paper/time_traveller.qmd` above the corresponding code chunks.*

---

## Abstract

The citizens best equipped to evaluate a factual claim are, on contested economic questions, the ones who divide along party lines the most. We document this on claims the public cannot verify — where the truth is distant in time, diffuse in cause, and unobservable from one's own life, like a traveller's report from a future no one can visit. Holding a survey item's wording fixed and tracking how its partisan structure changes as the issue tribalizes (measured exogenously from a century of congressional speech), we show that a truth-apt belief — that immigrants take jobs — acquires a partisan signature it did not have: the Republican–Democrat gap rises from essentially zero in 1996 to thirty-three points in 2024, driven almost entirely by the out-group converging on the expert consensus. By 2024 the *fact* sorts by party nearly as strongly as the matched policy *preference* it accompanies, a belief migrating into the partisan structure of a taste. The sorting is sharpest among the most politically knowledgeable, and the belief predicts vote choice net of party — the signature of identity-protective cognition rather than ignorance, and of conviction rather than cheerleading. We call this the Time-Traveller's Problem: when a claim cannot be checked, belief tracks the identity of its source, and a fact becomes a preference.

## 1. Introduction

Imagine a stranger claims to be a time traveller. You cannot inspect the future they describe; no evidence you could gather would settle the matter. Whether you believe them turns not on the content of their report but on who they are and whether you trust their kind. Much of what citizens are asked to believe about the economy has this structure. Will artificial intelligence raise unemployment? Did a protectionist trade agenda help the middle class? Do immigrants take jobs from the native-born? These are truth-apt claims — they have answers — but answers the ordinary citizen cannot check, because the relevant counterfactual is unobservable, the causes are diffuse, and the verdict arrives, if at all, only after years. On such claims the citizen, like the listener to the time traveller, falls back on a prior.

This paper is about which prior fills the vacuum, and what happens when the answer changes. We argue that economic beliefs under unverifiability are governed by two regimes. Where an issue is not politically contested, the fallback is folk-economic intuition — a shared, anti-market bias that more education corrects [@caplan2007myth; @boyer2018folk]. Where an issue is contested, the fallback is partisan identity, and the belief sorts by party. The empirical heart of the paper is what this substitution looks like when it happens to a single belief over time.

Our anchor is the disagreement between the American public and professional economists, which is largest precisely on the claims economists are surest of [@sapienza2013economic; @johnston2016economists; @gordon2013views]. On unverifiable, high-salience claims the public-expert gap is enormous (@tbl-gaps). But the gap is not uniform ignorance. It is *sorted*: as an issue tribalizes, the partisan structure of the belief changes, and it changes asymmetrically — the party for whom the expert position is congenial converges on the experts, while the other does not (@fig-partisanization).

Three findings make this more than a redescription of polarization. First, a factual belief comes to sort like a preference: the partisan gap on "immigrants take jobs" rises from roughly nine percent of the gap on the matched immigration-policy preference in 2004 to roughly seventy-two percent by 2024 (@fig-convergence). A truth-apt claim migrates into the partisan structure that a taste already had. Second, the sorting is concentrated among the *most sophisticated*. In a second survey with a behavioral knowledge measure, the partisan gap on the belief *widens* with political knowledge (@fig-anes) — the opposite of what an information-deficit account predicts, and the signature of identity-protective cognition [@kahan2012polarizing; @kahan2013ideology]. Third, the belief is not mere survey expression: it predicts presidential vote and border-wall support net of party identification (@tbl-behavior), carrying political weight that cheerleading on a single item would not.

Our contribution is theoretical as much as empirical. Issue evolution [@carmines1989issue] established that elite conflict reorganizes mass *preferences*, and we confirm its central dynamic — elites polarized roughly a decade before the public sorted (@fig-precedence). But issue evolution is silent on two things this paper explains. It does not say that truth-apt *facts*, not only preferences, are reorganized; and it offers no reason that *sophistication should accelerate* the reorganization. The Time-Traveller's Problem supplies both: when evidence cannot bind, capacity is recruited to defend identity rather than to track truth, so the citizens able to evaluate the claim are the ones who sort most.

The scope of the argument is deliberately narrow. It concerns truth-apt, low-verifiability, politically contested economic beliefs. It is not a theory of all attitudes, nor of verifiable facts, nor of pure preferences. Within that scope, it makes a forward prediction the data have not yet been able to test: AI-and-employment beliefs, currently weakly tribalized, will partisanize as the issue tribalizes — the next fact to sort. The remainder of the paper develops the two-regime model (§3), the design (§4–5), the evidence (§6), and the mechanism (§7), before turning to what it means for how — and whether — citizens can be convinced of things they cannot check (§8).

## 2. Related literature

The paper sits at the intersection of five literatures and claims the seam none of them fills.

**Public–expert economic disagreement.** That ordinary Americans diverge sharply from economists is well documented [@sapienza2013economic; @johnston2016economists; @gordon2013views], as is the structure of consensus within the profession [@vangunten2016consensus]. This work establishes the gap; it does not study how the gap's *partisan* structure changes over time on a fixed claim.

**Folk economics.** Caplan's account of systematically biased economic beliefs [@caplan2002systematically; @caplan2007myth] and the evolutionary-cognitive model of folk-economic intuition [@boyer2018folk] explain why the public is biased in a shared direction. They do not explain why, on some claims, the bias *sorts by party* — why the bias is shared on automation but partisan on immigration.

**Partisan sorting and issue evolution.** Carmines and Stimson's issue evolution [@carmines1989issue], the partisan sort [@levendusky2009partisan], and conflict extension [@layman2002party] describe how elite conflict reorganizes mass preferences. We concede this lineage explicitly and locate our precedence result within it. The seam is that this literature concerns *preferences*; we show the same machinery operating on *truth-apt beliefs*, and we identify a moderator — sophistication — it does not predict.

**Party cues and motivated reasoning.** That party shapes belief is established [@cohen2003party; @lenz2012follow; @barber2019party], and identity-protective cognition [@kahan2013ideology; @kahan2012polarizing] supplies our mechanism. Our addition is to show this mechanism operating on *economic facts under unverifiability*, and to use the sophistication signature to distinguish it cleanly from an information deficit.

**Belief revision toward experts.** Work on how mechanism-explanation moves people toward expert opinion [@meyers2020inducing; @meyers2023broad] and how citizens reason about economic policy [@stantcheva2021understanding] frames the paper's normative payoff: when, and how, can unverifiable truths be conveyed across the partisan filter.

The contribution's address is the conjunction these literatures leave empty: truth-apt economic beliefs, under unverifiability, sorting by party as a preference does, *accelerated by the very capacity that should correct them*. Even the classic null — that mass publics lack the ideological constraint to organize beliefs at all [@converse1964nature] — is complicated by a fact that comes to be organized by party with the tightness of a taste.

## 3. Theory: belief under unverifiability

Consider a citizen evaluating a truth-apt economic claim *C* with verifiability *v* ∈ [0,1], where *v* indexes how readily the claim's truth could, in principle, be checked from ordinary experience (low when the lag is long, the counterfactual unobservable, and the causes diffuse). Stated belief is a weighted average of available evidence and a prior, with the weight on evidence increasing in *v*: as *v* → 0, the evidence term vanishes and belief is the prior.

The theory's content is in *which* prior. We posit two: a folk-economic prior *f*, shared across the population and corrigible by education, and an identity prior *p*, the position of one's party. Which prior fills the vacuum is governed by the issue's tribalization *T* — the degree to which it has been organized by elite partisan conflict. The model yields five predictions.

- **P1 (the gap).** As *v* → 0, belief detaches from evidence, producing large public-expert gaps on high-verifiability-cost claims (@tbl-gaps).
- **P2 (folk regime, low *T*).** Where *T* is low, divergence from experts is universal and education-corrigible: the folk prior dominates and party is irrelevant (@tbl-micro).
- **P3 (identity regime, high *T*).** Where *T* is high, party predicts divergence, and the movement is asymmetric — the out-group converges on the experts (@tbl-gradient, @fig-partisanization).
- **P4 (capture).** As *T* rises on a fixed claim, the fact acquires partisan loading and comes to sort like the matched preference (@fig-convergence).
- **P5 (verifiability half-life).** As *v* rises — a claim becoming checkable — the partisan gap should shrink. We state this prediction but do not identify it: the studied claims lack within-claim variation in *v*, so the verifiability index serves to certify that the claims are genuinely unverifiable, not as a moderator (Appendix A).

The theory's signature, and what distinguishes it from issue evolution and from a pure information-deficit account, is a prediction about *sophistication*. If, under unverifiability, capacity is recruited to defend identity rather than to track evidence, then the identity regime should be *strongest among the most sophisticated* — the gap on a contested fact should widen, not narrow, with knowledge. An information-deficit account makes the opposite prediction. This is the comparative static the model earns its place by making, and §7 tests it.

## 4. Data

The argument requires an expert benchmark, public belief on matched claims over time, and an exogenous measure of tribalization.

**Expert benchmark.** The Kent A. Clark Center US Economic Experts Panel provides repeated, named-respondent surveys of leading economists on precisely worded claims [@igm_eep]. We reshape these into one record per economist per sub-question (753 records; `R/01`), collapsing the Likert responses to agree / not-agree to match the coarser public items.

**Public microdata.** We use the General Social Survey 1972–2024 cumulative file [@gss_2024], the Pew American Trends Panel waves on automation (2017) and AI (2024) [@pew_atp], and the 2024 American National Election Studies [@anes_2024]. Full variable coding and the verbatim matched-pair wordings appear in Appendix D; we note there, candidly, that the public-expert pairs are *conceptual* matches and that the inferential weight rests on the over-time and individual-level analyses of the public items themselves.

**Tribalization.** We measure tribalization exogenously from the Card et al. corpus of 140 years of congressional immigration speech [@card2022immigration; @card2022data], taking the Democrat-Republican gap in pro-immigration tone, smoothed, as the elite-polarization series.

## 5. Methods and identification

**Design.** The core design holds a single survey item's wording fixed and treats the change in its partisan structure across eras as the object of study, with tribalization measured outside the survey. This rules out the item-wording confounds that plague cross-issue comparison: when the same words sort differently in 2004 and 2024, the words are not the explanation.

**Estimation.** All estimates use survey-weighted logistic regression with design-based standard errors [@lumley2004analysis]; each survey is analyzed with its own native weights, and no weight is pooled across surveys. The precedence analysis uses lead-lag correlations and a Granger-style regression.

**Inference discipline.** We adopt one rule and state it plainly, because it governs how the headline claims are reported: for a claim about change *over time*, the relevant unit is the survey-year, not the individual. The capstone trend is therefore reported as a regression across the five survey-years (*r* = .92, *p* = .03), and the individual-level interaction is reported as corroboration robust to weighting; a naive individual-level *p*-value of order 10⁻²⁶ would treat 6,457 respondents as independent draws across five surveys and is not the basis of any claim.

**What the design can and cannot do.** The design is observational. It can establish that a fixed factual claim acquired partisan structure, that the structure emerged first among the sophisticated, and that the belief predicts behavior. It cannot, from repeated cross-sections, adjudicate whether the fact drives the preference or the preference the fact; we show their stable coupling and the fact's independent partisan trajectory, but we claim no causal direction between them. And it cannot identify the verifiability gate (P5) or separate sincere belief from expressive report with finality — the clean test of the latter is experimental and is set out, pre-registered, in Appendix E.

## 6. Results

We walk the evidence in the order that builds the argument.

**The gap exists (P1).** On high-verifiability-cost claims the public-expert gap is large — forty-five points on AI, thirty-six on trade, thirty-nine on immigration (@tbl-gaps, @fig-gap). Economists essentially reject the protectionist and immigration-cost claims (zero and three percent agreement); the public does not.

**It is universal and education-corrigible where untribalized (P2).** On the least tribalized claim, divergence from the experts is general and party is weak; education, not party, predicts the folk belief (college odds ratio 0.82; @tbl-micro). This is the folk regime.

**The identity effect scales with tribalization (P3).** Across claims ordered by tribalization, the party odds ratio on the folk belief rises monotonically — 1.04 (automation, 2017), 1.70 (AI, 2024), 3.79 (immigration) — even as education corrects throughout (@tbl-gradient, @fig-gradient).

**The scaling is sorting, not composition.** On a fixed item across eras, the party-by-era interaction survives controlling for education-by-era; the education-by-era term is null (@tbl-diploma). The across-era shift is identity, not the changing educational composition of the parties.

**Elites led the public.** Elite immigration-speech polarization rose roughly a decade before the public partisan gap (lag-10 *r* = 0.92; Granger β = 0.72, *p* = .063; @fig-precedence). We claim this as confirmation of issue evolution, not as discovery.

**The fact is partisanized (P4).** The Republican-Democrat gap on "immigrants take jobs" runs from −0.03 in 1996 to +0.33 in 2024 (@tbl-fact-gap, @fig-partisanization). The widening is almost entirely one-sided: ninety-eight percent of the change is Democratic movement, and it is movement *toward* the expert benchmark (which only three percent of economists endorse). Tribalization does not pull both parties apart symmetrically; it moves the party for whom the expert position is congenial toward consensus and leaves the other.

**A fact comes to sort like a preference.** This is the paper's title made literal (@fig-convergence). The matched immigration-policy *preference* was already partisan in 2004 (gap 0.09); the *fact* was not (gap 0.01). Over the next two decades the fact's partisan gap rose to roughly seventy-two percent of the preference's, up from nine percent. The belief migrated into the partisan structure the preference already had. We are precise about the claim: this is convergence in *levels* — the fact rising toward the preference's degree of partisanship — not a claim that the fact partisanized faster (on the log-odds scale the preference's slope is, if anything, marginally steeper). And it is distinct from the fact-preference *correlation*, which was stable near 0.4 throughout (@fig-coupling): what changed is not that the two items became more correlated, but that the factual one acquired the partisan loading the preference always carried. A fact did not fuse with a preference; it *became* one, in the precise sense of acquiring its partisan signature.

## 7. Mechanism: identity, not ignorance

Is this sorting the residue of ignorance — the less informed adopting whatever their side says — or identity-protective cognition, in which the capable use their capacity to defend the in-group position? The two accounts make opposite predictions about sophistication, and the prediction discriminates them.

In the GSS, the partisan gap on the fact emerges *first* among the college-educated: by 2014 it stood at roughly twenty-one points among graduates while still near zero among non-graduates, diffusing to the whole electorate only later (@fig-mechanism). Sorting that appears first where the capacity to evaluate evidence is highest is the signature of motivated reasoning, and it mirrors the elite-to-public diffusion of the precedence result. We report this as a temporal pattern, not as a single coefficient: across few survey-years the pooled interaction is positive but imprecise.

The clean test comes from a second survey, a behavioral measure of sophistication, and many sampling units. In the 2024 ANES, the partisan gap on "immigration is likely to take jobs" *widens monotonically with political knowledge* — from thirty-four points among the least knowledgeable to forty-six among the most — and the design-based party-by-knowledge interaction is +0.51 (*p* < .001; @tbl-anes, @fig-anes). The most informed Democrats are the *most* likely to reject the folk belief; informed Republicans do not move. The result is positive and significant across all twenty-four reasonable specifications (@fig-multiverse) [@simonsohn2020specification; @steegen2016multiverse], concentrates among strong partisans, and is robust to dropping the weights (Appendix B). An information-deficit account predicts the gap should *shrink* with knowledge; it does the reverse.

Two objections remain, and we meet them. The first is that the belief is mere partisan cheerleading — expressive report, not conviction [@bullock2015partisan; @prior2015serious]. Observationally, the belief carries weight cheerleading on a single item would not: it predicts 2024 presidential vote (odds ratio 7.6) and border-wall support (odds ratio 5.5) net of party identification and knowledge (@tbl-behavior). A belief that independently predicts how people vote is difficult to dismiss as survey expression — though we are candid that this is observational, that the fact may proxy an ideological disposition the three-category party measure does not fully capture, and that the decisive test is the incentivized experiment of Appendix E. The second objection is that immigration is sui generis. It may be; our over-time evidence is single-issue, and the trade analog is not estimable in the available data. We therefore rest generality on the cross-sectional gradient and on the model's forward prediction — that AI beliefs, now weakly sorted, will partisanize as the issue tribalizes — rather than overclaiming.

## 8. Discussion

The paper's organizing claim is that economic belief under unverifiability runs in two regimes, and that an issue can move from one to the other within a generation. Where a claim is uncontested, citizens hold a shared folk-economic error that information and mechanism-explanation can move toward the experts [@meyers2020inducing; @meyers2023broad]. Where a claim is contested, the same information fails — indeed backfires among the sophisticated — and belief sorts by party against the evidence [@kahan2012polarizing; @sapienza2013economic].

This is the answer to the question in the title. How do you convince someone of a claim they cannot check? It depends which regime they are in. On an uncontested claim, supply the mechanism: explanation moves belief toward truth. On a contested one, information is the wrong tool, because the obstacle is not a deficit of knowledge but a surplus of identity; the only levers the theory implies are de-tribalization or a trusted in-group messenger who can carry an unverifiable truth across the partisan filter. We offer this last as a conjecture the theory licenses, not a finding the data establish — its test is the pre-registered experiment.

The result also refines the rationality debate. The public is not uniformly irrational in the manner of Caplan's rational irrationality [@caplan2007myth]; it is *conditionally* so, rational-as-identity-management precisely where evidence cannot bind, and most so among those best able to reason. And it cautions the civic-knowledge tradition: on contested facts, political knowledge does not purify belief, it polarizes it.

## 9. Limitations and scope

We lead with the concession. The precedence of elite over mass polarization is an instance of issue evolution and is framed as confirmation, not discovery. Verifiability is a theoretical lens, not an identified moderator; the half-life prediction (P5) is stated and untested. The design is observational, and we make no causal claim about the direction between fact and preference. The over-time partisanization is demonstrated on a single issue; the trade analog is not estimable in the available data, and so generality rests on the cross-sectional gradient and a forward prediction. The expressive-responding objection is met observationally but not experimentally. The verifiability index is single-coded; a second coder and Krippendorff's α are reported in Appendix A. Finally, the United States is a hyper-polarized two-party system; the identity term in the model should be weaker under multi-party, coalition systems, a scope condition we discuss and a comparison the data do not yet support.

## 10. Conclusion

A truth-apt belief about the economy, holding its wording fixed, came to sort by party nearly as strongly as a taste — and did so fastest among the citizens best equipped to know better. When a claim cannot be checked, belief tracks the identity of the source, not the content of the message: the Time-Traveller's Problem. The next fact to sort is, the theory predicts, already visible in the data on artificial intelligence. Whether the discipline can find ways to carry unverifiable truths across the partisan filter — through mechanism, through messenger, through de-tribalization — is the question this diagnosis leaves for the work to come.
