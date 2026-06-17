library(dplyr)
library(ggplot2)
library(readr)
library(scales)

menus      <- read_csv("../data/menus_complets_enrichis.csv", show_col_types = FALSE)
restaurants <- read_csv("../data/liste_restaurants.csv",       show_col_types = FALSE)

# Statistiques de fiabilité par restaurant
fiabilite <- menus %>%
  group_by(restaurant_id) %>%
  summarise(
    nb_plats           = n(),
    nb_scores_distincts = n_distinct(nutriscore),
    pct_C              = mean(nutriscore == "C") * 100,
    .groups            = "drop"
  ) %>%
  filter(nb_plats >= 10) %>%
  left_join(
    restaurants %>% select(code, nom),
    by = c("restaurant_id" = "code")
  ) %>%
  mutate(
    suspect = pct_C >= 90 & nb_scores_distincts == 1,
    label   = if_else(suspect & nb_plats >= 80, nom, NA_character_)
  )

# Graphique : scatter pct_C vs nb_scores_distincts, taille = nb_plats
ggplot(fiabilite,
       aes(x = nb_scores_distincts, y = pct_C,
           size = nb_plats, color = suspect)) +
  geom_jitter(alpha = 0.65, width = 0.15, height = 0.5) +
  geom_hline(yintercept = 90, linetype = "dashed", color = "firebrick", linewidth = 0.8) +
  ggrepel::geom_label_repel(
    aes(label = label),
    size = 2.8, color = "firebrick", fill = "white",
    box.padding = 0.4, max.overlaps = 12, show.legend = FALSE
  ) +
  scale_color_manual(
    values = c("FALSE" = "#7ab8d4", "TRUE" = "firebrick"),
    labels = c("FALSE" = "Données cohérentes", "TRUE" = "Suspect (>=90 % de C, 1 seul score)")
  ) +
  scale_size_continuous(range = c(2, 10), breaks = c(10, 50, 100, 500)) +
  scale_y_continuous(labels = function(x) paste0(x, " %")) +
  labs(
    title    = "Fiabilité des données nutritionnelles par restaurant",
    subtitle = paste0(
      "Restaurants avec >= 10 plats - ",
      sum(fiabilite$suspect), " sur ", nrow(fiabilite),
      " présentent un profil suspect (>= 90 % de Nutri-Score C, 1 valeur unique)"
    ),
    x        = "Nombre de Nutri-Scores distincts utilisés",
    y        = "Proportion de plats avec Nutri-Score C",
    color    = NULL,
    size     = "Nombre de plats"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title     = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

# Table des restaurants les plus suspects
fiabilite %>%
  filter(suspect) %>%
  arrange(desc(nb_plats)) %>%
  slice_head(n = 15) %>%
  select(
    `Restaurant`             = nom,
    `ID`                     = restaurant_id,
    `Nb plats`               = nb_plats,
    `% Nutri-Score C`        = pct_C,
    `Scores distincts`       = nb_scores_distincts
  ) %>%
  knitr::kable(
    caption = "Top 15 des restaurants au profil nutritionnel suspect",
    digits  = 1
  )