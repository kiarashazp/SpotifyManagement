
      create table default_silver.dim_users
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/silver/dimensions/dim_users'
    
    as
      

with user_data as (
    select
        userId,
        firstName,
        lastName,
        gender,
        level,
        registration,
        city,
        state,
        zip,
        lat,
        lon,
        row_number() over (
            partition by userId
            order by ts desc
        ) as row_num
    from parquet.`hdfs://namenode:9000/user/bronze/listen_events`
    where userId is not null
),

latest_user_data as (
    select
        userId,
        firstName,
        lastName,
        gender,
        level,
        registration,
        city,
        state,
        zip,
        lat,
        lon
    from user_data
    where row_num = 1
)

select
    userId as user_id,
    firstName as first_name,
    lastName as last_name,
    gender,
    level as subscription_level,
    from_unixtime(registration/1000) as registration_timestamp,
    date_format(from_unixtime(registration/1000), 'yyyy-MM-dd') as registration_date,
    city,
    state,
    zip as zip_code,
    lat as latitude,
    lon as longitude,
    current_timestamp() as updated_at
from latest_user_data