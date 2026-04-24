{% macro latest_staging_model(stg_model_name) %}
    select *
    from {{ ref(stg_model_name) }}
    qualify
        row_number() over (
            partition by id
            order by
                row_is_active desc, row_valid_to desc, row_valid_from desc, _offset desc
        )
        = 1
{% endmacro %}
