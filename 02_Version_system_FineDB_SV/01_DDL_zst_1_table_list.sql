--// SPDX-License-Identifier: Unlicense
create table public.zst_1_table_list (
	id serial4 not null, -- id строки
	add_date timestamp default current_timestamp null, -- дата вставки строки
	login text default current_user null, -- логин пользователя в бд
	hst_date timestamp null, -- дата установки версионирования на таблицу
	check_date timestamp null, -- дата проверки установки версионирования на таблицу
	is_corr bool null, -- признак установки версионирования на таблицу
	check_after_insert bool null, -- признак установки триггера after insert на версионированную таблицу
	check_after_update bool null, -- признак установки триггера after update на версионированную таблицу
	check_after_delete bool null, -- признак установки триггера after delete на версионированную таблицу
	in_tablename text default 'example_table_name'::text null, -- название версионированной таблицы
	drop_hst_table bool default true null, -- флаг принудительного очищения таблицы изменений версионированной таблицы
	after_insert bool default true null, -- флаг установки триггера after insert на версионированную таблицу
	after_update bool default true null, -- флаг установки триггера after update на версионированную таблицу
	after_delete bool default true null, -- флаг установки триггера after delete на версионированную таблицу
	force_drop bool default true null, -- флаг принудительного дропа таблицы
	in_src_schema text default 'public'::text null, -- название схемы версионируемой таблицы
	in_hst_schema text default 'public'::text null, -- название схемы версионной таблицы
	is_all_hst_delete bool default false null, -- флаг удаления версионной таблицы и всех триггеров при запуске функции
	all_hst_delete_date timestamp null, -- дата удаления версионной таблицы и всех триггеров при запуске функции
	constraint hst_table_list_pkey primary key (id)
);
comment on column public.zst_1_table_list.id is 'id строки';
comment on column public.zst_1_table_list.add_date is 'дата вставки строки';
comment on column public.zst_1_table_list.login is 'логин пользователя в бд';
comment on column public.zst_1_table_list.hst_date is 'дата установки версионирования на таблицу';
comment on column public.zst_1_table_list.check_date is 'дата проверки установки версионирования на таблицу';
comment on column public.zst_1_table_list.is_corr is 'признак установки версионирования на таблицу';
comment on column public.zst_1_table_list.check_after_insert is 'признак установки триггера after insert на версионированную таблицу';
comment on column public.zst_1_table_list.check_after_update is 'признак установки триггера after update на версионированную таблицу';
comment on column public.zst_1_table_list.check_after_delete is 'признак установки триггера after delete на версионированную таблицу';
comment on column public.zst_1_table_list.in_tablename is 'название версионированной таблицы';
comment on column public.zst_1_table_list.drop_hst_table is 'флаг принудительного очищения таблицы изменений версионированной таблицы';
comment on column public.zst_1_table_list.after_insert is 'флаг установки триггера after insert на версионированную таблицу';
comment on column public.zst_1_table_list.after_update is 'флаг установки триггера after update на версионированную таблицу';
comment on column public.zst_1_table_list.after_delete is 'флаг установки триггера after delete на версионированную таблицу';
comment on column public.zst_1_table_list.force_drop is 'флаг принудительного дропа таблицы';
comment on column public.zst_1_table_list.in_src_schema is 'название схемы версионируемой таблицы';
comment on column public.zst_1_table_list.in_hst_schema is 'название схемы версионной таблицы';
comment on column public.zst_1_table_list.is_all_hst_delete is 'флаг удаления версионной таблицы и всех триггеров при запуске функции';
comment on column public.zst_1_table_list.all_hst_delete_date is 'дата удаления версионной таблицы и всех триггеров при запуске функции';