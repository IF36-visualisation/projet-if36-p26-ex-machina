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

### 2. **`liste_menus_restaurants.csv`** : liste des  menus pour chaque restaurant

### Description
Cette table contient les menus des restaurants. Chaque ligne correspond à un plat spécifique servi à un restaurant à une date donnée, dans un repas et une catégorie précis.

- **Nombre d’observations :** 82 551  
- **Nombre de variables :** 5 

### Colonnes

| Champ | Type | Description |
|-------|------|-------------|
| `restaurant_id` | entier | Identifiant unique du restaurant (correspond au champ `code` dans `liste_restaurants`) |
| `date` | date | Date du menu |
| `repas` | texte | Type de repas (`matin`, `midi`, `soir`) |
| `categorie` | texte | Catégorie du plat (`Entrées`, `Plats`, `Desserts`, etc.) |
| `plat` | texte | Nom du plat |

**Organisation et sous-groupes :**  

- Les données sont hiérarchisées : **restaurants → menus → types de repas → catégories → plats**  
- Chaque restaurant peut avoir plusieurs menus par jour et plusieurs plats par catégorie  

**Format :** CSV, séparateur `,`  

**Contexte et choix des données :**  

- Ces données permettent d’étudier les menus sur différentes périodes et restaurants.  
- Elles sont pertinentes pour analyser la diversité culinaire, la récurrence de certains plats, ou les préférences selon le type de repas et les catégories de plats.  


## Plan d’analyse

L’analyse sera exploratoire et se concentrera sur plusieurs axes :  

1. **Distribution des menus dans le temps**  
   - Quel jour sur le mois a le plus de menus ?  
   - Existe-t-il une saisonnalité dans l’offre des plats ?
   - Les restaurants publient-ils des menus de façon régulière sur la période étudiée ?  

2. **Analyse par type de repas et catégorie**  
   - Quels types de repas sont les plus fréquents (matin, midi, soir) ?  
   - Comment les catégories de plats (Entrées, Plats, Desserts) varient-elles selon les restaurants ou les périodes ?
   - Certaines catégories de plats (entrées, plats, desserts) sont-elles systématiquement absentes pour certains types de repas (matin, midi, soir) dans certains restaurants ?
   - Certains restaurants proposent-ils des menus déséquilibrés (surreprésentation d’une catégorie) ?  

3. **Comparaison entre restaurants**  
   - Les restaurants proposent-ils une diversité similaire de plats ?  
   - Quels restaurants ont le plus de menus ou de plats uniques pour une période donnée ?
   - Peut-on identifier des groupes de restaurants aux menus similaires ?
   - Quels restaurants présentent la plus forte répétition des mêmes plats ?

4. **Qualité et complétude des données**  
   - Y a-t-il des dates manquantes ou des restaurants sans menus pour certaines périodes ?  
   - Certains plats sont-ils mal catégorisés ou incomplets ?  
   - Existe-t-il des doublons dans les menus ou les restaurants ?
   - Certains plats apparaissent-ils avec des catégories différentes ?
   - Existe-t-il une variabilité excessive dans les noms des plats ?

5. **Analyse spatiale et territoriale des restaurants CROUS**
   - La diversité des plats varie-t-elle selon la zone géographique ?
   - Existe-t-il des zones à faible diversité culinaire ?
   - Les restaurants proches géographiquement proposent-ils des menus similaires ?

**Approche générale :**  

- Nettoyer les données pour éliminer les doublons et les valeurs manquantes  
- Filtrer les menus selon la période d’intérêt (ex. février 2026)  
- Comparer les distributions des types de repas et des catégories par restaurant et dans le temps  
- Identifier des tendances, anomalies ou lacunes dans l’offre des restaurants  
