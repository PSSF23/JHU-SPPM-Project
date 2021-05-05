# Function for processing 2C data================================
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


# Function for processing 3C data============================================
process_data_3C <- function(
                            data_list,
                            dosing_tag,
                            scheme) {
  AUC_tab <- c()
  Cmax_tab <- c()
  Ctrough_tab <- c()
  DCmin_tab <- c()
  TumorR_tab <- c()
  for (item in data_list)
  {
    AUC_tab <- cbind(AUC_tab, as.vector(get(names(item)[1], item)))
    Cmax_tab <- cbind(Cmax_tab, as.vector(get(names(item)[2], item)))
    Ctrough_tab <- cbind(Ctrough_tab, as.vector(get(names(item)[3], item)))
    DCmin_tab <- cbind(DCmin_tab, as.vector(get(names(item)[4], item)))
    TumorR_tab <- cbind(TumorR_tab, as.vector(get(names(item)[5], item)))
  }
  AUC_tab <- as.data.frame(AUC_tab)
  Cmax_tab <- as.data.frame(Cmax_tab)
  Ctrough_tab <- as.data.frame(Ctrough_tab)
  DCmin_tab <- as.data.frame(DCmin_tab)
  TumorR_tab <- as.data.frame(TumorR_tab)

  names(AUC_tab) <- dosing_tag
  names(Cmax_tab) <- dosing_tag
  names(Ctrough_tab) <- dosing_tag
  names(DCmin_tab) <- dosing_tag
  names(TumorR_tab) <- dosing_tag

  AUC_tab <- pivot_longer(AUC_tab, cols = everything(), names_to = "Dosing", values_to = "AUC")
  Cmax_tab <- pivot_longer(Cmax_tab, col = everything(), names_to = "Dosing", values_to = "Cmax")
  Ctrough_tab <- pivot_longer(Ctrough_tab, col = everything(), names_to = "Dosing", values_to = "Ctrough")
  DCmin_tab <- pivot_longer(DCmin_tab, col = everything(), names_to = "Dosing", values_to = "DrugComplex_min")
  TumorR_tab <- pivot_longer(TumorR_tab, col = everything(), names_to = "Dosing", values_to = "Tumor_Ratio")

  AUC_tab <- as.data.frame(cbind(AUC_tab, "Scheme" = rep(scheme, times = nrow(AUC_tab))))
  Cmax_tab <- as.data.frame(cbind(Cmax_tab, "Scheme" = rep(scheme, times = nrow(Cmax_tab))))
  Ctrough_tab <- as.data.frame(cbind(Ctrough_tab, "Scheme" = rep(scheme, times = nrow(Ctrough_tab))))
  DCmin_tab <- as.data.frame(cbind(DCmin_tab, "Scheme" = rep(scheme, times = nrow(DCmin_tab))))
  TumorR_tab <- as.data.frame(cbind(TumorR_tab, "Scheme" = rep(scheme, times = nrow(TumorR_tab))))
  return_list <- list("AUC" = AUC_tab, "Cmax" = Cmax_tab, "Ctrough" = Ctrough_tab, "DrugComplex_min" = DCmin_tab, "Tumor_Ratio" = TumorR_tab)
}

process_data_retake_3C <- function(
                                   data_list,
                                   dosing_tag,
                                   retake_tag) {
  AUC_tab <- c()
  Cmax_tab <- c()
  Ctrough_tab <- c()
  DCmin_tab <- c()
  TumorR_tab <- c()
  dosing_id <- 1
  for (item in data_list)
  {
    dosing_method <- dosing_tag[dosing_id]
    if (dosing_id == 1) {
      AUC_tab <- retake_table(item, 1, retake_tag, dosing_method)
      Cmax_tab <- retake_table(item, 2, retake_tag, dosing_method)
      Ctrough_tab <- retake_table(item, 3, retake_tag, dosing_method)
      DCmin_tab <- retake_table(item, 4, retake_tag, dosing_method)
      TumorR_tab <- retake_table(item, 5, retake_tag, dosing_method)
      dosing_id <- dosing_id + 1
      next
    }
    AUC_tab <- rbind(AUC_tab, retake_table(item, 1, retake_tag, dosing_method))
    Cmax_tab <- rbind(Cmax_tab, retake_table(item, 2, retake_tag, dosing_method))
    Ctrough_tab <- rbind(Ctrough_tab, retake_table(item, 3, retake_tag, dosing_method))
    DCmin_tab <- rbind(DCmin_tab, retake_table(item, 4, retake_tag, dosing_method))
    TumorR_tab <- rbind(TumorR_tab, retake_table(item, 5, retake_tag, dosing_method))
    dosing_id <- dosing_id + 1
  }
  return_list <- list("AUC" = AUC_tab, "Cmax" = Cmax_tab, "Ctrough" = Ctrough_tab, "DrugComplex_min" = DCmin_tab, "Tumor_Ratio" = TumorR_tab)
}
