select
    _offset,
    id,
    primary_skill_id,
    staffing_status,
    english_level,
    job_function_id,
    row_valid_from as valid_from_datetime,
    row_valid_to as valid_to_datetime
from {{ ref('stg_candidates') }}
