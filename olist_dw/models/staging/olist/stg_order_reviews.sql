-- File:        stg_order_reviews.sql
-- Description: Staging view for raw.order_reviews
--
-- Created at:  2026-10-06
-- Created by:  claude
-- Updated at:  2026-10-06
-- Updated by:  claude

with source as (
    select * from {{ source('olist_raw', 'order_reviews') }}
),
renamed as (
    select
        review_id,
        order_id,
        review_score::int                               as review_score,
        review_comment_title                            as comment_title,
        review_comment_message                          as comment_message,
        nullif(review_creation_date, '')::timestamp     as created_at,
        nullif(review_answer_timestamp, '')::timestamp  as answered_at
    from source
)
select * from renamed
