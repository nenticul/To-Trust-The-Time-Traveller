# To Trust The Time Traveller
### Unverifiable beliefs, expert consensus, and the partisan sorting of economic knowledge

Replication repository. **Central finding:** on economic claims the public cannot verify, factual beliefs sort like partisan preferences — measured against expert consensus, with the out-group converging on the experts. We watch a factual belief ("immigrants take jobs") acquire a partisan signature as the issue tribalizes: the Republican–Democrat gap on the belief widens from ~0 (1996) to +33 points (2024), driven by Democrats abandoning it, even as the belief stays tightly coupled to its matched policy preference ("reduce immigration") throughout.

## What's here

```
.
├── R/                     analysis pipeline (numbered, run in order)
│   ├── 01_clean_igm.R     expert panel -> data/processed/igm_long.csv
│   ├── 02_clean_public.R  public sources -> gaps + individual-level model
│   ├── 03_cvi.R           Claim Verifiability Index (verification check)
│   ├── 04_gaps.R          Table 1: public-expert gaps
│   ├── 05_gradient.R      Table 2: identity effect by tribalization
│   ├── 06_diploma_divide.R across-era sorting is identity, not composition
│   ├── 07_precedence.R    elites polarized before the public sorted
│   ├── 08_fusion.R        CAPSTONE: the partisanization of a fact
│   ├── 09_mechanism.R     mechanism (identity-protective cognition) + asymmetric convergence
│   ├── 10_anes_knowledge.R cross-survey confirmation (ANES 2024 knowledge battery)
│   └── 99_figures.R       figures from the processed results
├── data/
│   ├── raw/igm/           IGM/Clark Center source CSVs (public, included)
│   ├── raw/{gss,pew,anes,speeches}/  place restricted data here (see data/README.md)
│   └── processed/         committed derived aggregates + cleaned expert file
├── output/{figures,tables}/   regenerated outputs (git-ignored)
├── paper/                 manuscript (.qmd)
├── run_all.R              reproduce the whole pipeline
├── setup.R                renv bootstrap / restore
├── renv.lock             pinned package versions (created by setup.R)
└── data/README.md         data availability & acquisition
```

## Reproduction

The pipeline is fully scripted and version-pinned with `renv`.

1. **Environment.** From the repository root in R, `source("setup.R")` restores the exact package versions recorded in `renv.lock`.
2. **Data.** The IGM/Clark Center expert files are included. Place the restricted survey microdata (GSS cumulative, Pew ATP, ANES 2024) and the Card et al. (2022) speech corpus at the paths documented in `data/README.md`.
3. **Execute.** `Rscript run_all.R` runs `R/01`–`R/10` in sequence followed by `R/99_figures.R`; a fixed seed (`20260616`) is set in `run_all.R`. Derived aggregates are written to `data/processed/` and figures to `output/figures/`. The committed aggregates permit the tables and figures to be rebuilt without the restricted microdata.

### Verification

Each script prints its key estimates to the console; a clean run reproduces the following. Trivial last-decimal variation across platforms is expected.

| Script | Object | Expected value |
|---|---|---|
| `01_clean_igm` | cleaned expert panel | 753 economist × sub-question rows |
| `02_clean_public` | public–expert gap; individual divergence model | AI gap +0.45; college OR 0.82 (party OR 1.38) |
| `03_cvi` | Claim Verifiability Index (single coder) | range 5–12, mean 9.5 |
| `04_gaps` | public–expert gaps (Table 1) | AI +0.45, trade +0.36, immigration +0.39 |
| `05_gradient` | identity effect by tribalization (Table 2) | party OR 1.04 → 1.70 → 3.79 |
| `06_diploma_divide` | composition control | party×era OR 3.38; education×era OR 1.14 (n.s.) |
| `07_precedence` | elite-leads-public | lag-10 *r* = 0.92; Granger β = 0.72, *p* = .063 |
| `08_fusion` | capstone: partisanization of the fact | gap −0.03 (1996) → +0.33 (2024); survey-year trend *r* = .92, *p* = .03; fact–preference coupling *r* ≈ .35–.45 |
| `09_mechanism` | identity-protective cognition; asymmetric convergence | partisan gap emerges first among graduates (+0.21 by 2014); 98% of the change is Democratic convergence |
| `10_anes_knowledge` | cross-survey confirmation (ANES 2024) | gap +0.34 → +0.46 by knowledge; design-based party×knowledge interaction +0.51, *p* < .001 |

The manuscript compiles with `quarto render paper/time_traveller.qmd` (requires a TeX engine — run `quarto install tinytex` if none is present); citations use `references.bib` with APA style (`apa.csl`).

## Findings

- Large public–expert gaps on high-CVI claims (AI +45, trade +36, immigration +39 pts).
- Folk-economic divergence is universal and education-corrigible (college OR 0.46–0.82).
- The identity effect scales with tribalization (party OR 1.04 → 1.70 → 3.79).
- Across-era sorting on a fixed item is **not** compositional (party×era OR 3.38 survives; education×era null).
- Elites polarized ~a decade before the public (lagged r 0.92; Granger β 0.72, p .063).
- **Partisanization of a fact (capstone):** the Rep–Dem gap on the factual belief "immigrants take jobs" widens from ~0 (1996) to +33 pts (2024), driven by Democrats abandoning it; the over-time trend across the five survey-years is significant (r ≈ .92, p ≈ .03) and the individual-level party×year interaction is robust to dropping weights. The belief and its matched preference are *stably* coupled throughout (r ≈ .35–.45) — fused all along, so the dynamic is the fact becoming partisan, not the two converging.
- **Mechanism — identity, not ignorance:** the partisan gap on the fact *emerges first among the college-educated* (≈ +0.21 by 2014 vs ≈ 0 among non-graduates) before diffusing to all — the identity-protective-cognition signature (Kahan), inconsistent with an information-deficit account. The widening is asymmetric: ~98% is Democrats converging on the expert benchmark while Republicans stay put. Confirmed cross-survey in ANES 2024: the gap *widens with political knowledge* (+0.34 → +0.46, low to high; design-based party×knowledge interaction +0.51, p<.0001) — sophistication amplifies sorting, the opposite of an information-deficit story.

##  Method & Scope

The design holds a survey item's wording fixed and tracks how its partisan structure changes as the issue tribalizes (measured exogenously from congressional speech). The study is observational; the precedence result is an instance of issue evolution (Carmines & Stimson 1989) and is framed as confirmation, not discovery. See the manuscript's limitations.

## Data terms
Code is MIT-licensed (`LICENSE`). Survey microdata and the speech corpus are governed by their own terms and are **not** redistributed — see `data/README.md`.
