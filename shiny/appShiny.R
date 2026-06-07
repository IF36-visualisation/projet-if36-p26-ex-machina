library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(scales)

# Chargement des données 
restaurants <- read_csv("liste_restaurants.csv")
menus       <- read_csv("menus_complets_enrichis.csv") %>%
  mutate(date = as.Date(date, format = "%d/%m/%Y"))

# Jointure pour avoir la région dans les menus
menus <- menus %>%
  left_join(restaurants %>% select(code, region.libelle), by = c("restaurant_id" = "code"))

# Nettoyage de base
menus <- menus %>%
  filter(!is.na(nutriscore), nutriscore != "",
         !is.na(calories_estimees), calories_estimees > 0)

# Dictionnaire de regroupement des catégories (identique au rapport)
groupes <- c(
  "Entrées"        = "entr",
  "Plats"          = "plat|chaud|accompagne|grillade",
  "Desserts"       = "dessert|douceur|patisserie|compote|yaourt",
  "Boissons"       = "boisson|cafe|froid",
  "Snacking"       = "sandwich|panini|snacking|salade",
  "Formules/Menus" = "formule|menu",
  "Petit-déjeuner" = "viennois|petit.dej"
)

classer <- function(categorie) {
  cat_lower <- tolower(categorie)
  for (groupe in names(groupes)) {
    if (str_detect(cat_lower, groupes[groupe])) return(groupe)
  }
  return("Autre")
}

menus <- menus %>%
  mutate(categorie_groupe = map_chr(categorie, classer))

# Valeurs pour les filtres
regions_dispo    <- sort(unique(menus$region.libelle[!is.na(menus$region.libelle)]))
categories_dispo <- sort(unique(menus$categorie_groupe))

# Couleurs Nutri-Score (identiques au rapport)
COULEURS_NUTRI <- c("A" = "#038141", "B" = "#85BB2F",
                    "C" = "#FECB02", "D" = "#EE8100", "E" = "#E63E11")

# UI
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "Croustillant Menu"),
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Stats",       tabName = "stats",       icon = icon("th")),
      menuItem("Nutri-Score", tabName = "nutriscore",  icon = icon("heart")),
      menuItem("Calories",    tabName = "calories",    icon = icon("fire"))
    ),
    
    # Filtres communs aux deux onglets graphiques
    conditionalPanel(
      condition = "input.tabs == 'nutriscore' || input.tabs == 'calories'",
      selectInput("region", "Région :",
                  choices  = c("Toutes" = "all", regions_dispo),
                  selected = "all"),
      selectInput("repas", "Type de repas :",
                  choices  = c("Tous" = "all", "matin", "midi", "soir"),
                  selected = "all")
    ),
    
    # Filtre catégorie uniquement sur l'onglet calories
    conditionalPanel(
      condition = "input.tabs == 'calories'",
      selectInput("categorie", "Catégorie :",
                  choices  = c("Toutes" = "all", categories_dispo),
                  selected = "all")
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # Onglet Stats
      tabItem(tabName = "stats",
              fluidRow(
                valueBox(nrow(restaurants),      subtitle = "Restaurants",     icon = icon("store"),    color = "blue",   width = 4),
                valueBox(nrow(menus),             subtitle = "Entrées de menu", icon = icon("list"),     color = "aqua",   width = 4),
                valueBox(n_distinct(menus$plat),  subtitle = "Plats distincts", icon = icon("utensils"), color = "green",  width = 4)
              ),
              fluidRow(
                infoBoxOutput("nb_regions"),
                infoBoxOutput("cal_moyenne"),
                infoBoxOutput("pct_nutri_a")
              )
      ),
      
      # Onglet Nutri-Score
      tabItem(tabName = "nutriscore",
              h2("Distribution des Nutri-Scores"),
              fluidRow(
                box(title = "Répartition globale (interactif)", status = "primary",
                    solidHeader = TRUE,  width = 6, plotlyOutput("bar_nutri")),
                box(title = "Par catégorie de plat",            status = "warning",
                    solidHeader = FALSE, width = 6, plotOutput("bar_nutri_cat"))
              )
      ),
      
      # Onglet Calories
      tabItem(tabName = "calories",
              h2("Distribution des calories par catégorie"),
              fluidRow(
                box(title = "Boxplot par catégorie",              status = "danger",
                    solidHeader = TRUE,  width = 7, plotOutput("box_calories")),
                box(title = "Calories moyennes par catégorie",    status = "warning",
                    solidHeader = FALSE, width = 5, plotOutput("bar_cal_cat"))
              )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Données filtrées réactives (région + repas)
  filtered <- reactive({
    df <- menus
    if (input$region   != "all") df <- df %>% filter(region.libelle == input$region)
    if (input$repas    != "all") df <- df %>% filter(repas          == input$repas)
    df
  })
  
  # Données filtrées réactives (région + repas + catégorie)
  filtered_cal <- reactive({
    df <- filtered()
    if (input$categorie != "all") df <- df %>% filter(categorie_groupe == input$categorie)
    df
  })
  
  # InfoBoxes Stats
  output$nb_regions <- renderInfoBox({
    infoBox("Régions couvertes",
            value = n_distinct(menus$region.libelle, na.rm = TRUE),
            icon = icon("map"), color = "purple", width = 4)
  })
  output$cal_moyenne <- renderInfoBox({
    infoBox("Calories moyennes",
            value = paste0(round(mean(menus$calories_estimees), 0), " kcal"),
            icon = icon("fire"), color = "red", width = 4)
  })
  output$pct_nutri_a <- renderInfoBox({
    pct <- round(mean(menus$nutriscore == "A") * 100, 1)
    infoBox("Part Nutri-Score A",
            value = paste0(pct, "%"),
            icon = icon("leaf"), color = "green", width = 4)
  })
  
  # Bar chart Nutri-Score global — plotly
  output$bar_nutri <- renderPlotly({
    p <- filtered() %>%
      count(nutriscore) %>%
      mutate(nutriscore = factor(nutriscore, levels = c("A","B","C","D","E"))) %>%
      ggplot(aes(x = nutriscore, y = n, fill = nutriscore,
                 text = paste0("Score : ", nutriscore, "\nNombre : ", n))) +
      geom_col(width = 0.6) +
      scale_fill_manual(values = COULEURS_NUTRI) +
      theme_minimal(base_size = 11) +
      theme(legend.position = "none") +
      labs(x = "Nutri-Score", y = "Nombre de plats")
    
    ggplotly(p, tooltip = "text")
  })
  
  # Bar chart Nutri-Score par catégorie — ggplot
  output$bar_nutri_cat <- renderPlot({
    filtered() %>%
      filter(categorie_groupe != "Autre") %>%
      count(categorie_groupe, nutriscore) %>%
      group_by(categorie_groupe) %>%
      mutate(proportion = n / sum(n)) %>%
      ungroup() %>%
      mutate(nutriscore = factor(nutriscore, levels = c("A","B","C","D","E"))) %>%
      ggplot(aes(x = reorder(categorie_groupe, proportion),
                 y = proportion, fill = nutriscore)) +
      geom_col(position = "fill", width = 0.6) +
      scale_fill_manual(values = COULEURS_NUTRI, name = "Nutri-Score") +
      scale_y_continuous(labels = percent_format()) +
      coord_flip() +
      theme_minimal(base_size = 11) +
      labs(x = NULL, y = "Proportion")
  })
  
  # Boxplot calories — ggplot
  output$box_calories <- renderPlot({
    filtered_cal() %>%
      filter(categorie_groupe != "Autre") %>%
      ggplot(aes(x    = reorder(categorie_groupe, calories_estimees, median),
                 y    = calories_estimees,
                 fill = categorie_groupe)) +
      geom_boxplot(outlier.size = 0.8, alpha = 0.7, show.legend = FALSE) +
      scale_fill_brewer(palette = "Set2") +
      coord_flip() +
      theme_minimal(base_size = 11) +
      labs(x = NULL, y = "Calories (kcal)")
  })
  
  # Bar chart calories moyennes — ggplot
  output$bar_cal_cat <- renderPlot({
    filtered_cal() %>%
      filter(categorie_groupe != "Autre") %>%
      group_by(categorie_groupe) %>%
      summarise(cal_moy = mean(calories_estimees, na.rm = TRUE), .groups = "drop") %>%
      ggplot(aes(x = reorder(categorie_groupe, cal_moy), y = cal_moy,
                 fill = categorie_groupe)) +
      geom_col(width = 0.6, show.legend = FALSE) +
      scale_fill_brewer(palette = "Set2") +
      coord_flip() +
      theme_minimal(base_size = 11) +
      labs(x = NULL, y = "Calories moy. (kcal)")
  })
}

shinyApp(ui, server)