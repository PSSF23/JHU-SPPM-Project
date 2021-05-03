########## Load Packages ########
library("R.matlab")
library("tidyverse")
library("patchwork")
library("plotly")
library("shiny")
library(latex2exp)
########### Data Processing ######################
######### Dosing tags ##########
dosing_tag <- c("2mg/kg Q3W", "10mg/kg Q3W", "10mg/kg Q2W", "200mg Q3W", "400mg Q6W")
retake_tag <- c("1/5", "2/5", "3/5", "4/5", "5/5") # retake dosing cycles
####### 2C Model #############
# Function for processing data
process_data_2C <- function(
                            data_list,
                            dosing_tag) {
  AUC_tab <- c()
  Cmax_tab <- c()
  Ctrough_tab <- c()
  for (item in data_list)
  {
    AUC_tab <- cbind(AUC_tab, as.vector(get(names(item)[1], item)))
    Cmax_tab <- cbind(Cmax_tab, as.vector(get(names(item)[2], item)))
    Ctrough_tab <- cbind(Ctrough_tab, as.vector(get(names(item)[3], item)))
  }
  AUC_tab <- as.data.frame(AUC_tab)
  Cmax_tab <- as.data.frame(Cmax_tab)
  Ctrough_tab <- as.data.frame(Ctrough_tab)
  names(AUC_tab) <- dosing_tag
  names(Cmax_tab) <- dosing_tag
  names(Ctrough_tab) <- dosing_tag
  return_list <- list("AUC" = AUC_tab, "Cmax" = Cmax_tab, "Ctrough" = Ctrough_tab)
}

retake_table <- function(
                         item,
                         param_id,
                         retake_tag) {
  temp <- as.data.frame(t(get(names(item)[param_id], item)))
  colnames(temp) <- retake_tag
  pivot_longer(temp, names_to = "Retake", values_to = names(item)[param_id])
}

process_data_retake_2C <- function(
                                   data_list,
                                   dosing_tag,
                                   retake_tag) {
  AUC_tab <- c()
  Cmax_tab <- c()
  Ctrough_tab <- c()
  for (item in data_list)
  {
    AUC_tab <- cbind(AUC_tab, retake())
    Cmax_tab <- cbind(Cmax_tab, as.vector(get(names(item)[2], item)))
    Ctrough_tab <- cbind(Ctrough_tab, as.vector(get(names(item)[3], item)))
  }
  AUC_tab <- as.data.frame(AUC_tab)
  Cmax_tab <- as.data.frame(Cmax_tab)
  Ctrough_tab <- as.data.frame(Ctrough_tab)
  names(AUC_tab) <- dosing_tag
  names(Cmax_tab) <- dosing_tag
  names(Ctrough_tab) <- dosing_tag
  return_list <- list("AUC" = AUC_tab, "Cmax" = Cmax_tab, "Ctrough" = Ctrough_tab)
}
# Read full dose data
Full_2C_2mg_Q3W <- readMat("data/Full_2C_2mg_kg_Q3W.mat")
Full_2C_10mg_Q3W <- readMat("data/Full_2C_10mg_kg_Q3W.mat")
Full_2C_10mg_Q2W <- readMat("data/Full_2C_10mg_kg_Q2W.mat")
Full_2C_200mg_Q3W <- readMat("data/Full_2C_200mg_Q3W.mat")
Full_2C_400mg_Q6W <- readMat("data/Full_2C_400mg_Q6W.mat")

Full_data <- process_data_2C(
  list(Full_2C_2mg_Q3W, Full_2C_10mg_Q3W, Full_2C_10mg_Q2W, Full_2C_200mg_Q3W, Full_2C_400mg_Q6W),
  dosing_tag
)
# Read missed dose data
miss_2C_2mg_Q3W <- readMat("data/Missed_2C_2mg_kg_Q3W.mat")
miss_2C_10mg_Q3W <- readMat("data/Missed_2C_10mg_kg_Q3W.mat")
miss_2C_10mg_Q2W <- readMat("data/Missed_2C_10mg_kg_Q2W.mat")
miss_2C_200mg_Q3W <- readMat("data/Missed_2C_200mg_Q3W.mat")
miss_2C_400mg_Q6W <- readMat("data/Missed_2C_400mg_Q6W.mat")

miss_data <- process_data_2C(list(miss_2C_2mg_Q3W, miss_2C_10mg_Q3W, miss_2C_10mg_Q2W, miss_2C_200mg_Q3W, miss_2C_400mg_Q6W),
  dosing_tag = dosing_tag
)
# Read retaken dose data
retake_2C_2mg_Q3W <- readMat("data/Retake_2C_2mg_kg_Q3W.mat")
retake_2C_10mg_Q3W <- readMat("data/Retake_2C_10mg_kg_Q3W.mat")
retake_2C_10mg_Q2W <- readMat("data/Retake_2C_10mg_kg_Q2W.mat")
retake_2C_200mg_Q3W <- readMat("data/Retake_2C_200mg_Q3W.mat")
retake_2C_400mg_Q6W <- readMat("data/Retake_2C_400mg_Q6W.mat")
