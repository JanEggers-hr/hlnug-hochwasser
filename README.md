# hlnug-hochwasser
Produziert aus den Wasserstands- und Prognosedaten des HLNUG eine Hochwasserkarte. 

Simples und schnell gestricktes R-Skript, das als CRON-Job alle zehn Minuten aufgerufen wird und eine Datawrapper-Karte aktualisiert - indem sie eine Tabelle der 183 bekannten Messstationen übergibt. 

Stand: 22.12.2023

## Was es tut

Das Skript zapft die JSON-Dateien an, die die Webseite der HLNUG selbst nutzt - da es keine richtige API gibt. Es nutzt dabei eine Datei, die die Wasserstände für alle 183 Messpunkte enthält, und eine weitere, die Details zu den Messstationen enthält, unter anderem auch die Flüsse, die sie messen. Außerdem werden nach dem Schema der HLNUG-Website URLs generiert, die auf die Einzelseite und eine Thumbnail-Grafik für die jeweilige Messstation verweisen.

Diese Werte werden ausgelesen und in eine Tabelle/ein Dataframe geschrieben, das an eine [Datawrapper-Symbol-Karte](https://academy.datawrapper.de/article/114-how-to-create-a-symbol-map-in-datawrapper) übertragen wird. Jedes Symbol enthält neben den Koordinaten zwei Informationen: den Wasserstand (Größe) und die Warnstufe (Farbe: grün, gelb, orange, purpur)

Weitere Informationen - welcher Fluss, werden in den Tooltipps der Karte angezeigt; den Code für diese Datawrapper-Tooltipps findest du unten. 

## Was es noch nicht tut

Technisch einfach umzusetzen, aber in der Eile noch nicht geschrieben: 
- Informationen über die festgesetzten Warnstufen an der jeweiligen Messstation (geschrieben, aber noch nicht zu Ende korrigiert; einige Messstationen melden unvollständige Daten)
- Historie und (wo vorhanden) Prognose der jeweiligen Messsstation aus der "week.json"-Datei für jede Station (Beispiel: https://www.hlnug.de/static/pegel/wiskiweb3/data/internet/stations/0/42710050/W/week.json). Ein Teil der Stationen berechnet in diesem Datensatz eine Prognose für die nächsten 6 Stunden - für eine Warnkarte ist das der möglicherweise wichtigste Datenpunkt. 
- Die "Abschätzung" für die nächsten 7 Tage ist eine Trendberechnung, die 

(Noch nicht umgesetztes Konzept: die deutlich schwieriger zu bestückende [Locator-Karte](https://academy.datawrapper.de/article/161-how-to-create-a-locator-map); Symbole verdeutlichen Trend und zu erwartende Gefahren: Pfeil hoch/gleich/runter mit Tendenz, Farbe verdeutlicht Warnstufe in 6h. Dazu als Text: Wann wird der Höchstwert erwartet)

## Datenquelle

Das HLNUG bietet die Wasserstände und Prognosen über diese Karte an: 

https://www.hlnug.de/static/pegel/wiskiweb3/webpublic/#/overview/Wasserstand

Eine richtige API gibt es (noch) nicht - nur Downloads der Pegel-Historien und die Möglichkeit, Daten aus statisch abgelegten JSON-Dateien vom Server zu lesen. 

## Datenpunkte

Variable | Typ | Beschreibung | Beispiel
---------|-----|--------------|--------
Stationsname | String | Eindeutiger Name | Dillenburg1
Gebiet | String | Hydrologische Zuordnung | Lahn
Fluss | String | Bezeichnung des Gewässers | Dill
station_id | int | 5-stellige Stationsbezeichnung | 42455
station_no | int | 8-stellige Stationsnummer (manchmal wird die ID verwendet, manchmal die Nr.) | 25840708
LAT | float | Geokoordinate: Breitengrad | 50.741453
LON | float | Geokoordinate: Längengrad | 8.280537
Wasserstand | int | Aktuell gemessener Wasserstand in cm | 54
Warnstufe | String | Meldestufe: "MS1". "MS2" oder "MS3" - wenn keine Meldestufe erreicht ist, NA | NA
Warnstufe_num | int | Meldestufe numerisch (0-3) | 0
timestamp | Date | Zeitstempel der letzten Messung (i.d.R. alle 15min) | 2023-12-29T13:45:00.000+01:00
prog_yes | String | Existiert Prognose für diese Messstelle? "yes" oder "no" | yes
png_url | String | URL einer Thumbnail-Grafik (200x100px) des HLNUG mit Historie und evtl. Prognose | https://www.hlnug.de/static/pegel/wiskiweb3/data/internet/stations/0/25800600/W/small_wasserstand_vhs.png
page_url | String | URL der Einzelseite für diese Messstelle beim HLNUG | https://www.hlnug.de/static/pegel/wiskiweb3/webpublic/#/overview/Wasserstand/station/43044/Bad%20Hersfeld1/WVorhersage?period=P7D

## Funktionen

- **get_index()** gibt ein Dataframe mit den oben erwähnten Werten zurück
- **get_alarmlevel(station_no)** - holt die Wasserstände der drei Meldestufen bzw. gibt leeres df zurück, falls nicht zu bekommen
- **calling_all_stations_index()** - erstellt eine Tabelle mit allen Meldestufen und Basisdaten

## Datawrapper-Tooltipp

(lädt die Thumbnail-Grafik des HLNUG in den Tooltipp und bietet einen Link zur Einzelseite der jeweiligen Messstation)

```Gebiet: {{ fluss }} (bei {{ stationsname }}): {{ wasserstand }}cm```

```
Meldestufe: {{ warnstufe_num }}
<a href="{{ page_url }}" target="_blank"><img src="{{ png_url }}" alt="Prognosekarte HLNUG - nutzen Sie die Tabelle auf der unten verlinkten Seite" width="225px"></a>
<br><strong>Weitere Informationen: <a href="{{ page_url }}" target="_blank">{{ stationsname }}-Seite beim HLNUG</a></strong><br><br><small>aktualisiert: {{ FORMAT(timestamp, "DD. MMM. YY") }} um {{ FORMAT(timestamp, "HH:mm") }} Uhr
```


