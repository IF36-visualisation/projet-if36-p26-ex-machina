library(dplyr)
library(ggplot2)
library(readr)
library(forcats)

# -- Chargement --------------------------------------------------------------
restaurants <- read_csv("../data/liste_restaurants.csv", show_col_types = FALSE)
menus       <- read_csv("../data/menus_complets_enrichis.csv", show_col_types = FALSE)

# -- Jointure et filtrage ----------------------------------------------------
df <- menus %>%
  left_join(
    restaurants %>% select(code, region = "region.libelle"),
    by = c("restaurant_id" = "code")
  ) %>%
  filter(!is.na(region))

# Exclure les régions avec un seul restaurant (non représentatives)
regions_valides <- df %>%
  group_by(region) %>%
  summarise(n_rest = n_distinct(restaurant_id), .groups = "drop") %>%
  filter(n_rest >= 2) %>%          # >= 2 restaurants pour être conservée
  pull(region)

df <- df %>% filter(region %in% regions_valides)

# Métrique : plats distincts par restaurant
diversite_norm <- df %>%
  group_by(region) %>%
  summarise(
    n_plats_distincts = n_distinct(plat),
    n_restaurants     = n_distinct(restaurant_id),
    plats_par_resto   = n_plats_distincts / n_restaurants,
    .groups = "drop"
  ) %>%
  mutate(region = fct_reorder(region, plats_par_resto))

ggplot(diversite_norm, aes(x = plats_par_resto, y = region, fill = plats_par_resto)) +
  geom_col(show.legend = FALSE, width = 0.75) +
  geom_text(
    aes(label = sprintf("%.1f", plats_par_resto)),
    hjust = -0.15, size = 3.2, color = "grey30"
  ) +
  geom_vline(
    xintercept = mean(diversite_norm$plats_par_resto),
    linetype = "dashed", color = "firebrick", linewidth = 0.8
  ) +
  annotate(
    "text", x = mean(diversite_norm$plats_par_resto) + 0.3,
    y = 1.5, label = "Moyenne", color = "firebrick", size = 3.2, hjust = 0
  ) +
  scale_fill_gradient(low = "#b7dde8", high = "#1a6fa8") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title    = "Diversité normalisée : plats distincts par restaurant et par région",
    subtitle = "Corrige le biais de taille - les grandes régions ne sont plus avantagées",
    x        = "Nombre moyen de plats distincts par restaurant",
    y        = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title         = element_text(face = "bold", size = 14),
    panel.grid.major.y = element_blank()
  )

# Entropie de Shannon par restaurant
shannon_entropy <- function(x) {
  counts <- table(x)
  probs  <- counts / sum(counts)
  probs  <- probs[probs > 0]
  -sum(probs * log2(probs))
}

shannon_par_resto <- df %>%
  group_by(region, restaurant_id) %>%
  summarise(shannon = shannon_entropy(plat), .groups = "drop")

shannon_par_region <- shannon_par_resto %>%
  group_by(region) %>%
  summarise(
    shannon_moyen = mean(shannon),
    shannon_sd    = sd(shannon),
    n_rest        = n(),
    .groups = "drop"
  ) %>%
  mutate(
    region  = fct_reorder(region, shannon_moyen),
    # Intervalle indicatif à 95 %. L'approximation normale évite les segments
    # illisibles lorsque certaines régions ont très peu de restaurants.
    shannon_se = shannon_sd / sqrt(n_rest),
    ic_low     = pmax(0, shannon_moyen - 1.96 * shannon_se),
    ic_high    = shannon_moyen + 1.96 * shannon_se
  )

ggplot(shannon_par_region,
       aes(x = shannon_moyen, y = region)) +
  geom_segment(
    aes(x = ic_low, xend = ic_high, yend = region),
    color = "#b7cfe2", linewidth = 1.1, alpha = 0.8
  ) +
  geom_point(aes(color = shannon_moyen), size = 4, show.legend = FALSE) +
  geom_vline(
    xintercept = mean(shannon_par_region$shannon_moyen),
    linetype = "dashed", color = "firebrick", linewidth = 0.8
  ) +
  annotate(
    "text", x = mean(shannon_par_region$shannon_moyen) + 0.05,
    y = 1.5, label = "Moyenne", color = "firebrick", size = 3.2, hjust = 0
  ) +
  scale_color_gradient(low = "#b7dde8", high = "#1a6fa8") +
  scale_x_continuous(
    limits = c(0, max(shannon_par_region$ic_high, na.rm = TRUE) * 1.08),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title    = "Entropie de Shannon moyenne par région",
    subtitle = "Mesure l'équilibre de la distribution des plats au sein de chaque restaurant\nLes segments représentent un intervalle indicatif à 95 %",
    x        = "Entropie de Shannon moyenne (bits)",
    y        = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title         = element_text(face = "bold", size = 14),
    panel.grid.major.y = element_blank()
  )