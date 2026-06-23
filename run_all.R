# =====================================================================
# run_all.R — reproduce the full pipeline end to end.
# Usage:  Rscript run_all.R   (from the repo root)
# Prereqs: place restricted raw data per data/README.md, then run setup.R
#          once to install/restore packages via renv.
# =====================================================================
set.seed(20260616)   # fixed seed for reproducibility

scripts <- c(
  "R/01_clean_igm.R",      # expert panel -> data/processed/igm_long.csv
  "R/02_clean_public.R",   # public sources -> gaps + micro model
  "R/03_cvi.R",            # verification check
  "R/04_gaps.R",           # Table 1: public-expert gaps
  "R/05_gradient.R",       # Table 2: tribalization gradient
  "R/06_diploma_divide.R", # diploma-divide control
  "R/07_precedence.R",     # elite-leads-public precedence
  "R/08_fusion.R",         # CAPSTONE: the partisanization of a fact
  "R/09_mechanism.R",      # mechanism: identity-protective cognition + asymmetric convergence
  "R/10_anes_knowledge.R", # cross-survey confirm: gap widens with political knowledge (ANES 2024)
  "R/11_robustness.R",     # multiverse (spec curve) + heterogeneity by strength/age
  "R/12_convergence.R",    # fact converges on preference; + behavior test (anti-expressive)
  "R/13_falsification.R",  # conditional law (sophistication amplifies only in identity regime) + descriptives
  "R/14_benchmark.R",      # context: the immigration fact is now as party-sorted as value cleavages
  "R/15_evolution.R",      # generality: the same asymmetric capture on a scientific fact (evolution)
  "R/16_ces.R",            # mechanism at scale: CES n~38k confirms the asymmetric amplification
  "R/17_voter_panel.R",    # WITHIN-PERSON capture: VOTER panel 2011-2020 + cross-lagged direction
  "R/18_cdf_replication.R",# OUT-OF-SAMPLE: knowledge x party on the fact replicates in ANES 2008/2012/2016
  "R/19_content_neutrality.R", # CONTENT-NEUTRALITY: trade's folk-default party flips D->R (Republicans-as-out-group pre-2016)
  "R/20_issp_crossnational.R", # SCOPE: cross-national ISSP 2013 — capture follows elite issue-supply, not party-system size
  "R/21_structural_signature.R", # STRUCTURE: gap and sophistication premium both scale with elite tribalization (g(T) form)
  "R/99_figures.R"         # figures
)

for (s in scripts) {
  message("\n==== running ", s, " ====")
  tryCatch(source(s, echo = FALSE),
           error = function(e) message("  ! ", s, " failed: ", conditionMessage(e),
                                       "\n  (check raw data placement per data/README.md)"))
}
message("\nDone. Outputs in data/processed/ and output/figures/.")
