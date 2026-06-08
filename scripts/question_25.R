
library(tidyverse)

# Chargement
menus <- read.csv("menus_complets_enrichis.csv")

# Nettoyage des données
df_clean <- menus %>%
  filter(
    !is.na(style_culinaire),
    style_culinaire != "",
    !is.na(nutriscore),
    nutriscore != ""
  )

# Regrouper les styles trop rares
top_styles <- df_clean %>%
  count(style_culinaire, sort = TRUE) %>%
  top_n(10, n) %>%
  pull(style_culinaire)

df_clean <- df_clean %>%
  mutate(style_culinaire = ifelse(style_culinaire %in% top_styles,
                                  style_culinaire,
                                  "Autres"))

# Ordre des nutriscores
df_clean$nutriscore <- factor(df_clean$nutriscore,
                              levels = c("A", "B", "C", "D", "E"))

# Visualisation (Stackbar)
ggplot(df_clean, aes(x = style_culinaire, fill = nutriscore)) +
  geom_bar(position = "fill", width = 0.6) +
  scale_y_continuous(labels = scales::percent_format()) +
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
    title = "Répartition du Nutri-Score selon le style culinaire",
    x = "Style culinaire",
    y = "Proportion de plats"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )