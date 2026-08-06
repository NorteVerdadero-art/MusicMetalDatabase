-- =====================================================================
-- MusicWorks — example analytics queries (practice starters)
-- USE musicworks; before running these.
-- =====================================================================
USE musicworks;

-- 1) Top 10 tracks by streams in the most recent week
SELECT t.track_title, ar.artist_name, sw.streams, sw.revenue
FROM streaming_weekly sw
JOIN tracks t ON t.track_id = sw.track_id
JOIN releases r ON r.release_id = t.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
WHERE sw.week_id = (SELECT MAX(week_id) FROM calendar_week)
ORDER BY sw.streams DESC
LIMIT 10;

-- 2) Independent vs. mainstream: average monthly streams per artist
SELECT ar.artist_type, ROUND(AVG(monthly.streams),0) AS avg_monthly_streams
FROM (
  SELECT ar2.artist_id, cm.month_id, SUM(stm.streams) AS streams
  FROM streaming_by_territory_monthly stm
  JOIN tracks t ON t.track_id = stm.track_id
  JOIN releases r ON r.release_id = t.release_id
  JOIN artists ar2 ON ar2.artist_id = r.artist_id
  JOIN calendar_month cm ON cm.month_id = stm.month_id
  GROUP BY ar2.artist_id, cm.month_id
) monthly
JOIN artists ar ON ar.artist_id = monthly.artist_id
GROUP BY ar.artist_type;

-- 3) DSP revenue share (who pays the label the most per stream)
SELECT dsp_name, SUM(streams) AS streams, ROUND(SUM(revenue),2) AS revenue,
       ROUND(SUM(revenue)/SUM(streams), 6) AS effective_payout_per_stream
FROM streaming_weekly sw JOIN dsps d ON d.dsp_id = sw.dsp_id
GROUP BY dsp_name
ORDER BY revenue DESC;

-- 4) Playlist lift: streams in the 4 weeks after being added to a playlist
--    vs. the 4 weeks before, for tracks that got a placement
SELECT pp.track_id, t.track_title, pl.playlist_name,
       SUM(CASE WHEN sw.week_id BETWEEN pp.added_week_id AND pp.added_week_id+3 THEN sw.streams ELSE 0 END) AS streams_after,
       SUM(CASE WHEN sw.week_id BETWEEN pp.added_week_id-4 AND pp.added_week_id-1 THEN sw.streams ELSE 0 END) AS streams_before
FROM playlist_placements pp
JOIN tracks t ON t.track_id = pp.track_id
JOIN playlists pl ON pl.playlist_id = pp.playlist_id
JOIN streaming_weekly sw ON sw.track_id = pp.track_id
GROUP BY pp.track_id, t.track_title, pl.playlist_name
HAVING streams_before > 0
ORDER BY (streams_after - streams_before) DESC
LIMIT 10;

-- 5) Campaign ROI leaderboard (cost per conversion, cheapest first)
SELECT * FROM vw_campaign_roi
WHERE total_conversions > 0
ORDER BY cost_per_conversion ASC
LIMIT 10;

-- 6) Genre breakdown: which metal subgenres stream best on which DSP
SELECT g.genre_name, d.dsp_name, SUM(sw.streams) AS streams
FROM streaming_weekly sw
JOIN dsps d ON d.dsp_id = sw.dsp_id
JOIN tracks t ON t.track_id = sw.track_id
JOIN releases r ON r.release_id = t.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
JOIN genres g ON g.genre_id = ar.genre_id
GROUP BY g.genre_name, d.dsp_name
ORDER BY g.genre_name, streams DESC;

-- 7) Social follower growth rate (first vs. last month on record) per platform
SELECT ar.artist_name, sp.platform_name,
       MIN(smm.followers) AS followers_start,
       MAX(smm.followers) AS followers_now,
       ROUND(100.0 * (MAX(smm.followers) - MIN(smm.followers)) / MIN(smm.followers), 1) AS pct_growth
FROM social_metrics_monthly smm
JOIN artists ar ON ar.artist_id = smm.artist_id
JOIN social_platforms sp ON sp.platform_id = smm.platform_id
GROUP BY ar.artist_name, sp.platform_name
ORDER BY pct_growth DESC
LIMIT 10;

-- 8) Top territories by streams for a specific artist (swap the name)
SELECT ter.country_name, SUM(stm.streams) AS streams
FROM streaming_by_territory_monthly stm
JOIN territories ter ON ter.territory_id = stm.territory_id
JOIN tracks t ON t.track_id = stm.track_id
JOIN releases r ON r.release_id = t.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
WHERE ar.artist_name = 'Gojira'
GROUP BY ter.country_name
ORDER BY streams DESC;

-- 9) Label-level revenue rollup (majors vs. indies)
SELECT l.label_type, SUM(sw.revenue) AS total_revenue
FROM streaming_weekly sw
JOIN tracks t ON t.track_id = sw.track_id
JOIN releases r ON r.release_id = t.release_id
JOIN labels l ON l.label_id = r.label_id
GROUP BY l.label_type;

-- 10) Catalog vs. new-release performance: streams by track age bucket
SELECT
  CASE
    WHEN DATEDIFF(CURDATE(), r.release_date) <= 90 THEN '0-3 months'
    WHEN DATEDIFF(CURDATE(), r.release_date) <= 365 THEN '3-12 months'
    ELSE 'catalog (12mo+)'
  END AS age_bucket,
  SUM(sw.streams) AS streams
FROM streaming_weekly sw
JOIN tracks t ON t.track_id = sw.track_id
JOIN releases r ON r.release_id = t.release_id
GROUP BY age_bucket
ORDER BY streams DESC;
