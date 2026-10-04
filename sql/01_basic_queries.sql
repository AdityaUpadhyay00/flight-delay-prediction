CREATE TABLE flights (
    YEAR INT,
    MONTH INT,
    DAY INT,
    DAY_OF_WEEK INT,
    AIRLINE VARCHAR(10),
    FLIGHT_NUMBER INT,
    TAIL_NUMBER VARCHAR(20),
    ORIGIN_AIRPORT VARCHAR(10),
    DESTINATION_AIRPORT VARCHAR(10),
    SCHEDULED_DEPARTURE INT,
    DEPARTURE_TIME INT,
    DEPARTURE_DELAY NUMERIC,
    TAXI_OUT NUMERIC,
    WHEELS_OFF INT,
    SCHEDULED_TIME NUMERIC,
    ELAPSED_TIME NUMERIC,
    AIR_TIME NUMERIC,
    DISTANCE INT,
    WHEELS_ON INT,
    TAXI_IN NUMERIC,
    SCHEDULED_ARRIVAL INT,
    ARRIVAL_TIME INT,
    ARRIVAL_DELAY NUMERIC,
    DIVERTED INT,
    CANCELLED INT,
    CANCELLATION_REASON VARCHAR(5),
    AIR_SYSTEM_DELAY NUMERIC,
    SECURITY_DELAY NUMERIC,
    AIRLINE_DELAY NUMERIC,
    LATE_AIRCRAFT_DELAY NUMERIC,
    WEATHER_DELAY NUMERIC
);
SELECT *
FROM flights
LIMIT 10 

-- What we're building now
-- The SQL section will answer operational questions such as:


--1 
--Which airlines operate the most flights?
SELECT 
airline ,
count(*) as total_count
FROM flights 
group by airline
order by total_count desc;

--2
--What is the delay rate for each airline?
--delay rate = delayed flights /total flights
SELECT 
airline,
count(*) as total_count,
count(*) FILTER ( where arrival_delay >= 15 ) as delayed_flights,
round(count(*) filter (where arrival_delay>=15) * 100.0 / count(*),2) as delay_Rate
from flights
where arrival_delay is not null
group by AIRLINE;

--3
--Which origin airports have high delay rates?
SELECT 
origin_airport,
count(*) as total_flights,
count(*) FILTER ( where arrival_delay >= 15 ) as delayed_flights,
round(count(*) filter (where arrival_delay>=15) * 100.0 / count(*),2) as delay_Rate
from flights
where arrival_delay is not null
group by origin_airport
having count(*) >=500
order by delay_Rate desc;

--4
--Which destination airports have high delay rates?
SELECT 
destination_airport,
count(*) as total_flights,
count(*) FILTER ( where arrival_delay >= 15 ) as delayed_flights,
round(count(*) filter (where arrival_delay>=15) * 100.0 / count(*),2) as delay_Rate
from flights
where arrival_delay is not null
group by destination_airport
having count(*) >=500
order by delay_Rate desc;


--5
--Which routes have high delay rates?
select
origin_airport,
destination_airport,
count(*) as total_flights,
 count(*) filter(where arrival_delay >=15) as delayed_flights,
round(
    count(*) filter(where arrival_delay >=15) *100.0 / count(*), 
    2) as delay_rate
from flights
where arrival_delay is not null
group by origin_airport,destination_airport
having count(*) >=500
order by delay_rate desc
limit 10;

--6
--Does the delay rate change significantly across months?
select 
month,
count(*) as total_flights ,
count(*) filter(where arrival_delay >= 15) as delayed_flights,
round(
    count(*) filter(where arrival_delay >=15) * 100.0 / count(*),
    2) as delay_rate
from flights
where arrival_delay is not null
group by month
order by month;

--7
--Which days have higher delay rates?

select 
day_of_week,
count(*) as total_flights ,
count(*) filter(where arrival_delay >= 15) as delayed_flights,
round(
    count(*) filter(where arrival_delay >=15) * 100.0 / count(*),
    2) as delay_rate
from flights
where arrival_delay is not null
group by day_of_week
order by day_of_week;

--8
--How many flights were cancelled, and what percentage of all flights does that represent?


with average as (
select 
day_of_week,
count(*) as total_flights ,
count(*) filter(where arrival_delay >= 15) as delayed_flights,
round(
    count(*) filter(where arrival_delay >=15) * 100.0 / count(*),
    2) as delay_rate
from flights
where arrival_delay is not null
group by day_of_week
order by day_of_week
)

select *
avg(delay_rate) as avg 
from average

--9
--Which airlines have the highest percentage of their scheduled flights cancelled?

select airline,
count(*) as total_flights,
count(*) Filter(where cancelled = 1) as cancelled_flights,
round(count(*) Filter(where cancelled = 1) * 100.0 / count(*),2) as cancellation_rate
from flights
group by AIRLINE
order by cancellation_rate desc

--10
What are the reasons for those cancellations?
with cancel as (
select cancellation_reason,
count(*) as cancelled_flights

from flights
where cancelled = 1
group by cancellation_reason
order by cancelled_flights desc
)

SELECT *,
       ROUND(
           cancelled_flights * 100.0
           / SUM(cancelled_flights) OVER (),
           2
       ) AS cancellation_percentage
FROM cancel;

-11
--
--Which factors contribute the most total delay time?
with delay_min as (

SELECT 
    'Air System' AS delay_cause,
    SUM(air_system_delay) AS total_delay_minutes
FROM flights

UNION ALL

SELECT
    'Security' AS delay_cause,
    SUM(security_delay) AS total_delay_minutes
FROM flights

UNION ALL

SELECT
    'Airline' AS delay_cause,
    SUM(airline_delay) AS total_delay_minutes
FROM flights

UNION ALL

SELECT
    'Late Aircraft' AS delay_cause,
    SUM(late_aircraft_delay) AS total_delay_minutes
FROM flights

UNION ALL

SELECT
    'Weather' AS delay_cause,
    SUM(weather_delay) AS total_delay_minutes
FROM flights
)

select 
 delay_cause,
total_delay_minutes,
round(total_delay_minutes * 100 / (select sum(total_delay_minutes ) from delay_min),2) as delay_pecentage




from 
delay_min

--12
--When a flight leaves late, how does that affect its arrival delay?
SELECT
    ROUND(AVG(departure_delay), 2) AS average_departure_delay,
    ROUND(AVG(arrival_delay), 2) AS average_arrival_delay
FROM flights
WHERE departure_delay IS NOT NULL
  AND arrival_delay IS NOT NULL;