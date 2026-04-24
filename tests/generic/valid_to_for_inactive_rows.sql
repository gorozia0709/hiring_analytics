{% test valid_to_for_inactive_rows(model) %}

    select * from {{ model }} where row_is_active = 0 and row_valid_to is null

{% endtest %}
