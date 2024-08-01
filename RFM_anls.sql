select *
from bonuscheques b 
limit 100;

select count(*)
from bonuscheques b; 

delete from bonuscheques 
where card not like '200%';


drop table if exists group_card;
create table group_card
as
select card, sum(summ) as itog_clients, count(*) as count_buy, max(datetime) as last_buy, 
	(select max(datetime)  from bonuscheques b) - max(datetime) as count_day_after_last_day
from bonuscheques b 
group by card 
order by count_buy desc;


drop table if exists rfm_anls;
create table rfm_anls as
select *,
	case when (extract(day from count_day_after_last_day))::int <= 30 then '1'
		when (extract(day from count_day_after_last_day))::int between 31 and 90 then '2'
		else '3'
	end as recency,
	case when count_buy >= 6 then '1'
		when count_buy between 2 and 5 then '2'
		else '3'
	end as frequency,
	case when itog_clients >= 4082 then '1'
		when itog_clients between  1485 and 4081 then '2'
		else '3'
	end as monetary
from group_card gc;

create table segment as
select card, recency || frequency || monetary as segment
from rfm_anls ra; 

select *
from segment

