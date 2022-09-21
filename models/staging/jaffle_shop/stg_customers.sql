with null_errors as (
    select null as customer_id, 'John' as first_name, 'D.' as last_name
    union all
    select null, 'Jane', 'D.'
)

select
    id as customer_id,
    first_name,
    last_name

from {{ source('jaffle_shop', 'customers') }}

union all

select * 
from null_errors
