-- depends_on: {{ ref('stg_columns_config') }}
{{ staging_model('employees') }}
