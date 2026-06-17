library(dplyr)
library(ggplot2)
library(readr)
library(scales)

menus <- read_csv("../data/menus_complets_enrichis.csv", show_col_types = FALSE)
restaurants <- read_csv("../data/liste_restaurants.csv", show_col_types = FALSE)

pmr_nutri <- menus %>%
  filter(nutriscore %in% c("A", "B", "C", "D", "E")) %>%
  left_join(
    restaurants %>% select(code, ispmr),
    by = c("restaurant_id" = "code")
  ) %>%
  filter(!is.na(ispmr)) %>%
  mutate(
    accessibilite = if_else(ispmr, "Accessible PMR", "Non accessible PMR"),
    nutriscore = factor(nutriscore, levels = c("A", "B", "C", "D", "E")),
    score_sante = case_when(
      nutriscore == "A" ~ 5,
      nutriscore == "B" ~ 4,
      nutriscore == "C" ~ 3,
      nutriscore == "D" ~ 2,
      nutriscore == "E" ~ 1,
      TRUE ~ NA_real_
    )
  )

scores_moyens <- pmr_nutri %>%
  group_by(accessibilite) %>%
  summarise(score_moyen = mean(score_sante), .groups = "drop")

subtitle_q9 <- paste(
  paste0(scores_moyens$accessibilite, " : score moyen ", round(scores_moyens$score_moyen, 2), "/5"),
  collapse = " | "
)

ggplot(pmr_nutri, aes(x = accessibilite, fill = nutriscore)) +
  geom_bar(position = "fill", width = 0.65) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(
    values = c(
      "A" = "#549464",
      "B" = "#a3cc75",
      "C" = "#f5d44c",
      "D" = "#db9346",
      "E" = "#cf6342"
    ),
    name = "Nutri-Score"
  ) +
  labs(
    title = "Répartition des Nutri-Scores selon l'accessibilité PMR",
    subtitle = subtitle_q9,
    x = NULL,
    y = "Proportion de plats"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    panel.grid.major.x = element_blank()
  )