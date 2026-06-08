library(dplyr)
library(ggplot2)
library(readr)

menus <- read_csv("menus_complets_enrichis.csv")

# Nettoyage
df <- menus %>%
  filter(
    !is.na(nutriscore),
    !is.na(calories_estimees)
  ) %>%
  filter(
    nutriscore %in% c("A", "B", "C", "D", "E")
  )

# Boxplot
ggplot(df,
       aes(
         x = nutriscore,
         y = calories_estimees,
         fill = nutriscore
       )) +
  
  geom_boxplot(alpha = 0.8) +
  
  scale_fill_manual(
    values = c(
      "A" = "#038141",
      "B" = "#85BB2F",
      "C" = "#FECB02",
      "D" = "#EE8100",
      "E" = "#E63E11"
    )
  ) +
  
  labs(
    title = "Question 13 : Existe-t-il un lien entre calories et Nutri-Score ?",
    subtitle = "Distribution des calories selon la qualité nutritionnelle",
    x = "Nutri-Score",
    y = "Calories estimées"
  ) +
  
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold")
  )
