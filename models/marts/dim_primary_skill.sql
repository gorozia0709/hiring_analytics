select
    _offset,
    id,
    is_active,
    type,
    name,
    url,
    parent_id,
    row_valid_from as valid_from_datetime,
    row_valid_to as valid_to_datetime
from {{ ref('stg_skills') }}
where is_primary = true
