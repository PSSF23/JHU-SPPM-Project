########## Load Packages ########
library("R.matlab")
library("tidyverse")
library("patchwork")
library("plotly")
library("shiny")
# ========================================================================
# LOAD DATA
Q3W_10_raw <- readMat("data/10mgQ3W.mat")
Q2W_10_raw <- readMat("data/10mgQ2W.mat")
Q3W_2_raw <- readMat("data/2mgQ3W.mat")

# Data frame
Q3W_10_raw <- as.data.frame(Q3W_10_raw)
Q3W_2_raw <- as.data.frame(Q3W_2_raw)
Q2W_10_raw <- as.data.frame(Q2W_10_raw)

# Combine data
Q3W_10 <- cbind(Q3W_10_raw, Dose = rep.int("Q3W_10mg",
  times = nrow(Q3W_10_raw)
))
Q3W_2 <- cbind(Q3W_2_raw, Dose = rep.int("Q3W_2mg",
  times = nrow(Q3W_2_raw)
))
Q2W_10 <- cbind(Q2W_10_raw, Dose = rep.int("Q2W_10mg",
  times = nrow(Q2W_10_raw)
))
names(Q3W_10) <- c("Time", "V1", "V2", "V3", "Dose")
names(Q2W_10) <- c("Time", "V1", "V2", "V3", "Dose")
names(Q3W_2) <- c("Time", "V1", "V2", "V3", "Dose")
Data_all <- rbind(Q3W_10, Q3W_2, Q2W_10)
Data_all <- rbind(
  Data_all, c(0, 0, 0, 0, "Q3W_10mg"),
  c(0, 0, 0, 0, "Q3W_2mg"), c(0, 0, 0, 0, "Q2W_10mg")
)
Data_all$Time <- as.double(Data_all$Time) / 7
Data_all$V1 <- as.double(Data_all$V1)
Data_all$V2 <- as.double(Data_all$V2)
Data_all$V3 <- as.double(Data_all$V3)
Data_all$Dose <- factor(Data_all$Dose)

# Define theme
theme <- theme_light() +
  theme(
    text = element_text(size = 16),
    plot.title = element_text(hjust = 0.5),
    axis.title.x = element_text(margin = margin(10, 0, 0, 0)),
    axis.title.y = element_text(margin = margin(0, 10, 0, 0)),
    axis.text.x = element_text(margin = margin(5, 0, 0, 0)),
    axis.text.y = element_text(margin = margin(0, 5, 0, 0))
  )

# Plot graph
plot1 <- ggplot() +
  geom_line(data = Data_all, aes(
    x = Time, y = V1, color = Dose,
    linetype = Dose
  ), size = 1.3) +
  # scale_color_brewer(name = "", palette = "Dark2") +
  scale_y_continuous(
    trans = "log10", limits = c(5, 500),
    breaks = c(5, 10, 20, 50, 100, 200, 500)
  ) +
  theme +
  labs(
    title = "Typical Pembrolizumab Concentration-Time Profile",
    x = "Time Since First Dose, week",
    y = "Pembrolizumab Concentration, mg/L"
  ) +
  theme(
    panel.grid = element_blank(), legend.position = c(0.9, 0.15),
    legend.text = element_text(size = 10),
    legend.background = element_blank(),
    legend.title = element_blank()
  )
# ========================================================================
# APP UI
ui <- fluidPage(
  titlePanel(strong("Modeling of Pembrolizumab with Different Dosing")),

  h4(p("Showing drug concentrations and simulated parameters")),
  h5(p(
    "App by Haoyin Xu, Hanzhi Wang and Xiaoya Lu for ",
    em("Systems Pharmacology and Personalized Medicine")
  )),

  br(),
  plotlyOutput(outputId = "dose")
)
# ========================================================================
# APP SERVER
server <- function(input, output) {
  output$dose <- renderPlotly({
    ggplotly(plot1)
  })
}
# ========================================================================
# BUILD APP
shinyApp(ui = ui, server = server)
