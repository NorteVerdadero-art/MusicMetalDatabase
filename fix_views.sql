CREATE OR REPLACE VIEW vw_track_performance AS
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

CREATE OR REPLACE VIEW vw_artist_monthly_summary AS
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

CREATE OR REPLACE VIEW vw_campaign_roi AS
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

CREATE OR REPLACE VIEW track_catalog AS
SELECT
  t.track_title, ar.artist_name, ar.artist_type, g.genre_name,
  r.release_type, t.duration_sec, t.is_explicit, l.label_type
FROM tracks t
JOIN releases r ON r.release_id = t.release_id
JOIN artists ar ON ar.artist_id = r.artist_id
JOIN genres g ON g.genre_id = ar.genre_id
JOIN labels l ON l.label_id = r.label_id;

CREATE OR REPLACE VIEW stream_log AS
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
