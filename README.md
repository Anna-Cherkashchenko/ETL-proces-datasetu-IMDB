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
<p>
  <img src="https://github.com/Anna-Cherkashchenko/ETL-proces-datasetu-IMDB/blob/main/star_schema_imdb.png">
</p>
<p align="center">
  Obrazok 2: Star schema IMDB
</p>

Vypracovala som hviezdicový model (star schema) na analýzu údajov.
### Faktová tabuľka: `fact_ratings`
Hlavné metriky:
- avg_rating: Priemerné hodnotenie filmu.
- total_votes: Celkový počet hlasov (hodnotení) pre daný film.
- median_rating: Mediánové hodnotenie filmu.

Kľúče:
- fact_rating_id: Primárny kľúč pre identifikáciu faktov v tabuľke.
- dim_movie_id: Cudzí kľúč prepojený na dimenziu `dim_movies`, ktorý identifikuje konkrétny film.
- dim_director_id: Cudzí kľúč prepojený na dimenziu `dim_directors`, ktorý identifikuje režiséra daného filmu.
- date_published: Dátum zverejnenia filmu, prepojený na dimenziu `dim_date`.
- dim_roles_id: Cudzí kľúč prepojený na dimenziu `dim_roles`, ktorý identifikuje rolu, ktorú hrá herec vo filme.

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

4. Dimenzia `dim_roles`

Údaje:
- dim_roles_id: Primárny kľúč, identifikátor roly.
- name: Meno osoby, ktorá hrá rolu.
- category: Kategória roly (hlavná, vedľajšia atď.).

Vzťah s faktovou tabuľkou:
Prepojená priamo cez dim_roles_id, ktorý sa spája s `dim_roles`.

Typ dimenzie: SCD Type 1 (aktuálne informácie bez histórie).

5. Dimenzia `dim_date`

Údaje:
- dim_date_id: Primárny kľúč, identifikátor dátumu.
- full_date: Celý dátum.
- day: Deň.
- week: Týždeň.
- month: Mesiac.
- year: Rok.

Vzťah s faktovou tabuľkou:
Prepojená priamo cez date_published, ktorý sa spája s full_date v `dim_date`.

Typ dimenzie: SCD Type 1 (aktuálne informácie bez histórie).

### Bridge tabuľka: `bridge_dim_movies_dim_genres`
Údaje:
- dim_genres_dim_movie_id: ID žánru.
- dim_movies_dim_movie_id: ID filmu.
  
Vzťah s faktovou tabuľkou:
Nepriame prepojenie cez tabuľku `dim_genres` a `dim_movies`.

## 3. ETL proces v Snowflake
ETL (Extract, Transform, Load) je trojstupňový proces správy dát, ktorý v doslovnom preklade znamená „extrahovanie, transformácia, načítanie“. Tento proces som vytvorila v Snowflake s cieľom pripraviť zdrojové dáta zo staging vrstvy (dočasná vrstva v systéme ukladania alebo spracovania dát, ktorá sa používa na medziskladovanie surových dát pred ich transformáciou) do viacdimenzionálneho modelu, ktorý je vhodný na analýzu a vizualizáciu.
### 1. Extract
Najprv som vytvorila tabuľky na načítanie údajov. Jeden z príkladov:

```sql
CREATE OR REPLACE TABLE names_staging (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100),
    height INT,
    date_of_birth DATE,
    known_for_movies VARCHAR(100)
);
```

Potom som nahrala súbory do Snowflake vo formáte `CSV` cez interné stage úložisko s názvom `my_stage`.

```sql
CREATE OR REPLACE STAGE my_stage FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');
```

Pomocou príkazu `COPY INTO` som nahrala dáta z `CSV` súborov do tabuliek: 

```sql
COPY INTO names_staging
FROM @my_stage/names.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1 NULL_IF = ('NULL'));
```

Prehľad dát v tabuľkách:

```sql
SELECT * FROM names_staging;
```
### 2. Transform
На tomto etape bolo najprv potrebné vytvoriť dimenzie.  

1. `dim_movies`

Tabuľka `dim_movies` obsahuje informácie o filmoch. Bola vytvorená na základe údajov z tabuľky `movie_staging`.

```sql
CREATE TABLE dim_movies AS
SELECT DISTINCT
    m.id AS dim_movie_id,
    m.title,
    m.year,
    m.date_published,
    m.duration,
    m.worlwide_gross_income,
    m.production_company
FROM movie_staging m;
```

2. `dim_directors`

Tabuľka `dim_directors` obsahuje informácie o režiséroch. Bola vytvorená spojením tabuľky `names_staging` s tabuľkou `director_mapping_staging`.  

```sql
CREATE TABLE dim_directors AS
SELECT DISTINCT
    n.id AS dim_director_id,
    n.name,
FROM names_staging n
JOIN director_mapping_staging dm ON n.id = dm.name_id;
```

3. `dim_genres`

Tabuľka `dim_genres` obsahuje žánre filmov. Bola vytvorená na základe tabuľky `genre_staging`, ktorá obsahuje prepojenie medzi filmami a žánrami.

```sql
CREATE TABLE dim_genres AS
SELECT DISTINCT
    g.movie_id AS dim_movie_id,
    g.genre
FROM genre_staging g;
```

4. `dim_roles`

Tabuľka `dim_roles` obsahuje informácie o rolách hercov vo filmoch. Bola vytvorená spojením tabuľky `names_staging` s tabuľkou `role_mapping_staging`, ktorá prepojuje hercov s ich rolami.

```sql
CREATE TABLE dim_roles AS
SELECT DISTINCT
    n.id AS dim_roles_id,
    n.name,
    rm.category
FROM names_staging n
JOIN role_mapping_staging rm ON n.id = rm.name_id;
```

5. `dim_date`

Tabuľka `dim_date` obsahuje informácie o dátumoch zverejnenia filmov. Bola vytvorená z tabuľky `movie_staging` a zahŕňa rôzne aspekty dátumov.

```sql
CREATE OR REPLACE TABLE dim_date AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY CAST(date_published AS DATE)) AS dim_date_id,
    date_published AS full_date,   
    DAY(date_published) AS day,    
    WEEK(date_published) AS week,  
    MONTH(date_published) AS month,
    YEAR(date_published) AS year   
FROM 
    movie_staging;
```

A po tom som vytvorila hlavnú tabuľku `fact_ratings`.  

Tabuľka `fact_ratings` obsahuje informácie o hodnoteniach filmov. Bola vytvorená spojením tabuľky `ratings_staging` s tabuľkami `dim_movies`, `dim_directors`, `dim_date` a `dim_roles`.

```sql
CREATE OR REPLACE TABLE fact_ratings AS
SELECT DISTINCT
    r.movie_id AS fact_rating_id,
    r.avg_rating,
    r.total_votes,
    r.median_rating,
    d.dim_movie_id AS dim_movie_id,
    dr.dim_director_id AS dim_director_id,
    da.full_date AS date_published,
    rol.dim_roles_id AS dim_roles_id
FROM ratings_staging r
LEFT JOIN dim_movies d ON r.movie_id = d.dim_movie_id
LEFT JOIN director_mapping_staging dm ON r.movie_id = dm.movie_id
LEFT JOIN dim_directors dr ON dm.name_id = dr.dim_director_id
LEFT JOIN dim_date da ON d.date_published = da.full_date
LEFT JOIN role_mapping_staging rm ON r.movie_id = rm.movie_id 
LEFT JOIN dim_roles rol ON rm.name_id = rol.dim_roles_id;
```

Prehľad dát v tabuľkách:

```sql
SELECT * FROM dim_movies;
```

### 3. Load
Po vytvorení dimenzií a faktovej tabuľky boli dáta nahraté do finálnej štruktúry. Na záver boli staging tabuľky odstránené, aby sa optimalizovalo využitie úložiska:
```sql
DROP TABLE IF EXISTS names_staging;
```

## 4. Vizualizacia dat

### Graf 1: Počet filmov podľa žánrov za jednotlivé roky
<p>
  <img src="https://github.com/Anna-Cherkashchenko/ETL-proces-datasetu-IMDB/blob/main/Vizualiz%C3%A1cia%20d%C3%A1t/Po%C4%8Det%20filmov%20pod%C4%BEa%20%C5%BE%C3%A1nrov%20za%20jednotliv%C3%A9%20roky.png">
</p>
<p align="center">
  Počet filmov podľa žánrov za jednotlivé roky
</p>

```sql
CREATE OR REPLACE VIEW year_genre_movie_count AS
SELECT 
    m.year,
    g.genre,
    COUNT(g.dim_movie_id) AS movie_count
FROM 
    dim_genres g
JOIN 
    dim_movies m ON g.dim_movie_id = m.dim_movie_id
GROUP BY 
    m.year, g.genre
ORDER BY 
    m.year, movie_count DESC;
```

Táto pohľadová tabuľka (view) počíta počet filmov podľa žánrov pre každý rok.  
- Spojuje tabuľky `dim_genres` a `dim_movies` pomocou dim_movie_id.  
- Skupina výsledky podľa roka (m.year) a žánru (g.genre).  
- Počíta počet filmov pre každú kombináciu roka a žánru pomocou COUNT(g.dim_movie_id).  
- Raduje výsledky podľa roka a počtu filmov zostupne.
  
Tabuľka umožňuje analyzovať, ako sa mení počet filmov v rôznych žánroch počas rokov.  

### Graf 2: Rozdelenie hodnotení filmov
<p>
  <img src="https://github.com/Anna-Cherkashchenko/ETL-proces-datasetu-IMDB/blob/main/Vizualiz%C3%A1cia%20d%C3%A1t/Rozdelenie%20hodnoten%C3%AD%20filmov.png">
</p>
<p align="center">
  Rozdelenie hodnotení filmov
</p>

```sql
CREATE OR REPLACE VIEW rating_distribution AS
SELECT
    FLOOR(avg_rating) AS rating_range,
    COUNT(*) AS movie_count
FROM 
    fact_ratings
WHERE 
    avg_rating IS NOT NULL
GROUP BY 
    FLOOR(avg_rating)
ORDER BY 
    rating_range;
```

Táto pohľadová tabuľka zobrazuje rozdelenie hodnotení filmov.  
- Skupina záznamy v tabuľke `fact_ratings` podľa zaokrúhlených hodnôt priemernej hodnoty (avg_rating), pomocou FLOOR(avg_rating) na vytvorenie rozsahov hodnotení.  
- Počíta počet filmov v každom rozsahu hodnotení pomocou COUNT(*).  
- Raduje výsledky podľa rozsahov hodnotení vzostupne.
  
Tabuľka pomáha pochopiť, ako hodnotia filmy používatelia, a určiť, koľko filmov patrí do každého rozsahu hodnotení.  

### Graf 3: Proporcie filmov podľa žánrov
<p>
  <img src="https://github.com/Anna-Cherkashchenko/ETL-proces-datasetu-IMDB/blob/main/Vizualiz%C3%A1cia%20d%C3%A1t/Proporcie%20filmov%20pod%C4%BEa%20%C5%BE%C3%A1nrov.png">
</p>
<p align="center">
  Proporcie filmov podľa žánrov
</p>

```sql
CREATE OR REPLACE VIEW genre_proportions AS
SELECT 
    g.genre,
    COUNT(g.dim_movie_id) AS movie_count
FROM 
    dim_genres g
JOIN 
    dim_movies m ON g.dim_movie_id = m.dim_movie_id
GROUP BY 
    g.genre;
```

Táto pohľadová tabuľka zobrazuje proporcie filmov podľa žánrov.  
- Spojuje tabuľky `dim_genres` a `dim_movies` podľa dim_movie_id.  
- Skupina záznamy podľa žánru (g.genre).  
- Počíta počet filmov v každom žánri pomocou COUNT(g.dim_movie_id).  

Tabuľka umožňuje posúdiť, ktoré žánre sú najrozšírenejšie vo vašej databáze filmov.  

### Graf 4: Popularita režisérov
<p>
  <img src="https://github.com/Anna-Cherkashchenko/ETL-proces-datasetu-IMDB/blob/main/Vizualiz%C3%A1cia%20d%C3%A1t/Popularita%20re%C5%BEis%C3%A9rov.png">
</p>
<p align="center">
  Popularita režisérov
</p>

```sql
CREATE OR REPLACE VIEW director_popularity AS
SELECT 
    d.name AS director_name,
    COUNT(f.fact_movie_id) AS movie_count
FROM 
    dim_directors d
JOIN 
    fact_ratings f ON d.dim_director_id = f.director_dim_id
GROUP BY 
    d.name
ORDER BY 
    movie_count DESC;
```

Táto pohľadová tabuľka počíta popularitu režisérov, t.j. počet filmov, ktoré nakrútili.  
- Spojuje tabuľky `dim_director`s a `fact_ratings` podľa dim_director_id.  
- Skupina záznamy podľa mena režiséra (d.name).  
- Počíta počet filmov súvisiacich s každým režisérom pomocou COUNT(f.fact_movie_id).  
- Raduje výsledky podľa počtu filmov zostupne.
   
Tabuľka pomáha určiť, ktorí režiséri nakrútili najväčší počet filmov v databáze.  

### Graf 5: Hodnotenie podľa dĺžky trvania
<p>
  <img src="https://github.com/Anna-Cherkashchenko/ETL-proces-datasetu-IMDB/blob/main/Vizualiz%C3%A1cia%20d%C3%A1t/Hodnotenie%20pod%C4%BEa%20d%C4%BA%C5%BEky%20trvania.png">
</p>
<p align="center">
  Hodnotenie podľa dĺžky trvania
</p>

```sql
CREATE OR REPLACE VIEW duration_vs_rating AS
SELECT 
    m.duration,
    AVG(r.avg_rating) AS avg_rating
FROM 
    dim_movies m
JOIN 
    fact_ratings r ON m.dim_movie_id = r.movie_dim_id
WHERE 
    m.duration IS NOT NULL AND r.avg_rating IS NOT NULL
GROUP BY 
    m.duration
ORDER BY 
    m.duration;
```

Táto pohľadová tabuľka analyzuje vzťah medzi dĺžkou trvania filmov a ich hodnoteniami.  
- Spojuje tabuľky `dim_movies` a `fact_ratings` podľa dim_movie_id.  
- Skupina záznamy podľa dĺžky trvania filmov (m.duration).  
- Vypočítava priemerné hodnotenie (AVG(r.avg_rating)) pre každú dĺžku filmu.  
- Raduje výsledky podľa dĺžky filmu vzostupne.
  
Tabuľka umožňuje preskúmať, ako dĺžka trvania filmov ovplyvňuje ich hodnotenia, čo môže byť užitočné na analýzu výkonu filmov.

Na základe analýzy údajov prezentovaných vo vizualizáciách môžeme dospieť k záveru, že vizualizácie poskytujú dôležité informácie o počte filmov podľa žánrov, ich hodnoteniach a popularite režisérov. Celkovo tieto vizualizácie poskytujú cenné poznatky pre pochopenie a zlepšenie filmovej produkcie.

<hr>

Autor: Anna Cherkashchenko
