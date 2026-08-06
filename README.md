# MusicWorks (metal edition)

Simulated music marketing analytics database for practicing SQL — same
spirit as Microsoft's AdventureWorks sample, but themed around a record
label's streaming/marketing ecosystem.

**Disclaimer:** artist names are real, well-known metal acts (so the data
feels familiar). Everything else — labels, genres, streaming counts,
revenue, campaigns, social growth — is 100% simulated. None of it reflects
real chart performance, real contracts, or real financials.

## What's inside

- ~100 artists, ~450 releases, ~1,600 tracks
- 7 DSPs (Spotify, Apple Music, YouTube Music, Amazon Music, Deezer, Tidal, SoundCloud)
- ~800k rows of weekly streaming + revenue history (2 years)
- Streams by territory (20 countries), playlist placements, ad campaigns
  with weekly spend, and monthly social follower growth

## Requirements

- MySQL 8.0+ (uses recursive CTEs and window functions)

## Install

```bash
mysql -u root -h 127.0.0.1 -P 3306 < install_musicworks.sql
```

This drops and recreates the `musicworks` database from scratch. Takes
under a minute; generates ~800k+ rows.

## Explore

`example_queries.sql` has 10 starter queries: top tracks, indie vs.
mainstream streaming, DSP revenue share, playlist lift, campaign ROI,
genre-by-DSP breakdown, follower growth, geo breakdown, label rollups,
catalog vs. new-release performance.

```bash
mysql -u root -h 127.0.0.1 -P 3306 musicworks < example_queries.sql
```

## Schema overview

**Dimensions:** `labels`, `genres`, `territories`, `dsps`, `artists`,
`releases`, `tracks`, `playlists`, `campaigns`, `calendar_week`,
`calendar_month`, `social_platforms`

**Facts:** `streaming_weekly`, `streaming_by_territory_monthly`,
`playlist_placements`, `campaign_spend_weekly`, `social_metrics_monthly`,
`track_dsp_availability`

**Views:** `vw_track_performance`, `vw_artist_monthly_summary`,
`vw_campaign_roi`
