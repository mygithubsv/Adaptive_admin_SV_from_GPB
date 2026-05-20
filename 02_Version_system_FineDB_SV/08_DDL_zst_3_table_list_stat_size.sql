--// SPDX-License-Identifier: Unlicense
create table public.zst_3_table_list_stat_size (
	name_t information_schema."sql_identifier" collate "c" null, -- название версионируемой таблицы
	name_hst information_schema."sql_identifier" collate "c" null, -- название таблицы хранения версионируемой таблицы
	size_t text null, -- размер текущий версионируемой таблицы, текст
	size_hst text null, -- размер текущий таблицы хранения версионируемой таблицы, текст
	sizeb_t int8 null, -- размер текущий версионируемой таблицы, байты
	sizeb_hst int8 null, -- размер текущий таблицы хранения версионируемой таблицы, байты
	perc_inc numeric null -- процент увеличения объема таблицы хранения версионируемой таблицы относительно версионной таблицы
);

comment on column public.zst_3_table_list_stat_size.name_t is 'название версионируемой таблицы';
comment on column public.zst_3_table_list_stat_size.name_hst is 'название таблицы хранения версионируемой таблицы';
comment on column public.zst_3_table_list_stat_size.size_t is 'размер текущий версионируемой таблицы, текст';
comment on column public.zst_3_table_list_stat_size.size_hst is 'размер текущий таблицы хранения версионируемой таблицы, текст';
comment on column public.zst_3_table_list_stat_size.sizeb_t is 'размер текущий версионируемой таблицы, байты';
comment on column public.zst_3_table_list_stat_size.sizeb_hst is 'размер текущий таблицы хранения версионируемой таблицы, байты';
comment on column public.zst_3_table_list_stat_size.perc_inc is 'процент увеличения объема таблицы хранения версионируемой таблицы относительно версионной таблицы';