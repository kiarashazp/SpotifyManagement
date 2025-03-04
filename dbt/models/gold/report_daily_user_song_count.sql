{{
    config(
        materialized='table',
        location_root=var('gold_path'),
        file_format='parquet'
    )
}}

select
    user_id,
    listen_date,
    count(*) as song_count
from {{ ref('fact_listen_events') }}
group by user_id, listen_date
order by listen_date, user_id