{{
    config(
        materialized='table',
        location_root=var('gold_path'),
        file_format='parquet'
    )
}}

with active_users_by_city as (
    select
        l.city,
        l.state,
        count(distinct f.user_id) as active_users
    from {{ ref('fact_listen_events') }} f
    join {{ ref('dim_locations') }} l on f.location_id = l.location_id
    group by l.city, l.state
),

total_sessions_by_city as (
    select
        l.city,
        l.state,
        count(distinct s.session_id) as total_sessions
    from {{ ref('dim_sessions') }} s
    join {{ ref('fact_listen_events') }} f on s.session_id = f.session_id
    join {{ ref('dim_locations') }} l on f.location_id = l.location_id
    group by l.city, l.state
)

select
    a.city,
    a.state,
    a.active_users,
    t.total_sessions,
    t.total_sessions / a.active_users as avg_sessions_per_user
from active_users_by_city a
join total_sessions_by_city t on a.city = t.city and a.state = t.state
order by a.active_users desc
