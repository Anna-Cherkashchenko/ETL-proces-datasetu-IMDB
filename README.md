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

<p>
  <img src="https://github.com/Anna-Cherkashchenko/ETL-proces-datasetu-IMDB/blob/main/IMDB_ERD.png">
</p>
<p align="center">
  Obrázok 1: Entitno-relačná schéma IMDB
</p>

## 2. Dimenzionalny model
Vypracovala som hviezdicový model (star schema) na analýzu údajov.
### Faktová tabuľka: `fact_ratings`
Hlavné metriky:
- avg_rating: Priemerné hodnotenie filmu.
- total_votes: Celkový počet hlasov (hodnotení) pre daný film.
- median_rating: Mediánové hodnotenie filmu.

Kľúče:
- fact_movie_id: Primárny kľúč pre identifikáciu faktov v tabuľke.
- movie_dim_id, director_dim_id: Cudzie kľúče prepojené na dimenzie `dim_movies` a `dim_directors`.

### Dimenzie:
1. Dimenzia `dim_movies`
   
Údaje:
- dim_movie_id: Primárny kľúč pre identifikáciu filmu.
- title: Názov filmu.
- year: Rok vydania filmu.
- duration: Dĺžka filmu (v minútach).
- worlwide_gross_income: Celkové príjmy z predaja filmu na celom svete.
- production_company: Produkčná spoločnosť, ktorá vytvorila film.
  
Vzťah s faktovou tabuľkou:
Prepojená prostredníctvom cudzieho kľúča movie_dim_id v `fact_ratings`.

Typ dimenzie: SCD Type 1: filmy, ich aktuálne údaje (aktuálne informácie bez histórie).

2. Dimenzia `dim_directors`
   
Údaje:
- dim_director_id: Primárny kľúč pre identifikáciu režiséra.
- name: Meno režiséra.
  
Vzťah s faktovou tabuľkou:
Prepojená prostredníctvom cudzieho kľúča director_dim_id v `fact_ratings`.

Typ dimenzie: SCD Type 1: režiséri a ich aktuálne mená (aktuálne informácie bez histórie).

3. Dimenzia `dim_genres`

Údaje:
- dim_movie_id: Cudzí kľúč spájajúci tabuľku s filmami.
- genre: Typ žánru filmu (napr. komédia, dráma, akcia).
  
Vzťah s faktovou tabuľkou:
Prepojená nepriamo cez `bridge_dim_movies_dim_genres`, ktorá spája žánre s filmami.

Typ dimenzie: SCD Type 1: žánre bez histórie zmien (aktuálne informácie bez histórie).

### Bridge tabuľka: `bridge_dim_movies_dim_genres`

Údaje:
- dim_genres_dim_movie_id: ID žánru.
- dim_movies_dim_movie_id: ID filmu.
  
Vzťah s faktovou tabuľkou:
Nepriame prepojenie cez tabuľku `dim_genres` a `dim_movies`.

## 3. ETL proces v Snowflake
## 4. Vizualizacia dat

