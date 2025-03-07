

with status_change_data as (
    select
        ts,
        userId,
        sessionId,
        page,
        level,
        city,
        state,
        zip,
        lat,
        lon,
        itemInSession,
        status,
        success
    from parquet.`hdfs://namenode:9000/user/bronze/status_change_events`
    where ts is not null and userId is not null
)

select
    md5(concat(cast(ts as string), '|', cast(userId as string), '|', cast(sessionId as string), '|', cast(itemInSession as string))) as status_change_id,
    ts as timestamp_ms,
    userId as user_id,
    sessionId as session_id,
    md5(concat(city, '|', state, '|', coalesce(zip, ''))) as location_id,
    page as change_page,
    level as subscription_level,
    status as status_code,
    itemInSession as item_in_session,
    success as success_flag,
    from_unixtime(ts/1000) as status_change_timestamp,
    date_format(from_unixtime(ts/1000), 'yyyy-MM-dd') as status_change_date,
    current_timestamp() as created_at
from status_change_data