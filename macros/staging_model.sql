{% macro staging_model(raw_table_name, source_name='hiring_analytics') %}

    {% if execute %}
        {% set query %}
        select
            target_column_name,
            transform_expr
        from {{ ref('stg_columns_config') }}
        where lower(raw_table_name) = lower('{{ raw_table_name }}')
        order by target_order_num
        {% endset %}

        {% set results = run_query(query) %}
        {% set rows = results.rows %}
        {% set expressions = [] %}

        {% for row in rows %}
            {% set target_column_name = row[0] %}
            {% set transform_expr = row[1] %}
            {% do expressions.append(transform_expr ~ ' as ' ~ target_column_name) %}
        {% endfor %}
    {% endif %}

    with
        source_data as (select * from {{ source(source_name, raw_table_name) }}),

        renamed as (

            select
                {% if execute %} {{ expressions | join(',\n        ') }}
                {% else %} *
                {% endif %}
            from source_data

        ),

        final as (

            select
                *,
                updated_at as row_valid_from,
                lead(updated_at) over (
                    partition by id order by updated_at, _offset
                ) as row_valid_to,
                case
                    when
                        row_number() over (
                            partition by id
                            order by updated_at desc, created_at desc, _offset desc
                        )
                        = 1
                    then 1
                    else 0
                end as row_is_active
            from renamed

        )

    select *
    from final

{% endmacro %}
