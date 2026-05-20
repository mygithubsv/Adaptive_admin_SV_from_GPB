--// SPDX-License-Identifier: Unlicense
do
$$
begin
--анононимная процедура инициирования таблицы	zst_1_table_list данными для последующего развертывания системы версионированния FineDB
truncate table public.zst_1_table_list; --drop table public.zst_1_table_list;
insert into public.zst_1_table_list (in_tablename)
with
t_exc_1 as (
	select 
		distinct table_name
	from information_schema.tables
	where 
		table_catalog = 'finedb'
		and table_schema = 'public'
		and table_type = 'BASE TABLE'
	and (table_name like 'qrtz_%' --исключение малоинформативных таблиц
	  or table_name like 'zst_%' --исключение таблиц хранения версионирования
	  or table_name like '%_va' --исключение пустых таблиц
	  )
),
t_exc_2 as (
	select 
		distinct table_name
	from information_schema.tables
	where table_name in (
		'example' --название таблицы для создания системы версионирования вне патернов таблицы t_exc_1, в том числе не относящиеся к БД FineDB
		)
)
select
  distinct table_name
from information_schema.tables
where table_schema = 'public'
  and (table_name not in ( --исключение таблиц из списка
  'fine_scheduler_instance' 
  ,'fine_component_health'
  ,'updaterec'
    ) and table_name not in (select * from t_exc_1 union select * from t_exc_2))
  or --обязательное включение по патерну таблиц FineDB
  (( table_name like 'finebi_s_%'
    or
    table_name like 'finebi_d_%'
  ) and table_name not in (select * from t_exc_1 union select * from t_exc_2))
order by 1 desc;
end;
$$