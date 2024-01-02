library(tidyr)
library(dplyr)
library(stringr)
library(jsonlite)
library(httr)
# library(tidygeocoder)

hlnug_url <- "https://www.hlnug.de/static/pegel/wiskiweb3/data/internet/"
#'
#' @description
#' `get_index` holt Übersicht aller Wasserstands-Messstationen
#'
#' @details Ruft das Index-JSON vom HLNUG ab und legt es als Tabelle ab
#'
#' @examples tmp_df <- get_index()
#'
#' @returns Data frame
#' @export
get_index <- function() {
  values_url <- paste0(hlnug_url,"layers/10/index.json")
  try(values_df <- fromJSON(values_url,flatten = T) %>%
    select(station_no,
           ts_value,
           class_waterlevel,
           timestamp,
           Vorhersagepegel))
  index_url <- paste0(hlnug_url,"stations/stations.json")
  try(stations_df <- fromJSON(index_url,flatten = T))
  return(stations_df %>%
           select(-Vorhersagepegel) %>%
           right_join(values_df, by="station_no") %>%
           select(Stationsname = station_name,
                             Gebiet = hydrounit_name,
                             Fluss = catchment_name,
                             station_id,
                             station_no,
                             LAT = station_latitude,
                             LON = station_longitude,
                             Wasserstand = ts_value,
                             Warnstufe = class_waterlevel,
                             timestamp,
                             prog_yes = Vorhersagepegel) %>%
           # URL des Prognosebildes erstellen
           mutate(png_url = paste0(hlnug_url,
                                   "stations/0/",
                                   station_no,
                                   "/W/small_wasserstand_vhs.png")) %>%
           mutate(page_url = paste0("https://www.hlnug.de/static/pegel/wiskiweb3/webpublic/#/overview/Wasserstand/station/",
                                    station_id,"/",
                                    Stationsname,
                                    "WVorhersage")
                                    )
  )
}


get_week <- function(station_no) {
  values_url <- paste0(hlnug_url,"stations/0/",station_no,"/W/week.json")
  try(values_df <- fromJSON(values_url,flatten = T))
  # Gibt eine geschachtelte Tabelle zurück
}

#' @description
#' `get_maxima` holt die Pegel für Warnstufe 1,2,3 und das All-Time-Max dazu
#'
#' @details Ruft das Index-JSON vom HLNUG ab und legt es als Tabelle ab
#'
#' @examples tmp_df <- get_index()
#'
#' @returns Data frame
#' @export
get_alarmlevel <- function(station_no = 0) {
  alarmlevel_url <- paste0(hlnug_url,
                           "stations/0/",
                           station_no,
                           "/W/alarmlevel.json")
  # Versuche das JSON zu laden
  response <- GET(alarmlevel_url)
  if (status_code(response) == 200) {
    json <- content(response,"text", encoding="UTF-8")
    alarmlevel_df <- fromJSON(json,flatten = T) %>%
      select(station_no,ts_name,data) %>%
      arrange(ts_name)
    if (nrow(alarmlevel_df) > 1) {
      try(alarmlevel_df <- alarmlevel_df %>%
            unnest(cols = data) %>%
            mutate(value = data[,2]))
      alarmlevel_df <- alarmlevel_df %>%
            select(station_no,
                   ts_name,
                   value) %>%
            mutate(value = as.integer(value)) %>%
            pivot_wider(names_from = ts_name,values_from = value)
    } else {
      # Leere Datenspalte
      alarmlevel_df <- alarmlevel_df %>%
        select(station_no) %>%
        mutate(HHW =NA,
               Meldestufe1 = NA,
               Meldestufe2 = NA,
               Meldestufe3 = NA)
    }
    return(alarmlevel_df)
  } else {
    warning("Ungültige station_no: ",station_no," - HTTP Status Code: ",status_code(response))
  }
}

calling_all_stations_index <- function() {
  stations_df <- get_index()
  tmp_df <- tibble()
  for(s in stations_df$station_no) {
    tmp_df <- tmp_df %>% bind_rows(get_alarmlevel(s))
    cat(s,"\n")
  }
  return(stations_df)
}

