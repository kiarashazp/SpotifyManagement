{{
    config(materialized='table')
}}

-- users_first_week
users_first_week as (
    select user_id, registration_timestamp, registration_date
    from {{ ref('dim_users') }}
    where date_diff('day', date(registration_timestamp), current_date) <= 7;
),

new_users as (
    select * from users_first_week
),

-- user_retention_analysis
activities as (
    select
        user_id, date(from_unixtime(ts/1000)) as activity_date
    from {{ ref('fact_listen_events') }}
    where user_id in (select user_id from new_users)

    union all

    select
        user_id, date(from_unixtime(ts/1000)) as activity_date
    from {{ ref('fact_page_views') }}
    where user_id in (select user_id from new_users)

    union all

    select user_id, date(from_unixtime(ts/1000)) as activity_date
    from {{ ref('fact_auth_events') }}
    where user_id in (select user_id from new_users)
),

user_retention_analysis as(
select
    new_users.user_id,
    new_users.registration_date,
    count(distinct activities.activity_date) as active_days,
    round(count(distinct activities.activity_date) / 7.0, 2) as retention_rate
from new_users
left join activities
    on new_users.user_id = activities.user_id
    and activities.activity_date between new_users.registration_date and new_users.registration_date + interval '7' day
group by 1, 2;
)

-- avg_music_consumption
listen_events as (
    select user_id, duration_seconds
    from {{ ref('fact_listen_events') }}
    where user_id in (select user_id from new_users)
        and date(listen_timestamp) between
            (select min(registration_date) from new_users)
            and (select max(registration_date) from new_users) + interval '7' day
)

avg_music_consumption as(
    select
        user_id,
        avg(duration_seconds) as avg_duration_seconds,
        sum(duration_seconds) as total_duration_seconds
    from listen_events
    group by 1;

)

-- final_user_behavior_report
select
    r.user_id,
    r.retention_rate,
    m.avg_duration_seconds,
    m.total_duration_seconds
from user_retention_analysis r left join avg_music_consumption m
    on r.user_id = m.user_id;

