########## Load Packages ########
library("R.matlab")
library("tidyverse")
library("patchwork")
library("plotly")
library("shiny")
library(latex2exp)
library(shinydashboard)
source('helper_funs.R')
###### Create a reusable theme######

my_theme <- theme_light() +
  theme(text = element_text(size = 20),
        plot.title = element_text(hjust = 0.5))
########### Data Processing ######################==========================================================
######### Dosing tags ##########
dosing_tag <-
  c('2mg/kg Q3W',
    '10mg/kg Q3W',
    '10mg/kg Q2W',
    '200mg Q3W',
    '400mg Q6W')
retake_tag <- c('1/5', '2/5', '3/5', '4/5', '5/5') #retake dosing cycles
#######2C Model #############
#Read full dose data
Full_2C_2mg_Q3W <- readMat("data/Full_2C_2mg_kg_Q3W.mat")
Full_2C_10mg_Q3W <- readMat("data/Full_2C_10mg_kg_Q3W.mat")
Full_2C_10mg_Q2W <- readMat("data/Full_2C_10mg_kg_Q2W.mat")
Full_2C_200mg_Q3W <- readMat("data/Full_2C_200mg_Q3W.mat")
Full_2C_400mg_Q6W <- readMat("data/Full_2C_400mg_Q6W.mat")

full_2C <-
  process_data_2C(
    list(
      Full_2C_2mg_Q3W,
      Full_2C_10mg_Q3W,
      Full_2C_10mg_Q2W,
      Full_2C_200mg_Q3W,
      Full_2C_400mg_Q6W
    ),
    dosing_tag,
    scheme = 'full'
  )
#Read missed dose data
miss_2C_2mg_Q3W <- readMat("data/Missed_2C_2mg_kg_Q3W.mat")
miss_2C_10mg_Q3W <- readMat("data/Missed_2C_10mg_kg_Q3W.mat")
miss_2C_10mg_Q2W <- readMat("data/Missed_2C_10mg_kg_Q2W.mat")
miss_2C_200mg_Q3W <- readMat("data/Missed_2C_200mg_Q3W.mat")
miss_2C_400mg_Q6W <- readMat("data/Missed_2C_400mg_Q6W.mat")

miss_2C <-
  process_data_2C(
    list(
      miss_2C_2mg_Q3W,
      miss_2C_10mg_Q3W,
      miss_2C_10mg_Q2W,
      miss_2C_200mg_Q3W,
      miss_2C_400mg_Q6W
    ),
    dosing_tag = dosing_tag,
    scheme = 'miss'
  )
#Read retaken dose data
retake_2C_2mg_Q3W <- readMat("data/Retake_2C_2mg_kg_Q3W.mat")
retake_2C_10mg_Q3W <- readMat("data/Retake_2C_10mg_kg_Q3W.mat")
retake_2C_10mg_Q2W <- readMat("data/Retake_2C_10mg_kg_Q2W.mat")
retake_2C_200mg_Q3W <- readMat("data/Retake_2C_200mg_Q3W.mat")
retake_2C_400mg_Q6W <- readMat("data/Retake_2C_400mg_Q6W.mat")

retake_2C <-
  process_data_retake_2C(
    list(
      retake_2C_2mg_Q3W,
      retake_2C_10mg_Q3W,
      retake_2C_10mg_Q2W,
      retake_2C_200mg_Q3W,
      retake_2C_400mg_Q6W
    ),
    dosing_tag,
    retake_tag
  )

# Combine AUC, Cmax and Ctrough
AUC_2C <- rbind(full_2C[['AUC']], miss_2C[['AUC']], retake_2C[['AUC']])
Cmax_2C <-
  rbind(full_2C[['Cmax']], miss_2C[['Cmax']], retake_2C[['Cmax']])
Ctrough_2C <-
  rbind(full_2C[['Ctrough']], miss_2C[['Ctrough']], retake_2C[['Ctrough']])

AUC_2C$Dosing <- factor(AUC_2C$Dosing, levels = dosing_tag)
AUC_2C$Scheme <- factor(AUC_2C$Scheme)

Cmax_2C$Dosing <- factor(Cmax_2C$Dosing, levels = dosing_tag)
Cmax_2C$Scheme <- factor(Cmax_2C$Scheme)

Ctrough_2C$Dosing <- factor(Ctrough_2C$Dosing, levels = dosing_tag)
Ctrough_2C$Scheme <- factor(Ctrough_2C$Scheme)

### Plot AUC, Cmax and Ctrough for debugging ###
AUC_2C_plot <- ggplot(AUC_2C, aes(x = Scheme, y = AUC)) +
  geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
  facet_wrap(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "AUC (mg*Day/L)", x = "Schemes", title = 'AUC in Blood, 12 Weeks (2C model)') +
  my_theme +
  theme(legend.position = "none") +
  theme(
    axis.text.x = element_text(size = 16, angle = 0),
    axis.title.x = element_text(size = 20, vjust = 0)
  )
AUC_2C_plot

Cmax_2C_plot <- ggplot(Cmax_2C, aes(x = Scheme, y = Cmax)) +
  geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
  facet_wrap(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "Cmax (mg/L)", x = "Schemes", title = 'Cmax in Blood, 12 Weeks (2C model)') +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
Cmax_2C_plot

Ctrough_2C_plot <- ggplot(Ctrough_2C, aes(x = Scheme, y = Ctrough)) +
  geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
  facet_wrap(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "Ctrough (mg/L)", x = "Schemes", title = 'Ctrough in Blood, 12 Weeks (2C model)') +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
Ctrough_2C_plot


####### 3C Model ###########
#Read full dose data
Full_3C_2mg_Q3W <- readMat("data/Full_3C_2mg_kg_Q3W.mat")
Full_3C_10mg_Q3W <- readMat("data/Full_3C_10mg_kg_Q3W.mat")
Full_3C_10mg_Q2W <- readMat("data/Full_3C_10mg_kg_Q2W.mat")
Full_3C_200mg_Q3W <- readMat("data/Full_3C_200mg_Q3W.mat")
Full_3C_400mg_Q6W <- readMat("data/Full_3C_400mg_Q6W.mat")

full_3C <-
  process_data_3C(
    list(
      Full_3C_2mg_Q3W,
      Full_3C_10mg_Q3W,
      Full_3C_10mg_Q2W,
      Full_3C_200mg_Q3W,
      Full_3C_400mg_Q6W
    ),
    dosing_tag,
    scheme = 'full'
  )
#Read missed dose data
miss_3C_2mg_Q3W <- readMat("data/Missed_3C_2mg_kg_Q3W.mat")
miss_3C_10mg_Q3W <- readMat("data/Missed_3C_10mg_kg_Q3W.mat")
miss_3C_10mg_Q2W <- readMat("data/Missed_3C_10mg_kg_Q2W.mat")
miss_3C_200mg_Q3W <- readMat("data/Missed_3C_200mg_Q3W.mat")
miss_3C_400mg_Q6W <- readMat("data/Missed_3C_400mg_Q6W.mat")

miss_3C <-
  process_data_3C(
    list(
      miss_3C_2mg_Q3W,
      miss_3C_10mg_Q3W,
      miss_3C_10mg_Q2W,
      miss_3C_200mg_Q3W,
      miss_3C_400mg_Q6W
    ),
    dosing_tag = dosing_tag,
    scheme = 'miss'
  )
#Read retaken dose data
retake_3C_2mg_Q3W <- readMat("data/Retake_3C_2mg_kg_Q3W.mat")
retake_3C_10mg_Q3W <- readMat("data/Retake_3C_10mg_kg_Q3W.mat")
retake_3C_10mg_Q2W <- readMat("data/Retake_3C_10mg_kg_Q2W.mat")
retake_3C_200mg_Q3W <- readMat("data/Retake_3C_200mg_Q3W.mat")
retake_3C_400mg_Q6W <- readMat("data/Retake_3C_400mg_Q6W.mat")

retake_3C <-
  process_data_retake_3C(
    list(
      retake_3C_2mg_Q3W,
      retake_3C_10mg_Q3W,
      retake_3C_10mg_Q2W,
      retake_3C_200mg_Q3W,
      retake_3C_400mg_Q6W
    ),
    dosing_tag,
    retake_tag
  )

# Combine AUC, Cmax, Ctrough, DrugComplex_min, Tumor_Ratio
AUC_3C <- rbind(full_3C[['AUC']], miss_3C[['AUC']], retake_3C[['AUC']])
Cmax_3C <-
  rbind(full_3C[['Cmax']], miss_3C[['Cmax']], retake_3C[['Cmax']])
Ctrough_3C <-
  rbind(full_3C[['Ctrough']], miss_3C[['Ctrough']], retake_3C[['Ctrough']])
colnames(retake_3C[['DrugComplex_min']]) <-
  c("Scheme", "DrugComplex_min", "Dosing")
DCmin_3C <-
  rbind(full_3C[['DrugComplex_min']], miss_3C[['DrugComplex_min']], retake_3C[['DrugComplex_min']])
colnames(retake_3C[['Tumor_Ratio']]) <-
  c("Scheme", "Tumor_Ratio", "Dosing")
TumorR_3C <-
  rbind(full_3C[['Tumor_Ratio']], miss_3C[['Tumor_Ratio']], retake_3C[['Tumor_Ratio']])

AUC_3C$Dosing <- factor(AUC_3C$Dosing, levels = dosing_tag)
AUC_3C$Scheme <- factor(AUC_3C$Scheme)

Cmax_3C$Dosing <- factor(Cmax_3C$Dosing, levels = dosing_tag)
Cmax_3C$Scheme <- factor(Cmax_3C$Scheme)

Ctrough_3C$Dosing <- factor(Ctrough_3C$Dosing, levels = dosing_tag)
Ctrough_3C$Scheme <- factor(Ctrough_3C$Scheme)

DCmin_3C$Dosing <- factor(DCmin_3C$Dosing, levels = dosing_tag)
DCmin_3C$Scheme <- factor(DCmin_3C$Scheme)

TumorR_3C$Dosing <- factor(TumorR_3C$Dosing, levels = dosing_tag)
TumorR_3C$Scheme <- factor(TumorR_3C$Scheme)

### Plot AUC, Cmax, Ctrough, DCmin and Tumor Ratio for debugging ###
AUC_3C_plot <- ggplot(AUC_3C, aes(x = Scheme, y = AUC)) +
  geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
  facet_wrap(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "AUC (mg*Day/L)", x = "schemes", title = 'AUC 12W for 3C models') +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0),
        axis.title.x = element_text(size = 20))
AUC_3C_plot

Cmax_3C_plot <- ggplot(Cmax_3C, aes(x = Scheme, y = Cmax)) +
  geom_violin(aes(fill = Scheme), scale = "width") +
  facet_grid(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "Cmax (mg/L)", x = "Schemes", title = 'Cmax for 3C models') +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
Cmax_3C_plot

Ctrough_3C_plot <- ggplot(Ctrough_3C, aes(x = Scheme, y = Ctrough)) +
  geom_violin(aes(fill = Scheme), scale = "width") +
  facet_grid(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "Ctrough (mg/L)", x = "Schemes", title = 'Ctrough for 3C models') +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
Ctrough_3C_plot

DCmin_3C_plot <- ggplot(DCmin_3C, aes(x = Scheme, y = DrugComplex_min)) +
  geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
  facet_wrap(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "Drug Complex Ratio (%)", x = "Schemes", title = 'Mininum PD-1 Receptor Occupancy, 12 Weeks (3C Model)') +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
DCmin_3C_plot

TumorR_3C_plot <- ggplot(TumorR_3C, aes(x = Scheme, y = Tumor_Ratio)) +
  scale_color_brewer(palette = 'Dark2') +
  geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
  facet_wrap(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "Tumor change ratio", x = "Schemes", title = 'Tumor Change Ratio, 12 Weeks (3C model)') +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
TumorR_3C_plot


#### Typical Time-Concentration profile ####################
#### 2C Model Data Processing====================================
T_2C <- readMat('data/2C_T.mat')
Y_2C <- readMat('data/2C_Y.mat')
#Full and miss
T_full_2C <-
  as.data.frame(cbind(T_2C[[1]], 'Scheme' = rep('full', times = nrow(T_2C[[1]]))))
T_miss_2C <-
  as.data.frame(cbind(T_2C[[2]], 'Scheme' = rep('miss', times = nrow(T_2C[[2]]))))
colnames(T_full_2C) <- c('Time', 'Scheme')
colnames(T_miss_2C) <- c('Time', 'Scheme')
YT_full_2C <- as.data.frame(cbind(Y_2C[[1]], T_full_2C))
YT_miss_2C <- as.data.frame(cbind(Y_2C[[2]], T_miss_2C))
colnames(YT_full_2C) <- c('D1', 'Time', 'Scheme')
colnames(YT_miss_2C) <- c('D1', 'Time', 'Scheme')

#Retake
T_retake_2C <- as.data.frame(T_2C[[3]])
Y_retake_2C <- as.data.frame(Y_2C[[3]])

colnames(T_retake_2C) <- retake_tag
colnames(Y_retake_2C) <- retake_tag

T_retake_2C <-
  pivot_longer(
    T_retake_2C,
    cols = everything(),
    names_to = 'Scheme',
    values_to = 'Time'
  )
Y_retake_2C_new <-
  as.data.frame(
    c(
      Y_retake_2C$'1/5',
      Y_retake_2C$'2/5',
      Y_retake_2C$'3/5',
      Y_retake_2C$'4/5',
      Y_retake_2C$'5/5'
    )
  )
colnames(Y_retake_2C_new) <- 'D1'
T_retake_2C <- T_retake_2C[order(T_retake_2C$Scheme), ]
YT_retake_2C <- cbind(Y_retake_2C_new, T_retake_2C)

# Combine T and Y
YT_2C <- rbind(YT_full_2C, YT_miss_2C, YT_retake_2C)
YT_2C$Scheme <- factor(YT_2C$Scheme)
YT_2C$D1 <- as.numeric(YT_2C$D1)
YT_2C$Time <- as.numeric(YT_2C$Time)

YT_2C_plot_base <- ggplot(YT_2C, aes(x = Time, y = D1, color = Scheme)) +
  geom_line()
YT_2C_plot_base

#### 3C Model Data Processing====================================
T_3C <- readMat('data/3C_T.mat')
Y_3C <- readMat('data/3C_Y.mat')
#Full and miss
Y_full_3C <-
  as.data.frame(cbind((Y_3C[[1]]), "Scheme" = rep("full", times = nrow(Y_3C[[1]]))))
Y_miss_3C <-
  as.data.frame(cbind((Y_3C[[2]]), "Scheme" = rep("miss", times = nrow(Y_3C[[2]]))))
colnames(Y_full_3C) <- c("D1", "DrugComplex", "TumorV", 'Scheme')
colnames(Y_miss_3C) <- c("D1", "DrugComplex", "TumorV", 'Scheme')
T_full_3C <- as.data.frame(T_3C[[1]])
T_miss_3C <- as.data.frame(T_3C[[2]])
colnames(T_full_3C) <- 'Time'
colnames(T_miss_3C) <- 'Time'
YT_full_3C <- cbind(Y_full_3C, T_full_3C)
YT_miss_3C <- cbind(Y_miss_3C, T_miss_3C)
colnames(YT_full_3C) <- c("D1", "DrugComplex", "TumorV", 'Scheme', 'Time')
colnames(YT_miss_3C) <- c("D1", "DrugComplex", "TumorV", 'Scheme', 'Time')
#Retake
Y_retake_3C <- Y_3C[[3]]
T_retake_3C <- T_3C[[3]]

Temp1 = as.data.frame(cbind(
  data.matrix(Y_retake_3C[, 1:3]),
  'Scheme' = rep('1/5', times = nrow(Y_retake_3C)),
  data.matrix(T_retake_3C[, 1])
))
Temp2 = as.data.frame(cbind(
  data.matrix(Y_retake_3C[, 4:6]),
  'Scheme' = rep('2/5', times = nrow(Y_retake_3C)),
  data.matrix(T_retake_3C[, 2])
))
Temp3 = as.data.frame(cbind(
  data.matrix(Y_retake_3C[, 7:9]),
  'Scheme' = rep('3/5', times = nrow(Y_retake_3C)),
  data.matrix(T_retake_3C[, 3])
))
Temp4 = as.data.frame(cbind(
  data.matrix(Y_retake_3C[, 10:12]),
  'Scheme' = rep('4/5', times = nrow(Y_retake_3C)),
  data.matrix(T_retake_3C[, 4])
))
Temp5 = as.data.frame(cbind(
  data.matrix(Y_retake_3C[, 13:15]),
  'Scheme' = rep('5/5', times = nrow(Y_retake_3C)),
  data.matrix(T_retake_3C[, 5])
))
colnames(Temp1) <- c("D1", "DrugComplex", "TumorV", 'Scheme', 'Time')
colnames(Temp2) <- c("D1", "DrugComplex", "TumorV", 'Scheme', 'Time')
colnames(Temp3) <- c("D1", "DrugComplex", "TumorV", 'Scheme', 'Time')
colnames(Temp4) <- c("D1", "DrugComplex", "TumorV", 'Scheme', 'Time')
colnames(Temp5) <- c("D1", "DrugComplex", "TumorV", 'Scheme', 'Time')
YT_retake_3C <- rbind(Temp1, Temp2, Temp3, Temp4, Temp5)
#Combine Y and T
YT_3C <- rbind(YT_full_3C, YT_miss_3C, YT_retake_3C)
columns <- c("D1", "DrugComplex", "TumorV", "Time")
YT_3C[, columns] <-
  lapply(columns, function(x)
    as.numeric(YT_3C[[x]]))

## Plots 3C Typical ============================================
# require(scales)
# TumorV_3C<-ggplot(YT_3C,aes(x = Time/7,y = TumorV/1000,color = Scheme))+
#   geom_line(size= 1.3,alpha = 0.8)+
#   scale_color_brewer(name = '',palette = 'Set1')+
#   scale_x_continuous(limits = c(0,12),breaks = seq(0,12,2))+
#   scale_y_continuous(trans = log2_trans(),
#                      breaks = trans_breaks("log2", function(x) 2^x),
#                      labels = trans_format("log2", math_format(2^.x)))+
#   labs(x = 'Time, Week', y = 'Tumor Volume, mm^3',title = 'Tumor Volume Change')+
#   my_theme+
#   theme(legend.background = element_blank(),
#         legend.text = element_text(size = 16))+
#   theme(plot.title = element_text(hjust = 0.5))
# TumorV_3C

##########  UI ###############==========================================================
## APP UI=======================================================
## 1. header----------------------------------------------------
header <-
  dashboardHeader(
    title = HTML("Missed Dose Analysis for Pembrolizumab"),
    disable = FALSE,
    titleWidth = 500
  )
## 2. sidebar----------------------------------------------------
sidebar <-
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      id = 'sidebar',
      style = "position: relative; overflow: visible;",
      menuItem(
        "Description",
        tabName = "description",
        icon = icon('question-circle')
      ),
      menuItem(
        'Missed Dose 2C Results',
        tabName = '2C_result',
        icon = icon('dashboard'),
        menuSubItem('Typical Concentration-Time Profile', tabName = '2C_typical'),
        menuSubItem('Population Variation', tabName = '2C_pop')
      ),
      menuItem(
        'Missed Dose 3C Reults',
        tabName = '3C_result',
        icon = icon('dashboard'),
        menuSubItem('Typical Concentration-Time Profile', tabName = '3C_typical'),
        menuSubItem('Population Variation', tabName = '3C_pop')
      )
    )
  )
## 3. main body--------------------------------------------------
body <-
  dashboardBody(tabItems(
    tabItem(tabName = 'description',
            fluidRow(
              column(
                12,
                h1("Summary of analysis"),
                tags$h3(
                  "In this analysis, pembrolizumab is prescribed to random simulated patients to analyze
               the effect of missed or retaken dose. One 2 compartment PK model and one 3 compartment
               PK/PD model are used to simulate the results."
                ),
                br(),
                h2("Pembrolizumab Information"),
                tags$h3(
                  "Pembrolizumab is a monoclonal IgG antibody that binds with PD-1 receptors,",
                  " and thus inhibits the PD-1/PD-L1 pathway, by which cancer cells use to downregulate T cell",
                  "activities. Immune blockade of PD-1 by pembrolizumab will enhance T cell potency and",
                  " lead to inhibited tumor growth. For more information, see this article:",
                  tags$b(
                    "A Review About Pembrolizumab in First-Line Treatment of Advanced NSCLC: Focus on KEYNOTE Studies"
                  ),
                  tags$a(
                    tags$i(
                      'PMID: 32801888(https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7395702/)'
                    )
                  )
                ),
                br(),
                h2("5 Dosing regimens"),
                h3(
                  tags$p(
                    "We selected 5 dosing regimens. 3 are weight-based dosing selected from",
                    tags$a("KEYNOTE-001, 002,006 and 010"),
                    " studies. 2 are fixed dosing recommended by ",
                    tags$a("Keytruda.")
                  ),
                  tags$ul(
                    tags$li(
                      "3 weight-based dosing: 2mg/kg Q3W (Once every 3 weeks), 10mg/kg Q3W, 10mg/kg Q2W"
                    ),
                    tags$li("2 fixed dosing: 200mg Q3W, 400mg Q6W")
                  )
                ),
                br(),
                h2("Missed dose scenarios"),
                h3(tags$ul(
                  tags$li(
                    "'full' is a positive control, where patients take all doses strictly as scheduled. "
                  ),
                  tags$li("'miss' refers to cases where patients miss the 2nd dose."),
                  tags$li(
                    "Retaken dose are cases where a patient miss the 2nd dose but retake the dose
                    before the 3rd dose. The fractions 1/5, 2/5, 3/5, 4/5 and 5/5 means the length of
                    delayed dosing interval. 5/5 means a double dose at the 3rd dose."
                  )
                )),
                br(),
                h2("Models and outputs"),
                h3(
                  tags$p(
                    "Two models are used. The 2 compartmental PK model is adapted from the paper
                   ",
                    tags$b(
                      "Model-Based Characterization of the Pharmacokinetics of Pembrolizumab: A Humanized Anti-PD-1 Monoclonal Antibody in Advanced Solid Tumors"
                    ),
                    tags$a(
                      tags$i(
                        "PMID: 27863186. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5270291/#psp412139-note-0006. "
                      )
                    ),
                  ),
                  tags$p(
                    "The 3 compartmental PK/PD model reserves some components from the 2 compartment
                   PK model. The PD component is adapted from the paper",
                    tags$b(
                      "Translational Pharmacokinetic/Pharmacodynamic Modeling of Tumor Growth Inhibition Supports Dose-Range Selection of the Anti-PD-1 Antibody Pembrolizumab"
                    ),
                    tags$a(
                      tags$i("PMID: 27863176. https://pubmed.ncbi.nlm.nih.gov/27863176/. ")
                    )
                  ),
                  tags$p('Outputs for 2 compartment models:'),
                  tags$ul(
                    tags$li(
                      " Area under curve of pembrolizumab concentration in central compartment over 12
                    weeks (12W AUC); ",
                      tags$li('Cmax of central compartment;'),
                      tags$li('Ctrough of central compartment')
                    ),
                  ),
                  tags$p("Outputs for 3 compartment models:"),
                  tags$ul(
                    tags$li("12W AUC"),
                    tags$li("Cmax of central compartment"),
                    tags$li("Ctrough of central compartment"),
                    tags$li("minimum PD-1 receptor occupancy (drug-PD-1 complex/total PD-1)"),
                    tags$li("Tumor change ratio: (Volume change ratio Vafter/Vbefore - 1)")
                  )
                )
              )
            )),
    #tabItem(tabName = '2C_result'),
    tabItem(tabName = '2C_typical',
            fluidRow(
              box(
                title = 'Parameter Selection',
                width = 2,
                solidHeader = TRUE,
                status = 'primary',
                checkboxGroupInput(
                  inputId = '2C_typical_scheme',
                  label = 'Choose drug taking schemes:',
                  choices = c(
                    '1/5 Interval' = '1/5',
                    '2/5 Interval' = '2/5',
                    '3/5 Interval' = '3/5',
                    '4/5 Interval' = '4/5',
                    '5/5 Interval' = '5/5',
                    'full' = 'full',
                    'miss' = 'miss'
                  ),
                  selected = c('1/5', '2/5', '3/5', '4/5', '5/5', 'full', 'miss')
                )
              ),
              box(
                title = 'Typical Time-Concentration Response for 10mg/kg Q3W (2C Model)',
                width = 10,
                solidHeader = TRUE,
                status = 'primary',
                fluidRow(column(
                  10,
                  h4(
                    "The following is the time-concentration curve for central compartment over a 12-week time span."
                  )
                )),
                plotlyOutput(height = '600px', outputId = '2C_typical_plot')
              )
            )),
    tabItem(tabName = '2C_pop',
            fluidRow(
              box(
                title = "Parameter Selection",
                width = 2,
                solidHeader = TRUE,
                status = "primary",
                checkboxGroupInput(
                  inputId = '2C_dosing',
                  label = 'Choose dosing regimens to display:',
                  choices = c(
                    '2mg/kg Q3W' = '2mg/kg Q3W',
                    '10mg/kg Q3W' = '10mg/kg Q3W',
                    '10mg/kg Q2W' = '10mg/kg Q2W',
                    '200mg Q3W' = '200mg Q3W',
                    '400mg Q6W' = '400mg Q6W'
                  ),
                  selected = c(
                    '2mg/kg Q3W',
                    '10mg/kg Q3W',
                    '10mg/kg Q2W',
                    '200mg Q3W',
                    '400mg Q6W'
                  )
                ),
                checkboxGroupInput(
                  inputId = '2C_scheme',
                  label = 'Choose drug taking schemes:',
                  choices = c(
                    '1/5 Interval' = '1/5',
                    '2/5 Interval' = '2/5',
                    '3/5 Interval' = '3/5',
                    '4/5 Interval' = '4/5',
                    '5/5 Interval' = '5/5',
                    'full' = 'full',
                    'miss' = 'miss'
                  ),
                  selected = c('1/5', '2/5', '3/5', '4/5', '5/5', 'full', 'miss')
                ),
              ),
              box(
                title = 'Population Simulation Result for 2C models',
                width = 10,
                solidHeader = TRUE,
                status = 'primary',
                plotlyOutput(height = '700px', outputId = '2C_AUC'),
                hr(style = "border-top: 5px solid #3C8DBC ;"),
                plotlyOutput(height = '700px', outputId = '2C_Cmax'),
                hr(style = "border-top: 5px solid #3C8DBC ;"),
                plotlyOutput(height = '700px', outputId = '2C_Ctrough')
              )
            )),
    #tabItem(tabName = '3C_result'),
    tabItem(tabName = '3C_typical',
            fluidRow(
              box(
                title = 'Parameter Selection',
                width = 2,
                solidHeader = TRUE,
                status = 'primary',
                checkboxGroupInput(
                  inputId = '3C_typical_scheme',
                  label = 'Choose drug taking schemes:',
                  choices = c(
                    '1/5 Interval' = '1/5',
                    '2/5 Interval' = '2/5',
                    '3/5 Interval' = '3/5',
                    '4/5 Interval' = '4/5',
                    '5/5 Interval' = '5/5',
                    'full' = 'full',
                    'miss' = 'miss'
                  ),
                  selected = c('1/5', '2/5', '3/5', '4/5', '5/5', 'full', 'miss')
                )
              ),
              box(
                title = 'Typical Time-Concentration Response for 10mg/kg Q3W (3C Model)',
                width = 10,
                solidHeader = TRUE,
                status = 'primary',
                fluidRow(column(
                  10,
                  h4("Three profiles are examined here. "),
                  tags$li("First, a time-concentration curve of central compartment."),
                  tags$li(
                    "Second,drug complex ratio (drug-PD1 complex/total PD1) time profile. "
                  ),
                  tags$li('Third, the tumor volume time profile.')
                )),
                plotlyOutput(height = '600px', outputId = '3C_D1_plot'),
                hr(style = "border-top: 5px solid #3C8DBC ;"),
                plotlyOutput(height = '600px', outputId = '3C_DC_plot'),
                hr(style = "border-top: 5px solid #3C8DBC ;"),
                plotlyOutput(height = '600px', outputId = '3C_TumorV_plot'),
              )
            )),
    tabItem(tabName = '3C_pop',
            fluidRow(
              box(
                title = "Parameter Selection",
                width = 2,
                solidHeader = TRUE,
                status = "primary",
                checkboxGroupInput(
                  inputId = '3C_dosing',
                  label = 'Choose dosing regimens to display:',
                  choices = c(
                    '2mg/kg Q3W' = '2mg/kg Q3W',
                    '10mg/kg Q3W' = '10mg/kg Q3W',
                    '10mg/kg Q2W' = '10mg/kg Q2W',
                    '200mg Q3W' = '200mg Q3W',
                    '400mg Q6W' = '400mg Q6W'
                  ),
                  selected = c(
                    '2mg/kg Q3W',
                    '10mg/kg Q3W',
                    '10mg/kg Q2W',
                    '200mg Q3W',
                    '400mg Q6W'
                  )
                ),
                checkboxGroupInput(
                  inputId = '3C_scheme',
                  label = 'Choose drug taking schemes:',
                  choices = c(
                    '1/5 Interval' = '1/5',
                    '2/5 Interval' = '2/5',
                    '3/5 Interval' = '3/5',
                    '4/5 Interval' = '4/5',
                    '5/5 Interval' = '5/5',
                    'full' = 'full',
                    'miss' = 'miss'
                  ),
                  selected = c('1/5', '2/5', '3/5', '4/5', '5/5', 'full', 'miss')
                ),
              ),
              box(
                title = 'Population Simulation Result for 3C models',
                width = 10,
                solidHeader = TRUE,
                status = 'primary',
                plotlyOutput(height = '700px', outputId = '3C_AUC'),
                hr(style = "border-top: 5px solid #3C8DBC ;"),
                plotlyOutput(height = '700px', outputId = '3C_Cmax'),
                hr(style = "border-top: 5px solid #3C8DBC ;"),
                plotlyOutput(height = '700px', outputId = '3C_Ctrough'),
                hr(style = "border-top: 5px solid #3C8DBC ;"),
                plotlyOutput(height = '700px', outputId = '3C_DCmin'),
                hr(style = "border-top: 5px solid #3C8DBC ;"),
                plotlyOutput(height = '700px', outputId = '3C_TumorR')
              )
            ))
  ))

## put UI together
ui <- dashboardPage(header, sidebar, body)
# ==============================================================================
## APP Server=======================================================
server <- function(input, output) {
  #========== 2C Typical Data ==========
  YT_2C_selected <-
    reactive(filter(YT_2C, Scheme %in% input$'2C_typical_scheme'))
  #========= 2C Typical plots ==========
  output$'2C_typical_plot' <- renderPlotly({
    typi_2C <-
      ggplot(YT_2C_selected(), aes(x = Time / 7, y = D1, color = Scheme)) +
      geom_line(size = 1.3, alpha = 0.8) +
      scale_color_brewer(name = '', palette = 'Set1') +
      scale_x_continuous(limits = c(0, 12), breaks = seq(0, 12, 2)) +
      labs(x = 'Time, Week', y = 'Concentration, mg/L', title = 'Typical Dosing Response for Different Missing/Retake Schemes') +
      my_theme +
      theme(legend.background = element_blank(),
            legend.text = element_text(size = 16)) +
      theme(plot.title = element_text(hjust = 0.5))
    plotly_build(typi_2C)
  })
  #========== 2C Pop Data ==============
  AUC_2C_selected <- reactive(filter(
    AUC_2C,
    Dosing %in% input$'2C_dosing' &
      Scheme %in% input$'2C_scheme'
  ))
  Cmax_2C_selected <- reactive(filter(
    Cmax_2C,
    Dosing %in% input$'2C_dosing' &
      Scheme %in% input$'2C_scheme'
  ))
  Ctrough_2C_selected <- reactive(filter(
    Ctrough_2C,
    Dosing %in% input$'2C_dosing' &
      Scheme %in% input$'2C_scheme'
  ))
  #========= 2C Pop plots ====================
  output$'2C_AUC' <- renderPlotly({
    plot_AUC_2C <- ggplot(AUC_2C_selected(), aes(x = Scheme, y = AUC)) +
      geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
      facet_grid(. ~ Dosing) +
      geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
      labs(x = "Miss Dose Schemes", y = '', title = 'AUC 12W for 2C models') +
      my_theme +
      theme(legend.position = "none") +
      theme(
        axis.text.x = element_text(
          size = 11,
          angle = 45,
          margin = margin(0, 0, 0, 0)
        ),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 16, margin = margin(0, 0, 0, 0)),
        axis.title.x = element_text(size = 20, margin = margin(10, 0, 0, 0))
      )
    plot_AUC_2C <- plot_AUC_2C %>% plotly_build() %>%
      layout(yaxis = list(title = list(
        text = 'AUC (mg*Day/L)',
        standoff = 2,
        font = list(size = 25)
      )),
      xaxis = list(title = list(
        text = '',
        standoff = 10,
        font = list(size = 10)
      )))
  })
  
  output$'2C_Cmax' <- renderPlotly({
    plot_Cmax_2C <- ggplot(Cmax_2C_selected(), aes(x = Scheme, y = Cmax)) +
      geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
      facet_grid(. ~ Dosing) +
      geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
      labs(x = "Miss Dose Schemes", y = '', title = 'Cmax for 2C models') +
      my_theme +
      theme(legend.position = "none") +
      theme(
        axis.text.x = element_text(
          size = 11,
          angle = 45,
          margin = margin(0, 0, 0, 0)
        ),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 16, margin = margin(0, 0, 0, 0)),
        axis.title.x = element_text(size = 20, margin = margin(100, 0, 0, 0))
      )
    plot_Cmax_2C <- plot_Cmax_2C %>% plotly_build() %>%
      layout(yaxis = list(title = list(
        text = 'Cmax (mg/L)',
        standoff = 2,
        font = list(size = 25)
      )),
      xaxis = list(title = list(
        text = '',
        standoff = 10,
        font = list(size = 10)
      )))
  })
  
  output$'2C_Ctrough' <- renderPlotly({
    plot_Ctrough_2C <-
      ggplot(Ctrough_2C_selected(), aes(x = Scheme, y = Ctrough)) +
      geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
      facet_grid(. ~ Dosing) +
      geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
      labs(x = "Miss Dose Schemes", y = '', title = 'Ctrough for 2C models') +
      my_theme +
      theme(legend.position = "none") +
      theme(
        axis.text.x = element_text(
          size = 11,
          angle = 45,
          margin = margin(0, 0, 0, 0)
        ),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 16, margin = margin(0, 0, 0, 0)),
        axis.title.x = element_text(size = 20, margin = margin(100, 0, 0, 0))
      )
    plot_Ctrough_2C <- plot_Ctrough_2C %>% plotly_build() %>%
      layout(yaxis = list(title = list(
        text = 'Ctrough (mg/L)',
        standoff = 2,
        font = list(size = 25)
      )),
      xaxis = list(title = list(
        text = '',
        standoff = 10,
        font = list(size = 10)
      )))
  })
  
  #========== 3C Typical Data ==========
  YT_3C_selected <-
    reactive(filter(YT_3C, Scheme %in% input$'3C_typical_scheme'))
  #========= 3C Typical plots ==========
  output$'3C_D1_plot' <- renderPlotly({
    D1_3C <-
      ggplot(YT_3C_selected(), aes(x = Time / 7, y = D1, color = Scheme)) +
      geom_line(size = 1.3, alpha = 0.8) +
      scale_color_brewer(name = '', palette = 'Set1') +
      scale_x_continuous(limits = c(0, 12), breaks = seq(0, 12, 2)) +
      labs(x = 'Time, Week', y = 'Concentration, mg/L', title = 'Central Compartment Drug Concentration') +
      my_theme +
      theme(legend.background = element_blank(),
            legend.text = element_text(size = 16)) +
      theme(plot.title = element_text(hjust = 0.5))
    plotly_build(D1_3C)
  })
  output$'3C_DC_plot' <- renderPlotly({
    DC_3C <-
      ggplot(YT_3C_selected(),
             aes(x = Time / 7, y = DrugComplex, color = Scheme)) +
      geom_line(size = 1.3, alpha = 0.8) +
      scale_color_brewer(name = '', palette = 'Set1') +
      scale_x_continuous(limits = c(0, 12), breaks = seq(0, 12, 2)) +
      scale_y_continuous(limits = c(96, 100), breaks = seq(96, 100, 1)) +
      labs(x = 'Time, Week', y = 'Drug Complex Ratio, %', title = 'Drug-PD1 Complex/total PD1 Ratio') +
      my_theme +
      theme(legend.background = element_blank(),
            legend.text = element_text(size = 16)) +
      theme(plot.title = element_text(hjust = 0.5))
    plotly_build(DC_3C)
  })
  output$'3C_TumorV_plot' <- renderPlotly({
    TumorV_3C <-
      ggplot(YT_3C_selected(),
             aes(
               x = Time / 7,
               y = TumorV / 1000,
               color = Scheme
             )) +
      geom_line(size = 1.3, alpha = 0.8) +
      scale_color_brewer(name = '', palette = 'Set1') +
      scale_x_continuous(limits = c(0, 12), breaks = seq(0, 12, 2)) +
      labs(x = 'Time, Week', y = 'Tumor Volume, mL', title = 'Tumor Volume Change') +
      my_theme +
      theme(legend.background = element_blank(),
            legend.text = element_text(size = 16)) +
      theme(plot.title = element_text(hjust = 0.5))
    plotly_build(TumorV_3C)
  })
  #================= 3C Pop Data =========================
  AUC_3C_selected <- reactive(filter(
    AUC_3C,
    Dosing %in% input$'3C_dosing' &
      Scheme %in% input$'3C_scheme'
  ))
  Cmax_3C_selected <- reactive(filter(
    Cmax_3C,
    Dosing %in% input$'3C_dosing' &
      Scheme %in% input$'3C_scheme'
  ))
  Ctrough_3C_selected <- reactive(filter(
    Ctrough_3C,
    Dosing %in% input$'3C_dosing' &
      Scheme %in% input$'3C_scheme'
  ))
  DCmin_3C_selected <- reactive(filter(
    DCmin_3C,
    Dosing %in% input$'3C_dosing' &
      Scheme %in% input$'3C_scheme'
  ))
  TumorR_3C_selected <- reactive(filter(
    TumorR_3C,
    Dosing %in% input$'3C_dosing' &
      Scheme %in% input$'3C_scheme'
  ))
  #================= 3C Pop plots =========================
  output$'3C_AUC' <- renderPlotly({
    plot_AUC_3C <- ggplot(AUC_3C_selected(), aes(x = Scheme, y = AUC)) +
      geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
      facet_grid(. ~ Dosing) +
      geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
      labs(x = "Miss Dose Schemes", y = '', title = 'AUC 12W for 3C models') +
      my_theme +
      theme(legend.position = "none") +
      theme(
        axis.text.x = element_text(
          size = 11,
          angle = 45,
          margin = margin(0, 0, 0, 0)
        ),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 16, margin = margin(0, 0, 0, 0)),
        axis.title.x = element_text(size = 20, margin = margin(100, 0, 0, 0))
      )
    plot_AUC_3C <- plot_AUC_3C %>% plotly_build() %>%
      layout(yaxis = list(title = list(
        text = 'AUC (mg*Day/L)',
        standoff = 2,
        font = list(size = 25)
      )),
      xaxis = list(title = list(
        text = '',
        standoff = 10,
        font = list(size = 10)
      )))
  })
  
  output$'3C_Cmax' <- renderPlotly({
    plot_Cmax_3C <- ggplot(Cmax_3C_selected(), aes(x = Scheme, y = Cmax)) +
      geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
      facet_grid(. ~ Dosing) +
      geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
      labs(x = "Miss Dose Schemes", y = '', title = 'Cmax for 3C models') +
      my_theme +
      theme(legend.position = "none") +
      theme(
        axis.text.x = element_text(
          size = 11,
          angle = 45,
          margin = margin(0, 0, 0, 0)
        ),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 16, margin = margin(0, 0, 0, 0)),
        axis.title.x = element_text(size = 20, margin = margin(100, 0, 0, 0))
      )
    plot_Cmax_3C <- plot_Cmax_3C %>% plotly_build() %>%
      layout(yaxis = list(title = list(
        text = 'Cmax (mg/L)',
        standoff = 2,
        font = list(size = 25)
      )),
      xaxis = list(title = list(
        text = '',
        standoff = 10,
        font = list(size = 10)
      )))
  })
  
  output$'3C_Ctrough' <- renderPlotly({
    plot_Ctrough_3C <-
      ggplot(Ctrough_3C_selected(), aes(x = Scheme, y = Ctrough)) +
      geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
      facet_grid(. ~ Dosing) +
      geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
      labs(x = "Miss Dose Schemes", y = '', title = 'Ctrough for 3C models') +
      my_theme +
      theme(legend.position = "none") +
      theme(
        axis.text.x = element_text(
          size = 11,
          angle = 45,
          margin = margin(0, 0, 0, 0)
        ),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 16, margin = margin(0, 0, 0, 0)),
        axis.title.x = element_text(size = 20, margin = margin(100, 0, 0, 0))
      )
    plot_Ctrough_3C <- plot_Ctrough_3C %>% plotly_build() %>%
      layout(yaxis = list(title = list(
        text = 'Ctrough (mg/L)',
        standoff = 2,
        font = list(size = 25)
      )),
      xaxis = list(title = list(
        text = '',
        standoff = 10,
        font = list(size = 10)
      )))
  })
  
  output$'3C_DCmin' <- renderPlotly({
    plot_DCmin_3C <-
      ggplot(DCmin_3C_selected(), aes(x = Scheme, y = DrugComplex_min)) +
      geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
      facet_grid(. ~ Dosing) +
      geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
      labs(x = "Miss Dose Schemes", y = '', title = 'Min Drug Complex Ratio for 3C models') +
      my_theme +
      theme(legend.position = "none") +
      theme(
        axis.text.x = element_text(
          size = 11,
          angle = 45,
          margin = margin(0, 0, 0, 0)
        ),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 16, margin = margin(0, 0, 0, 0)),
        axis.title.x = element_text(size = 20, margin = margin(100, 0, 0, 0))
      )
    plot_DCmin_3C <- plot_DCmin_3C %>% plotly_build() %>%
      layout(yaxis = list(
        title = list(
          text = 'Min Drug Complex Ratio (%)',
          standoff = 2,
          font = list(size = 25)
        )
      ),
      xaxis = list(title = list(
        text = '',
        standoff = 10,
        font = list(size = 10)
      )))
  })
  
  output$'3C_TumorR' <- renderPlotly({
    plot_TumorR_3C <-
      ggplot(TumorR_3C_selected(), aes(x = Scheme, y = Tumor_Ratio)) +
      geom_violin(aes(fill = Scheme), scale = "width", alpha = 0.4) +
      facet_grid(. ~ Dosing) +
      geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
      labs(x = "Miss Dose Schemes", y = '', title = 'Tumor Change Ratio for 3C models') +
      my_theme +
      theme(legend.position = "none") +
      theme(
        axis.text.x = element_text(
          size = 11,
          angle = 45,
          margin = margin(0, 0, 0, 0)
        ),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 16, margin = margin(0, 0, 0, 0)),
        axis.title.x = element_text(size = 20, margin = margin(100, 0, 0, 0))
      )
    plot_TumorR_3C <- plot_TumorR_3C %>% plotly_build() %>%
      layout(yaxis = list(title = list(
        text = 'Tumor Change Ratio',
        standoff = 2,
        font = list(size = 25)
      )),
      xaxis = list(title = list(
        text = '',
        standoff = 10,
        font = list(size = 10)
      )))
  })
}
# ==============================================================================
# BUILD APP

# Knit UI and Server to create app
shinyApp(ui = ui, server = server)
