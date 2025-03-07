

select
    user_id,
    listen_date,
    count(*) as song_count
from default_silver.fact_listen_events
group by user_id, listen_date
order by listen_date, user_id