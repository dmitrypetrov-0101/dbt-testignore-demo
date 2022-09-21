with test_payment as (
    select  
        -999,
        -999,
        'crypto',
        'dummy_status',
        -999,
        date_add(current_date(), INTERVAL -5 DAY)
)

select
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status as payment_status,
    -- amount is stored in cents, convert it to dollars
    amount / 100 as amount,
    created as created_at

from {{ source('stripe', 'payment') }}

union all 

select *
from test_payment
