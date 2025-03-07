-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS spotify;

-- Use the spotify database
USE spotify;

-- Daily User Song Count
CREATE TABLE spotify.report_daily_user_song_count_hdfs
(
    user_id UInt32,
    listen_date Date,
    song_count UInt64
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_daily_user_song_count/*.parquet', 'Parquet');

-- Error Status Codes
CREATE TABLE spotify.report_error_status_codes_hdfs
(
    status_code UInt16,
    status_category String,
    page String,
    event_date Date,
    error_count UInt64,
    affected_users UInt64,
    affected_sessions UInt64
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_error_status_codes/*.parquet', 'Parquet');

-- New User Behavior
CREATE TABLE spotify.report_new_user_behavior_hdfs
(
    user_id UInt32,
    days_since_registration Int32,
    daily_song_plays UInt64,
    daily_sessions UInt64,
    daily_listening_time_seconds Float64,
    daily_listening_time_minutes Float64
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_new_user_behavior/*.parquet', 'Parquet');

-- Skipping Sessions
CREATE TABLE spotify.report_skipping_sessions_hdfs
(
    session_id UInt32,
    user_id UInt32,
    nextsong_count UInt64,
    session_duration_seconds Float64,
    total_actions UInt64,
    skip_ratio Float64,
    skips_per_minute Float64,
    subscription_level String
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_skipping_sessions/*.parquet', 'Parquet');

-- Top Songs
CREATE TABLE spotify.report_top_songs_hdfs
(
    song_id String,
    song_name String,
    artist_name String,
    play_count UInt64,
    unique_listeners UInt64,
    avg_play_duration Float64
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_top_songs/*.parquet', 'Parquet');

-- Weekday Average Listening Time
CREATE TABLE spotify.report_weekday_avg_listening_time_hdfs
(
    day_of_week String,
    day_of_week_number UInt8,
    avg_listening_time_seconds Float64,
    total_listening_time_seconds Float64,
    total_listen_events UInt64
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_weekday_avg_listening_time/*.parquet', 'Parquet');

-- Average Session Duration
CREATE TABLE spotify.report_avg_session_duration_hdfs
(
    user_id UInt32,
    avg_session_duration_seconds Float64,
    avg_session_duration_minutes Float64,
    avg_actions_per_session Float64,
    total_sessions UInt64,
    subscription_level String
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_avg_session_duration/*.parquet', 'Parquet');

-- City Active Users
CREATE TABLE spotify.report_city_active_users_hdfs
(
    city String,
    state String,
    active_users UInt64,
    paid_users UInt64,
    free_users UInt64
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_city_active_users/*.parquet', 'Parquet');

-- Conversion Rate
CREATE TABLE spotify.report_conversion_rate_hdfs
(
    date Date,
    total_users UInt64,
    paid_users UInt64,
    free_users UInt64,
    conversion_rate Float64
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_conversion_rate/*.parquet', 'Parquet');

-- Free vs Paid Users
CREATE TABLE spotify.report_free_vs_paid_users_hdfs
(
    date Date,
    subscription_level String,
    user_count UInt64,
    percentage Float64
)
ENGINE = HDFS('hdfs://namenode:9000/user/gold/report_free_vs_paid_users/*.parquet', 'Parquet');
