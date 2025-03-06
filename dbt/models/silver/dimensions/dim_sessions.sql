{{
    config(
        materialized='table',
        location_root=var('silver_path') + '/dimensions',
        file_format='parquet'
    )
}}

with session_data as (
    select
        sessionId,
        userId,
        min(ts) as session_start_ts,
        max(ts) as session_end_ts,
        count(*) as total_actions
    from parquet.`hdfs://namenode:9000/user/bronze/listen_events`
    where sessionId is not null and userId is not null
    group by sessionId, userId

    union

    select
        sessionId,
        userId,
        min(ts) as session_start_ts,
        max(ts) as session_end_ts,
        count(*) as total_actions
    from parquet.`hdfs://namenode:9000/user/bronze/page_view_events`
    where sessionId is not null and userId is not null
    group by sessionId, userId
)

select
    sessionId as session_id,
    userId as user_id,
    from_unixtime(session_start_ts/1000) as session_start_time,
    from_unixtime(session_end_ts/1000) as session_end_time,
    date_format(from_unixtime(session_start_ts/1000), 'yyyy-MM-dd') as session_date,
    (session_end_ts - session_start_ts) / 1000 as session_duration_seconds,
    total_actions,
    current_timestamp() as created_at
from session_data
