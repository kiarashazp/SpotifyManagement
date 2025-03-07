
      create table default_silver.fact_auth_events
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/silver/facts/fact_auth_events'
    
    as
      

with auth_data as (
    select
        ts,
        userId,
        sessionId,
        level,
        city,
        state,
        zip,
        lat,
        lon,
        itemInSession,
        success
    from parquet.`hdfs://namenode:9000/user/bronze/auth_events`
    where ts is not null and userId is not null
)

select
    md5(concat(cast(ts as string), '|', cast(userId as string), '|', cast(sessionId as string), '|', cast(itemInSession as string))) as auth_id,
    ts as timestamp_ms,
    userId as user_id,
    sessionId as session_id,
    md5(concat(city, '|', state, '|', coalesce(zip, ''))) as location_id,
    level as subscription_level,
    itemInSession as item_in_session,
    success as success_flag,
    from_unixtime(ts/1000) as auth_timestamp,
    date_format(from_unixtime(ts/1000), 'yyyy-MM-dd') as auth_date,
    current_timestamp() as created_at
from auth_data