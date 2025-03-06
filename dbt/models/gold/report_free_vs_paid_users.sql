{{
    config(
        materialized='table',
        location_root=var('gold_path'),
        file_format='parquet'
    )
}}

with user_level_stats as (
    select
        f.user_id,
        u.subscription_level,
        count(*) as total_songs_played,
        sum(f.duration_seconds) as total_listening_time,
        count(distinct f.session_id) as total_sessions
    from {{ ref('fact_listen_events') }} f
    join {{ ref('dim_users') }} u on f.user_id = u.user_id
    group by f.user_id, u.subscription_level
)

select
    subscription_level,
    count(*) as user_count,
    avg(total_songs_played) as avg_songs_per_user,
    avg(total_listening_time) as avg_listening_time_per_user,
    avg(total_sessions) as avg_sessions_per_user,
    sum(total_songs_played) as total_songs_played,
    sum(total_listening_time) as total_listening_time,
    sum(total_sessions) as total_sessions
from user_level_stats
group by subscription_level
order by subscription_level