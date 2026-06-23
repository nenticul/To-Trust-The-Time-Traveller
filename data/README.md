# Data availability & acquisition

This project uses five data bodies. The **public IGM/Clark Center files are included** in `data/raw/igm/`. The survey microdata (GSS, Pew, ANES, VOTER) and the speech corpus are **not redistributed** here — they carry their own terms of use and/or are large. Obtain each as below and place it at the indicated path; the scripts read from these paths.

| Source | Included? | Path | How to obtain |
|---|---|---|---|
| **IGM / Kent A. Clark Center** US Economic Experts Panel | ✅ yes (public) | `data/raw/igm/*.csv` | Already in the repo. Originals: kentclarkcenter.org → individual survey pages → "Download Poll Data". |
| **GSS** 1972–2024 Cumulative | ❌ no | `data/raw/gss/gss7224_r3.dta` | gss.norc.org/get-the-data → **STATA** format → unzip → place the `.dta` here. Free, no registration for the cumulative file. |
| **Pew American Trends Panel** | ❌ no | `data/raw/pew/ATP W27.sav`, `ATP W152.sav` | pewresearch.org/american-trends-panel-datasets → register (free) → download **Wave 27** (automation, 2017) and **Wave 152** (AI, 2024) → place the `.sav` files here. |
| **ANES 2024** Time Series | ❌ no | `data/raw/anes/anes_timeseries_2024_csv_20260519.csv` | electionstudies.org/data-center → register (free) → 2024 Time Series Study → CSV. Used for the cross-survey check and the design-based political-knowledge mechanism test. |
| **ANES Time Series Cumulative File** (1948–2024) | ❌ no | `data/raw/anes/anes_timeseries_cdf_csv_20260205.csv` | electionstudies.org/data-center → Time Series Cumulative Data File → CSV. Used for the out-of-sample mechanism replication (R/18): immigration "take jobs" fact `VCF9223` × interviewer political-info rating `VCF0050a` × party `VCF0301`, 2004–2016. |
| **Congressional immigration speeches** (Card et al. 2022) | ❌ no (script-pulled) | `data/raw/speeches/speech_data.csv` | `git clone https://github.com/dallascard/us-immigration-speeches` then copy `public_opinion_and_sei/data/input/speech_data.csv` here. |
| **VOTER Survey** (Democracy Fund Voter Study Group), 2011–2020 panel | ❌ no | `data/raw/voter/voter_panel.dta` | voterstudygroup.org → Data → Views of the Electorate Research (VOTER) Survey → register (free) → download the merged **panel** file in **STATA** format → place the `.dta` here. Used for the within-person capture / cross-lagged result (R/17). |
| **ISSP 2013 National Identity III** (ZA5950) | ❌ no | `data/raw/issp/ZA5950_v2-0-0.dta` | search.gesis.org/research_data/ZA5950 → register (free) → download **Stata** file. Cross-national scope test (R/20): `V50` (immigrants take jobs), `PARTY_LR` (left–right party family), `V3` (country), `WEIGHT`. |

## Variables used (so you can verify after download)
- **GSS:** `immjobs`, `letin1a`, `moretrde`, `partyid`, `degree`, `age`, `year`, `wtssall`, `wtssps`.
- **Pew W27:** `ROBJOB4B_W27`, `F_PARTYSUM_FINAL`, `F_EDUCCAT_FINAL`, `WEIGHT_W27`.
- **Pew W152:** `AIJOBS_W152`, `F_PARTYSUM_FINAL`, `F_EDUCCAT`, `WEIGHT_W152`.
- **ANES 2024:** `V242227` (immigration levels), `V242228` (belief: immigration likely to take jobs), `V241227x` (party ID), `V241612`–`V241615` (4-item political-knowledge battery), `V240107a` (pre weight), and `V240107b`/`V240107c`/`V240107d` (post weight / PSU / strata for the design-based knowledge test).
- **Speeches:** `date`, `party`, `tone_label_int`.
- **VOTER:** `immi_contribution_2011`/`_2016`/`_2018`/`_2020Nov` (immigrants contribution vs drain), `pid7_2011`/`_2016`/`_2018`/`_2020Nov` (7-point party ID by wave), `weight_genpop_2020Nov`.

## Notes
- `data/raw/gss/`, `pew/`, `anes/`, `voter/`, `speeches/` are git-ignored except a `.gitkeep`, so cloning the repo gives you the structure without the restricted files.
- The GSS `.dta` may need `encoding = "latin1"`; `haven::read_dta()` handles this.
- A few processed aggregates (year-level series, the cleaned expert file) ARE committed in `data/processed/` because they are non-identifiable derivatives that aid reproduction. No restricted microdata is committed.
