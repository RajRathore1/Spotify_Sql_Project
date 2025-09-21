CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
select * from spotify;
-- EDA
select count(*) from spotify;
Select count(Distinct artist ) from spotify;
Select count(Distinct album ) from spotify;
select distinct album_type from spotify;
select max(duration_min) from spotify;
select min(duration_min) from spotify;
select * from spotify
where duration_min=0;
Delete from spotify
Where duration_min=0;
select distinct channel from spotify;
select distinct most_played_on from spotify;

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * from spotify
where stream>1000000000
--2.List all albums along with their respective artists.
select distinct album ,artist from spotify;
--3. Get the total number of comments for track where licensed=True.
Select sum(comments) as total_comment from spotify
where licensed = 'true';
--4. find all tracks that belong to the album type single
select track from spotify
where album_type = 'single';
--5. count the total number of tracks by each artist.
select artist count (*) as total_songs from spotify
group by artist
order by 2 desc;
--6. calculate the avg danceability of tracks in each album.
select album, avg(danceability) as avg_danceability
from spotify
group by 1;
--7. find the top 5 tracks with the highest energy values.
SELECT track, MAX(energy) AS max_energy
FROM spotify
GROUP BY track
ORDER BY max_energy DESC
LIMIT 5;
--8. List all tracks along with their views and likes where official_video=True.
select track , sum(views) as total_views,
sum(likes) as total_likes,
sum(views) as total_views
from spotify
where official_video='true'
group by 1
order by 2 desc
limit 5;
--9. for each album, calculate the total views of all associated tracks.
select album,track,sum(views)
from spotify
group by 1,2
order by 3 desc;
--10. Retrieve the track names that have been streamed on spotify more than youtube.
SELECT *
FROM (
    SELECT 
        track,
        COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM spotify
    GROUP BY track
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
  AND streamed_on_youtube <> 0;
-- 11. Find the top 3 most viewed tracks for each artist using window function
WITH ranking_artist AS
(
    SELECT 
        artist,
        track,
        SUM(views) AS total_view,
        DENSE_RANK() OVER(
            PARTITION BY artist 
            ORDER BY SUM(views) DESC
        ) AS rank
    FROM spotify
    GROUP BY artist, track
    ORDER BY total_view DESC
)
SELECT * 
FROM ranking_artist
WHERE rank <= 3;
-- 12.write a query to find tracks the liveness score is above the average.
select track,artist,liveness from spotify
where liveness>(select avg(liveness) from spotify)
--use a with clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with cte
as (select
album,
max(energy)as highest_energy,
min(energy)as lowest_energy
from spotify
group by 1)
select album,highest_energy-lowest_energy as energy_diff
from cte
order by 2 desc
-- 14. Find the top 3 tracks where the energy-to-liveness ratio is greater than 1.2
SELECT 
    track,
    artist,
    (energy / liveness) AS energy_liveness
FROM spotify
WHERE (energy / liveness) > 1.2
ORDER BY track DESC
LIMIT 3;
--15. calculate the cumulative sum of likes for tracks ordered by the number of views using window function.
-- 15. Calculate the cumulative sum of likes for tracks ordered by number of views
SELECT 
    track,
    artist,
    views,
    likes,
    SUM(likes) OVER (
        ORDER BY views
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_likes
FROM spotify
ORDER BY views;

