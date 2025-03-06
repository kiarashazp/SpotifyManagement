{{
    config(
        materialized='table',
        location_root=var('silver_path') + '/dimensions',
        file_format='parquet'
    )
}}

with song_data as (
    select
        song,
        artist,
        duration,
        row_number() over (
            partition by song, artist
            order by ts desc
        ) as row_num
    from parquet.`hdfs://namenode:9000/user/bronze/listen_events`
    where song is not null and artist is not null
)

select
    md5(concat(song, '|', artist)) as song_id,
    song as song_name,
    artist as artist_name,
    duration as duration_seconds,
    current_timestamp() as created_at
from song_data
where row_num = 1
