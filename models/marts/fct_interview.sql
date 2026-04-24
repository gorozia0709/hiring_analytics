with
    interview_history as (select * from {{ ref('stg_interviews') }}),

    created_interview as (

        select *
        from interview_history
        qualify
            row_number() over (partition by id order by row_valid_from asc, _offset asc)
            = 1

    ),

    latest_interview as (select * from {{ ref('stg_latest_interviews') }}),

    status_timestamps as (

        select
            id,
            min(
                case when status = 'requested' then row_valid_from end
            ) as requested_datetime,
            min(
                case when status = 'scheduled' then row_valid_from end
            ) as scheduled_datetime,
            min(
                case when status = 'in_progress' then row_valid_from end
            ) as started_datetime,
            min(
                case when status = 'pending_feedback' then row_valid_from end
            ) as finished_datetime,
            min(
                case when status = 'completed' then row_valid_from end
            ) as feedback_provided_datetime,
            min(
                case when status = 'cancelled' then row_valid_from end
            ) as cancelled_datetime
        from interview_history
        group by id

    ),

    candidate as (

        select interview_id, candidate_offset
        from
            (
                select
                    ci.id as interview_id,
                    c._offset as candidate_offset,
                    row_number() over (
                        partition by ci.id
                        order by c.valid_from_datetime desc, c._offset desc
                    ) as rn
                from created_interview ci
                left join
                    {{ ref('dim_candidate') }} c
                    on ci.candidate_id = c.id
                    and ci.row_valid_from >= c.valid_from_datetime
                    and ci.row_valid_from < c.valid_to_datetime
            )
        where rn = 1

    ),

    employee as (

        select interview_id, interviewer_offset
        from
            (
                select
                    ci.id as interview_id,
                    e._offset as interviewer_offset,
                    row_number() over (
                        partition by ci.id
                        order by e.valid_from_datetime desc, e._offset desc
                    ) as rn
                from created_interview ci
                left join
                    {{ ref('dim_employee') }} e
                    on ci.interviewer_id = e.id
                    and ci.row_valid_from >= e.valid_from_datetime
                    and ci.row_valid_from < e.valid_to_datetime
            )
        where rn = 1

    )

select
    li.id,
    li.candidate_type,
    ca.candidate_offset,
    li.status,
    ea.interviewer_offset,
    li.location,
    li.is_logged,
    li.is_media_available,
    li.run_type,
    li.type,
    li.media_status,
    li.invite_answer_status,
    d.date as created_date,
    ci.row_valid_from as created_datetime,
    st.requested_datetime,
    st.scheduled_datetime,
    st.started_datetime,
    st.finished_datetime,
    st.feedback_provided_datetime,
    st.cancelled_datetime,

    case
        when st.started_datetime is not null and st.finished_datetime is not null
        then datediff(minute, st.started_datetime, st.finished_datetime)
    end as interview_duration,

    case
        when
            st.finished_datetime is not null
            and st.feedback_provided_datetime is not null
        then datediff(minute, st.finished_datetime, st.feedback_provided_datetime)
    end as feedback_delay

from latest_interview li
left join created_interview ci on li.id = ci.id
left join status_timestamps st on li.id = st.id
left join candidate ca on li.id = ca.interview_id
left join employee ea on li.id = ea.interview_id
left join {{ ref('dim_date') }} d on cast(ci.row_valid_from as date) = d.date
