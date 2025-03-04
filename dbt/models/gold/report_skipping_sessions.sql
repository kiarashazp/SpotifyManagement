{{
    config(
        materialized='table',
        location_root=var('gold_path'),
        file_format='parquet'
    )
}}

with nextsong_events as (
    select
        session_id,
        user_id,
        page,
        count(*) as nextsong_count
    from {{ ref('fact_page_views') }}
    where page = 'NextSong'
    group by session_id, user_id, page
),

session_stats as (
    select
        n.session_id,
        n.user_id,
        n.nextsong_count,
        s.session_duration_seconds,
        s.total_actions,
        u.subscription_level
    from nextsong_events n
    join {{ ref('dim_sessions') }} s on n.session_id = s.session_id
    join {{ ref('dim_users') }} u on n.user_id = u.user_id
)

select
    session_id,
    user_id,
    nextsong_count,
    session_duration_seconds,
    total_actions,
    nextsong_count / total_actions as skip_ratio,
    nextsong_count / (session_duration_seconds / 60) as skips_per_minute,
    subscription_level
from session_stats
where nextsong_count > 5
order by nextsong_count desc