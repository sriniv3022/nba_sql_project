DROP TABLE nba_stats;

CREATE TABLE nba_stats (
    year         NUMBER(4),
    player       VARCHAR2(100),
    pos          VARCHAR2(5),
    age          NUMBER(3),
    team         VARCHAR2(10),
    g            NUMBER(3),
    gs           NUMBER(3),
    mp           FLOAT,
    pts          FLOAT,
    trb          FLOAT,
    ast          FLOAT,
    fgpct        FLOAT,
    threeppct    FLOAT,
    ftpct        FLOAT
);

SELECT * FROM nba_stats
WHERE ROWNUM <= 20;

SELECT COUNT(*) FROM nba_stats;

SELECT year, player, pts
FROM nba_stats
WHERE year = 2015
ORDER BY pts DESC
FETCH FIRST 10 ROWS ONLY;

-- Window function for Top 5 players by points per year
SELECT year, player, pts,
       RANK() OVER (PARTITION BY year ORDER BY pts DESC) AS rank
FROM nba_stats
WHERE g >= 20
ORDER BY year, rank
FETCH FIRST 50 ROWS ONLY;

-- Window function for rolling 3-year average points
SELECT player, year, pts,
       ROUND(AVG(pts) OVER (
           PARTITION BY player ORDER BY year
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_avg_pts
FROM nba_stats

-- CTE + LAG, Find players who improved 3 years in a row
WITH player_growth AS (
  SELECT player, year, pts,
         LAG(pts, 1) OVER (PARTITION BY player ORDER BY year) AS prev1,
         LAG(pts, 2) OVER (PARTITION BY player ORDER BY year) AS prev2
  FROM nba_stats
)
SELECT player, year, pts, prev1, prev2
FROM player_growth
WHERE pts > prev1 AND prev1 > prev2
AND prev1 IS NOT NULL AND prev2 IS NOT NULL;

-- Group by for Average stats by position
SELECT pos,
       ROUND(AVG(pts), 2) AS avg_pts,
       ROUND(AVG(ast), 2) AS avg_ast,
       ROUND(AVG(trb), 2) AS avg_reb
FROM nba_stats
GROUP BY pos
ORDER BY avg_pts DESC;

-- Team with most points in each year
SELECT year, team, SUM(pts) AS team_total_pts
FROM nba_stats
GROUP BY year, team
ORDER BY year, team_total_pts DESC;




