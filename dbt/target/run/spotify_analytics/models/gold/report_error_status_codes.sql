
      create table default_gold.report_error_status_codes
    
    
    using parquet
    
    
    
    
    location 'hdfs://namenode:9000/user/gold/report_error_status_codes'
    
    as
      

with error_events as (
    select
        http_status as status_code,
        case
            when http_status between 200 and 299 then 'Success'
            when http_status between 300 and 399 then 'Redirection'
            when http_status between 400 and 499 then 'Client Error'
            when http_status between 500 and 599 then 'Server Error'
            else 'Unknown'
        end as status_category,
        page,
        page_view_timestamp,
        date_format(page_view_timestamp, 'yyyy-MM-dd') as event_date,
        user_id,
        session_id
    from default_silver.fact_page_views
    where http_status is not null
)

select
    status_code,
    status_category,
    page,
    event_date,
    count(*) as error_count,
    count(distinct user_id) as affected_users,
    count(distinct session_id) as affected_sessions
from error_events
group by status_code, status_category, page, event_date
order by event_date, error_count desc