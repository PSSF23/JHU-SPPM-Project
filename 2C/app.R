# Load necessary packages
library("R.matlab")
library("tidyverse")
library("patchwork")
library("shiny")
library("plotly")
# ========================================================================
# DATA
# Process the simulation files
weight1 <- readMat("data/AUC12WSen1Weight.mat")
weight2 <- readMat("data/AUC12WSen2Weight.mat")
weight3 <- readMat("data/AUC12WSen3Weight.mat")
weight4 <- readMat("data/AUC12WSen4Weight.mat")
weight5 <- readMat("data/AUC12WSen5Weight.mat")

sex_idx <- rep(c("Male", "Female"), 1000)

auc1weight <- cbind.data.frame(
  sex_idx, weight1$auc1, weight2$auc1, weight2$auc1, weight2$auc1,
  weight2$auc1)

names(auc1weight) <- c(
  "Sex", "2mg/kg Q3W", "10mg/kg Q2W", "10mg/kg Q3W", "200mg Q3W", "400mg Q6W"
)
auc1weight <- pivot_longer(auc1weight,
                     cols = 2:6, names_to = "Dosing",
                     values_to = "AUC"
)

auc2weight <- cbind.data.frame(
  sex_idx, weight1$auc2, weight2$auc2, weight2$auc2, weight2$auc2,
  weight2$auc2)

names(auc2weight) <- c(
  "Sex", "2mg/kg Q3W", "10mg/kg Q2W", "10mg/kg Q3W", "200mg Q3W", "400mg Q6W"
)
auc2weight <- pivot_longer(auc2weight,
                     cols = 2:6, names_to = "Dosing",
                     values_to = "AUC"
)
# ========================================================================
# PLOTS
# Plot graphs with simulations
my_theme <- theme_light() +
  theme(
    text = element_text(size = 24),
    plot.title = element_text(hjust = 0.5),
    axis.title.x = element_text(margin = margin(10, 0, 0, 0)),
    axis.title.y = element_text(margin = margin(0, 10, 0, 0)),
    axis.text.x = element_text(margin = margin(5, 0, 0, 0)),
    axis.text.y = element_text(margin = margin(0, 5, 0, 0))
  )
# ========================================================================
# APP UI
# Design UI for app
ui <- fluidPage(
  titlePanel(strong("Modeling of Pembrolizumab with 5 Dosing Scenarios")),
  
  h4(p("Showing drug AUC in 2 compartments")),
  h5(p("App by Haoyin Xu, Hanzhi Wang, and Xiaoya Lu for ", 
  em("Systems Pharmacology and Personalized Medicine"))),
  
  br(),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      actionButton("S1", "Scenario 1"),
      actionButton("S2", "Scenario 2"),
      actionButton("S3", "Scenario 3"),
      actionButton("S4", "Scenario 4"),
      actionButton("S5", "Scenario 5"),
    ),
    
    mainPanel(
      width = 9,
      plotlyOutput(outputId = "c", height = "600px"),
      br(),
      plotlyOutput(outputId = "p", height = "600px")
    )
  )
)
# ========================================================================
# APP SERVER
# Create R code for app functions
server <- function(input, output) {
  auc1_s <- reactiveValues(data = NULL)
  auc2_s <- reactiveValues(data = NULL)
  
  observeEvent(input$S1, {
    auc1_s$data <- filter(auc1weight, Dosing == "2mg/kg Q3W")
    auc2_s$data <- filter(auc2weight, Dosing == "2mg/kg Q3W")
  })
  
  observeEvent(input$S2, {
    auc1_s$data <- filter(auc1weight, Dosing == "10mg/kg Q2W")
    auc2_s$data <- filter(auc2weight, Dosing == "10mg/kg Q2W")
  })
  
  observeEvent(input$S3, {
    auc1_s$data <- filter(auc1weight, Dosing == "10mg/kg Q3W")
    auc2_s$data <- filter(auc2weight, Dosing == "10mg/kg Q3W")
  })
  
  observeEvent(input$S4, {
    auc1_s$data <- filter(auc1weight, Dosing == "200mg Q3W")
    auc2_s$data <- filter(auc2weight, Dosing == "200mg Q3W")
  })

  observeEvent(input$S5, {
    auc1_s$data <- filter(auc1weight, Dosing == "400mg Q6W")
    auc2_s$data <- filter(auc2weight, Dosing == "400mg Q6W")
  })
  
  output$c <- renderPlotly({
    if (is.null(auc1_s$data)) {
      return()
    }
    df <- auc1_s$data
    plot_c <- df %>%
      plot_ly(type = "violin")
    plot_c <- plot_c %>%
      add_trace(
        x = ~ Dosing[df$Sex == "Male"],
        y = ~ AUC[df$Sex == "Male"],
        legendgroup = "M",
        scalegroup = "M",
        name = "Male",
        box = list(
          visible = T
        ),
        meanline = list(
          visible = T
        ),
        color = I("blue")
      )
    plot_c <- plot_c %>%
      add_trace(
        x = ~ Dosing[df$Sex == "Female"],
        y = ~ AUC[df$Sex == "Female"],
        legendgroup = "F",
        scalegroup = "F",
        name = "Female",
        box = list(
          visible = T
        ),
        meanline = list(
          visible = T
        ),
        color = I("pink")
      )
    plot_c <- plot_c %>%
      layout(
        title = "12W AUC for Central Compartment",
        
        xaxis = list(
          title = "Dosing Scenario"
        ),
        yaxis = list(
          title = "AUC",
          zeroline = F
        ),
        violinmode = "group"
      )
    plot_c
  })
  
  output$p <- renderPlotly({
    if (is.null(auc2_s$data)) {
      return()
    }
    df <- auc2_s$data
    plot_p <- df %>%
      plot_ly(type = "violin")
    plot_p <- plot_p %>%
      add_trace(
        x = ~ Dosing[df$Sex == "Male"],
        y = ~ AUC[df$Sex == "Male"],
        legendgroup = "M",
        scalegroup = "M",
        name = "Male",
        box = list(
          visible = T
        ),
        meanline = list(
          visible = T
        ),
        color = I("blue")
      )
    plot_p <- plot_p %>%
      add_trace(
        x = ~ Dosing[df$Sex == "Female"],
        y = ~ AUC[df$Sex == "Female"],
        legendgroup = "F",
        scalegroup = "F",
        name = "Female",
        box = list(
          visible = T
        ),
        meanline = list(
          visible = T
        ),
        color = I("pink")
      )
    plot_p <- plot_p %>%
      layout(
        title = "12W AUC for Peripheral Compartment",
        xaxis = list(
          title = "Dosing Scenario"
        ),
        yaxis = list(
          title = "AUC",
          zeroline = F
        ),
        violinmode = "group"
      )
    plot_p
  })
}
# ========================================================================
# BUILD APP
# Knit UI and Server to create app
shinyApp(ui = ui, server = server)
