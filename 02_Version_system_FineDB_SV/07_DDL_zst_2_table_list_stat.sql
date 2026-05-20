--// SPDX-License-Identifier: Unlicense
create table public.zst_2_table_list_stat (
	schema_name text null, -- схема версионируемой таблицы
	table_name text null, -- название версионируемой таблицы
	min_day date null, -- первая дата в таблице для версионируемой таблицы
	max_day date null, -- последняя дата в таблице для версионируемой таблицы
	cnt_days int8 null, -- число дней в таблице для версионируемой таблицы
	delta_days int4 null, -- разница между последним и первым днём в таблице для версионируемой таблицы
	cnt_rec_all int8 null, -- всего записей в версионируемой таблице
	cnt_rec_init int8 null, -- число записей в версионируемой таблице при инициализации (первый insert состояния)
	cnt_rec_insert int8 null, -- число записей вставки в версионируемой таблице при инициализации
	cnt_rec_update int8 null, -- число записей обновления в версионируемой таблице при инициализации
	cnt_rec_delete int8 null -- число записей удаления в версионируемой таблице при инициализации
);

comment on column public.zst_2_table_list_stat.schema_name is 'схема версионируемой таблицы';
comment on column public.zst_2_table_list_stat.table_name is 'название версионируемой таблицы';
comment on column public.zst_2_table_list_stat.min_day is 'первая дата в таблице для версионируемой таблицы';
comment on column public.zst_2_table_list_stat.max_day is 'последняя дата в таблице для версионируемой таблицы';
comment on column public.zst_2_table_list_stat.cnt_days is 'число дней в таблице для версионируемой таблицы';
comment on column public.zst_2_table_list_stat.delta_days is 'разница между последним и первым днём в таблице для версионируемой таблицы';
comment on column public.zst_2_table_list_stat.cnt_rec_all is 'всего записей в версионируемой таблице';
comment on column public.zst_2_table_list_stat.cnt_rec_init is 'число записей в версионируемой таблице при инициализации (первый insert состояния)';
comment on column public.zst_2_table_list_stat.cnt_rec_insert is 'число записей вставки в версионируемой таблице при инициализации';
comment on column public.zst_2_table_list_stat.cnt_rec_update is 'число записей обновления в версионируемой таблице при инициализации';
comment on column public.zst_2_table_list_stat.cnt_rec_delete is 'число записей удаления в версионируемой таблице при инициализации';