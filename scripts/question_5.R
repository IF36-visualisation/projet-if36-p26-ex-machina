#Question 5 : Quel est le Nutri-Score moyen des 100 plats les plus fréquents ?

library(tidyverse)
library(ggplot2)

menus <- read_csv("menus_complets_enrichis.csv")

data_nutri <- menus %>%
  mutate(
    plat_test = iconv(str_to_lower(plat), to = "ASCII//TRANSLIT"),
    plat_test = str_squish(plat_test),
    # Conversion du Nutri-Score
    nutri_num = case_when(
      nutriscore == "A" ~ 1,
      nutriscore == "B" ~ 2,
      nutriscore == "C" ~ 3,
      nutriscore == "D" ~ 4,
      nutriscore == "E" ~ 5,
      TRUE ~ NA_real_
    )
  ) %>%
  # --- BLOC DE NETTOYAGE RADICAL ---
  filter(
    !str_detect(plat_test, "montreal|a emporter|telechargez|note douce|carte detaillee|inspiration du jour|simple & gourmand|manque plus que vous"),
    !str_detect(plat_test, "bon appetit|allergenes|consultez la carte|plat du jour|le dandy|les ameliores|hors d'oeuvre varies"),
    !str_detect(plat_test, "pain est compris|origine france|selon fabrication")
  ) %>%
  # Bloc de regroupement
  mutate(plat_general = case_when(
    str_detect(plat_test, "sandwich|baguette|complet|viennois|ciabatta|bagnat|jambon beurre|rosette|thon mayo|pain speciaux|pain suedois") ~ "Sandwichs & Baguettes",
    str_detect(plat_test, "burger|hamburger|tenders|box tenders|tacos|bacon butternut|chicken hawai") ~ "Burgers, Tenders & Tacos",
    str_detect(plat_test, "panini") ~ "Paninis",
    str_detect(plat_test, "wrap|nordiques") ~ "Wraps & Spécialités froides",
    str_detect(plat_test, "salade|cesar|santorin|bowl|crudites|nicoise|taboule|surimi|coleslaw|oeufs mayo") ~ "Salades & Entrées",
    str_detect(plat_test, "pasta|pate|bolognaise|carbonara|napolitaine|pesto|sodebo|fusilli|penne|coquillette|macaroni|torsade") ~ "Pâtes & Pasta Box",
    str_detect(plat_test, "pizza|margherita|bruchetta") ~ "Pizzas & Bruschettas",
    str_detect(plat_test, "croque[- ]monsieur|croques monsieur") ~ "Croque-monsieur",
    str_detect(plat_test, "quiche|tarte salee|lorraine|chevre|courgette") ~ "Quiches & Tartes salées",
    str_detect(plat_test, "poulet|tikka|curry|cajun|teriyaki|nuggets|escalope|cordon bleu|dinde|carbonade|viande|boeuf|chili con carne") ~ "Plats de Viandes (Rouge & Volaille)",
    str_detect(plat_test, "poisson|saumon|bordelaise|colin|macha ko tharkari") ~ "Plats de Poisson & Exotiques",
    str_detect(plat_test, "yaourt|laitage|fromage blanc|entremets|verre de lait") ~ "Yaourts & Produits Laitiers",
    str_detect(plat_test, "cookie|muffin|beignet|donut|brownie|patisserie|viennoiserie|croissant|pain au chocolat|choco suisse|palmier|gateau|crepe|nutella|biscuit|tartelette") ~ "Viennoiseries & Pâtisseries",
    str_detect(plat_test, "fruit|compote|pomme|banane|orange|confiture") ~ "Fruits & Compotes",
    str_detect(plat_test, "eau |fontaine|cristaline|vittel|volvic|perrier|gazeuse|plate") ~ "Eaux & Fontaines",
    str_detect(plat_test, "coca|soda|red bull|monster|oasis|fuzz|minute maid|jus de|the aromatise|the nature|canette") ~ "Boissons Sucrées (Sodas/Jus/Thés)",
    str_detect(plat_test, "cafe|expresso|latte|macchiato|capuccino|moccaccino|chocolat chaud") ~ "Boissons Chaudes",
    TRUE ~ plat 
  ))

# 2. Calcul du Top 100 et de leur Nutri-Score moyen
top_100_nutri <- data_nutri %>%
  group_by(plat_general) %>%
  summarise(
    n = n(),
    nutri_moyen = mean(nutri_num, na.rm = TRUE)
  ) %>%
  filter(!is.na(nutri_moyen)) %>%
  # Suppression manuelle des dernières miettes si nécessaire
  filter(!plat_general %in% c("Frites", "Chips, pringles", "Chips natures ou aromatisées")) %>%
  arrange(desc(n)) %>%
  head(100)

# 3. Préparation pour le graphique
top_100_nutri_div <- top_100_nutri %>%
  mutate(nutri_label = round(nutri_moyen, 1)) %>%
  arrange(nutri_moyen)

# Résultat final
print(top_100_nutri_div, n = 100)

# Visualisation
# Création du graphique "Divergent Lollipop"
p_vertical <- ggplot(top_100_nutri_div, aes(x = reorder(plat_general, nutri_moyen), y = nutri_moyen)) +
  # Ligne de référence horizontale pour le Nutri-Score C
  geom_hline(yintercept = 3, linetype = "dashed", color = "grey80") +
  
  # La tige  qui monte vers le score
  geom_segment(aes(xend = plat_general, y = 3, yend = nutri_moyen), 
               color = "grey85", size = 0.8) +
  
  # La bulle
  geom_point(aes(color = nutri_moyen), size = 5) + 
  
  # Le texte dans la bulle
  geom_text(aes(label = nutri_label), color = "white", size = 1.5, fontface = "bold") +
  
  # Couleurs Nutri-Score
  scale_color_gradientn(
    colors = c("#1a9850", "#91cf60", "#fee08b", "#fc8d59", "#d73027"),
    limits = c(1, 5), 
    breaks = c(1, 2, 3, 4, 5),             
    labels = c("1-A", "2-B", "3-C", "4-D", "5-E"), 
    name = "Qualité Nutritionnelle"
  ) +
  
  # 
  theme_minimal() +
  labs(
    title = "5. Nutri-Score moyen des 100 plats les plus fréquents",
    #subtitle = "Plats en abscisses | Nutri-Score en ordonnées (Référence C = 3)",
    x = "Plats distribués", 
    y = "Moyenne Nutri-Score",
    caption = "Visualisation par : Ange Kamgue | Groupe Ex-Machina"
  ) +
  theme(
    # ROTATION DES NOMS 
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 6),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    
    #Agrandir l'echelle
    legend.key.width = unit(3, "cm"),   # Étire la barre de couleur horizontalement
    legend.key.height = unit(0.5, "cm"), # Épaissit la barre de couleur
    legend.title = element_text(face = "bold", vjust = 1),
    legend.text = element_text(size = 8)
  )

# 3. SAUVEGARDE EN FORMAT "PANORAMIQUE"
# On force une largeur très grande (30 pouces) pour étaler les 100 plats
ggsave("nutriscore_vertical_large.png", plot = p_vertical, width = 30, height = 13, dpi = 300)

# Affichage
print(p_vertical)