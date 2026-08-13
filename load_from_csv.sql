-- =====================================================================
-- MusicWorks — load from the CSV exports instead of regenerating data
-- Use this if you want the EXACT SAME dataset as everyone else in class
-- (install_musicworks.sql uses RAND(), so each run differs).
--
-- Run from the repo root (paths below are relative to csv/):
--   mysql -u root -h 127.0.0.1 -P 3306 --local-infile=1 < load_from_csv.sql
--
-- If you get "The used command is not allowed with this MySQL version"
-- or a local_infile error, first run:
--   mysql -u root -h 127.0.0.1 -P 3306 -e "SET GLOBAL local_infile=1;"
-- =====================================================================

DROP DATABASE IF EXISTS musicworks;
CREATE DATABASE musicworks;
USE musicworks;

CREATE TABLE labels (
  label_id     INT PRIMARY KEY,
  label_name   VARCHAR(80) NOT NULL,
  label_type   ENUM('major','indie') NOT NULL,
  hq_country   VARCHAR(60),
  founded_year INT
);

CREATE TABLE genres (
  genre_id   INT PRIMARY KEY,
  genre_name VARCHAR(40)
);

CREATE TABLE territories (
  territory_id INT PRIMARY KEY,
  country_code CHAR(2),
  country_name VARCHAR(60),
  region       VARCHAR(30)
);

CREATE TABLE dsps (
  dsp_id               INT PRIMARY KEY,
  dsp_name             VARCHAR(40),
  platform_type        ENUM('streaming','video','social'),
  avg_payout_per_stream DECIMAL(8,6),
  reach_share          DECIMAL(4,3)
);

CREATE TABLE social_platforms (
  platform_id INT PRIMARY KEY,
  platform_name VARCHAR(30)
);

CREATE TABLE calendar_week (
  week_id        INT PRIMARY KEY,
  week_start_date DATE NOT NULL,
  week_end_date   DATE NOT NULL,
  iso_year        INT,
  iso_week        INT
);

CREATE TABLE calendar_month (
  month_id   INT PRIMARY KEY,
  month_date DATE NOT NULL
);

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

CREATE TABLE playlists (
  playlist_id   INT PRIMARY KEY,
  playlist_name VARCHAR(100),
  dsp_id        INT NOT NULL,
  playlist_type ENUM('editorial','algorithmic','user'),
  follower_count INT,
  FOREIGN KEY (dsp_id) REFERENCES dsps(dsp_id)
);

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

CREATE TABLE track_dsp_availability (
  track_id      INT NOT NULL,
  dsp_id        INT NOT NULL,
  available_date DATE NOT NULL,
  PRIMARY KEY (track_id, dsp_id),
  FOREIGN KEY (track_id) REFERENCES tracks(track_id),
  FOREIGN KEY (dsp_id) REFERENCES dsps(dsp_id)
);

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

CREATE TABLE track_territory_map (
  track_id     INT NOT NULL,
  territory_id INT NOT NULL,
  rnk          INT NOT NULL,
  PRIMARY KEY (track_id, territory_id),
  FOREIGN KEY (track_id) REFERENCES tracks(track_id),
  FOREIGN KEY (territory_id) REFERENCES territories(territory_id)
);

CREATE TABLE streaming_by_territory_monthly (
  track_id     INT NOT NULL,
  territory_id INT NOT NULL,
  month_id     INT NOT NULL,
  streams      BIGINT,
  PRIMARY KEY (track_id, territory_id, month_id),
  FOREIGN KEY (territory_id) REFERENCES territories(territory_id),
  FOREIGN KEY (month_id) REFERENCES calendar_month(month_id)
);

CREATE TABLE playlist_placements (
  track_id       INT NOT NULL,
  playlist_id    INT NOT NULL,
  added_week_id  INT NOT NULL,
  removed_week_id INT,
  PRIMARY KEY (track_id, playlist_id),
  FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id),
  FOREIGN KEY (added_week_id) REFERENCES calendar_week(week_id)
);

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

-- ---------------------------------------------------------------------
-- Load CSVs in FK-safe order
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'csv/labels.csv' INTO TABLE labels
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/genres.csv' INTO TABLE genres
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/territories.csv' INTO TABLE territories
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/dsps.csv' INTO TABLE dsps
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/social_platforms.csv' INTO TABLE social_platforms
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/calendar_week.csv' INTO TABLE calendar_week
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/calendar_month.csv' INTO TABLE calendar_month
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/artists.csv' INTO TABLE artists
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/releases.csv' INTO TABLE releases
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/tracks.csv' INTO TABLE tracks
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/playlists.csv' INTO TABLE playlists
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/campaigns.csv' INTO TABLE campaigns
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/track_dsp_availability.csv' INTO TABLE track_dsp_availability
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/streaming_weekly.csv' INTO TABLE streaming_weekly
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/track_territory_map.csv' INTO TABLE track_territory_map
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/streaming_by_territory_monthly.csv' INTO TABLE streaming_by_territory_monthly
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/playlist_placements.csv' INTO TABLE playlist_placements
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
  (track_id, playlist_id, added_week_id, @removed)
  SET removed_week_id = NULLIF(@removed, '');

LOAD DATA LOCAL INFILE 'csv/campaign_spend_weekly.csv' INTO TABLE campaign_spend_weekly
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'csv/social_metrics_monthly.csv' INTO TABLE social_metrics_monthly
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

-- ---------------------------------------------------------------------
-- Views (same as install_musicworks.sql)
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

SELECT 'MusicWorks loaded from CSV successfully.' AS status;
