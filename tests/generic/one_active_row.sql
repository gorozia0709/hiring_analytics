{% test one_active_row(model, key_column, active_column) %}

    select {{ key_column }}
    from {{ model }}
    group by {{ key_column }}
    having sum(case when {{ active_column }} = 1 then 1 else 0 end) <> 1

{% endtest %}
