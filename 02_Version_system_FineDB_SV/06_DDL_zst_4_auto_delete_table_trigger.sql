--// SPDX-License-Identifier: Unlicense
create or replace function public.zst_4_auto_delete_table_trigger()
 returns boolean
 language plpgsql
as $function$
--функция автоматического удаления системы версионирование на основе таблицы zst_1_table_list через вызов функции zst_2_delete_table_trigger для каждой строки по условию "is_all_hst_delete = true and all_hst_delete_date is null";
declare
is_success bool;
table_record record;
res bool default false;
sql_text text default '';
table_cursor cursor for
    select *
    from public.zst_1_table_list
    where is_all_hst_delete = true
      and all_hst_delete_date is null;
begin
    -- open cursor
    raise info '#-#-#-#-#-#-#-#-#-#-#-#-#';
    raise info '#1 zst_2_delete_table_trigger';
    open table_cursor;
    -- fetch rows and return
    loop
        fetch next from table_cursor into table_record;
        if not found then
        	raise info 'No other record with condition "is_all_hst_delete = true and all_hst_delete_date is null"'; 
       		return true;
       	end if;
				--
        execute 'select public.zst_2_delete_table_trigger(
          '''||table_record.in_tablename||''',--in_tablename
          '||table_record.drop_hst_table||',--drop_hst_table
          '||table_record.after_insert||',  --after_insert
          '||table_record.after_update||',  --after_update
          '||table_record.after_delete||',   --after_delete
					'''||table_record.in_src_schema||''',   --in_src_schema
					'''||table_record.in_hst_schema||'''   --in_hst_schema
        )'
        into sql_text;
       	execute sql_text into is_success;
        if is_success = true then res = true; end if; --если хотя бы одна таблица была успешно обработана, то механизм снятия версионирования рабочий
       	--
        raise info '#2 update zst_1_table_list';
          execute '
            update public.zst_1_table_list
            set all_hst_delete_date = current_timestamp, is_corr = false
            where id = '||table_record.id||';';
    end loop;
    -- close cursor
    close table_cursor; 
    --
    return res;
end;
$function$
;
