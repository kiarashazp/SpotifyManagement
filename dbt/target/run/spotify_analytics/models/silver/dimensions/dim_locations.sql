
      create table default_silver.dim_locations
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/silver/dimensions/dim_locations'
    
    as
      

with location_data as (
    select
        distinct 
        city,
        state,
        zip,
        lat,
        lon
    from parquet.`hdfs://namenode:9000/user/bronze/listen_events`
    where city is not null and state is not null
)

select
    md5(concat(city, '|', state, '|', coalesce(zip, ''))) as location_id,
    city,
    state,
    zip,
    lat as latitude,
    lon as longitude,
    current_timestamp() as created_at
from location_data