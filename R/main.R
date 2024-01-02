#' hlnug-hochwasser/R/main.R
#'
#' 22.12.2023 Jan Eggers, hr - jan.eggers (at) hr.de
#' Kurzes Importprogramm, das Daten von der HLNUG-Seite importiert und an Datawrapper-Kare ausgibt

# Das großartige Datawrapper-API-Paket von Benedict Witzenberger
# https://github.com/munichrocker/DatawRappr
# Datawrapper-Library liegt nicht auf CRAN und muss ggf. über
# devtools installiert werden
library(DatawRappr)

# Paketmanager-Library, die p_load() zur Verfügung stellt
library(pacman)
# p_load - wenn Paket nicht installiert, installiere es nach
p_load(this.path)
# Alles löschen, falls wir lokal laufen
rm(list=ls())

# Aktuelles Verzeichnis des Skripts als workdir
setwd(this.path::this.dir())
# Basis-Directory des Projekts - Aus dem R-Verzeichnis eine Ebene rauf
setwd("..")

# Funktionen einbinden
source("./R/get_data.R")

# Datumsfunktionen aus dem Tidyverse
p_load(lubridate)
# ID der Datawrapper-Symbol-Karte https://datawrapper.dwcdn.net/qcSxx/
dw_id ="qcSxx"

# Hole die Tabelle mit den Wasserständen und Warnstufen (siehe README.md)
stations_df <- get_index() %>%
  # Ergänze numerische Warnstufe für die Karten-Darstellung
  # Warnstufe 0 falls NA
  mutate(Warnstufe_num =ifelse(is.na(Warnstufe),0,as.integer(str_sub(Warnstufe,3,3))))

dw_data_to_chart(stations_df,dw_id,parse_dates = TRUE)

datum = max(as_datetime(stations_df$timestamp,tz="CET"))
annotate_str <- paste0("Zuletzt aktualisiert: ",
                       format(datum),
                       " - laut HLNUG ungeprüfte Rohdaten")
dw_edit_chart(dw_id,annotate = annotate_str)
dw_publish_chart(dw_id)
