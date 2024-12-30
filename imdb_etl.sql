CREATE DATABASE imdb_cricket;
CREATE SCHEMA imdb_cricket.staging;
USE SCHEMA imdb_cricket.staging;

CREATE OR REPLACE TABLE names_staging (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100),
    height INT,
    date_of_birth DATE,
    known_for_movies VARCHAR(100)
);

CREATE OR REPLACE TABLE movie_staging (
    id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(200),
    year INT,
    date_published DATE,
    duration INT,
    country VARCHAR(250),
    worlwide_gross_income VARCHAR(30),
    languages VARCHAR(200),
    production_company VARCHAR(200)
);

CREATE OR REPLACE TABLE genre_staging (
    movie_id VARCHAR(10),
    genre VARCHAR(20) PRIMARY KEY,
    FOREIGN KEY (movie_id) REFERENCES movie_staging(id)
);

CREATE OR REPLACE TABLE director_mapping_staging (
    movie_id VARCHAR(10),
    name_id VARCHAR(10),
    FOREIGN KEY (movie_id) REFERENCES movie_staging(id),
    FOREIGN KEY (name_id) REFERENCES names_staging(id)
);

CREATE OR REPLACE TABLE role_mapping_staging (
    movie_id VARCHAR(10),
    name_id VARCHAR(10),
    category VARCHAR(10),
    FOREIGN KEY (movie_id) REFERENCES movie_staging(id),
    FOREIGN KEY (name_id) REFERENCES names_staging(id)
);

CREATE OR REPLACE TABLE ratings_staging (
    movie_id VARCHAR(10),
    avg_rating DECIMAL(3,1),
    total_votes INT,
    median_rating INT,
    FOREIGN KEY (movie_id) REFERENCES movie_staging(id)
);

CREATE OR REPLACE STAGE my_stage FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO names_staging
FROM @my_stage/names.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1 NULL_IF = ('NULL'));

COPY INTO movie_staging
FROM @my_stage/movie.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO genre_staging
FROM @my_stage/genre.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO director_mapping_staging
FROM @my_stage/director_mapping.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO role_mapping_staging
FROM @my_stage/role_mapping.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO ratings_staging
FROM @my_stage/ratings.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

SELECT * FROM names_staging;
SELECT * FROM movie_staging;
SELECT * FROM genre_staging;
SELECT * FROM director_mapping_staging;
SELECT * FROM role_mapping_staging;
SELECT * FROM ratings_staging;


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

CREATE TABLE dim_directors AS
SELECT DISTINCT
    n.id AS dim_director_id,
    n.name,
FROM names_staging n
JOIN director_mapping_staging dm ON n.id = dm.name_id;

CREATE TABLE dim_genres AS
SELECT DISTINCT
    g.movie_id AS dim_movie_id,
    g.genre
FROM genre_staging g;

CREATE TABLE bridge_dim_movies_dim_genres AS
SELECT DISTINCT
    g.dim_genres_dim_movie_id,
    m.dim_movies_dim_movie_id
FROM genre_staging g
JOIN dim_genres d ON g.genre = d.genre
JOIN dim_movies m ON g.movie_id = m.dim_movie_id;

CREATE TABLE fact_ratings AS
SELECT DISTINCT
    r.movie_id AS fact_movie_id,
    r.avg_rating,
    r.total_votes,
    r.median_rating,
    d.dim_movie_id AS movie_dim_id,
    dr.dim_director_id AS director_dim_id
FROM ratings_staging r
LEFT JOIN dim_movies d ON r.movie_id = d.dim_movie_id
LEFT JOIN director_mapping_staging dm ON r.movie_id = dm.movie_id
LEFT JOIN dim_directors dr ON dm.name_id = dr.dim_director_id;

SELECT * FROM dim_movies;
SELECT * FROM dim_directors;
SELECT * FROM dim_genres;
SELECT * FROM fact_ratings;
SELECT * FROM bridge_dim_movies_dim_genres;

DROP TABLE IF EXISTS names_staging;
DROP TABLE IF EXISTS movie_staging;
DROP TABLE IF EXISTS genre_staging;
DROP TABLE IF EXISTS director_mapping_staging;
DROP TABLE IF EXISTS role_mapping_staging;
DROP TABLE IF EXISTS ratings_staging;

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

SELECT * FROM year_genre_movie_count;
SELECT * FROM rating_distribution;
SELECT * FROM genre_proportions;
SELECT * FROM director_popularity;
SELECT * FROM duration_vs_rating;
