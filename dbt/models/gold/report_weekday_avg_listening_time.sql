{{
    config(
        materialized='table',
        location_root=var('gold_path'),
        file_format='parquet'
    )
}}

with listen_times as (
    select
        t.day_of_week,
        t.day_of_week_number,
        f.duration_seconds
    from {{ ref('fact_listen_events') }} f
    join {{ ref('dim_time') }} t on f.timestamp_ms = t.timestamp_ms
)

select
    day_of_week,
    day_of_week_number,
    avg(duration_seconds) as avg_listening_time_seconds,
    sum(duration_seconds) as total_listening_time_seconds,
    count(*) as total_listen_events
from listen_times
group by day_of_week, day_of_week_number
order by day_of_week_number