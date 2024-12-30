# ETL proces datasetu IMDB

Téma projektu sa zameriava na návrh a implementáciu ETL procesu pre spracovanie dát z databázy IMDb. Projekt je zameraný na transformáciu údajov o filmoch, režiséroch, hercoch a hodnoteniach do dimenzionálneho modelu uloženého v Snowflake. Tento model podporuje analýzu a vizualizáciu kľúčových aspektov filmového priemyslu.

## 1. Uvod a popis zdrojovych dat

### Tabuľky údajov:
- `names.csv`: Obsahuje informácie o osobách, ktoré sa zúčastňujú na filmoch, vrátane ich mien, výšky, dátumu narodenia a filmov, za ktoré sú známi.
- `movie.csv`: Zahrňuje údaje o filmoch, ako sú názov, rok vydania, dátum publikovania, dĺžka, krajina výroby, svetový hrubý príjem, jazyky a produkčná spoločnosť.
- `genre.csv`: Obsahuje informácie o žánroch filmov, ktoré sú spojené s konkrétnymi filmami podľa ich identifikátorov.
- `director_mapping.csv`: Prepojuje filmy s ich režisérmi pomocou identifikátorov filmov a osôb.
- `role_mapping.csv`: Uvádza úlohy hercov vo filmoch, vrátane kategórií rolí (napr. hlavná úloha, vedľajšia úloha).
- `ratings.csv`: Obsahuje údaje o hodnoteniach filmov, priemerné hodnotenie, celkový počet hlasov a mediánové hodnotenie.
  
### Účel analýzy:
Cieľom tohto projektu je identifikácia trendov vo filmovej produkcii, distribúcia hodnotení, štatistiky zárobkov a analýza populárnych žánrov a režisérov. Vďaka ETL procesu a pohľadom projekt umožňuje detailné preskúmanie údajov o filmoch pre prijímanie informovaných rozhodnutí. [Tu](https://github.com/AntaraChat/SQL---IMDb-Movie-Analysis/blob/main/EXECUTIVE%20SUMMARY.pdf) môžete získať odkaz na databázu projektu.

### ERD diagram:


## 2. Dimenzionalny model
## 3. ETL proces v Snowflake
## 4. Vizualizacia dat

