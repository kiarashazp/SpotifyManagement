

with timestamp_data as (
    select distinct ts
    from parquet.`hdfs://namenode:9000/user/bronze/listen_events`
    where ts is not null
    
    union distinct
    
    select distinct ts
    from parquet.`hdfs://namenode:9000/user/bronze/page_view_events`
    where ts is not null
    
    union distinct
    
    select distinct ts
    from parquet.`hdfs://namenode:9000/user/bronze/auth_events`
    where ts is not null
    
    union distinct
    
    select distinct ts
    from parquet.`hdfs://namenode:9000/user/bronze/status_change_events`
    where ts is not null
)

select
    ts as timestamp_ms,
    from_unixtime(ts/1000) as timestamp,
    date_format(from_unixtime(ts/1000), 'yyyy-MM-dd') as date,
    year(from_unixtime(ts/1000)) as year,
    month(from_unixtime(ts/1000)) as month,
    day(from_unixtime(ts/1000)) as day,
    hour(from_unixtime(ts/1000)) as hour,
    minute(from_unixtime(ts/1000)) as minute,
    second(from_unixtime(ts/1000)) as second,
    date_format(from_unixtime(ts/1000), 'EEEE') as day_of_week,
    dayofweek(from_unixtime(ts/1000)) as day_of_week_number,
    weekofyear(from_unixtime(ts/1000)) as week_of_year,
    date_format(from_unixtime(ts/1000), 'MMMM') as month_name,
    date_format(from_unixtime(ts/1000), 'Q') as quarter,
    case
        when hour(from_unixtime(ts/1000)) between 6 and 11 then 'Morning'
        when hour(from_unixtime(ts/1000)) between 12 and 17 then 'Afternoon'
        when hour(from_unixtime(ts/1000)) between 18 and 23 then 'Evening'
        else 'Night'
    end as time_of_day
from timestamp_data