
# ==============================================================================
# LOAD PACKAGES

#Sensitivity analysis of 0.5% change of clearance, V1, V2, Q, weight, eGFR, ALB, and BSLD

# Load necessary packages
library("R.matlab")
library("tidyverse")
library("patchwork")
library("plotly")
library(shiny)
library(shinydashboard)



# ==============================================================================

#import all the data from matlab for 2compartment local 

AUC4W <- readMat('data/Sens_AUC4W.mat')
AUC12W <- readMat('data/Sens_AUC12W.mat')
Cmax  <- readMat('data/Sens_Cmax.mat')
Data <- readMat('data/Sens_expdata.mat')

#create labels for Data 
column_names <-c("base, 2mg Q3W","base, 10mg Q2W","base, 10mg Q3W","base, 200mg Q3W",
          "base, 400mg Q6W","cl, 2mg Q3W","cl, 10mg Q2W","cl, 10mg Q3W","cl, 200mg Q3W",
          "cl, 400mg Q6W","v1, 2mg Q3W","v1, 10mg Q2W","v1, 10mg Q3W","v1, 200mg Q3W",
          "v1, 400mg Q6W","v2, 2mg Q3W","v2, 10mg Q2W","v2, 10mg Q3W","v2, 200mg Q3W",
          "v2, 400mg Q6W","Q, 2mg Q3W","Q, 10mg Q2W","Q, 10mg Q3W","Q, 200mg Q3W","Q, 400mg Q6W",
          "weight, 2mg Q3W","weight, 10mg Q2W","weight, 10mg Q3W","weight, 200mg Q3W",
          "weight, 400mg Q6W","eGFR, 2mg Q3W","eGFR, 10mg Q2W","eGFR, 10mg Q3W","eGFR, 200mg Q3W",
          "eGFR, 400mg Q6W","ALB, 2mg Q3W","ALB, 10mg Q2W","ALB, 10mg Q3W","ALB, 200mg Q3W",
          "ALB, 400mg Q6W","BSLD, 2mg Q3W","BSLD, 10mg Q2W","BSLD, 10mg Q3W","BSLD, 200mg Q3W",
          "BSLD, 400mg Q6W")


#convert to data frame 
AUC4W <- as.data.frame(AUC4W)
AUC12W <- as.data.frame(AUC12W)
Cmax <- as.data.frame(Cmax)
Data <- as.data.frame(Data)


Dosing <- c('2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W')
Parameter <- c('cl','v1','v2','Q','weight','eGFR','ALB','BSLD')


# add corresponding parameter for each row 
AUC4W <- cbind(Parameter, AUC4W)
names(AUC4W) <- c('Parameter', Dosing)
AUC12W <- cbind(Parameter, AUC12W)
names(AUC12W) <- c('Parameter', Dosing)
Cmax <- cbind(Parameter, Cmax)
names(Cmax) <- c('Parameter', Dosing)

# tidy the data for each scenerio
names(Data) <- c('Time', column_names)
Data<- pivot_longer(Data, !Time, names_to = 'Condition', values_to = 'Concentration')
Data <- separate(Data, col = "Condition",
                 into = c("Parameter","Dosing"),
                 sep = ", ")
Data$Time<-as.double(Data$Time)/7


# Reformat data so all of the output is in one column
AUC4W <- pivot_longer(AUC4W, !Parameter, names_to = 'Dosing', values_to = 'Sens')
AUC12W <- pivot_longer(AUC12W, !Parameter, names_to = 'Dosing', values_to = 'Sens')
Cmax <- pivot_longer(Cmax, !Parameter, names_to = 'Dosing', values_to = 'Sens')

# Change parameter column to factor and specify order
AUC4W$Parameter <- factor(AUC4W$Parameter, levels = c('cl','v1','v2','Q','weight','eGFR','ALB','BSLD'))
AUC12W$Parameter <- factor(AUC12W$Parameter, levels = c('cl','v1','v2','Q','weight','eGFR','ALB','BSLD'))
Cmax$Parameter <- factor(Cmax$Parameter, levels = c('cl','v1','v2','Q','weight','eGFR','ALB','BSLD'))
Data$Parameter <- factor(Data$Parameter, levels = c('base','cl','v1','v2','Q','weight','eGFR','ALB','BSLD'))

AUC4W$Dosing <- factor(AUC4W$Dosing, levels = c('2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W'))
AUC12W$Dosing <- factor(AUC12W$Dosing, levels = c('2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W'))
Cmax$Dosing <- factor(Cmax$Dosing, levels = c('2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W'))
Data$Dosing <- factor(Data$Dosing)


##==============================================================================
#import all the data from matlab for 3compartment local 

AUC12W3C <- readMat('data/AUC12W3C.mat')
Cmax3C <- readMat('data/Cmax3C.mat')
Vtumor3C <- readMat('data/Vtumor3C.mat')
Dtumor3C <- readMat('data/Dtumor3C.mat')

AUC12W3C <- as.data.frame(AUC12W3C)
Cmax3C <- as.data.frame(Cmax3C)
Vtumor3C <- as.data.frame(Vtumor3C)
Dtumor3C <- as.data.frame(Dtumor3C)

Parameter <- c('weight','eGFR','ALB','BSLD', 'Qt', 'kdegD', 'kon','koff', 'Emaxtp',
               'EC50tp', 'NTc', 'PD1Tc', 'PercT_PD1', 'Tmulti','gamma')

AUC12W3C <- cbind(Parameter, AUC12W3C)
Cmax3C <- cbind(Parameter, Cmax3C)
Vtumor3C <- cbind(Parameter, Vtumor3C)
Dtumor3C <- cbind(Parameter, Dtumor3C)

names (AUC12W3C) = c('Parameter', Dosing)
names (Cmax3C) = c('Parameter', Dosing)
names (Vtumor3C) = c('Parameter', Dosing)
names (Dtumor3C) = c('Parameter', Dosing)

AUC12W3C <- pivot_longer(AUC12W3C, !Parameter, names_to = 'Dosing', values_to = 'Sens')
Cmax3C <- pivot_longer(Cmax3C, !Parameter, names_to = 'Dosing', values_to = 'Sens')
Vtumor3C <- pivot_longer(Vtumor3C, !Parameter, names_to = 'Dosing', values_to = 'Sens')
Dtumor3C <- pivot_longer(Dtumor3C, !Parameter, names_to = 'Dosing', values_to = 'Sens')

repeated = c("Parameter", "Dosing")
Local3C <- merge(merge(merge(AUC12W3C, Cmax3C, by = repeated),Vtumor3C,by = repeated),Dtumor3C,by =repeated)
names (Local3C) <- c('Parameter', 'Dosing', 'AUC12W', "Cmax", "Vtumor","Dtumor")
Local3C <- pivot_longer(Local3C, cols = c('AUC12W', "Cmax", "Vtumor","Dtumor"), names_to = 'Outcome', values_to = 'Sens')

Local3C$Dosing <- factor(Local3C$Dosing, levels = c('2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W'))
Local3C$Parameter <- factor(Local3C$Parameter, levels = c('weight','eGFR','ALB','BSLD', 'Qt', 'kdegD', 'kon','koff', 'Emaxtp',
                                                          'EC50tp', 'NTc', 'PD1Tc', 'PercT_PD1', 'Tmulti','gamma'))

## ===================================================================================
#Load data for global sensitivity 

#import all the data from matlab

Sensg_AUC4W_A <- readMat('data/Sensg_AUC4W_A.mat')
Sensg_AUC4W_W <- readMat('data/Sensg_AUC4W_W.mat')
Sensg_AUC12W_A <- readMat('data/Sensg_AUC12W_A.mat')
Sensg_AUC12W_W <- readMat('data/Sensg_AUC12W_W.mat')
Sensg_Cmax_A <- readMat('data/Sensg_Cmax_A.mat')
Sensg_Cmax_W <- readMat('data/Sensg_Cmax_W.mat')

#convert to data frame 
Sensg_AUC4W_A <- as.data.frame(Sensg_AUC4W_A)
Sensg_AUC4W_W <- as.data.frame(Sensg_AUC4W_W)
Sensg_AUC12W_A <- as.data.frame(Sensg_AUC12W_A)
Sensg_AUC12W_W <- as.data.frame(Sensg_AUC12W_W)
Sensg_Cmax_A <- as.data.frame(Sensg_Cmax_A)
Sensg_Cmax_W <- as.data.frame(Sensg_Cmax_W)

# labels for Albumin and Weight global analysis 
Alb = seq(12, 59, length.out = 21)
Alb = round(Alb)
Weight = seq(40,90, length.out = 21)
Weight = round(Weight)

Sensg_AUC4W_A <- cbind(Alb, Sensg_AUC4W_A)
Sensg_AUC12W_A <- cbind(Alb, Sensg_AUC12W_A)
Sensg_Cmax_A <- cbind(Alb, Sensg_Cmax_A)

Sensg_AUC4W_W <- cbind(Alb, Sensg_AUC4W_W)
Sensg_AUC12W_W <- cbind(Alb, Sensg_AUC12W_W)
Sensg_Cmax_W <- cbind(Alb, Sensg_Cmax_W)

column_names_A <-c("Albumin","cl, 2mg Q3W","cl, 10mg Q2W","cl, 10mg Q3W","cl, 200mg Q3W",
                 "cl, 400mg Q6W","v1, 2mg Q3W","v1, 10mg Q2W","v1, 10mg Q3W","v1, 200mg Q3W",
                 "v1, 400mg Q6W","v2, 2mg Q3W","v2, 10mg Q2W","v2, 10mg Q3W","v2, 200mg Q3W",
                 "v2, 400mg Q6W","Q, 2mg Q3W","Q, 10mg Q2W","Q, 10mg Q3W","Q, 200mg Q3W","Q, 400mg Q6W",
                 "weight, 2mg Q3W","weight, 10mg Q2W","weight, 10mg Q3W","weight, 200mg Q3W",
                 "weight, 400mg Q6W","eGFR, 2mg Q3W","eGFR, 10mg Q2W","eGFR, 10mg Q3W","eGFR, 200mg Q3W",
                 "eGFR, 400mg Q6W","ALB, 2mg Q3W","ALB, 10mg Q2W","ALB, 10mg Q3W","ALB, 200mg Q3W",
                 "ALB, 400mg Q6W","BSLD, 2mg Q3W","BSLD, 10mg Q2W","BSLD, 10mg Q3W","BSLD, 200mg Q3W",
                 "BSLD, 400mg Q6W")

column_names_W <-c("Weight","cl, 2mg Q3W","cl, 10mg Q2W","cl, 10mg Q3W","cl, 200mg Q3W",
                   "cl, 400mg Q6W","v1, 2mg Q3W","v1, 10mg Q2W","v1, 10mg Q3W","v1, 200mg Q3W",
                   "v1, 400mg Q6W","v2, 2mg Q3W","v2, 10mg Q2W","v2, 10mg Q3W","v2, 200mg Q3W",
                   "v2, 400mg Q6W","Q, 2mg Q3W","Q, 10mg Q2W","Q, 10mg Q3W","Q, 200mg Q3W","Q, 400mg Q6W",
                   "weight, 2mg Q3W","weight, 10mg Q2W","weight, 10mg Q3W","weight, 200mg Q3W",
                   "weight, 400mg Q6W","eGFR, 2mg Q3W","eGFR, 10mg Q2W","eGFR, 10mg Q3W","eGFR, 200mg Q3W",
                   "eGFR, 400mg Q6W","ALB, 2mg Q3W","ALB, 10mg Q2W","ALB, 10mg Q3W","ALB, 200mg Q3W",
                   "ALB, 400mg Q6W","BSLD, 2mg Q3W","BSLD, 10mg Q2W","BSLD, 10mg Q3W","BSLD, 200mg Q3W",
                   "BSLD, 400mg Q6W")

names(Sensg_AUC4W_A) = column_names_A
names(Sensg_AUC12W_A) = column_names_A
names(Sensg_Cmax_A) = column_names_A

names(Sensg_AUC4W_W) = column_names_W
names(Sensg_AUC12W_W) = column_names_W
names(Sensg_Cmax_W) = column_names_W


# Reformat data so all of the output is in one column
AUC4W_A <- pivot_longer(Sensg_AUC4W_A, !Albumin, names_to = 'Dosing', values_to = 'Sens')
AUC12W_A <- pivot_longer(Sensg_AUC12W_A, !Albumin, names_to = 'Dosing', values_to = 'Sens')
Cmax_A <- pivot_longer(Sensg_Cmax_A, !Albumin, names_to = 'Dosing', values_to = 'Sens')

AUC4W_W <- pivot_longer(Sensg_AUC4W_W, !Weight, names_to = 'Dosing', values_to = 'Sens')
AUC12W_W <- pivot_longer(Sensg_AUC12W_W, !Weight, names_to = 'Dosing', values_to = 'Sens')
Cmax_W <- pivot_longer(Sensg_Cmax_W, !Weight, names_to = 'Dosing', values_to = 'Sens')

repeated = c("Albumin", "Dosing")
globe_A <- merge(AUC4W_A, AUC12W_A, by = repeated)
globe_A <- merge(globe_A, Cmax_A, by = repeated)
names(globe_A) = c("Albumin", "Dosing", "AUC4","AUC12","Cmax")
globe_A <- pivot_longer(globe_A, cols = c("AUC4","AUC12","Cmax"), names_to = 'Outcome', values_to = 'Sens')

repeated = c("Weight", "Dosing")
globe_W <- merge(AUC4W_W, AUC12W_W, by = repeated)
globe_W <- merge(globe_W, Cmax_W, by = repeated)
names(globe_W) = c("Weight", "Dosing", "AUC4","AUC12","Cmax")
globe_W <- pivot_longer(globe_W, cols = c("AUC4","AUC12","Cmax"), names_to = 'Outcome', values_to = 'Sens')

globe_A <- separate(globe_A, col = "Dosing",
                 into = c("Parameter","Dosing"),
                 sep = ", ")
globe_W <- separate(globe_W, col = "Dosing",
                    into = c("Parameter","Dosing"),
                    sep = ", ")

globe_A$Dosing <- factor(globe_A$Dosing)
globe_A$Albumin <- factor(globe_A$Albumin)
globe_A$Outcome <- factor(globe_A$Outcome)

globe_W$Dosing <- factor(globe_W$Dosing)
globe_W$Weight <- factor(globe_W$Weight)
globe_W$Outcome <- factor(globe_W$Outcome)

##==============================================================================
# load data for 2-dimensional global sensitivity 2C
AUC4W_g <- readMat('data/AUC4W_g.mat')
AUC12W_g <- readMat('data/AUC12W_g.mat')
Cmax_g <- readMat('data/Cmax_g.mat')

AUC4W_g <- as.data.frame(AUC4W_g)
AUC12W_g <- as.data.frame(AUC12W_g)
Cmax_g <- as.data.frame(Cmax_g)

column_names_g <- c("Weight", "12, 2mg Q3W","14, 2mg Q3W","17, 2mg Q3W","19, 2mg Q3W",
                    "21, 2mg Q3W","24, 2mg Q3W","26, 2mg Q3W","28, 2mg Q3W",
                    "31, 2mg Q3W","33, 2mg Q3W","36, 2mg Q3W","38, 2mg Q3W",
                    "40, 2mg Q3W","43, 2mg Q3W","45, 2mg Q3W","47, 2mg Q3W",
                    "50, 2mg Q3W","52, 2mg Q3W","54, 2mg Q3W","57, 2mg Q3W",
                    "59, 2mg Q3W","12, 10mg Q2W","14, 10mg Q2W","17, 10mg Q2W",
                    "19, 10mg Q2W","21, 10mg Q2W","24, 10mg Q2W","26, 10mg Q2W",
                    "28, 10mg Q2W","31, 10mg Q2W","33, 10mg Q2W","36, 10mg Q2W",
                    "38, 10mg Q2W","40, 10mg Q2W","43, 10mg Q2W","45, 10mg Q2W",
                    "47, 10mg Q2W","50, 10mg Q2W","52, 10mg Q2W","54, 10mg Q2W",
                    "57, 10mg Q2W","59, 10mg Q2W","12, 10mg Q3W","14, 10mg Q3W",
                    "17, 10mg Q3W","19, 10mg Q3W","21, 10mg Q3W","24, 10mg Q3W",
                    "26, 10mg Q3W","28, 10mg Q3W","31, 10mg Q3W","33, 10mg Q3W",
                    "36, 10mg Q3W","38, 10mg Q3W","40, 10mg Q3W","43, 10mg Q3W",
                    "45, 10mg Q3W","47, 10mg Q3W","50, 10mg Q3W","52, 10mg Q3W",
                    "54, 10mg Q3W","57, 10mg Q3W","59, 10mg Q3W","12, 200mg Q3W",
                    "14, 200mg Q3W","17, 200mg Q3W","19, 200mg Q3W","21, 200mg Q3W",
                    "24, 200mg Q3W","26, 200mg Q3W","28, 200mg Q3W","31, 200mg Q3W",
                    "33, 200mg Q3W","36, 200mg Q3W","38, 200mg Q3W","40, 200mg Q3W",
                    "43, 200mg Q3W","45, 200mg Q3W","47, 200mg Q3W","50, 200mg Q3W",
                    "52, 200mg Q3W","54, 200mg Q3W","57, 200mg Q3W","59, 200mg Q3W",
                    "12, 400mg Q6W","14, 400mg Q6W","17, 400mg Q6W","19, 400mg Q6W",
                    "21, 400mg Q6W","24, 400mg Q6W","26, 400mg Q6W","28, 400mg Q6W",
                    "31, 400mg Q6W","33, 400mg Q6W","36, 400mg Q6W","38, 400mg Q6W",
                    "40, 400mg Q6W","43, 400mg Q6W","45, 400mg Q6W","47, 400mg Q6W",
                    "50, 400mg Q6W","52, 400mg Q6W","54, 400mg Q6W","57, 400mg Q6W",
                    "59, 400mg Q6W")


AUC4W_g <- cbind(Weight, AUC4W_g)
AUC12W_g <- cbind(Weight, AUC12W_g)
Cmax_g <- cbind(Weight, Cmax_g)

names(AUC4W_g) = column_names_g
names(AUC12W_g) = column_names_g
names(Cmax_g) = column_names_g

AUC4W_g <- pivot_longer(AUC4W_g, !Weight, names_to = 'Dosing', values_to = 'Sens')
AUC12W_g <- pivot_longer(AUC12W_g, !Weight, names_to = 'Dosing', values_to = 'Sens')
Cmax_g <- pivot_longer(Cmax_g, !Weight, names_to = 'Dosing', values_to = 'Sens')



repeated = c("Weight", "Dosing")
Globe <- merge(AUC4W_g, AUC12W_g, by = repeated)
Globe <- merge(Globe, Cmax_g, by = repeated)
names(Globe) <- c("Weight","Dosing","AUC4", "AUC12", "Cmax")

Globe <- pivot_longer(Globe, cols = c("AUC4","AUC12","Cmax"), names_to = 'Outcome', values_to = 'Sens')
Globe <- separate(Globe, col = "Dosing",
                    into = c("Albumin","Dosing"),
                    sep = ", ")
Globe$Dosing <- factor(Globe$Dosing)
Globe$Outcome <- factor(Globe$Outcome)


#===============================================================================
#GLOBAL SENSITIVITY 3-COMPARTMENT
AUC12W3C_g <- readMat('data/AUC12W3C_g.mat')
Cmax3C_g <- readMat('data/Cmax3C_g.mat')
Vtumor3C_g <- readMat('data/Vtumor3C_g.mat')
Dtumor3C_g <- readMat('data/Dtumor3C_g.mat')

AUC12W3C_g <- as.data.frame(AUC12W3C_g)
Cmax3C_g <- as.data.frame(Cmax3C_g)
Vtumor3C_g  <- as.data.frame(Vtumor3C_g)
Dtumor3C_g  <- as.data.frame(Dtumor3C_g)

AUC12W3C_g <- cbind(Weight, AUC12W3C_g)
Cmax3C_g <- cbind(Weight, Cmax3C_g)
Vtumor3C_g <- cbind(Weight, Vtumor3C_g)
Dtumor3C_g <- cbind(Weight, Dtumor3C_g)

names(AUC12W3C_g) = column_names_g
names(Cmax3C_g) = column_names_g
names(Vtumor3C_g) = column_names_g
names(Dtumor3C_g) = column_names_g

AUC12W3C_g <- pivot_longer(AUC12W3C_g, !Weight, names_to = 'Dosing', values_to = 'Sens')
Cmax3C_g <- pivot_longer(Cmax3C_g, !Weight, names_to = 'Dosing', values_to = 'Sens')
Vtumor3C_g <- pivot_longer(Vtumor3C_g, !Weight, names_to = 'Dosing', values_to = 'Sens')
Dtumor3C_g <- pivot_longer(Dtumor3C_g, !Weight, names_to = 'Dosing', values_to = 'Sens')

repeated = c("Weight", "Dosing")
Globe3C <- merge(merge(merge(AUC12W3C_g, Cmax3C_g, by = repeated),Vtumor3C_g,by = repeated),Dtumor3C_g,by =repeated)

names(Globe3C) <- c("Weight","Dosing","AUC12W", "Cmax", "Vtumor", "Dtumor")
Globe3C <- separate(Globe3C, col = "Dosing",
                  into = c("Albumin","Dosing"),
                  sep = ", ")

Globe3C <- pivot_longer(Globe3C, cols = c('AUC12W', "Cmax", "Vtumor","Dtumor"), names_to = 'Outcome', values_to = 'Sens')


# ==============================================================================
# PLOT The Basecase 

# Create a reusable theme
my_theme <- theme_classic() +
  theme(
    text = element_text(size = 15),
    plot.title = element_text(hjust = 0.5)
  )

theme1 <- theme_light() +
  theme(text = element_text(size = 16),
        plot.title = element_text(hjust = 0.5),
        axis.title.x = element_text(margin = margin(10, 0, 0, 0)),
        axis.title.y = element_text(margin = margin(0, 10, 0, 0)),
        axis.text.x = element_text(margin = margin(5, 0, 0, 0)),
        axis.text.y = element_text(margin = margin(0, 5, 0, 0)))


heatmap_theme <- theme_minimal() + 
  theme(text = element_text(size = 16),
        plot.title = element_text(hjust = 0.5),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        legend.key.size=unit(0.5,'inch'),
        axis.title.x = element_text(margin = margin(10,0,0,0)),
        axis.title.y = element_text(margin = margin(0,10,0,0)))


# ==============================================================================
# APP UI


# Design UI for app
ui <- dashboardPage(
      #the tile of the app
      dashboardHeader(title = "Sensitivity Analysis"),
      #the side menu of the app 
      dashboardSidebar(
        sidebarMenu(
          menuItem("Description", tabName = "description"),
          menuItem("Local Sensitivity 2C", tabName = "local", icon = icon("dashboard"),
                   menuSubItem("Local Sensitivity Heatmap",
                               tabName = "heatmaps"), 
                   menuSubItem("Concentration-time Profile",
                               tabName = "conctime")
                   ),
          menuItem("Global Sensitivity 2C", tabName = "global", icon = icon("dashboard"),
                   menuSubItem("Two-dimenstional Global",
                               tabName = "global"),
                   menuSubItem("Global VS parameters",
                               tabName = "glo_para")
                   
                   ),
          menuItem("Local Sensitivity 3C", tabName = "local3c", icon = icon("dashboard")),
          menuItem("Global Sensitivity 3C", tabName = "global3c", icon = icon("dashboard"))
                   
      )),
      #the main page of the app 
      dashboardBody(
        tabItems(
          tabItem(tabName = "description",
                  # Captions for top of app, explains what is going on
                  fluidRow(column(10,
                                  h2("Local and global sensitivity analysis for five different dosing methods of Pembrolizumab"),
                                  h4("The model we used for sensitivity analysis is a two compartment model."),
                                  h3("Local Sensitivity"),
                                  h4("Here we have sensitivity analysis for 5 different dosing methods. Three weight-based dosing 
                      include 2mg/kg every 3 weeks, 10mg/kg every 2 weeks, 10mg/kg every 3 weeks; and two fixed dosing 
                      methods include 200mg every 3 weeks and 400mg every 6 weeks."),
                                  br(),
                                  
                                  h4("Eight parameters include", em("baseline tumor burden, albumin concentration, estimated glomerular 
                      filtration rate, weight, intercompartment transport, volume of central compartment and periopheral
                      compartment"),
                                     "and", 
                                     em("Clearance Constant"), "were increased 10%",
                                     "Data simulated from MATLAB ODE solver."),
                                  h3("Global Sensitivity"),
                                  h4("In case of the global sensitivity analysis, we pick the two parameters with relative high senstivity:",
                                     em("albumin concentration"),
                                     "and",
                                     em("weight"),
                                     "to understand how will wide range of change impact the AUCs and maximum concentrations. The first part
                                     of the global sensitivity is to conduct local paramter vs global albumin and weight ranges, each of the parameter 
                                     was increased for 5%. The second
                                      part will be two-dimensional global sensitivity analysis."),
                                  h5(p("Final Project", em("Systems Pharmacology and 
                  Personalized Medicine.")))
                                  ))

                  
                  ),
# =====================================================================================================================
          tabItem(tabName = "heatmaps", icon = 'dashboard',
                  fluidRow(box(title = "Selection", width = 3, solidHeader = TRUE, status = "primary",
                                     checkboxGroupInput(
                                       inputId = "parameter",
                                       label = "Choose which parameters to display:",
                                       choices = c("Clearance rate" = "cl",
                                                   "Central Compartment" = "v1",
                                                   "Peripheral Compartment" = "v2",
                                                   "Inter-compartment Flow" = 'Q',
                                                   "Patient weight" = 'weight',
                                                   "Estimated glomerular filtration rate" = 'eGFR',
                                                   "Albumin" = 'ALB',
                                                   "Baseline tumor burden"  = 'BSLD'
                                       ),
                                       selected = c('cl','v1','v2','Q','weight','eGFR','ALB','BSLD')
                                     ),
                                     checkboxGroupInput(
                                       inputId = "dosing",
                                       label = "Choose which dosing method to display:",
                                       choices = c(
                                         "2mg/kg every 3 weeks" = '2mg Q3W', 
                                         "10mg/kg every 2 weeks" = '10mg Q2W', 
                                         "10mg/kg every 3 weeks" = '10mg Q3W',
                                         "fixed 200mg every 3 weeks" = '200mg Q3W',
                                         "fixed 400mg every 6 weeks" ='400mg Q6W'
                                       ),
                                       selected = c('2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W')
                                     )
                                   
                                   ),
                
                         box(title = "Heat maps", width = 9, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId = "localSensPlot1"),
                           plotlyOutput(outputId = "localSensPlot2"),
                           plotlyOutput(outputId = "localSensPlot3")
                         ))

                  ),
            tabItem(tabName = "conctime",
                      box(title = "Selection", width = 3, solidHeader = TRUE, status = "primary",
                      selectInput(
                      inputId = "parameter1",
                      label = "Choose which parameters to display:",
                      choices = c("Clearance rate" = "cl",
                                  "Central Compartment" = "v1",
                                  "Peripheral Compartment" = "v2",
                                  "Inter-compartment Flow" = 'Q',
                                  "Patient weight" = 'weight',
                                  "Estimated glomerular filtration rate" = 'eGFR',
                                  "Albumin" = 'ALB',
                                  "Baseline tumor burden"  = 'BSLD'
                                  ),
                      selected = c('cl')),
                    selectInput(
                      inputId = "dosing1",
                      label = "Choose which dosing method to display:",
                      choices = c( "2mg/kg every 3 weeks" = '2mg Q3W', 
                                   "10mg/kg every 2 weeks" = '10mg Q2W', 
                                   "10mg/kg every 3 weeks" = '10mg Q3W',
                                   "fixed 200mg every 3 weeks" = '200mg Q3W',
                                   "fixed 400mg every 6 weeks" ='400mg Q6W'
                      ),
                      selected = c("2mg Q3W"))
                    ),
                    box(title = "Sensitivitiy Comparison", width = 9, solidHeader = TRUE, status = "primary",
                        plotlyOutput(outputId = "Plotconc")
                  
                    )),
          
          
## ==============================================================================================================          
   #Global Sensitivity - 2compartment       
          tabItem(tabName = "glo_para",
                  fluidRow( box(title = "Selection", width = 3, solidHeader = TRUE, status = "primary",
                                checkboxGroupInput(
                                  inputId = "parameter2",
                                  label = "Choose which parameters to display:",
                                  choices = c("Clearance rate" = "cl",
                                              "Central Compartment" = "v1",
                                              "Peripheral Compartment" = "v2",
                                              "Inter-compartment Flow" = 'Q',
                                              "Patient weight" = 'weight',
                                              "Estimated glomerular filtration rate" = 'eGFR',
                                              "Albumin" = 'ALB',
                                              "Baseline tumor burden"  = 'BSLD'
                                  ),
                                  selected = c('cl','v1','v2','Q','weight','eGFR','ALB','BSLD')
                                ),
                                selectInput(
                                  inputId = "dosing2",
                                  label = "Choose which dosing method to display:",
                                  choices = c(
                                    "2mg/kg every 3 weeks" = '2mg Q3W', 
                                    "10mg/kg every 2 weeks" = '10mg Q2W', 
                                    "10mg/kg every 3 weeks" = '10mg Q3W',
                                    "fixed 200mg every 3 weeks" = '200mg Q3W',
                                    "fixed 400mg every 6 weeks" ='400mg Q6W'
                                  ),
                                  selected = c('2mg Q3W')
                                ),
                                selectInput(
                                  inputId = "outcome2",
                                  label = "Choose which changing outcome to display:",
                                  choices = c( "The area under curve for first 4 weeks" = 'AUC4', 
                                               "The area under curve for 12 weeks" = 'AUC12', 
                                               "Maximum Concentration" = 'Cmax'),
                                  selected = c("AUC4"))
                                
                  ),
                  
                  box(title = "Heat maps", width = 9, solidHeader = TRUE, status = "primary",
                      plotlyOutput(outputId = "glo_para_A"),
                      plotlyOutput(outputId = "glo_para_W")
                      ))
                      
                  ),
            tabItem(tabName = "global",
                    fluidRow( box(title = "Selection", width = 3, solidHeader = TRUE, status = "primary",
                                  selectInput(
                                    inputId = "dosing3",
                                    label = "Choose which dosing method to display:",
                                    choices = c(
                                      "2mg/kg every 3 weeks" = '2mg Q3W', 
                                      "10mg/kg every 2 weeks" = '10mg Q2W', 
                                      "10mg/kg every 3 weeks" = '10mg Q3W',
                                      "fixed 200mg every 3 weeks" = '200mg Q3W',
                                      "fixed 400mg every 6 weeks" ='400mg Q6W'
                                    ),
                                    selected = c('2mg Q3W')
                                  ),
                                  selectInput(
                                    inputId = "outcome3",
                                    label = "Choose which changing outcome to display:",
                                    choices = c( "The area under curve for first 4 weeks" = 'AUC4', 
                                                 "The area under curve for 12 weeks" = 'AUC12', 
                                                 "Maximum Concentration" = 'Cmax'),
                                    selected = c("AUC4"))
                                  
                    ),
                    
                    box(title = "Heat maps", width = 9, solidHeader = TRUE, status = "primary",
                        plotlyOutput(outputId = "globe")
                        ))
                      ),

##=============================================================================================
     tabItem(tabName = "local3c", icon = 'dashboard',
             fluidRow(box(title = "Selection", width = 3, solidHeader = TRUE, status = "primary",
                      checkboxGroupInput(
                        inputId = "parameter4",
                        label = "Choose which parameters to display:",
                        choices = c("Patient Weight" = "weight",
                                    "Estimated glomerular filtration rate" = 'eGFR',
                                    "Albumin" = 'ALB',
                                    "Baseline tumor burden"  = 'BSLD',
                                    "Inter-compartment Flow" = 'Qt',
                                    "Degradation constant" = 'kdegD',
                                    "kon constant" = 'kon',
                                    "koff constant" = 'koff',
                                    "Monod maximum binding" = 'Emaxtp',
                                    "Monod EC50" = 'EC50tp',
                                    "Concentratin of T cells" = 'NTc', 
                                    "PD1 recepters per T cell" = 'PD1Tc', 
                                    "Percent of T cells expressiong PD1" = 'PercT_PD1', 
                                    "Ratio of PD1 in tumor vs blood" = 'Tmulti',
                                    "Drug effect" = 'gamma'),
                        selected = c('weight','eGFR','ALB','BSLD', 'Qt', 'kdegD', 'kon','koff', 'Emaxtp', 
                                     'EC50tp', 'NTc', 'PD1Tc', 'PercT_PD1', 'Tmulti')),
                      checkboxGroupInput(
                        inputId = "dosing4",
                        label = "Choose which dosing method to display:",
                        choices = c(
                          "2mg/kg every 3 weeks" = '2mg Q3W', 
                          "10mg/kg every 2 weeks" = '10mg Q2W', 
                          "10mg/kg every 3 weeks" = '10mg Q3W',
                          "fixed 200mg every 3 weeks" = '200mg Q3W',
                          "fixed 400mg every 6 weeks" ='400mg Q6W'
                        ),
                        selected = c('2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W')
                        ),
                  selectInput(
                    inputId = "outcome4",
                    label = "Choose which changing outcome to display:",
                    choices = c("Central Compartment AUC for 12 weeks" = 'AUC12W', 
                                "Maximum Concentration in Blood" = 'Cmax',
                                "Tumor Volume Change Ratio" = 'Vtumor',
                                "Pembrolizumab-PD1 Complex in Tumor at 12 weeks" = 'Dtumor' ),
                    selected = c("AUC12W"))
                      ),
                      
        box(title = "Heat maps", width = 9, solidHeader = TRUE, status = "primary",
            plotlyOutput(outputId = "localSensPlot") 
            ))
        
           ),
    tabItem(tabName = "global3c", icon = 'dashboard',
        fluidRow( box(title = "Selection", width = 3, solidHeader = TRUE, status = "primary",
                      selectInput(
                        inputId = "dosing5",
                        label = "Choose which dosing method to display:",
                        choices = c(
                          "2mg/kg every 3 weeks" = '2mg Q3W', 
                          "10mg/kg every 2 weeks" = '10mg Q2W', 
                          "10mg/kg every 3 weeks" = '10mg Q3W',
                          "fixed 200mg every 3 weeks" = '200mg Q3W',
                          "fixed 400mg every 6 weeks" ='400mg Q6W'
                        ),
                        selected = c('2mg Q3W')
                      ),
                      selectInput(
                        inputId = "outcome5",
                        label = "Choose which changing outcome to display:",
                        choices = c( "Central Compartment AUC for 12 weeks" = 'AUC12W', 
                                     "Maximum Concentration in Blood" = 'Cmax',
                                     "Tumor Volume Change Ratio" = 'Vtumor',
                                     "Pembrolizumab-PD1 Complex in Tumor at 12 weeks" = 'Dtumor'),
                        selected = c("AUC12W"))
                      
        ),
        
        box(title = "Heat maps", width = 9, solidHeader = TRUE, status = "primary",
            plotlyOutput(outputId = "globe3C")
        ))
))
          
          ))


# ==============================================================================
  # APP SERVER
  
  # Create R code for app functions
  server <- function(input, output) {
##==================================================================================================
    # Local sensitivity analysis 
    output$localSensPlot1 <- renderPlotly({
     
      AUC4W_filtered <- filter(AUC4W, Parameter %in% input$parameter & Dosing %in% input$dosing)
      
      
      # Add points with filtered data
      localSensPlot1 <- ggplot(data = AUC4W_filtered, aes(x = Dosing, y = Parameter, fill = Sens)) +
        geom_tile() +
        scale_fill_distiller(name = 'Sensitivity', palette = 'RdBu', limits = c(-1,1.5)) + 
        labs(title = 'Local Sensitivity of AUC in Blood of 4 weeks',
             x = "Dosing Methods") +
        heatmap_theme
    # Convert ggplot to Plotly plot
    plotly_build(localSensPlot1)
  })
 
     # Create reactive Plotly plot for app
   
    output$localSensPlot2 <- renderPlotly({
      
    AUC12W_filtered <- filter(AUC12W, Parameter %in% input$parameter & Dosing %in% input$dosing)
     
    
     # Add points with filtered data
    localSensPlot2 <- ggplot(data = AUC12W_filtered, aes(x = Dosing, y = Parameter, fill = Sens)) +
      geom_tile() +
      scale_fill_distiller(name = 'Sensitivity', palette = 'RdBu', limits = c(-1,1.1)) + 
      labs(title = 'Parameter Local Sensitivity of AUC in Blood of 12 weeks',
           x = "Dosing Methods") +
      heatmap_theme
      # Convert ggplot to Plotly plot
      plotly_build(localSensPlot2)
      
    })
  
  
   output$localSensPlot3 <- renderPlotly({
     Cmax_filtered <- filter(Cmax, Parameter %in% input$parameter & Dosing %in% input$dosing)
     
     # Add points with filtered data
     localSensPlot3 <- ggplot(data = Cmax_filtered, aes(x = Dosing, y = Parameter, fill = Sens)) +
       geom_tile() +
       scale_fill_distiller(name = 'Sensitivity', palette = 'RdBu', limits = c(-1,2)) + 
       labs(title = 'Parameter Local Sensitivity of Maximum Concentration in Blood',
            x = "Dosing Methods") +
       heatmap_theme
     # Convert ggplot to Plotly plot
     plotly_build(localSensPlot3)
     
    
   })
   
   
   output$Plotconc<- renderPlotly({
   
     
     Data_filtered1 <- filter(Data, Parameter == 'base' & Dosing == input$dosing1)
     Data_filtered2 <- filter(Data, Parameter == input$parameter1 & Dosing == input$dosing1)
     
     #Plot line Graph
     Plotconc<-ggplot(data = NULL)+
       geom_line(data = Data_filtered1,aes(x = Time, y = Concentration, color = Parameter),size = 0.75)+
       scale_y_continuous(trans='log10',limits = c(5,500),
                          breaks = c(5,10,20,50,100,200,500))+
       scale_color_brewer(name = '', palette = 'Set2')
       theme1+
       theme(panel.grid = element_blank())
       
      # Add points with filtered data
     Plotconc  <- Plotconc + geom_line(
       data = Data_filtered2,
       aes(x = Time, y = Concentration, color = Parameter),
       size = 0.5,
       alpha = 1
        )+
       scale_color_brewer(name = '', palette = 'Set2')+
       labs(title = "Pembrolizumab Concentration-time Profile",
            x = "Time since first dose, week",
            y = "Pembrolizumab Concentration, mg/L")

     
     # Convert ggplot to Plotly plot
     plotly_build(Plotconc)
     
     
   })
  #### ===============================================================================
   #lobal Sensitivity VS parameters 
   output$glo_para_A <- renderPlotly({
     globe_A_filtered  <- filter(globe_A , Parameter %in% input$parameter2 & 
                                   Dosing == input$dosing2 & Outcome == input$outcome2)
     
     # Add plots with filtered data
     glo_para_A <- ggplot(data = globe_A_filtered, aes(x = Albumin, y = Parameter, fill = Sens)) +
       geom_tile() +
       scale_fill_distiller(name = 'Sensitivity', palette = 'RdBu', limits = c(min(globe_A_filtered['Sens']),max(globe_A_filtered['Sens']))) + 
       labs(title = 'Parameters VS Global Sensitivity of Albumin',
            x = 'Albumin concentration, g/L',
            y = "Parameters") +
       heatmap_theme 
     

     # Convert ggplot to Plotly plot
     plotly_build(glo_para_A)
     
     
   })
   output$glo_para_W <- renderPlotly({
     globe_W_filtered <- filter(globe_W , Parameter %in% input$parameter
                                & Dosing == input$dosing2 & Outcome == input$outcome2)
     
     # Add points with filtered data
     glo_para_W <- ggplot(data = globe_W_filtered, aes(x = Weight, y = Parameter, fill = Sens)) +
       geom_tile() +
       scale_fill_distiller(name = 'Sensitivity', palette = 'RdBu', limits = c(min(globe_W_filtered['Sens']),max(globe_W_filtered['Sens']))) + 
       labs(title = 'Parameters VS Global Sensitivity of Weight',
            x = "Body weights, kg",
            y = "Parameters") +
       heatmap_theme
     # Convert ggplot to Plotly plot
     plotly_build(glo_para_W)
     
     
   })

   ##=====================================================================================
   output$globe <- renderPlotly({
     Globe_filtered  <- filter(Globe, Dosing == input$dosing3 & Outcome == input$outcome3)
     
     # Add plots with filtered data
     globe <- ggplot(data = Globe_filtered, aes(x = Albumin, y = Weight, fill = Sens)) +
       geom_tile() +
       scale_fill_distiller(name = 'Sensitivity', palette = 'YlGnBu', 
                            limits = c(min(Globe_filtered['Sens']),max(Globe_filtered['Sens']))) + 
       labs(title = 'Two-dimensional Global Senstivity',
            x = "Albumin (g/L)",
            y = "Weight(kg)") +
       heatmap_theme
     
     
     # Convert ggplot to Plotly plot
     plotly_build(globe)
     
     
   })
   
   ##===============================================================================
   output$localSensPlot <- renderPlotly({
     
     Local3C_filtered <- filter(Local3C, Parameter %in% input$parameter4 & Dosing %in% input$dosing4 &
                                  Outcome == input$outcome4)
     
     
     # Add points with filtered data
     localSensPlot <- ggplot(data =Local3C_filtered, aes(x = Dosing, y = Parameter, fill = Sens)) +
       geom_tile() +
       scale_fill_distiller(name = 'Sensitivity', palette = 'RdBu', 
                            limits = c(-1,1)*max(abs(Local3C_filtered['Sens']))) + 
       labs(title = 'Parameter Local Sensitivity',
            x = "Dosing Methods") +
       heatmap_theme
     # Convert ggplot to Plotly plot
     plotly_build(localSensPlot)
   })
   
   output$globe3C <- renderPlotly({
     
     Globe3C_filtered <- filter(Globe3C, Dosing == input$dosing5 &  Outcome == input$outcome5)
     
     
     # Add points with filtered data
     globe3C <- ggplot(data =Globe3C_filtered, aes(x = Albumin, y = Weight, fill = Sens)) +
       geom_tile() +
       scale_fill_distiller(name = 'Sensitivity', palette = 'YlGnBu', 
                            limits = c(min(Globe3C_filtered['Sens']),max(Globe3C_filtered['Sens']))) + 
       labs(title = 'Global Sensitivity',
            x = "Albumin (g/L)",
            y = "Weight(kg)") +
       heatmap_theme
     # Convert ggplot to Plotly plot
     plotly_build(globe3C)
   })

  
}

# ==============================================================================
# BUILD APP

# Knit UI and Server to create app
shinyApp(ui = ui, server = server)
