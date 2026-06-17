library(dplyr)
library(ggplot2)
library(lubridate)
library(readr)
library(scales)

# 1. Chargement et conversion robuste
menus <- read_csv("../data/menus_complets_enrichis.csv", show_col_types = FALSE) %>%
  mutate(
    date_propre = dmy(date) # Conversion basée sur le format DD/MM/YYYY visible sur l'image
  )

# 2. Préparation des variables temporelles
menus_evol <- menus %>%
  filter(!is.na(date_propre)) %>%
  mutate(
    jour_semaine = wday(date_propre, label = TRUE, abbr = TRUE, week_start = 1),
    semaine_debut = floor_date(date_propre, unit = "week", week_start = 1)
  ) %>%
  mutate(semaine_label = paste("Semaine du", format(semaine_debut, "%d %b")))

# ==========================================
# ETAPE DEMANDÉE : LE COUNT PAR SEMAINE
# ==========================================
# Ce petit tableau va s'afficher directement dans ton document final Rmd
tableau_comptage <- menus_evol %>%
  group_by(semaine_label) %>%
  summarise(
    `Nombre total de menus` = n(),
    .groups = "drop"
  ) %>%
  arrange(semaine_label)

# Affichage du tableau de décompte dans le rapport
print(knitr::kable(tableau_comptage, caption = "Décompte du nombre total de menus enregistrés par semaine"))

# 3. Agrégation par jour pour le graphique
menus_par_jour_hebdo <- menus_evol %>%
  group_by(semaine_debut, semaine_label, jour_semaine) %>%
  count(name = "nb_menus") %>%
  ungroup() %>%
  mutate(highlight = nb_menus == max(nb_menus))

# 4. Affichage du graphique à échelle fixe
ggplot(menus_par_jour_hebdo, aes(x = jour_semaine, y = nb_menus, fill = highlight)) +
  geom_col(show.legend = FALSE, width = 0.7) +
  facet_wrap(~ reorder(semaine_label, semaine_debut), ncol = 3) +
  scale_fill_manual(values = c("FALSE" = "#7ab8d4", "TRUE" = "#1a6fa8")) +
  scale_y_continuous(labels = comma_format(big.mark = " ")) +
  labs(
    title    = "Évolution hebdomadaire de l'offre de menus par jour de la semaine",
    subtitle = "Visualisation des variations du volume de plats avec suivi du rythme (Lundi au Dimanche)",
    x        = "Jour de la semaine",
    y        = "Nombre de menus proposés"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 16),
    strip.text = element_text(face = "bold", size = 11, color = "white"),
    strip.background = element_rect(fill = "#1a6fa8", color = NA),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(face = "bold")
  )