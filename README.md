![Image du Dataset](data/banner_croustillant.png)
# Projet IF36 Analyse exploratoire des menus de restaurants – Croustillant Menu

## Membres

Équipe Ex-Machina :

- Ange KAMGUE
- Jules TIMADJI
- Housséni YABRE
- Rayan LEGRAND

## Sommaire

- [Contexte et objectifs](#contexte-et-objectifs)
- [Présentation des données](#présentation-des-données)
- [Plan d’analyse](#plan-danalyse)

## Contexte et objectifs
Ce projet s’inscrit dans le domaine de l’analyse de données appliquée à la restauration universitaire CROUS. Il repose sur l’exploitation des données fournies par l’API **Croustillant Menu** (https://api.croustillant.menu/) qui permet de récupérer les menus des restaurants ainsi que les détails des plats proposés.

Le projet a pour objectif de réaliser une **analyse exploratoire** des menus et des restaurants afin de :

- Identifier les tendances dans l’offre culinaire selon les restaurants et les périodes (ex. février 2026)  
- Analyser la diversité des plats et des catégories (Entrées, Plats, Desserts)  
- Comparer les menus entre restaurants et observer des régularités ou anomalies  
- Détecter des insights exploitables pour des analyses plus avancées (ex. popularité des plats, types de repas les plus fréquents)  

## Présentation des données

Le jeu de données comporte plusieurs fichiers CSV situés dans le dossier `data/` :

### 1. **`liste_restaurants.csv`** : liste des restaurants distincts
- **Nombre d’observations :** 942 (correspond au nombre de restaurants présents dans le fichier CSV)  
- **Nombre de variables :** 20  

| Champ | Type | Description |
|-------|------|-------------|
| `code` | entier | Identifiant unique du restaurant |
| `nom` | texte | Nom du restaurant |
| `adresse` | texte | Adresse complète |
| `latitude` | numérique | Latitude GPS |
| `longitude` | numérique | Longitude GPS |
| `horaires` | texte | Horaires d’ouverture (ex. 11:00-22:00) |
| `jours_ouvert` | texte | Jours de la semaine où le restaurant est ouvert |
| `image_url` | texte | Lien vers une image représentative du restaurant |
| `email` | texte | Adresse email du restaurant |
| `telephone` | texte | Numéro de téléphone |
| `ispmr` | booléen | Accessibilité PMR (personnes à mobilité réduite) |
| `zone` | texte | Zone géographique ou quartier |
| `paiement` | texte | Modes de paiement acceptés |
| `acces` | texte | Informations sur l’accès (parking, transports…) |
| `ouvert` | booléen | Indique si le restaurant est actuellement ouvert |
| `actif` | booléen | Indique si le restaurant est actif dans la base |
| `region.code` | entier | Code de la région |
| `region.libelle` | texte | Nom de la région |
| `type.code` | entier | Code du type de restaurant |
| `type.libelle` | texte | Libellé du type de restaurant (ex. Brasserie, Fast-food) |
   - Chaque observation correspond à un restaurant unique dans une région.

### 2. **`menus_complets_enrichis.csv`** : liste des  menus pour chaque restaurant

### Description
Cette table contient l’ensemble des menus proposés dans les restaurants universitaires.  
Chaque ligne correspond à un plat spécifique servi dans un restaurant donné, à une date, pour un type de repas et une catégorie précis.

Les données ont été enrichies manuellement à partir d’informations issues du site **OpenFoodFacts** (https://world-fr.openfoodfacts.org/), puis combinées avec les données récupérées via l’API **CROUStillant Menu**.

Ce choix d’enrichissement manuel a été motivé par plusieurs contraintes :
- le volume très important des données OpenFoodFacts (~9 Go),
- la complexité de leur structure,
- la forte sensibilité aux variations d’écriture des noms de plats.

- **Nombre d’observations :** 80 307 
- **Nombre de variables :** 10

### Colonnes

| Champ | Type | Description |
|----------|------|------------|
| `restaurant_id` | entier | Identifiant du restaurant |
| `date` | date | Date du menu |
| `repas` | texte | Type de repas |
| `categorie` | texte | Catégorie du plat |
| `plat` | texte | Nom du plat |
| `nutriscore` | texte | Score nutritionnel (A–E) |
| `regime` | texte | Type alimentaire (carné, végétarien, etc) |
| `impact_carbone` | texte | Empreinte carbone (bas, moyen, élevé) |
| `style_culinaire` | texte | Style du plat (soupe, cuisine traditionnelle, etc) |
| `calories_estimees` | entier | Nombre de calories estimées en kcal |

**Organisation et sous-groupes :**  

- Les données sont hiérarchisées : **restaurants → menus → types de repas → catégories → plats**  
- Chaque restaurant peut avoir plusieurs menus par jour et plusieurs plats par catégorie  

**Format :** CSV, séparateur `,`  

**Contexte et choix des données :**  

- Ces données permettent d’étudier les menus sur différentes périodes et restaurants.  
- Elles sont pertinentes pour analyser la diversité culinaire, la récurrence de certains plats, ou les préférences selon le type de repas et les catégories de plats.  


## Plan d’analyse

**Approche générale :**  

- Nettoyer les données pour éliminer les doublons et les valeurs manquantes  
- Filtrer les menus selon la période d’intérêt (ex. février 2026)  
- Comparer les distributions des types de repas et des catégories par restaurant et dans le temps  
- Identifier des tendances, anomalies ou lacunes dans l’offre des restaurants

Afin d’explorer les données issues des fichiers `liste_restaurants.csv` et `menus_complets_enrichis.csv`, nous avons sélectionné un ensemble de questions que nous avons structurées autour de plusieurs axes d’analyse.


### 1. Dynamique temporelle

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 1 | Quel jour du mois concentre le plus de menus ? | `date` | Bar chart | Identifier les pics d'activité |
| 2 | Existe-t-il une saisonnalité dans l’offre des plats ? | `date`, `categorie` | Line chart | Détecter des tendances temporelles |
| 3 | Quelle est la fréquence d'ouverture réelle des restaurants sur l'année ? | `jours_ouvert`, `restaurant_id` | Heatmap calendaire | Mesurer la régularité du service et identifier les fermetures prolongées |
| 4 | L’offre nutritionnelle évolue-t-elle dans le temps ? | `date`, `nutriscore` | Line chart | Observer l’évolution de la qualité nutritionnelle |


### 2. Structure des menus

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 5 | Quel est le Nutri-Score moyen des 100 plats les plus fréquents ? | `plat`, `nutriscore` | lollipop chart | Déterminer si les plats les plus populaires du CROUS sont équilibrés ou non |
| 6 | Comment les catégories varient-elles selon les repas ? | `repas`, `categorie` | Stacked bar | Analyser la structure des menus |
| 7 | Les restaurants proposent-ils des menus équilibrés en catégories ? | `restaurant_id`, `categorie` | Boxplot | Évaluer la diversité des menus |


### 3. Comparaison entre restaurants

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 8 | Les restaurants proposent-ils une diversité similaire ? | `restaurant_id`, `plat` | Boxplot | Comparer la richesse des menus |
| 9 | Les restaurants accessibles PMR offrent-ils des menus plus sains ? | `restaurant_id`, `ispmr`, `nutriscore` | Grouped bar chart | Vérifier si les bâtiments modernes (accessibles pmr) servent une meilleure qualité nutritionnelle |
| 10 |Quels restaurants proposent le plus de nouveautés ? | `restaurant_id`, `plat`, `date` | Line chart | Mesurer le renouvellement des menus |

### 4. Qualité nutritionnelle et environnementale

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 11 | Quelle est la distribution des Nutri-Scores ? | `nutriscore` | Bar chart | Évaluer la qualité nutritionnelle globale |
| 12 | Les restaurants diffèrent-ils en qualité nutritionnelle ? | `restaurant_id`, `nutriscore` | Stacked bar | Comparer les profils |
| 13 | Existe-t-il un lien entre calories et Nutri-Score ? | `calories_estimees`, `nutriscore` | Boxplot | Tester la cohérence nutritionnelle |
| 14 | Peut-on identifier des restaurants “écoresponsables” ? | `restaurant_id`, `impact_carbone` | Bar chart | Identifier les meilleures pratiques |


### 5. Analyse territoriale

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 15 | Existe-t-il une fracture nutritionnelle entre les régions ou les villes ? | `region`, `ville`, `nutriscore`, `regime` | Carte, Boxplot | Identifier des inégalités territoriales |
| 16 | La diversité des plats varie-t-elle selon la région ? | `region`, `restaurant_id`, `plat` | Bar chart | Comparer l’offre culinaire |
| 17 | Les restaurants proches géographiquement ont-ils des menus similaires ? | `latitude`, `longitude`, `plat` | Carte / clustering | Tester la corrélation géographique |
| 18 | Existe-t-il une fracture géographique de l'accessibilité PMR ? | `ville`, `ispmr` | Bar chart | Identifier les villes en retard sur la mise aux normes PMR |


### 6. Qualité des données

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 19 | Existe-t-il une variabilité excessive dans les noms de plats ? | `plat` | Nuage de mots | Identifier les problèmes de normalisation |
| 20 | Certains plats apparaissent-ils avec plusieurs catégories ? | `plat`, `categorie` | Bar chart | Détecter des incohérences |
| 21 | Quelle proportion de plats a des informations nutritionnelles manquantes ? | `plat`, `nutriscore`, `calories_estimees` | Bar chart | Évaluer la complétude |
| 22 | Certains restaurants ont-ils des données moins fiables ? | `restaurant_id`, `nutriscore`, `calories_estimees` | Bar chart | Identifier des sources problématiques |


### 7. Analyse énergétique et style culinaire

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 23 | Quelle est la distribution des calories des plats ? | `calories_estimees` | Histogramme, line chart | Comprendre l’apport énergétique global des menus |
| 24 | Les calories varient-elles selon les catégories de plats ? | `categorie`, `calories_estimees` | Boxplot | Identifier les catégories les plus caloriques |
| 25 | Le style culinaire influence-t-il les caractéristiques nutritionnelles des plats ? | `style_culinaire`, `calories_estimees`, `nutriscore` | Boxplot, Stacked bar | Étudier l’impact du style culinaire sur la qualité nutritionnelle |


**Approche générale :**

- Nettoyer les données pour éliminer les doublons et les valeurs manquantes  
- Filtrer les menus selon la période d’intérêt (ex. février 2026)  
- Comparer les distributions des types de repas et des catégories par restaurant et dans le temps  
- Identifier des tendances, anomalies ou lacunes dans l’offre des restaurants  
