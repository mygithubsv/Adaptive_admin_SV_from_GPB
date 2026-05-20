--// SPDX-License-Identifier: Unlicense
create or replace function public.zst_7_auto_check_table_trigger()
 returns boolean
 language plpgsql
as $function$
--функция автоматической проверки наличия триггеров и функций для системы версионирования на основе списка таблиц zst_1_table_list
declare
	is_success bool;
	tr_state text;
	sql_text text;
	table_record record;
	table_cursor cursor for
			select * from public.zst_1_table_list;
begin
    -- open cursor
    open table_cursor;
    -- fetch rows and return
    loop
        fetch next from table_cursor into table_record;
        exit when not found;
        raise info '#-#-#-#-#-#-#-#-#-#-#-#-#';
        raise info '#1 check table: %', table_record.in_tablename;
				--проверка существования триггеров и функций
				execute
       	'with
					t_table as (
					select '''||table_record.in_tablename||''' as tab
					),
					t_pre as (
					select 
					max(case when trigger_name = ''zst_''||t.tab||''_insert_trigger'' then 1 else 0 end) as has_insert_trigger
					,max(case when trigger_name = ''zst_''||t.tab||''_update_trigger'' then 1 else 0 end) as has_update_trigger
					,max(case when trigger_name = ''zst_''||t.tab||''_delete_trigger'' then 1 else 0 end) as has_delete_trigger
					,min(case when length(to_regproc(''zst_func_''||t.tab||''_trg_ai'')::text)>0 then 1 else 0 end) as has_insert_trigger_func
					,min(case when length(to_regproc(''zst_func_''||t.tab||''_trg_au'')::text)>0 then 1 else 0 end) as has_update_trigger_func
					,min(case when length(to_regproc(''zst_func_''||t.tab||''_trg_ad'')::text)>0 then 1 else 0 end) as has_delete_trigger_func
					from t_table t
					left join information_schema.triggers tr on tr.event_object_table = t.tab
					left join pg_proc p on tr.event_object_table = t.tab
					)
					select 
						(
						has_insert_trigger||''|''||
						has_update_trigger||''|''||
						has_delete_trigger||''|''||
						has_insert_trigger_func||''|''||
						has_update_trigger_func||''|''||
						has_delete_trigger_func 
						)::text as tr_state
					from t_pre;' 
				into tr_state;
        --# table_record.title;
        raise info '#2 update hst_table_list';
          select '
            update public.zst_1_table_list
            set 
							 check_after_insert = least(split_part('''||tr_state||''',''|'',1),split_part('''||tr_state||''',''|'',4))::bool
							,check_after_update = least(split_part('''||tr_state||''',''|'',2),split_part('''||tr_state||''',''|'',5))::bool
							,check_after_delete = least(split_part('''||tr_state||''',''|'',3),split_part('''||tr_state||''',''|'',6))::bool
							,check_date = current_timestamp
            where id = '||table_record.id||';'
           into sql_text;
           execute sql_text;
    end loop;
    -- close cursor
    close table_cursor; 
    --
    return true;
end;
$function$
;