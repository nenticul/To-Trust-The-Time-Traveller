# =====================================================================
# 99_figures.R — build the five manuscript figures from processed results
# Run after 03-08. Saves PNGs to output/figures/.
# =====================================================================
library(tidyverse)
proc <- "data/processed"; fig <- "output/figures"
theme_set(theme_minimal(base_size = 12))

# Fig 1 — public-expert gap by claim
if (file.exists(file.path(proc, "macro_gaps.csv"))) {
  read_csv(file.path(proc, "macro_gaps.csv"), show_col_types = FALSE) |>
    pivot_longer(c(public_agree, expert_agree)) |>
    ggplot(aes(reorder(pair, value), value, fill = name)) +
    geom_col(position = "dodge") +
    coord_flip() + scale_y_continuous(labels = scales::percent) +
    labs(title = "Public-expert gap on unverifiable economic claims",
         x = NULL, y = "share agreeing", fill = NULL)
  ggsave(file.path(fig, "fig1_gap.png"), width = 7, height = 4, dpi = 200)
}

# Fig 2 — tribalization gradient (party OR by claim)
if (file.exists(file.path(proc, "tribalization_gradient.csv"))) {
  read_csv(file.path(proc, "tribalization_gradient.csv"), show_col_types = FALSE) |>
    filter(term == "partyRep") |>
    ggplot(aes(reorder(claim, estimate), estimate)) +
    geom_pointrange(aes(ymin = conf.low, ymax = conf.high)) +
    geom_hline(yintercept = 1, linetype = 2) + coord_flip() +
    labs(title = "Identity effect rises with tribalization",
         x = NULL, y = "party odds ratio (Rep vs Dem) on folk belief")
  ggsave(file.path(fig, "fig2_gradient.png"), width = 7, height = 4, dpi = 200)
}

# Fig 3 — precedence: elite leads public
if (file.exists(file.path(proc, "elite_polarization_series.csv")) &&
    file.exists(file.path(proc, "precedence_series_letin1a.csv"))) {
  elite <- read_csv(file.path(proc, "elite_polarization_series.csv"), show_col_types = FALSE)
  pub   <- read_csv(file.path(proc, "precedence_series_letin1a.csv"), show_col_types = FALSE)
  ggplot() +
    geom_line(data = elite, aes(year, polz_s, color = "Elite polarization")) +
    geom_line(data = pub, aes(year, public_gap, color = "Public partisan gap"), linetype = 2) +
    geom_point(data = pub, aes(year, public_gap, color = "Public partisan gap")) +
    coord_cartesian(xlim = c(1950, 2025)) +
    labs(title = "Elites polarized before the public sorted",
         x = "year", y = "polarization / partisan gap", color = NULL)
  ggsave(file.path(fig, "fig3_precedence.png"), width = 8, height = 4.5, dpi = 200)
}

# Fig 4 — fact-preference coupling is stable (co-respondents only; not a rising "fusion")
if (file.exists(file.path(proc, "fusion_coupling.csv"))) {
  read_csv(file.path(proc, "fusion_coupling.csv"), show_col_types = FALSE) |>
    mutate(pref_item = recode(pref_item,
             letin1 = "levels item (letin1)", letin1a = "reduce item (letin1a)")) |>
    ggplot(aes(year, r, color = pref_item, shape = pref_item)) +
    geom_line() + geom_point(size = 3) +
    scale_y_continuous(limits = c(0, 0.6)) +
    labs(title = "Fact and preference are stably coupled (true co-respondents)",
         x = "year", y = "within-year correlation, immjobs vs immigration preference",
         color = NULL, shape = NULL)
  ggsave(file.path(fig, "fig4_coupling.png"), width = 7.5, height = 4, dpi = 200)
}

# Fig 5 — CAPSTONE: the partisanization of a fact
if (file.exists(file.path(proc, "fact_partisan_gap.csv"))) {
  read_csv(file.path(proc, "fact_partisan_gap.csv"), show_col_types = FALSE) |>
    pivot_longer(c(dem_share, rep_share), names_to = "party", values_to = "share") |>
    mutate(party = recode(party, dem_share = "Democrats", rep_share = "Republicans")) |>
    ggplot(aes(year, share, color = party, shape = party)) +
    geom_line(linewidth = 1) + geom_point(size = 3) +
    scale_y_continuous(labels = scales::percent, limits = c(0, 0.6)) +
    scale_color_manual(values = c(Democrats = "#378ADD", Republicans = "#D85A30")) +
    labs(title = "The partisanization of a fact: \"immigrants take jobs,\" by party",
         subtitle = "Rep-Dem gap widens from ~0 (1996) to +33 pts (2024)",
         x = "year", y = "share agreeing", color = NULL, shape = NULL)
  ggsave(file.path(fig, "fig5_partisanization.png"), width = 7.5, height = 4.5, dpi = 200)
}

# Fig 6 — mechanism: the partisan gap on the fact appears first among the educated
if (file.exists(file.path(proc, "fact_gap_by_education.csv"))) {
  read_csv(file.path(proc, "fact_gap_by_education.csv"), show_col_types = FALSE) |>
    mutate(education = recode(education, college = "college", no_college = "no college")) |>
    ggplot(aes(year, gap, color = education, shape = education)) +
    geom_hline(yintercept = 0, color = "grey70") +
    geom_line(linewidth = 1) + geom_point(size = 3) +
    scale_y_continuous(labels = scales::percent) +
    labs(title = "Identity-protective cognition: sorting emerges first among the educated",
         subtitle = "Rep-Dem gap on \"immigrants take jobs,\" by education",
         x = "year", y = "Rep - Dem gap", color = NULL, shape = NULL)
  ggsave(file.path(fig, "fig6_mechanism.png"), width = 7.5, height = 4.5, dpi = 200)
}

# Fig 7 — cross-survey confirmation: the gap widens with political knowledge (ANES 2024)
if (file.exists(file.path(proc, "anes_gap_by_knowledge.csv"))) {
  read_csv(file.path(proc, "anes_gap_by_knowledge.csv"), show_col_types = FALSE) |>
    mutate(knowledge = factor(knowledge, levels = c("low (0-1)", "mid (2)", "high (3-4)"))) |>
    pivot_longer(c(dem_share, rep_share), names_to = "party", values_to = "share") |>
    mutate(party = recode(party, dem_share = "Democrats", rep_share = "Republicans")) |>
    ggplot(aes(knowledge, share, color = party, group = party, shape = party)) +
    geom_line(linewidth = 1) + geom_point(size = 3) +
    scale_y_continuous(labels = scales::percent, limits = c(0, 0.6)) +
    scale_color_manual(values = c(Democrats = "#378ADD", Republicans = "#D85A30")) +
    labs(title = "The gap widens with knowledge (ANES 2024): identity, not ignorance",
         subtitle = "\"Immigrants take jobs,\" by political-knowledge level",
         x = "political knowledge (0-4 correct)", y = "share agreeing",
         color = NULL, shape = NULL)
  ggsave(file.path(fig, "fig7_anes_knowledge.png"), width = 7.5, height = 4.5, dpi = 200)
}

message("Figures written to ", fig)
