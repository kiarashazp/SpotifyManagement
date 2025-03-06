{{
    config(
        materialized='table',
        location_root=var('gold_path'),
        file_format='parquet'
    )
}}


with session_durations as (
    select
        s.user_id,
        s.session_id,
        s.session_duration_seconds,
        s.total_actions,
        u.subscription_level
    from {{ ref('dim_sessions') }} s
    join {{ ref('dim_users') }} u on s.user_id = u.user_id
)

select
    user_id,
    avg(session_duration_seconds) as avg_session_duration_seconds,
    avg(session_duration_seconds / 60) as avg_session_duration_minutes,
    avg(total_actions) as avg_actions_per_session,
    count(*) as total_sessions,
    subscription_level
from session_durations
group by user_id, subscription_level
order by avg_session_duration_seconds desc