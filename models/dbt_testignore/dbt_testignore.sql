{{ 
        config(
            schema='dbt_testignore', 
            materialized='table'
            ) 
}}

select
    error_key,
    test_name,
    ignore_reason
from {{ ref('dbt_testignore_seed') }}
