{{
    config(
        materialized='table',
        location_root=var('silver_path') + '/dimensions',
        file_format='parquet'
    )
}}

with artist_data as (
    select
        distinct artist as artist_name
    from parquet.`hdfs://namenode:9000/user/bronze/listen_events`
    where artist is not null
)

select
    md5(artist_name) as artist_id,
    artist_name,
    current_timestamp() as created_at
from artist_data
