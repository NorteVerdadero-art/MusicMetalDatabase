-- =====================================================================
-- MusicWorks — simulated music marketing analytics database (metal edition)
-- Requires: MySQL 8.0+ (recursive CTEs, window functions)
-- Run:      mysql -u root -h 127.0.0.1 -P 3306 < install_musicworks.sql
-- Drops and recreates the `musicworks` database.
--
-- DISCLAIMER FOR STUDENTS: artist names are real, well-known metal acts,
-- used so the data feels familiar. EVERYTHING ELSE — label assignment,
-- genre tag, streaming counts, revenue, campaigns, social growth — is
-- 100% SIMULATED for this exercise and does NOT reflect real chart
-- performance, real contracts, or real financials.
-- =====================================================================

SET SESSION cte_max_recursion_depth = 3000;

DROP DATABASE IF EXISTS musicworks;
CREATE DATABASE musicworks;
USE musicworks;

-- ---------------------------------------------------------------------
-- Helper tables (dropped at end of script)
-- ---------------------------------------------------------------------
CREATE TABLE seq_helper (n INT PRIMARY KEY);
INSERT INTO seq_helper (n)
WITH RECURSIVE seq AS (
  SELECT 0 AS n
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 1999
)
SELECT n FROM seq;

CREATE TABLE word_adj (id INT PRIMARY KEY, w VARCHAR(30));
INSERT INTO word_adj (id, w) VALUES
(1,'Midnight'),(2,'Electric'),(3,'Velvet'),(4,'Neon'),(5,'Crimson'),
(6,'Silver'),(7,'Golden'),(8,'Broken'),(9,'Wild'),(10,'Lonely'),
(11,'Solar'),(12,'Static'),(13,'Hollow'),(14,'Amber'),(15,'Iron'),
(16,'Paper'),(17,'Glass'),(18,'Sacred'),(19,'Sunken'),(20,'Restless');

CREATE TABLE word_noun (id INT PRIMARY KEY, w VARCHAR(30));
INSERT INTO word_noun (id, w) VALUES
(1,'Foxes'),(2,'Wolves'),(3,'Riot'),(4,'Echoes'),(5,'Waves'),
(6,'Shadows'),(7,'Saints'),(8,'Ghosts'),(9,'Hearts'),(10,'Bones'),
(11,'Youth'),(12,'Horizon'),(13,'Ravens'),(14,'Tides'),(15,'Sirens'),
(16,'Rebels'),(17,'Vibes'),(18,'Phantoms'),(19,'Roses'),(20,'Vultures');

CREATE TABLE metal_artist_names (id INT PRIMARY KEY, w VARCHAR(60));
INSERT INTO metal_artist_names (id, w) VALUES
(1,'Metallica'),(2,'Iron Maiden'),(3,'Slayer'),(4,'Megadeth'),(5,'Black Sabbath'),
(6,'Judas Priest'),(7,'Pantera'),(8,'Slipknot'),(9,'System of a Down'),(10,'Tool'),
(11,'Opeth'),(12,'Mastodon'),(13,'Gojira'),(14,'Lamb of God'),(15,'Trivium'),
(16,'Avenged Sevenfold'),(17,'Bring Me the Horizon'),(18,'Rammstein'),(19,'Nightwish'),(20,'Within Temptation'),
(21,'Ghost'),(22,'Behemoth'),(23,'Meshuggah'),(24,'Sepultura'),(25,'Anthrax'),
(26,'Testament'),(27,'Exodus'),(28,'Death'),(29,'Cannibal Corpse'),(30,'Dimmu Borgir'),
(31,'Emperor'),(32,'Mayhem'),(33,'Immortal'),(34,'Amon Amarth'),(35,'Arch Enemy'),
(36,'In Flames'),(37,'At the Gates'),(38,'Children of Bodom'),(39,'Dream Theater'),(40,'Symphony X'),
(41,'Blind Guardian'),(42,'Helloween'),(43,'Sabaton'),(44,'Powerwolf'),(45,'Korn'),
(46,'Deftones'),(47,'Disturbed'),(48,'Five Finger Death Punch'),(49,'Volbeat'),(50,'Halestorm'),
(51,'Motorhead'),(52,'Venom'),(53,'Celtic Frost'),(54,'Bathory'),(55,'Type O Negative'),
(56,'Killswitch Engage'),(57,'Parkway Drive'),(58,'Architects'),(59,'Bullet for My Valentine'),(60,'As I Lay Dying'),
(61,'All That Remains'),(62,'Machine Head'),(63,'Fear Factory'),(64,'Static-X'),(65,'Mudvayne'),
(66,'Godsmack'),(67,'Alice in Chains'),(68,'Soundgarden'),(69,'Faith No More'),(70,'Rage Against the Machine'),
(71,'Overkill'),(72,'Kreator'),(73,'Destruction'),(74,'Sodom'),(75,'Watain'),
(76,'Marduk'),(77,'Gorgoroth'),(78,'Cradle of Filth'),(79,'Paradise Lost'),(80,'My Dying Bride'),
(81,'Katatonia'),(82,'Anathema'),(83,'Nile'),(84,'Morbid Angel'),(85,'Obituary'),
(86,'Deicide'),(87,'Whitechapel'),(88,'Suicide Silence'),(89,'Job for a Cowboy'),(90,'Chelsea Grin'),
(91,'Bad Omens'),(92,'Motionless in White'),(93,'Ice Nine Kills'),(94,'Spiritbox'),(95,'Sleep Token'),
(96,'Amaranthe'),(97,'Kamelot'),(98,'Epica'),(99,'Delain'),(100,'Wintersun');

-- ---------------------------------------------------------------------
-- Dimension tables
-- ---------------------------------------------------------------------
CREATE TABLE labels (
  label_id     INT PRIMARY KEY,
  label_name   VARCHAR(80) NOT NULL,
  label_type   ENUM('major','indie') NOT NULL,
  hq_country   VARCHAR(60),
  founded_year INT
);
INSERT INTO labels (label_id, label_name, label_type, hq_country, founded_year) VALUES
(1,'Panorama Music Group','major','USA',1978),
(2,'Costa Norte Discos','major','Mexico',1985),
(3,'Aurelia Records','major','Spain',1990),
(4,'Vertigo Sound','major','UK',1972),
(5,'Bedroom Tapes Records','indie','USA',2014),
(6,'Nocturno Discos','indie','Colombia',2016),
(7,'Rooftop Sessions','indie','Argentina',2018),
(8,'Static Field Recordings','indie','Germany',2012),
(9,'Rio Sonoro Label','indie','Brazil',2015),
(10,'Paper Moon Music','indie','Canada',2019),
(11,'Salt & Ember Records','indie','Chile',2017),
(12,'Low Tide Audio','indie','Peru',2020);

CREATE TABLE genres (
  genre_id   INT PRIMARY KEY,
  genre_name VARCHAR(40)
);
INSERT INTO genres (genre_id, genre_name) VALUES
(1,'Thrash Metal'),(2,'Death Metal'),(3,'Black Metal'),(4,'Doom Metal'),(5,'Power Metal'),
(6,'Nu Metal'),(7,'Metalcore'),(8,'Groove Metal'),(9,'Symphonic Metal'),
(10,'Progressive Metal'),(11,'Heavy Metal'),(12,'Industrial Metal'),(13,'Folk Metal'),
(14,'Sludge Metal'),(15,'Deathcore');

CREATE TABLE territories (
  territory_id INT PRIMARY KEY,
  country_code CHAR(2),
  country_name VARCHAR(60),
  region       VARCHAR(30)
);
INSERT INTO territories (territory_id, country_code, country_name, region) VALUES
(1,'MX','Mexico','LATAM'),(2,'US','United States','NA'),(3,'CO','Colombia','LATAM'),
(4,'AR','Argentina','LATAM'),(5,'ES','Spain','EU'),(6,'BR','Brazil','LATAM'),
(7,'CL','Chile','LATAM'),(8,'PE','Peru','LATAM'),(9,'GB','United Kingdom','EU'),
(10,'DE','Germany','EU'),(11,'FR','France','EU'),(12,'CA','Canada','NA'),
(13,'PR','Puerto Rico','LATAM'),(14,'DO','Dominican Republic','LATAM'),
(15,'IT','Italy','EU'),(16,'NL','Netherlands','EU'),(17,'JP','Japan','APAC'),
(18,'KR','South Korea','APAC'),(19,'AU','Australia','APAC'),(20,'IN','India','APAC');

CREATE TABLE dsps (
  dsp_id               INT PRIMARY KEY,
  dsp_name             VARCHAR(40),
  platform_type        ENUM('streaming','video','social'),
  avg_payout_per_stream DECIMAL(8,6),
  reach_share          DECIMAL(4,3)
);
INSERT INTO dsps (dsp_id, dsp_name, platform_type, avg_payout_per_stream, reach_share) VALUES
(1,'Spotify','streaming',0.004000,0.550),
(2,'Apple Music','streaming',0.008000,0.180),
(3,'YouTube Music','video',0.002100,0.110),
(4,'Amazon Music','streaming',0.004200,0.070),
(5,'Deezer','streaming',0.004500,0.040),
(6,'Tidal','streaming',0.012500,0.020),
(7,'SoundCloud','streaming',0.002500,0.030);

CREATE TABLE calendar_week (
  week_id        INT PRIMARY KEY,
  week_start_date DATE NOT NULL,
  week_end_date   DATE NOT NULL,
  iso_year        INT,
  iso_week        INT
);
INSERT INTO calendar_week (week_id, week_start_date, week_end_date, iso_year, iso_week)
WITH RECURSIVE wk AS (
  SELECT 0 AS i
  UNION ALL
  SELECT i + 1 FROM wk WHERE i < 103
)
SELECT
  104 - i AS week_id,
  DATE_SUB(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL i WEEK) AS week_start_date,
  DATE_ADD(DATE_SUB(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL i WEEK), INTERVAL 6 DAY) AS week_end_date,
  YEAR(DATE_SUB(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL i WEEK)) AS iso_year,
  WEEK(DATE_SUB(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL i WEEK), 3) AS iso_week
FROM wk;

CREATE TABLE calendar_month (
  month_id   INT PRIMARY KEY,
  month_date DATE NOT NULL
);
INSERT INTO calendar_month (month_id, month_date)
WITH RECURSIVE mo AS (
  SELECT 0 AS i
  UNION ALL
  SELECT i + 1 FROM mo WHERE i < 23
)
SELECT
  24 - i AS month_id,
  DATE_SUB(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL i MONTH) AS month_date
FROM mo;

CREATE TABLE artists (
  artist_id     INT PRIMARY KEY,
  artist_name   VARCHAR(100) NOT NULL,
  label_id      INT NOT NULL,
  genre_id      INT NOT NULL,
  artist_type   ENUM('independent','mainstream') NOT NULL,
  home_country  VARCHAR(60),
  debut_year    INT,
  monthly_listeners_baseline INT,
  FOREIGN KEY (label_id) REFERENCES labels(label_id),
  FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);
INSERT INTO artists (artist_id, artist_name, label_id, genre_id, artist_type, home_country, debut_year, monthly_listeners_baseline)
SELECT
  m.id AS artist_id,
  m.w AS artist_name,
  1 + (m.id % 12) AS label_id,
  1 + (m.id % 15) AS genre_id,
  CASE WHEN m.id % 4 = 0 THEN 'mainstream' ELSE 'independent' END AS artist_type,
  t.country_name AS home_country,
  2010 + (m.id % 15) AS debut_year,
  FLOOR(5000 + RAND() * 2000000) AS monthly_listeners_baseline
FROM metal_artist_names m
JOIN territories t ON t.territory_id = 1 + (m.id % 20);

CREATE TABLE releases (
  release_id   INT PRIMARY KEY,
  artist_id    INT NOT NULL,
  label_id     INT NOT NULL,
  release_title VARCHAR(100),
  release_type  ENUM('single','ep','album') NOT NULL,
  release_date  DATE,
  FOREIGN KEY (artist_id) REFERENCES artists(artist_id),
  FOREIGN KEY (label_id) REFERENCES labels(label_id)
);
INSERT INTO releases (release_id, artist_id, label_id, release_title, release_type, release_date)
SELECT
  ROW_NUMBER() OVER (ORDER BY ar.artist_id, sl.n) AS release_id,
  ar.artist_id,
  ar.label_id,
  CONCAT(wa.w, ' ', wn.w) AS release_title,
  CASE
    WHEN (ar.artist_id + sl.n) % 10 < 5 THEN 'single'
    WHEN (ar.artist_id + sl.n) % 10 < 8 THEN 'ep'
    ELSE 'album'
  END AS release_type,
  DATE_SUB(CURDATE(), INTERVAL FLOOR(30 + RAND() * 1800) DAY) AS release_date
FROM artists ar
JOIN seq_helper sl ON sl.n < (3 + (ar.artist_id % 4))
JOIN word_adj wa ON wa.id = 1 + ((ar.artist_id * 3 + sl.n * 5) % 20)
JOIN word_noun wn ON wn.id = 1 + ((ar.artist_id * 9 + sl.n * 2) % 20);

CREATE TABLE tracks (
  track_id     INT PRIMARY KEY,
  release_id   INT NOT NULL,
  track_title  VARCHAR(100),
  track_number INT,
  duration_sec INT,
  isrc         CHAR(15),
  is_explicit  TINYINT(1),
  FOREIGN KEY (release_id) REFERENCES releases(release_id)
);
INSERT INTO tracks (track_id, release_id, track_title, track_number, duration_sec, isrc, is_explicit)
SELECT
  ROW_NUMBER() OVER (ORDER BY r.release_id, sl.n) AS track_id,
  r.release_id,
  CONCAT(wa.w, ' ', wn.w) AS track_title,
  sl.n + 1 AS track_number,
  FLOOR(150 + RAND() * 120) AS duration_sec,
  CONCAT('SIM', LPAD(r.release_id, 6, '0'), LPAD(sl.n + 1, 2, '0')) AS isrc,
  (RAND() < 0.15) AS is_explicit
FROM releases r
JOIN seq_helper sl
  ON sl.n < CASE r.release_type
              WHEN 'single' THEN 1
              WHEN 'ep' THEN 3 + (r.release_id % 3)
              ELSE 7 + (r.release_id % 6)
            END
JOIN word_adj wa ON wa.id = 1 + ((r.release_id * 13 + sl.n * 7) % 20)
JOIN word_noun wn ON wn.id = 1 + ((r.release_id * 17 + sl.n * 3) % 20);

CREATE TABLE playlists (
  playlist_id   INT PRIMARY KEY,
  playlist_name VARCHAR(100),
  dsp_id        INT NOT NULL,
  playlist_type ENUM('editorial','algorithmic','user'),
  follower_count INT,
  FOREIGN KEY (dsp_id) REFERENCES dsps(dsp_id)
);
INSERT INTO playlists (playlist_id, playlist_name, dsp_id, playlist_type, follower_count) VALUES
(1,'New Music Friday',1,'editorial',4200000),
(2,'Kickass Metal',1,'editorial',1580000),
(3,'Digging Deeper',1,'editorial',1230000),
(4,'Century Break',1,'editorial',345000),
(5,'mint',1,'editorial',620000),
(6,'Rock This',1,'editorial',3100000),
(7,'Discover Weekly',1,'algorithmic',0),
(8,'Release Radar',1,'algorithmic',0),
(9,'New Noise',1,'editorial',540000),
(10,'Descargas Pesadas',1,'editorial',89000),
(11,'A-List Rock',2,'editorial',510000),
(12,'Encore',2,'editorial',380000),
(13,'Best of the Week',2,'algorithmic',0),
(14,'New Music Daily',2,'editorial',720000),
(15,'Trending Now',3,'algorithmic',0),
(16,'Music Discovery',3,'editorial',210000),
(17,'Fresh Finds',4,'editorial',98000),
(18,'Amazon Music Breakthrough',4,'editorial',74000),
(19,'Deezer Editorial Picks',5,'editorial',61000),
(20,'Tidal Rising',6,'editorial',42000),
(21,'SoundCloud Go',7,'editorial',35000),
(22,'Bedroom Riffs',5,'user',29000),
(23,'Riffs & Chains',1,'editorial',390000),
(24,'Blackened Nights',1,'editorial',270000),
(25,'Groove Foundry',1,'editorial',160000),
(26,'Djent Lab',1,'editorial',220000),
(27,'Symphonic Realms',1,'editorial',110000),
(28,'Electro Industrial Nights',5,'editorial',53000),
(29,'Alt Rock Radar',6,'editorial',28000),
(30,'Doom & Gloom',2,'editorial',61000);

-- ---------------------------------------------------------------------
-- campaigns (dimension-ish, has its own natural keys/dates)
-- ---------------------------------------------------------------------
CREATE TABLE campaigns (
  campaign_id   INT PRIMARY KEY,
  artist_id     INT NOT NULL,
  release_id    INT,
  campaign_name VARCHAR(100),
  platform      ENUM('Meta','TikTok','Google','YouTube','Spotify Ad Studio'),
  objective     ENUM('awareness','streams','followers','pre-save'),
  start_date    DATE,
  end_date      DATE,
  total_budget  DECIMAL(10,2),
  FOREIGN KEY (artist_id) REFERENCES artists(artist_id),
  FOREIGN KEY (release_id) REFERENCES releases(release_id)
);
INSERT INTO campaigns (campaign_id, artist_id, release_id, campaign_name, platform, objective, start_date, end_date, total_budget)
SELECT
  ROW_NUMBER() OVER (ORDER BY ar.artist_id, sl.n) AS campaign_id,
  ar.artist_id,
  r.release_id,
  CONCAT(r.release_title, ' — ',
    CASE (ar.artist_id + sl.n) % 5
      WHEN 0 THEN 'Awareness Push'
      WHEN 1 THEN 'Streams Boost'
      WHEN 2 THEN 'Follower Growth'
      WHEN 3 THEN 'Pre-Save Drive'
      ELSE 'Release Campaign'
    END) AS campaign_name,
  CASE (ar.artist_id + sl.n) % 5
    WHEN 0 THEN 'Meta' WHEN 1 THEN 'TikTok' WHEN 2 THEN 'Google' WHEN 3 THEN 'YouTube' ELSE 'Spotify Ad Studio'
  END AS platform,
  CASE (ar.artist_id + sl.n) % 4
    WHEN 0 THEN 'awareness' WHEN 1 THEN 'streams' WHEN 2 THEN 'followers' ELSE 'pre-save'
  END AS objective,
  DATE_ADD(r.release_date, INTERVAL -14 DAY) AS start_date,
  DATE_ADD(r.release_date, INTERVAL (4 + (sl.n % 6)) WEEK) AS end_date,
  ROUND((CASE ar.artist_type WHEN 'mainstream' THEN 8000 ELSE 1500 END) * (0.6 + RAND() * 1.2), 2) AS total_budget
FROM artists ar
JOIN seq_helper sl ON sl.n < (1 + (ar.artist_id % 2))
JOIN (SELECT artist_id, MIN(release_id) AS first_release_id FROM releases GROUP BY artist_id) fr ON fr.artist_id = ar.artist_id
JOIN releases r ON r.release_id = fr.first_release_id + sl.n;

-- ---------------------------------------------------------------------
-- Fact: track availability per DSP (drives which track/dsp pairs stream)
-- ---------------------------------------------------------------------
CREATE TABLE track_dsp_availability (
  track_id      INT NOT NULL,
  dsp_id        INT NOT NULL,
  available_date DATE NOT NULL,
  PRIMARY KEY (track_id, dsp_id),
  FOREIGN KEY (track_id) REFERENCES tracks(track_id),
  FOREIGN KEY (dsp_id) REFERENCES dsps(dsp_id)
);
INSERT INTO track_dsp_availability (track_id, dsp_id, available_date)
SELECT t.track_id, d.dsp_id, r.release_date
FROM tracks t
JOIN releases r ON r.release_id = t.release_id
CROSS JOIN dsps d
WHERE RAND() < 0.8 OR d.dsp_id = 1;

-- ---------------------------------------------------------------------
-- Fact: weekly streams + revenue per track/DSP
-- ---------------------------------------------------------------------
CREATE TABLE streaming_weekly (
  track_id  INT NOT NULL,
  dsp_id    INT NOT NULL,
  week_id   INT NOT NULL,
  streams   BIGINT,
  revenue   DECIMAL(12,4),
  PRIMARY KEY (track_id, dsp_id, week_id),
  FOREIGN KEY (dsp_id) REFERENCES dsps(dsp_id),
  FOREIGN KEY (week_id) REFERENCES calendar_week(week_id)
);
INSERT INTO streaming_weekly (track_id, dsp_id, week_id, streams, revenue)
SELECT track_id, dsp_id, week_id, streams, ROUND(streams * avg_payout_per_stream, 4)
FROM (
  SELECT
    a.track_id,
    a.dsp_id,
    cw.week_id,
    d.avg_payout_per_stream,
    GREATEST(0, ROUND(
      (ar.monthly_listeners_baseline / 30)
      * d.reach_share
      * POW(0.985, ROW_NUMBER() OVER (PARTITION BY a.track_id, a.dsp_id ORDER BY cw.week_start_date) - 1)
      * (0.7 + RAND() * 0.6)
    )) AS streams
  FROM track_dsp_availability a
  JOIN dsps d ON d.dsp_id = a.dsp_id
  JOIN tracks tr ON tr.track_id = a.track_id
  JOIN releases r ON r.release_id = tr.release_id
  JOIN artists ar ON ar.artist_id = r.artist_id
  JOIN calendar_week cw ON cw.week_start_date >= a.available_date AND cw.week_start_date <= CURDATE()
) x;

-- ---------------------------------------------------------------------
-- Track -> top 3 territories (weighted toward artist home country)
-- ---------------------------------------------------------------------
CREATE TABLE track_territory_map (
  track_id     INT NOT NULL,
  territory_id INT NOT NULL,
  rnk          INT NOT NULL,
  PRIMARY KEY (track_id, territory_id),
  FOREIGN KEY (track_id) REFERENCES tracks(track_id),
  FOREIGN KEY (territory_id) REFERENCES territories(territory_id)
);
INSERT INTO track_territory_map (track_id, territory_id, rnk)
SELECT track_id, territory_id, rnk
FROM (
  SELECT
    tr.track_id,
    ter.territory_id,
    ROW_NUMBER() OVER (
      PARTITION BY tr.track_id
      ORDER BY CASE WHEN ter.country_name = ar.home_country THEN 0 ELSE RAND() END
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rnk
  FROM tracks tr
  JOIN releases r ON r.release_id = tr.release_id
  JOIN artists ar ON ar.artist_id = r.artist_id
  CROSS JOIN territories ter
) ranked
WHERE rnk <= 3;

CREATE TABLE streaming_by_territory_monthly (
  track_id     INT NOT NULL,
  territory_id INT NOT NULL,
  month_id     INT NOT NULL,
  streams      BIGINT,
  PRIMARY KEY (track_id, territory_id, month_id),
  FOREIGN KEY (territory_id) REFERENCES territories(territory_id),
  FOREIGN KEY (month_id) REFERENCES calendar_month(month_id)
);
INSERT INTO streaming_by_territory_monthly (track_id, territory_id, month_id, streams)
SELECT
  m.track_id,
  m.territory_id,
  cm.month_id,
  GREATEST(0, ROUND(
    (ar.monthly_listeners_baseline * 0.2)
    * (CASE m.rnk WHEN 1 THEN 0.5 WHEN 2 THEN 0.3 ELSE 0.2 END)
    * POW(0.97, ROW_NUMBER() OVER (PARTITION BY m.track_id, m.territory_id ORDER BY cm.month_date) - 1)
    * (0.7 + RAND() * 0.6)
  )) AS streams
FROM track_territory_map m
JOIN tracks tr ON tr.track_id = m.track_id
JOIN releases r ON r.release_id = tr.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
JOIN calendar_month cm ON cm.month_date >= DATE_FORMAT(r.release_date, '%Y-%m-01') AND cm.month_date <= CURDATE();

-- ---------------------------------------------------------------------
-- Playlist placements
-- ---------------------------------------------------------------------
CREATE TABLE playlist_placements (
  track_id       INT NOT NULL,
  playlist_id    INT NOT NULL,
  added_week_id  INT NOT NULL,
  removed_week_id INT,
  PRIMARY KEY (track_id, playlist_id),
  FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id),
  FOREIGN KEY (added_week_id) REFERENCES calendar_week(week_id)
);
INSERT INTO playlist_placements (track_id, playlist_id, added_week_id, removed_week_id)
SELECT track_id, playlist_id, added_week_id,
  CASE WHEN RAND() < 0.6 THEN LEAST(104, added_week_id + FLOOR(1 + RAND() * 8)) ELSE NULL END AS removed_week_id
FROM (
  SELECT
    tr.track_id,
    p.playlist_id,
    1 + FLOOR(RAND() * 104) AS added_week_id,
    ROW_NUMBER() OVER (PARTITION BY p.playlist_id ORDER BY RAND() ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS pick
  FROM playlists p
  CROSS JOIN tracks tr
) placed
WHERE pick <= 60;

-- ---------------------------------------------------------------------
-- Weekly campaign spend / performance
-- ---------------------------------------------------------------------
CREATE TABLE campaign_spend_weekly (
  campaign_id INT NOT NULL,
  week_id     INT NOT NULL,
  spend       DECIMAL(10,2),
  impressions BIGINT,
  clicks      INT,
  conversions INT,
  PRIMARY KEY (campaign_id, week_id),
  FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id),
  FOREIGN KEY (week_id) REFERENCES calendar_week(week_id)
);
INSERT INTO campaign_spend_weekly (campaign_id, week_id, spend, impressions, clicks, conversions)
SELECT
  c.campaign_id,
  cw.week_id,
  ROUND(c.total_budget / GREATEST(1, DATEDIFF(c.end_date, c.start_date) / 7), 2) AS spend,
  FLOOR(20000 + RAND() * 180000) AS impressions,
  FLOOR(200 + RAND() * 4000) AS clicks,
  FLOOR(5 + RAND() * 300) AS conversions
FROM campaigns c
JOIN calendar_week cw ON cw.week_start_date >= c.start_date AND cw.week_start_date <= c.end_date;

-- ---------------------------------------------------------------------
-- Monthly social metrics per artist per platform
-- ---------------------------------------------------------------------
CREATE TABLE social_platforms (
  platform_id INT PRIMARY KEY,
  platform_name VARCHAR(30)
);
INSERT INTO social_platforms VALUES (1,'Instagram'),(2,'TikTok'),(3,'YouTube'),(4,'X');

CREATE TABLE social_metrics_monthly (
  artist_id   INT NOT NULL,
  platform_id INT NOT NULL,
  month_id    INT NOT NULL,
  followers   BIGINT,
  avg_engagement_rate DECIMAL(5,4),
  PRIMARY KEY (artist_id, platform_id, month_id),
  FOREIGN KEY (artist_id) REFERENCES artists(artist_id),
  FOREIGN KEY (platform_id) REFERENCES social_platforms(platform_id),
  FOREIGN KEY (month_id) REFERENCES calendar_month(month_id)
);
INSERT INTO social_metrics_monthly (artist_id, platform_id, month_id, followers, avg_engagement_rate)
SELECT
  ar.artist_id,
  sp.platform_id,
  cm.month_id,
  ROUND(
    (ar.monthly_listeners_baseline * 0.3 * (CASE sp.platform_id WHEN 1 THEN 0.9 WHEN 2 THEN 0.6 WHEN 3 THEN 0.4 ELSE 0.25 END))
    * (1 + (ROW_NUMBER() OVER (PARTITION BY ar.artist_id, sp.platform_id ORDER BY cm.month_date) - 1) * 0.01)
  ) AS followers,
  ROUND(0.01 + RAND() * 0.07, 4) AS avg_engagement_rate
FROM artists ar
CROSS JOIN social_platforms sp
CROSS JOIN calendar_month cm;

-- ---------------------------------------------------------------------
-- Convenience views for analytics practice
-- ---------------------------------------------------------------------
CREATE VIEW vw_track_performance AS
SELECT
  t.track_id, t.track_title, r.release_title, r.release_type,
  ar.artist_id, ar.artist_name, ar.artist_type, g.genre_name,
  d.dsp_name, cw.iso_year, cw.iso_week, sw.streams, sw.revenue
FROM streaming_weekly sw
JOIN tracks t ON t.track_id = sw.track_id
JOIN releases r ON r.release_id = t.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
JOIN genres g ON g.genre_id = ar.genre_id
JOIN dsps d ON d.dsp_id = sw.dsp_id
JOIN calendar_week cw ON cw.week_id = sw.week_id;

CREATE VIEW vw_artist_monthly_summary AS
SELECT
  ar.artist_id, ar.artist_name, ar.artist_type, l.label_name,
  cm.month_id, cm.month_date,
  SUM(stm.streams) AS territory_streams
FROM streaming_by_territory_monthly stm
JOIN tracks t ON t.track_id = stm.track_id
JOIN releases r ON r.release_id = t.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
JOIN labels l ON l.label_id = ar.label_id
JOIN calendar_month cm ON cm.month_id = stm.month_id
GROUP BY ar.artist_id, ar.artist_name, ar.artist_type, l.label_name, cm.month_id, cm.month_date;

CREATE VIEW vw_campaign_roi AS
SELECT
  c.campaign_id, c.campaign_name, ar.artist_name, c.platform, c.objective,
  SUM(csw.spend) AS total_spend,
  SUM(csw.impressions) AS total_impressions,
  SUM(csw.clicks) AS total_clicks,
  SUM(csw.conversions) AS total_conversions,
  ROUND(SUM(csw.spend) / NULLIF(SUM(csw.conversions), 0), 2) AS cost_per_conversion
FROM campaign_spend_weekly csw
JOIN campaigns c ON c.campaign_id = csw.campaign_id
JOIN artists ar ON ar.artist_id = c.artist_id
GROUP BY c.campaign_id, c.campaign_name, ar.artist_name, c.platform, c.objective;

-- ---------------------------------------------------------------------
-- Teaching views: single flat "table" per view, no JOIN needed by
-- students. Used in the classroom exercises (SELECT/WHERE/GROUP BY
-- practice) before JOINs are introduced.
-- ---------------------------------------------------------------------
CREATE VIEW track_catalog AS
SELECT
  t.track_title, ar.artist_name, ar.artist_type, g.genre_name,
  r.release_type, t.duration_sec, t.is_explicit, l.label_type
FROM tracks t
JOIN releases r ON r.release_id = t.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
JOIN genres g ON g.genre_id = ar.genre_id
JOIN labels l ON l.label_id = r.label_id;

CREATE VIEW stream_log AS
SELECT
  ar.artist_name, ar.artist_type, g.genre_name, d.dsp_name,
  cw.iso_week AS week_num,
  SUM(sw.streams) AS streams,
  ROUND(SUM(sw.revenue), 2) AS revenue
FROM streaming_weekly sw
JOIN tracks t ON t.track_id = sw.track_id
JOIN releases r ON r.release_id = t.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
JOIN genres g ON g.genre_id = ar.genre_id
JOIN dsps d ON d.dsp_id = sw.dsp_id
JOIN calendar_week cw ON cw.week_id = sw.week_id
GROUP BY ar.artist_name, ar.artist_type, g.genre_name, d.dsp_name, cw.iso_week;

-- ---------------------------------------------------------------------
-- Cleanup: drop generation-only helper tables
-- ---------------------------------------------------------------------
DROP TABLE seq_helper;
DROP TABLE word_adj;
DROP TABLE word_noun;
DROP TABLE metal_artist_names;

SELECT 'MusicWorks database created successfully.' AS status;
