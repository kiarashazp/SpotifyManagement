-- Create database if not exists
CREATE DATABASE IF NOT EXISTS spotify;

-- Use the spotify database
USE spotify;

-- Report 1: Daily song count per user
CREATE TABLE IF NOT EXISTS report_daily_user_song_count
(
    user_id Int32,
    listen_date Date,
    song_count Int32
) ENGINE = MergeTree()
ORDER BY (listen_date, user_id);

-- Report 2: Average listening time by day of the week
CREATE TABLE IF NOT EXISTS report_weekday_avg_listening_time
(
    day_of_week String,
    day_of_week_number Int8,
    avg_listening_time_seconds Float64,
    total_listening_time_seconds Float64,
    total_listen_events Int32
) ENGINE = MergeTree()
ORDER BY day_of_week_number;

-- Report 3: City ranking by active users
CREATE TABLE IF NOT EXISTS report_city_active_users
(
    city String,
    state String,
    active_users Int32,
    total_sessions Int32,
    avg_sessions_per_user Float64
) ENGINE = MergeTree()
ORDER BY active_users;

-- Report 4: Top songs by play count
CREATE TABLE IF NOT EXISTS report_top_songs
(
    song_id String,
    song_name String,
    artist_name String,
    play_count Int32,
    unique_listeners Int32,
    avg_play_duration Float64
) ENGINE = MergeTree()
ORDER BY play_count;

-- Report 5: Free vs. Paid users comparison
CREATE TABLE IF NOT EXISTS report_free_vs_paid_users
(
    subscription_level String,
    user_count Int32,
    avg_songs_per_user Float64,
    avg_listening_time_per_user Float64,
    avg_sessions_per_user Float64,
    total_songs_played Int64,
    total_listening_time Float64,
    total_sessions Int64
) ENGINE = MergeTree()
ORDER BY subscription_level;

-- Report 6: Average session duration per user
CREATE TABLE IF NOT EXISTS report_avg_session_duration
(
    user_id Int32,
    avg_session_duration_seconds Float64,
    avg_session_duration_minutes Float64,
    avg_actions_per_session Float64,
    total_sessions Int32,
    subscription_level String
) ENGINE = MergeTree()
ORDER BY avg_session_duration_seconds;

-- Report 7: Conversion rate from Free to Paid subscriptions
CREATE TABLE IF NOT EXISTS report_conversion_rate
(
    date Date,
    free_users Int32,
    conversions Int32,
    daily_conversion_rate Float64
) ENGINE = MergeTree()
ORDER BY date;

-- Report 8: System error status codes 
CREATE TABLE IF NOT EXISTS report_error_status_codes
(
    status_code Int32,
    status_category String,
    page String,
    event_date Date,
    error_count Int32,
    affected_users Int32,
    affected_sessions Int32
) ENGINE = MergeTree()
ORDER BY (event_date, error_count, status_code);

-- Report 9: Sessions with high skipping behavior
CREATE TABLE IF NOT EXISTS report_skipping_sessions
(
    session_id Int32,
    user_id Int32,
    nextsong_count Int32,
    session_duration_seconds Float64,
    total_actions Int32,
    skip_ratio Float64,
    skips_per_minute Float64,
    subscription_level String
) ENGINE = MergeTree()
ORDER BY nextsong_count;

-- Report 10: New user behavior in first week
CREATE TABLE IF NOT EXISTS report_new_user_behavior
(
    user_id Int32,
    days_since_registration Int8,
    daily_song_plays Int32,
    daily_sessions Int32,
    daily_listening_time_seconds Float64,
    daily_listening_time_minutes Float64
) ENGINE = MergeTree()
ORDER BY (user_id, days_since_registration);