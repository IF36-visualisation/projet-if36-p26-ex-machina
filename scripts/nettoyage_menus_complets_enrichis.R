library(tidyverse)

# 1. Chargement
df <- read_csv("menus_complets_enrichis.csv")

# 2. Algorithme de NETTOYAGE TOTAL (Ultra-Radical)
df_propre <- df %>%
  mutate(
    plat = str_squish(plat),
    plat_test = iconv(str_to_lower(plat), to = "ASCII//TRANSLIT")
  ) %>%
  filter(
    # --- SILO 1 : PRIX ET TARIFS 
    !str_detect(plat_test, "prix|tarif|ttc| ht|euro|étudiant|social"),
    
    # --- SILO 2 : FORMULES ET MENUS 
    !str_detect(plat_test, "formule|menu duo|menu trio|happy hour| morning|wake up|bon plan"),
    !str_detect(plat_test, "un dessert au choix|deux desserts|repas a tarif"),
    
    # --- SILO 3 : CAFÉS ET BOISSONS 
    !str_detect(plat_test, "cafe|expresso|capuccino|moccaccino|chocolat|fuzz tee|jus d'orange"),
    
    # --- SILO 4 : SNACKING GÉNÉRIQUE ET MESSAGES 
    !str_detect(plat_test, "confiseries|la gourde|plat cuisine|entrees variees|desserts varies"),
    !str_detect(plat_test, "snacking|tous les jours|italienne|accompagné|animation"),
    !str_detect(plat_test, "sous reserve|disponibilite|denrees"),
    
    # --- SILO 5 : JOURS DE LA SEMAINE 
    !str_detect(plat_test, "lundi|mardi|mercredi|jeudi|vendredi|samedi|dimanche"),
    
    # --- SILO 6 : DESSERTS, FRUITS ET ACCOMPAGNEMENTS
    !str_detect(plat_test, "tartes|fromage|riz pilaf|semoule|brocolis|gratins"),
    
    # --- SILO 7 : STRUCTURE ET CARACTÈRES SPÉCIAUX (Lignes 43, 49, 71, 82...) ---
    !str_detect(plat, ":"),           # Supprime les lignes avec ":" (Salades composées :, Quiches :, etc.)
    !str_detect(plat, "\\*"),         # Supprime les lignes avec astérisques
    !str_detect(plat, "\\("),         # Supprime les parenthèses (Salade sodebo (classique)...)
    !str_detect(plat, "/"),           # Supprime les lignes avec "/" (Sandwichs/Pâtes...)
    !str_detect(plat, "^\\+"),        # Supprime les lignes commençant par "+"
    
    # --- SILO 8 : SÉCURITÉ CATÉGORIE ---
    !categorie %in% c("Boissons", "Petit déjeuner", "Produits laitiers", "Dessert", "Entrées", "Petits déjeuners"),
    
    # Qualité finale
    nchar(plat) > 5
  ) %>%
  select(-plat_test)

# 3. Sauvegarde
write_csv(df_propre, "menus_complets_propres.csv")

# 4. Vérification (On recrée ton top_100 pour être sûr)
top_100_plats <- df_propre %>% 
  count(plat, sort = TRUE) %>% 
  rename(plat_general = plat)

print(top_100_plats, n=100)