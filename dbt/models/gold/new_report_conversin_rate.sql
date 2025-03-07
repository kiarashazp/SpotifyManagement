{{
    config(
        materialized='table',
        alias='conversion_rate_free_to_paid'
    )
}}

WITH user_subscription_changes AS (
    SELECT
        user_id,
        subscription_level,
        LAG(subscription_level) OVER (PARTITION BY user_id ORDER BY updated_at) AS previous_subscription_level,
        updated_at
    FROM {{ ref('dim_users') }}
),

conversion_events AS (
    SELECT
        user_id,
        updated_at AS conversion_date
    FROM user_subscription_changes
    WHERE
        previous_subscription_level = 'free'
        AND subscription_level = 'paid'
)


SELECT
    DATE(conversion_date) AS conversion_day,
    COUNT(user_id) AS conversions_count,
    COUNT(user_id) * 1.0 / (
        SELECT COUNT(DISTINCT user_id)
        FROM {{ ref('dim_users') }}
        WHERE subscription_level = 'free'
            AND DATE(updated_at) <= conversion_day
    ) AS conversion_rate
FROM conversion_events
GROUP BY conversion_day
ORDER BY conversion_day;