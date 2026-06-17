library(dplyr)
library(ggplot2)
library(readr)
library(forcats)
library(scales)

restaurants <- read_csv("../data/liste_restaurants.csv", show_col_types = FALSE)

accessibilite_pmr <- restaurants %>%
  filter(!is.na(`region.libelle`), !is.na(ispmr)) %>%
  group_by(region = `region.libelle`) %>%
  summarise(
    n_restaurants = n_distinct(code),
    n_pmr = sum(ispmr),
    pct_pmr = n_pmr / n_restaurants,
    .groups = "drop"
  ) %>%
  filter(n_restaurants >= 2) %>%
  mutate(
    region = fct_reorder(region, pct_pmr),
    label = paste0(percent(pct_pmr, accuracy = 1), " (", n_pmr, "/", n_restaurants, ")"),
    hjust_label = if_else(pct_pmr >= 0.92, 1.05, -0.08),
    x_label = if_else(pct_pmr >= 0.92, pct_pmr - 0.02, pct_pmr)
  )

moyenne_pmr <- sum(accessibilite_pmr$n_pmr) / sum(accessibilite_pmr$n_restaurants)

ggplot(accessibilite_pmr, aes(x = pct_pmr, y = region, fill = pct_pmr)) +
  geom_col(width = 0.72, show.legend = FALSE) +
  geom_vline(
    xintercept = moyenne_pmr,
    linetype = "dashed", color = "firebrick", linewidth = 0.8
  ) +
  geom_text(
    aes(x = x_label, label = label, hjust = hjust_label),
    size = 3.2, color = "grey25"
  ) +
  annotate(
    "text",
    x = moyenne_pmr + 0.015,
    y = 1.3,
    label = "Moyenne",
    color = "firebrick",
    size = 3.2,
    hjust = 0
  ) +
  scale_x_continuous(
    labels = percent_format(accuracy = 1),
    limits = c(0, 1),
    expand = expansion(mult = c(0, 0.02))
  ) +
  scale_fill_gradient(low = "#b7dde8", high = "#1a6fa8") +
  labs(
    title = "Part de restaurants accessibles PMR par région",
    subtitle = "Les étiquettes indiquent le pourcentage et le ratio restaurants accessibles / restaurants renseignés",
    x = "Restaurants accessibles PMR",
    y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.y = element_blank()
  )