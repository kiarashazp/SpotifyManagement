
      create table default_gold.report_avg_session_duration
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/gold/report_avg_session_duration'
    
    as
      


with session_durations as (
    select
        s.user_id,
        s.session_id,
        s.session_duration_seconds,
        s.total_actions,
        u.subscription_level
    from default_silver.dim_sessions s
    join default_silver.dim_users u on s.user_id = u.user_id
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