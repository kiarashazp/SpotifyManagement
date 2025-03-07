

with subscription_changes as (
    select
        f.user_id,
        f.status_change_timestamp,
        lag(f.subscription_level) over (
            partition by f.user_id
            order by f.status_change_timestamp
        ) as previous_level,
        f.subscription_level as current_level
    from default_silver.fact_status_changes f
    where f.change_page = 'Submit Upgrade'
    order by f.user_id, f.status_change_timestamp
),

conversions as (
    select
        user_id,
        status_change_timestamp as conversion_timestamp,
        previous_level,
        current_level
    from subscription_changes
    where previous_level = 'free' and current_level = 'paid'
),

conversion_stats_by_date as (
    select
        date_format(conversion_timestamp, 'yyyy-MM-dd') as conversion_date,
        count(*) as conversions
    from conversions
    group by date_format(conversion_timestamp, 'yyyy-MM-dd')
),

active_free_users_by_date as (
    select
        listen_date,
        count(distinct user_id) as free_users
    from default_silver.fact_listen_events
    where subscription_level = 'free'
    group by listen_date
)

select
    a.listen_date as date,
    a.free_users,
    coalesce(c.conversions, 0) as conversions,
    coalesce(c.conversions, 0) / a.free_users as daily_conversion_rate
from active_free_users_by_date a
left join conversion_stats_by_date c on a.listen_date = c.conversion_date
order by a.listen_date