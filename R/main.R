# Kurzes Importprogramm, das
library(pacman)
p_load(this.path)
rm(list=ls())

# Aktuelles Verzeichnis als workdir
setwd(this.path::this.dir())
# Aus dem R-Verzeichnis eine Ebene rauf
setwd("..")


source("./R/get_data.R")

library(DatawRappr)
p_load(lubridate)
dw_id ="qcSxx"

stations_df <- get_index() %>%
  # Warnstufe 0 falls NA
  mutate(Warnstufe_num =ifelse(is.na(Warnstufe),0,as.integer(str_sub(Warnstufe,3,3))))
dw_data_to_chart(stations_df,dw_id,parse_dates = TRUE)

datum = max(as_datetime(stations_df$timestamp,tz="CET"))
annotate_str <- paste0("Zuletzt aktualisiert: ",
                       format(datum),
                       " - laut HLNUG ungeprüfte Rohdaten")
dw_edit_chart(dw_id,annotate = annotate_str)
dw_publish_chart(dw_id)
