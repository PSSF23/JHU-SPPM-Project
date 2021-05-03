########## Load Packages ########
library("R.matlab")
library("tidyverse")
library("patchwork")
library("plotly")
library("shiny")
library(latex2exp)
###### Create a reusable theme######
my_theme <- theme_light() +
  theme(
    text = element_text(size = 20),
    plot.title = element_text(hjust = 0.5)
  )
########### Data Processing ######################
######### Dosing tags ##########
dosing_tag <- c("2mg/kg Q3W", "10mg/kg Q3W", "10mg/kg Q2W", "200mg Q3W", "400mg Q6W")
retake_tag <- c("1/5", "2/5", "3/5", "4/5", "5/5") # retake dosing cycles
####### 2C Model #############
# Function for processing data
process_data_2C <- function(
                            data_list,
                            dosing_tag,
                            scheme) {
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
  AUC_tab <- pivot_longer(AUC_tab, cols = everything(), names_to = "Dosing", values_to = "AUC")
  Cmax_tab <- pivot_longer(Cmax_tab, col = everything(), names_to = "Dosing", values_to = "Cmax")
  Ctrough_tab <- pivot_longer(Ctrough_tab, col = everything(), names_to = "Dosing", values_to = "Ctrough")
  AUC_tab <- as.data.frame(cbind(AUC_tab, "Scheme" = rep(scheme, times = nrow(AUC_tab))))
  Cmax_tab <- as.data.frame(cbind(Cmax_tab, "Scheme" = rep(scheme, times = nrow(Cmax_tab))))
  Ctrough_tab <- as.data.frame(cbind(Ctrough_tab, "Scheme" = rep(scheme, times = nrow(Ctrough_tab))))
  return_list <- list("AUC" = AUC_tab, "Cmax" = Cmax_tab, "Ctrough" = Ctrough_tab)
}

retake_table <- function(
                         item,
                         param_id,
                         retake_tag,
                         dosing_method) {
  temp <- as.data.frame(t(get(names(item)[param_id], item)))
  colnames(temp) <- retake_tag
  temp <- pivot_longer(temp, cols = everything(), names_to = "Scheme", values_to = substr(
    names(item)[param_id],
    1, nchar(names(item)[param_id]) - 7
  ))
  temp <- as.data.frame(cbind(temp, "Dosing" = rep(dosing_method, times = nrow(temp))))
}

process_data_retake_2C <- function(
                                   data_list,
                                   dosing_tag,
                                   retake_tag) {
  AUC_tab <- c()
  Cmax_tab <- c()
  Ctrough_tab <- c()
  dosing_id <- 1
  for (item in data_list)
  {
    dosing_method <- dosing_tag[dosing_id]
    if (dosing_id == 1) {
      AUC_tab <- retake_table(item, 1, retake_tag, dosing_method)
      Cmax_tab <- retake_table(item, 2, retake_tag, dosing_method)
      Ctrough_tab <- retake_table(item, 3, retake_tag, dosing_method)
      dosing_id <- dosing_id + 1
      next
    }
    AUC_tab <- rbind(AUC_tab, retake_table(item, 1, retake_tag, dosing_method))
    Cmax_tab <- rbind(Cmax_tab, retake_table(item, 2, retake_tag, dosing_method))
    Ctrough_tab <- rbind(Ctrough_tab, retake_table(item, 3, retake_tag, dosing_method))
    dosing_id <- dosing_id + 1
  }
  return_list <- list("AUC" = AUC_tab, "Cmax" = Cmax_tab, "Ctrough" = Ctrough_tab)
}
# Read full dose data
Full_2C_2mg_Q3W <- readMat("data/Full_2C_2mg_kg_Q3W.mat")
Full_2C_10mg_Q3W <- readMat("data/Full_2C_10mg_kg_Q3W.mat")
Full_2C_10mg_Q2W <- readMat("data/Full_2C_10mg_kg_Q2W.mat")
Full_2C_200mg_Q3W <- readMat("data/Full_2C_200mg_Q3W.mat")
Full_2C_400mg_Q6W <- readMat("data/Full_2C_400mg_Q6W.mat")

full_2C <- process_data_2C(list(Full_2C_2mg_Q3W, Full_2C_10mg_Q3W, Full_2C_10mg_Q2W, Full_2C_200mg_Q3W, Full_2C_400mg_Q6W),
  dosing_tag,
  scheme = "full"
)
# Read missed dose data
miss_2C_2mg_Q3W <- readMat("data/Missed_2C_2mg_kg_Q3W.mat")
miss_2C_10mg_Q3W <- readMat("data/Missed_2C_10mg_kg_Q3W.mat")
miss_2C_10mg_Q2W <- readMat("data/Missed_2C_10mg_kg_Q2W.mat")
miss_2C_200mg_Q3W <- readMat("data/Missed_2C_200mg_Q3W.mat")
miss_2C_400mg_Q6W <- readMat("data/Missed_2C_400mg_Q6W.mat")

miss_2C <- process_data_2C(list(miss_2C_2mg_Q3W, miss_2C_10mg_Q3W, miss_2C_10mg_Q2W, miss_2C_200mg_Q3W, miss_2C_400mg_Q6W),
  dosing_tag = dosing_tag, scheme = "miss"
)
# Read retaken dose data
retake_2C_2mg_Q3W <- readMat("data/Retake_2C_2mg_kg_Q3W.mat")
retake_2C_10mg_Q3W <- readMat("data/Retake_2C_10mg_kg_Q3W.mat")
retake_2C_10mg_Q2W <- readMat("data/Retake_2C_10mg_kg_Q2W.mat")
retake_2C_200mg_Q3W <- readMat("data/Retake_2C_200mg_Q3W.mat")
retake_2C_400mg_Q6W <- readMat("data/Retake_2C_400mg_Q6W.mat")

retake_2C <- process_data_retake_2C(list(
  retake_2C_2mg_Q3W, retake_2C_10mg_Q3W, retake_2C_10mg_Q2W,
  retake_2C_200mg_Q3W, retake_2C_400mg_Q6W
), dosing_tag, retake_tag)

# Combine AUC, Cmax and Ctrough
AUC_2C <- rbind(full_2C[["AUC"]], miss_2C[["AUC"]], retake_2C[["AUC"]])
Cmax_2C <- rbind(full_2C[["Cmax"]], miss_2C[["Cmax"]], retake_2C[["Cmax"]])
Ctrough_2C <- rbind(full_2C[["Ctrough"]], miss_2C[["Ctrough"]], retake_2C[["Ctrough"]])

AUC_2C$Dosing <- factor(AUC_2C$Dosing, levels = dosing_tag)
AUC_2C$Scheme <- factor(AUC_2C$Scheme)

Cmax_2C$Dosing <- factor(Cmax_2C$Dosing, levels = dosing_tag)
Cmax_2C$Scheme <- factor(Cmax_2C$Scheme)

Ctrough_2C$Dosing <- factor(Ctrough_2C$Dosing, levels = dosing_tag)
Ctrough_2C$Scheme <- factor(Ctrough_2C$Scheme)

### Plot AUC, Cmax and Ctrough ###
AUC_2C_plot <- ggplot(AUC_2C, aes(x = Scheme, y = AUC)) +
  geom_violin(aes(fill = Scheme), scale = "width") +
  facet_grid(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "AUC (mg*Day/L)", x = "", title = "AUC 12W for 2C models") +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
AUC_2C_plot

Cmax_2C_plot <- ggplot(Cmax_2C, aes(x = Scheme, y = Cmax)) +
  geom_violin(aes(fill = Scheme), scale = "width") +
  facet_grid(. ~ Dosing) +
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "Cmax (mg/L)", x = "Schemes", title = "Cmax for 2C models") +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
Cmax_2C_plot

Ctrough_2C_plot <- ggplot(Ctrough_2C, aes(x = Scheme, y = Ctrough)) +
  geom_violin(aes(fill = Scheme), scale = "width") +
  #  facet_grid(.~Dosing)+
  geom_boxplot(aes(fill = Scheme), width = 0.25, alpha = 0.4) +
  labs(y = "Ctrough (mg/L)", x = "Schemes", title = "Ctrough for 2C models") +
  my_theme +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(size = 16, angle = 0))
Ctrough_2C_plot
