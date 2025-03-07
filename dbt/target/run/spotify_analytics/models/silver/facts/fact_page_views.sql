
      create table default_silver.fact_page_views
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/silver/facts/fact_page_views'
    
    as
      

with page_view_data as (
    select
        ts,
        userId,
        sessionId,
        page,
        method,
        status,
        auth,
        level,
        city,
        state,
        zip,
        lat,
        lon,
        itemInSession,
        success
    from parquet.`hdfs://namenode:9000/user/bronze/page_view_events`
    where ts is not null and userId is not null
)

select
    md5(concat(cast(ts as string), '|', cast(userId as string), '|', cast(sessionId as string), '|', cast(itemInSession as string))) as page_view_id,
    ts as timestamp_ms,
    userId as user_id,
    sessionId as session_id,
    md5(concat(city, '|', state, '|', coalesce(zip, ''))) as location_id,
    page,
    method,
    status as http_status,
    auth as auth_status,
    level as subscription_level,
    itemInSession as item_in_session,
    success as success_flag,
    from_unixtime(ts/1000) as page_view_timestamp,
    date_format(from_unixtime(ts/1000), 'yyyy-MM-dd') as page_view_date,
    current_timestamp() as created_at
from page_view_data