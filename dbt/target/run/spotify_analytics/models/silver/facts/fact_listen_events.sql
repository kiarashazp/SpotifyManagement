
      create table default_silver.fact_listen_events
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/silver/facts/fact_listen_events'
    
    as
      

with listen_data as (
    select
        ts,
        userId,
        sessionId,
        artist,
        song,
        duration,
        auth,
        level,
        city,
        state,
        zip,
        lat,
        lon,
        itemInSession,
        success
    from parquet.`hdfs://namenode:9000/user/bronze/listen_events`
    where ts is not null and userId is not null
)

select
    md5(concat(cast(ts as string), '|', cast(userId as string), '|', cast(sessionId as string), '|', cast(itemInSession as string))) as listen_id,
    ts as timestamp_ms,
    userId as user_id,
    sessionId as session_id,
    md5(concat(song, '|', artist)) as song_id,
    md5(artist) as artist_id,
    md5(concat(city, '|', state, '|', coalesce(zip, ''))) as location_id,
    itemInSession as item_in_session,
    duration as duration_seconds,
    auth as auth_status,
    level as subscription_level,
    success as success_flag,
    from_unixtime(ts/1000) as listen_timestamp,
    date_format(from_unixtime(ts/1000), 'yyyy-MM-dd') as listen_date,
    current_timestamp() as created_at
from listen_data