{{
    config(
        materialized='table',
        location_root=var('gold_path'),
        file_format='parquet'
    )
}}

select
    s.song_id,
    s.song_name,
    s.artist_name,
    count(*) as play_count,
    count(distinct f.user_id) as unique_listeners,
    avg(f.duration_seconds) as avg_play_duration
from {{ ref('fact_listen_events') }} f
join {{ ref('dim_songs') }} s on f.song_id = s.song_id
group by s.song_id, s.song_name, s.artist_name
order by play_count desc