# Load necessary packages
library("R.matlab")
library("tidyverse")
library("patchwork")
library("shiny")
library("plotly")
# ========================================================================
# DATA
# Process the simulation files
weight1 <- readMat("data/PKSen1Weight.mat")
weight2 <- readMat("data/PKSen2Weight.mat")
weight3 <- readMat("data/PKSen3Weight.mat")
weight4 <- readMat("data/PKSen4Weight.mat")
weight5 <- readMat("data/PKSen5Weight.mat")

sex_idx <- rep(c("Male", "Female"), 1000)
sens <- c(
  "Sex", "2mg/kg Q3W", "10mg/kg Q2W", "10mg/kg Q3W", "200mg Q3W", "400mg Q6W"
)

# 12W AUC
auc1weight <- cbind.data.frame(
  sex_idx, weight1$auc1, weight2$auc1, weight3$auc1, weight4$auc1,
  weight5$auc1
)
names(auc1weight) <- sens
auc1weight <- pivot_longer(auc1weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

auc2weight <- cbind.data.frame(
  sex_idx, weight1$auc2, weight2$auc2, weight3$auc2, weight4$auc2,
  weight5$auc2
)
names(auc2weight) <- sens
auc2weight <- pivot_longer(auc2weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

# 4W AUC
auc4w1weight <- cbind.data.frame(
  sex_idx, weight1$auc4w1, weight2$auc4w1, weight3$auc4w1, weight4$auc4w1,
  weight5$auc4w1
)
names(auc4w1weight) <- sens
auc4w1weight <- pivot_longer(auc4w1weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

auc4w2weight <- cbind.data.frame(
  sex_idx, weight1$auc4w2, weight2$auc4w2, weight3$auc4w2, weight4$auc4w2,
  weight5$auc4w2
)
names(auc4w2weight) <- sens
auc4w2weight <- pivot_longer(auc4w2weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

# Max Concentration
cmax1weight <- cbind.data.frame(
  sex_idx, weight1$cmax1, weight2$cmax1, weight3$cmax1, weight4$cmax1,
  weight5$cmax1
)
names(cmax1weight) <- sens
cmax1weight <- pivot_longer(cmax1weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "Cmax"
)

cmax2weight <- cbind.data.frame(
  sex_idx, weight1$cmax2, weight2$cmax2, weight3$cmax2, weight4$cmax2,
  weight5$cmax2
)
names(cmax2weight) <- sens
cmax2weight <- pivot_longer(cmax2weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "Cmax"
)

albumin1 <- readMat("data/PKSen1Albumin.mat")
albumin2 <- readMat("data/PKSen2Albumin.mat")
albumin3 <- readMat("data/PKSen3Albumin.mat")
albumin4 <- readMat("data/PKSen4Albumin.mat")
albumin5 <- readMat("data/PKSen5Albumin.mat")

# 12W AUC
auc1albumin <- cbind.data.frame(
  sex_idx, albumin1$auc1, albumin2$auc1, albumin3$auc1, albumin4$auc1,
  albumin5$auc1
)
names(auc1albumin) <- sens
auc1albumin <- pivot_longer(auc1albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

auc2albumin <- cbind.data.frame(
  sex_idx, albumin1$auc2, albumin2$auc2, albumin3$auc2, albumin4$auc2,
  albumin5$auc2
)
names(auc2albumin) <- sens
auc2albumin <- pivot_longer(auc2albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

# 4W AUC
auc4w1albumin <- cbind.data.frame(
  sex_idx, albumin1$auc4w1, albumin2$auc4w1, albumin3$auc4w1, albumin4$auc4w1,
  albumin5$auc4w1
)
names(auc4w1albumin) <- sens
auc4w1albumin <- pivot_longer(auc4w1albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

auc4w2albumin <- cbind.data.frame(
  sex_idx, albumin1$auc4w2, albumin2$auc4w2, albumin3$auc4w2, albumin4$auc4w2,
  albumin5$auc4w2
)
names(auc4w2albumin) <- sens
auc4w2albumin <- pivot_longer(auc4w2albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

# Max Concentration
cmax1albumin <- cbind.data.frame(
  sex_idx, albumin1$cmax1, albumin2$cmax1, albumin3$cmax1, albumin4$cmax1,
  albumin5$cmax1
)
names(cmax1albumin) <- sens
cmax1albumin <- pivot_longer(cmax1albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "Cmax"
)

cmax2albumin <- cbind.data.frame(
  sex_idx, albumin1$cmax2, albumin2$cmax2, albumin3$cmax2, albumin4$cmax2,
  albumin5$cmax2
)
names(cmax2albumin) <- sens
cmax2albumin <- pivot_longer(cmax2albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "Cmax"
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

  h4(p("Showing drug AUCs & Cmax in 2 compartments")),
  h5(p(
    "App by Haoyin Xu, Hanzhi Wang, and Xiaoya Lu for ",
    em("Systems Pharmacology and Personalized Medicine")
  )),

  br(),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      actionButton("W", "Weight"),
      actionButton("A", "Albumin"),
      # br(),
      # br(),
      # actionButton("S1", "Scenario 1"),
      # actionButton("S2", "Scenario 2"),
      # actionButton("S3", "Scenario 3"),
      # actionButton("S4", "Scenario 4"),
      # actionButton("S5", "Scenario 5"),
    ),

    mainPanel(
      width = 9,
      plotlyOutput(outputId = "c", height = "600px"),
      br(),
      plotlyOutput(outputId = "p", height = "600px"),
      br(),
      plotlyOutput(outputId = "c4w", height = "600px"),
      br(),
      plotlyOutput(outputId = "p4w", height = "600px"),
      br(),
      plotlyOutput(outputId = "cm", height = "600px"),
      br(),
      plotlyOutput(outputId = "pm", height = "600px")
    )
  )
)
# ========================================================================
# APP SERVER
# Create R code for app functions
server <- function(input, output) {
  auc1_s <- reactiveValues(data = auc1weight)
  auc2_s <- reactiveValues(data = auc2weight)
  auc4w1_s <- reactiveValues(data = auc4w1weight)
  auc4w2_s <- reactiveValues(data = auc4w2weight)
  cmax1_s <- reactiveValues(data = cmax1weight)
  cmax2_s <- reactiveValues(data = cmax2weight)

  observeEvent(input$W, {
    auc1_s$data <- auc1weight
    auc2_s$data <- auc2weight
    auc4w1_s$data <- auc4w1weight
    auc4w2_s$data <- auc4w2weight
    cmax1_s$data <- cmax1weight
    cmax2_s$data <- cmax2weight
  })

  observeEvent(input$A, {
    auc1_s$data <- auc1albumin
    auc2_s$data <- auc2albumin
    auc4w1_s$data <- auc4w1albumin
    auc4w2_s$data <- auc4w2albumin
    cmax1_s$data <- cmax1albumin
    cmax2_s$data <- cmax2albumin
  })

  # observeEvent(input$S1, {
  #   auc1_s$data <- filter(auc1_s$data, Dosing == "2mg/kg Q3W")
  #   auc2_s$data <- filter(auc2_s$data, Dosing == "2mg/kg Q3W")
  # })
  #
  # observeEvent(input$S2, {
  #   auc1_s$data <- filter(auc1weight, Dosing == "10mg/kg Q2W")
  #   auc2_s$data <- filter(auc2weight, Dosing == "10mg/kg Q2W")
  # })
  #
  # observeEvent(input$S3, {
  #   auc1_s$data <- filter(auc1weight, Dosing == "10mg/kg Q3W")
  #   auc2_s$data <- filter(auc2weight, Dosing == "10mg/kg Q3W")
  # })
  #
  # observeEvent(input$S4, {
  #   auc1_s$data <- filter(auc1weight, Dosing == "200mg Q3W")
  #   auc2_s$data <- filter(auc2weight, Dosing == "200mg Q3W")
  # })
  #
  # observeEvent(input$S5, {
  #   auc1_s$data <- filter(auc1weight, Dosing == "400mg Q6W")
  #   auc2_s$data <- filter(auc2weight, Dosing == "400mg Q6W")
  # })

  # 12W AUC
  output$c <- renderPlotly({
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

  # 4W AUC
  output$c4w <- renderPlotly({
    df <- auc4w1_s$data
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
        title = "4W AUC for Central Compartment",

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

  output$p4w <- renderPlotly({
    df <- auc4w2_s$data
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
        title = "4W AUC for Peripheral Compartment",
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

  # Max Concentration
  output$cm <- renderPlotly({
    df <- cmax1_s$data
    plot_c <- df %>%
      plot_ly(type = "violin")
    plot_c <- plot_c %>%
      add_trace(
        x = ~ Dosing[df$Sex == "Male"],
        y = ~ Cmax[df$Sex == "Male"],
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
        y = ~ Cmax[df$Sex == "Female"],
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
        title = "Max Concentration for Central Compartment",

        xaxis = list(
          title = "Dosing Scenario"
        ),
        yaxis = list(
          title = "Concentration",
          zeroline = F
        ),
        violinmode = "group"
      )
    plot_c
  })

  output$pm <- renderPlotly({
    df <- cmax2_s$data
    plot_p <- df %>%
      plot_ly(type = "violin")
    plot_p <- plot_p %>%
      add_trace(
        x = ~ Dosing[df$Sex == "Male"],
        y = ~ Cmax[df$Sex == "Male"],
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
        y = ~ Cmax[df$Sex == "Female"],
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
        title = "Max Concentration for Peripheral Compartment",
        xaxis = list(
          title = "Dosing Scenario"
        ),
        yaxis = list(
          title = "Concentration",
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
