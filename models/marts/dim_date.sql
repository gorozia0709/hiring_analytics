with
    date_spine as (

        select dateadd(day, seq4(), to_date('2000-01-01')) as date
        from table(generator(rowcount => 10000))

    ),

    filtered as (select date from date_spine where date <= to_date('2026-12-31'))

select
    date,
    year(date) as year,
    quarter(date) as quarter,
    month(date) as month,
    day(date) as day,
    weekofyear(date) as week,
    dayofweekiso(date) as day_of_week,
    dayname(date) as day_name,
    monthname(date) as month_name,
    case when dayofweekiso(date) in (6, 7) then true else false end as is_weekend,
    false as is_holiday
from filtered
order by date
