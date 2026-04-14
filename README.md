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
- **Nombre de variables :** 21  

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
- **Nombre de variables :** 11

### Colonnes

| Champ | Type | Description |
|----------|------|------------|
| `restaurant_id` | entier | Identifiant du restaurant |
| `date` | date | Date du menu |
| `repas` | texte | Type de repas |
| `categorie` | texte | Catégorie du plat |
| `plat` | texte | Nom du plat |
| `nutriscore` | texte | Score nutritionnel (A–E) |
| `regime` | texte | Type alimentaire (carné, végétarien, ect) |
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

L’analyse sera exploratoire et se concentrera sur plusieurs axes :  

### 1. Distribution des menus dans le temps

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 1 | Quel jour du mois concentre le plus de menus ? | `date` | Bar chart | Identifier les pics d'activité |
| 2 | Existe-t-il une saisonnalité dans l'offre des plats ? | `date`, `plat` | Line chart | Détecter des tendances temporelles |
| 3 | Les restaurants publient-ils des menus régulièrement ? | `date`, `restaurant_id` | Heatmap | Mesurer la régularité des publications |

### 2. Analyse par type de repas et catégorie

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 4 | Quels types de repas sont les plus fréquents ? | `repas` | Bar chart | Comprendre la répartition matin/midi/soir |
| 5 | Comment les catégories varient-elles selon le repas et le restaurant ? | `repas`, `categorie`, `restaurant_id` | Stacked bar, Heatmap | Analyser la diversité par repas |
| 6 | Certaines catégories sont-elles systématiquement absentes selon le repas ? | `repas`, `categorie`, `restaurant_id` | Heatmap | Détecter les absences structurelles |
| 7 | Certains restaurants ont-ils des menus déséquilibrés ? | `restaurant_id`, `categorie`, `NbPlats (COUNT plat)` | Boxplot, Bar chart | Repérer les surreprésentations de catégorie |

### 3. Comparaison entre restaurants

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 8 | Les restaurants proposent-ils une diversité similaire ? | `restaurant_id`, `NbPlatsUniques (COUNT DISTINCT plat)` | Bar chart, Boxplot | Comparer la richesse des menus |
| 9 | Quels restaurants ont le plus de plats uniques sur la période ? | `restaurant_id`, `date`, `NbPlatsUniques` | Bar chart | Identifier les restaurants les plus variés |
| 10 | Peut-on regrouper des restaurants aux menus similaires ? | `restaurant_id`, `plat`, `categorie` | Heatmap, Dendrogramme | Former des clusters de restaurants |
| 11 | Quels restaurants répètent le plus les mêmes plats ? | `restaurant_id`, `plat`, `TauxRepetition (COUNT plat / NbPlatsUniques)` | Bar chart | Mesurer la monotonie de l'offre |

### 4. Qualité et complétude des données

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 12 | Y a-t-il des dates manquantes pour certains restaurants ? | `date`, `restaurant_id` | Heatmap | Évaluer la complétude temporelle |
| 13 | Certains plats sont-ils mal catégorisés ou incomplets ? | `plat`, `categorie` | Table, Bar chart | Repérer les anomalies de catégorisation |
| 14 | Existe-t-il des doublons dans les menus ? | `restaurant_id`, `plat`, `date`, `repas`, `categorie` | Table | Quantifier les doublons exacts |
| 15 | Certains plats apparaissent-ils avec des catégories différentes ? | `plat`, `categorie`, `NbCategories (COUNT DISTINCT categorie)` | Bar chart, Table | Détecter les incohérences de classification |
| 16 | Existe-t-il une variabilité excessive dans les noms de plats ? | `plat` | Nuage de mots, Bar chart | Identifier les problèmes de normalisation |

### 5. Analyse spatiale et territoriale

| # | Question | Variables | Visualisation | Objectif |
|---|----------|-----------|---------------|----------|
| 17 | La diversité des plats varie-t-elle selon la zone géographique ? | `latitude`, `longitude`, `region.libelle`, `NbPlatsUniques` | Carte choroplèthe, Bar chart | Visualiser les inégalités territoriales |
| 18 | Existe-t-il des zones à faible diversité culinaire ? | `region.libelle`, `zone`, `NbPlatsUniques` | Carte choroplèthe | Identifier les déserts culinaires |
| 19 | Les restaurants proches géographiquement ont-ils des menus similaires ? | `latitude`, `longitude`, `restaurant_id`, `plat` | Scatter map, Heatmap | Tester la corrélation géographique des menus |

**Approche générale :**  

- Nettoyer les données pour éliminer les doublons et les valeurs manquantes  
- Filtrer les menus selon la période d’intérêt (ex. février 2026)  
- Comparer les distributions des types de repas et des catégories par restaurant et dans le temps  
- Identifier des tendances, anomalies ou lacunes dans l’offre des restaurants  
