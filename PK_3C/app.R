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

sex_idx <- rep(c("Male", "Female"), 100)
sens <- c(
  "Sex", "2mg/kg Q3W", "10mg/kg Q2W", "10mg/kg Q3W", "200mg Q3W", "400mg Q6W"
)

# 12W AUC
auc_weight <- cbind.data.frame(
  sex_idx, weight1$auc, weight2$auc, weight3$auc, weight4$auc,
  weight5$auc
)
names(auc_weight) <- sens
auc_weight <- pivot_longer(auc_weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

# Max Concentration in Central
cmax_weight <- cbind.data.frame(
  sex_idx, weight1$cmax, weight2$cmax, weight3$cmax, weight4$cmax,
  weight5$cmax
)
names(cmax_weight) <- sens
cmax_weight <- pivot_longer(cmax_weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "Cmax"
)

# Tumor Volume Change Ratio
tvcr_weight <- cbind.data.frame(
  sex_idx, weight1$tvcr, weight2$tvcr, weight3$tvcr, weight4$tvcr,
  weight5$tvcr
)
names(tvcr_weight) <- sens
tvcr_weight <- pivot_longer(tvcr_weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "TVCR"
)

# Max Complex Concentration in Tumor
ccmax_weight <- cbind.data.frame(
  sex_idx, weight1$ccmax, weight2$ccmax, weight3$ccmax, weight4$ccmax,
  weight5$ccmax
)
names(ccmax_weight) <- sens
ccmax_weight <- pivot_longer(ccmax_weight,
  cols = 2:6, names_to = "Dosing",
  values_to = "CCmax"
)

albumin1 <- readMat("data/PKSen1Albumin.mat")
albumin2 <- readMat("data/PKSen2Albumin.mat")
albumin3 <- readMat("data/PKSen3Albumin.mat")
albumin4 <- readMat("data/PKSen4Albumin.mat")
albumin5 <- readMat("data/PKSen5Albumin.mat")

# 12W AUC
auc_albumin <- cbind.data.frame(
  sex_idx, albumin1$auc, albumin2$auc, albumin3$auc, albumin4$auc,
  albumin5$auc
)
names(auc_albumin) <- sens
auc_albumin <- pivot_longer(auc_albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "AUC"
)

# Max Concentration in Central
cmax_albumin <- cbind.data.frame(
  sex_idx, albumin1$cmax, albumin2$cmax, albumin3$cmax, albumin4$cmax,
  albumin5$cmax
)
names(cmax_albumin) <- sens
cmax_albumin <- pivot_longer(cmax_albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "Cmax"
)

# Tumor Volume Change Ratio
tvcr_albumin <- cbind.data.frame(
  sex_idx, albumin1$tvcr, albumin2$tvcr, albumin3$tvcr, albumin4$tvcr,
  albumin5$tvcr
)
names(tvcr_albumin) <- sens
tvcr_albumin <- pivot_longer(tvcr_albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "TVCR"
)

# Max Complex Concentration in Tumor
ccmax_albumin <- cbind.data.frame(
  sex_idx, albumin1$ccmax, albumin2$ccmax, albumin3$ccmax, albumin4$ccmax,
  albumin5$ccmax
)
names(ccmax_albumin) <- sens
ccmax_albumin <- pivot_longer(ccmax_albumin,
  cols = 2:6, names_to = "Dosing",
  values_to = "CCmax"
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

  h4(p("Showing drug AUC, Cmax, tumor volume change ratio & pembrolizumab:PD-1 complex Cmax in 3 compartments")),
  h5(p(
    "App by Haoyin Xu, Hanzhi Wang, and Xiaoya Lu for ",
    em("Systems Pharmacology and Personalized Medicine")
  )),

  br(),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      actionButton("W", "See variations caused by weight"),
      actionButton("A", "See variations caused by albumin"),
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
      plotlyOutput(outputId = "auc", height = "300px"),
      br(),
      plotlyOutput(outputId = "cmax", height = "300px"),
      br(),
      plotlyOutput(outputId = "tvcr", height = "300px"),
      br(),
      plotlyOutput(outputId = "ccmax", height = "300px")
    )
  )
)
# ========================================================================
# APP SERVER
# Create R code for app functions
server <- function(input, output) {
  auc_s <- reactiveValues(data = auc_weight)
  cmax_s <- reactiveValues(data = cmax_weight)
  tvcr_s <- reactiveValues(data = tvcr_weight)
  ccmax_s <- reactiveValues(data = ccmax_weight)

  observeEvent(input$W, {
    auc_s$data <- auc_weight
    cmax_s$data <- cmax_weight
    tvcr_s$data <- tvcr_weight
    ccmax_s$data <- ccmax_weight
  })

  observeEvent(input$A, {
    auc_s$data <- auc_albumin
    cmax_s$data <- cmax_albumin
    tvcr_s$data <- tvcr_albumin
    ccmax_s$data <- ccmax_albumin
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
  output$auc <- renderPlotly({
    df <- auc_s$data
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
        title = "Drug AUC in Blood for 12 Weeks",

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

  # Max Concentration in Central
  output$cmax <- renderPlotly({
    df <- cmax_s$data
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
        title = "Max Drug Concentration in Blood for 12 Weeks",

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

  # Tumor Volume Change Ratio
  output$tvcr <- renderPlotly({
    df <- tvcr_s$data
    plot_c <- df %>%
      plot_ly(type = "violin")
    plot_c <- plot_c %>%
      add_trace(
        x = ~ Dosing[df$Sex == "Male"],
        y = ~ TVCR[df$Sex == "Male"],
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
        y = ~ TVCR[df$Sex == "Female"],
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
        title = "Tumor Volume Change Ratio for 12 Weeks",

        xaxis = list(
          title = "Dosing Scenario"
        ),
        yaxis = list(
          title = "Change Ratio",
          zeroline = F
        ),
        violinmode = "group"
      )
    plot_c
  })

  # Max Complex Concentration in Tumor
  output$ccmax <- renderPlotly({
    df <- ccmax_s$data
    plot_c <- df %>%
      plot_ly(type = "violin")
    plot_c <- plot_c %>%
      add_trace(
        x = ~ Dosing[df$Sex == "Male"],
        y = ~ CCmax[df$Sex == "Male"],
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
        y = ~ CCmax[df$Sex == "Female"],
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
        title = "Max Drug:Receptor Complex Concentration in Tumor for 12 Weeks",

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
}
# ========================================================================
# BUILD APP
# Knit UI and Server to create app
shinyApp(ui = ui, server = server)
