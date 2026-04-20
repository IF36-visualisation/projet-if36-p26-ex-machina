library(tidyverse)

# 1. Chargement des données
menus <- read_csv("liste_menus_restaurants.csv")

# 2. Nettoyage et Enrichissement Multi-colonnes
data_enrichie <- menus %>%
  # --- ÉTAPE 1 : NETTOYAGE DES LIGNES ABERRANTES ---
  filter(
    !str_detect(plat, "(?i)ouvert|lundi au|vendredi|clôture|disposition|merci de|propose du|fermé|étage|consommer|boissons|nourritures|cliquez|consulter|bienvenue|structure fermée")
  ) %>%
  filter(plat != categorie) %>%
  filter(nchar(plat) > 2) %>%
  
  # --- ÉTAPE 2 : CALCUL DES INDICATEURS ---
  mutate(
    plat_low = str_to_lower(plat),
    
    # A. NUTRISCORE (Qualité)
    nutriscore = case_when(
      str_detect(plat_low, "légumes|salade|soupe|velouté|lentilles|pois chiche|poisson|fruit|compote|haricots|épinards") ~ "A",
      str_detect(plat_low, "poulet|dinde|œuf|omelette|yaourt nature|fromage blanc") ~ "B",
      str_detect(plat_low, "pâtes|riz|semoule|lasagnes|féculent|fromage") ~ "C",
      str_detect(plat_low, "frites|steak|haché|boeuf|porc|saucisse|nuggets|cordon bleu|burger|pizzas|pâtisserie|gâteau") ~ "D",
      str_detect(plat_low, "beignet|donut|salami|mayonnaise|charcuterie") ~ "E",
      TRUE ~ "C" 
    ),
    
    # B. RÉGIME ALIMENTAIRE
    regime = case_when(
      str_detect(plat_low, "boeuf|steak|poulet|porc|saucisse|jambon|poisson|thon|saumon|dinde|lardons|nuggets|haché") ~ "Carné",
      str_detect(plat_low, "oeuf|fromage|camembert|emmental|mozzarella|omelette|yaourt|crème") ~ "Végétarien",
      TRUE ~ "Végétalien/Base Végétale"
    ),
    
    # C. IMPACT CARBONE
    impact_carbone = case_when(
      str_detect(plat_low, "boeuf|agneau") ~ "Très Haut",
      str_detect(plat_low, "porc|poulet|dinde|fromage|poisson") ~ "Moyen",
      TRUE ~ "Bas"
    ),
    
    # D. STYLE CULINAIRE
    style_culinaire = case_when(
      str_detect(plat_low, "frites|burger|pizza|nuggets|kebab|panini") ~ "Street Food",
      str_detect(plat_low, "velouté|soupe|potage") ~ "Soupes",
      str_detect(plat_low, "pâtisserie|gâteau|mousse|donuts|eclair|sucre") ~ "Plats Sucrés",
      str_detect(plat_low, "salade|crudités") ~ "Fraîcheur",
      TRUE ~ "Cuisine Traditionnelle"
    ),
    
    # E. ESTIMATION CALORIES (Portion standard)
    calories_estimees = case_when(
      str_detect(plat_low, "burger|pizza|frites|nuggets|cordon bleu|beignet|salami") ~ 700,
      str_detect(plat_low, "steak|poulet|saumon|lasagnes|pâtes|riz|sauté|haché") ~ 450,
      str_detect(plat_low, "pâtisserie|gâteau|mousse|donut") ~ 300,
      str_detect(plat_low, "velouté|soupe|salade|crudités|haricots|épinards") ~ 150,
      str_detect(plat_low, "fruit|yaourt|compote|fromage blanc") ~ 80,
      TRUE ~ 250
    )
  ) %>%
  # Suppression de la colonne de travail temporaire
  select(-plat_low)

# 3. Vérification statistique rapide
print("--- APERÇU DES DONNÉES ENRICHIES ---")
print(paste("Nombre de lignes après nettoyage :", nrow(data_enrichie)))
print("Répartition Nutriscore :")
print(table(data_enrichie$nutriscore))
print("Répartition Régime :")
print(table(data_enrichie$regime))

# 4. Sauvegarde
write_csv(data_enrichie, "menus_complets_enrichis_82k.csv")