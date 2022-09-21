/*
Customization of dbt builtin test 'not_null'.
Code of original 'not_null' test in dbt repository https://github.com/dbt-labs/dbt-core/blob/main/core/dbt/include/global_project/macros/generic_test_sql/not_null.sql
Additional parametrs.
key_columns:    Argument for providing a list of model's columns which should be used with dbt_utils.surrogate_key macro to generate an 'error_key' - an id of error in 
                test results. Default is empty list - in this case test will use values from all of the columns of tested model to generate a key for 
                error (expensive full table scan). Argument can be provided in .yml file where 'not_null' test is declared.
where:          Argument for providing additional filtering conditions in WHERE clause. Argument can be passed from .yml file where 'not_null' test is declared.
*/

{% macro default__test_not_null(model, column_name, key_columns=[], where="1=1") %}

{#- Prepare variables -#}

{#- Lower case for all input parameters and tested model field names -#}

{%- set column_name = column_name.lower() -%}
{%- set key_columns_lower = [] -%}
{%- for key_col in key_columns -%}
    {%- do key_columns_lower.append(key_col.lower()) -%}
{%- endfor -%}

{#- Columns to generate error id: use key_columns list or all columns of the model -#}
{%- set model_columns = adapter.get_columns_in_relation(model) -%}
{%- set selected_columns = [] -%}
{%- if key_columns_lower|length != 0 -%}
    {%- for column in model_columns if column['name'].lower() in key_columns_lower -%}
        {%- do selected_columns.append(column['name'].lower()) -%}
    {%- endfor -%}
{%- else -%}
    {%- for column in model_columns if column['name'].lower() != column_name -%}
        {%- do selected_columns.append(column['name'].lower()) -%}
    {%- endfor -%}
{%- endif -%}

{#- Use identifier of the table for storing error results as a 'test_name' -#}
{%- if execute %}
    {% set store_failures_table = this.identifier  %}
{%- else %}
    {% set store_failures_table = "" %}
{%- endif %}

SELECT 
        {{ dbt_utils.surrogate_key(selected_columns) }} AS error_key,
        {{ column_name }},
        {%- for selected_column in selected_columns %}
        {{ selected_column }}{% if not loop.last %},{%- endif -%}
        {% endfor %}
FROM    {{ model }}
WHERE   {{ column_name }} IS NULL
        AND {{ dbt_utils.surrogate_key(selected_columns) }} NOT IN (
                SELECT error_key FROM {{ ref('dbt_testignore') }}
                WHERE test_name in ('{{ store_failures_table }}')
                )
        AND {{ where }}

{% endmacro %}
