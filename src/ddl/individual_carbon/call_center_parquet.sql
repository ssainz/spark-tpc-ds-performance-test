drop table if exists call_center;
create table call_center 
using parquet
as (select * from call_center_text)
;
drop table if exists call_center_text;
