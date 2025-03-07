
      create table default_gold.report_new_user_behavior
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/gold/report_new_user_behavior'
    
    as
      


with new_users as (
    select
        user_id,
        registration_timestamp
    from default_silver.dim_users
),

first_week_activity as (
    select
        f.user_id,
        date_diff('day', from_unixtime(u.registration_timestamp), f.listen_timestamp) as days_since_registration,
        count(*) as song_plays,
        count(distinct f.session_id) as sessions,
        sum(f.duration_seconds) as total_listening_time
    from default_silver.fact_listen_events f
    join new_users u on f.user_id = u.user_id
    where date_diff('day', from_unixtime(u.registration_timestamp), f.listen_timestamp) between 0 and 7
    group by f.user_id, date_diff('day', from_unixtime(u.registration_timestamp), f.listen_timestamp)
)

select
    user_id,
    days_since_registration,
    song_plays as daily_song_plays,
    sessions as daily_sessions,
    total_listening_time as daily_listening_time_seconds,
    total_listening_time / 60 as daily_listening_time_minutes
from first_week_activity
order by user_id, days_since_registration