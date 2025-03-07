
      create table default_gold.report_top_songs
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/gold/report_top_songs'
    
    as
      

select
    s.song_id,
    s.song_name,
    s.artist_name,
    count(*) as play_count,
    count(distinct f.user_id) as unique_listeners,
    avg(f.duration_seconds) as avg_play_duration
from default_silver.fact_listen_events f
join default_silver.dim_songs s on f.song_id = s.song_id
group by s.song_id, s.song_name, s.artist_name
order by play_count desc