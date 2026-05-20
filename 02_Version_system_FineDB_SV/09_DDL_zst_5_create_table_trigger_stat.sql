--// SPDX-License-Identifier: Unlicense
create or replace function public.zst_5_create_table_trigger_stat(row_stat integer default 1, size_stat integer default 1)
 returns boolean
 language plpgsql
as $function$
--функция формирования таблиц статистики zst_2_table_list_stat и zst_3_table_list_stat_size по работе таблиц системы версионирование на основе таблицы zst_1_table_list для каждой строки по условию "hst_date is not null";
--ri_out text; --переменная для вывода sql кода при отладке
declare
text_sql text;
is_success bool;
is_exist bool;
table_record record;
table_cursor cursor for
    select * 
    from public.zst_1_table_list
    where hst_date is not null;
begin
is_success = false;
--
if row_stat = 1 then
	begin
	    raise info '#-#-#-#-#-#-#-#-#-#-#-#-#';
	    raise info 'part #1';
	    raise info 'start calc table zst_2_table_list_stat';
		-- open cursor
	    open table_cursor;
	    -- fetch rows and return
	    loop
	        fetch next from table_cursor into table_record;
	        exit when not found;
	        raise info '#-#-#-#-#-#-#-#-#-#-#-#-#';
	        raise info 'in_tablename: %',table_record.in_tablename;
	        execute '
	        select exists (
	          select 1
	          from information_schema.tables
	          where table_schema = '''||table_record.in_hst_schema||'''
	          and table_name = ''zst_'||table_record.in_tablename||'''
	        ) as table_exists;
	          ' into is_exist;
	        if is_exist = true
	          then
	          begin
	            raise info '#1 delete exist stat: %', '''zst_'||table_record.in_tablename||'''';
	              execute '
	                delete from public.zst_2_table_list_stat where table_name = ''zst_'||table_record.in_tablename||'''';      
	            raise info '#2 insert new stat';
	            --execute 'select concat(''#'','''||table_record.id||''','' таблица: '','''||table_record.in_tablename||''')' into ri_out;
	            --raise info ri_out;
	            --# table_record.title;
	            execute '
	              insert into public.zst_2_table_list_stat
	              select 
	                '''||table_record.in_hst_schema||''' as schema_name
	                ,''zst_'||table_record.in_tablename||''' as table_name
	                ,min(time_op::date) as min_day
	                ,max(time_op::date) as max_day
	                ,count(distinct time_op::date) as cnt_days
	                ,max(time_op::date)-min(time_op::date) as delta_days
	                ,count(*) as cnt_rec_all
	                ,count(case when h.time_op = (select min(time_op) from '||table_record.in_hst_schema||'.zst_'||table_record.in_tablename||') then h.type_op else null end) as cnt_rec_init
	                ,count(case when h.type_op = ''insert'' and h.time_op > (select min(time_op) from '||table_record.in_hst_schema||'.zst_'||table_record.in_tablename||') then h.type_op else null end) as cnt_rec_insert
	                ,count(case when h.type_op = ''update'' and h.time_op > (select min(time_op) from '||table_record.in_hst_schema||'.zst_'||table_record.in_tablename||') then h.type_op else null end) as cnt_rec_update
	                ,count(case when h.type_op = ''delete'' and h.time_op > (select min(time_op) from '||table_record.in_hst_schema||'.zst_'||table_record.in_tablename||') then h.type_op else null end) as cnt_rec_delete
	              from '||table_record.in_hst_schema||'.zst_'||table_record.in_tablename||' h;
	              ';          
	          end;
	          end if;
	        --return next;
	    end loop;
	    -- close cursor
	    close table_cursor;  
	end;   
end if;
--
if size_stat = 1 then
	begin
	    --
	    raise info '#-#-#-#-#-#-#-#-#-#-#-#-#';
	    raise info 'part #2';
	    raise info 'start calc table zst_3_table_list_stat_size';
	    --#part 2 table size 
	      delete from public.zst_3_table_list_stat_size;
	      insert into public.zst_3_table_list_stat_size
	      with
	      t_tab as (
	        select
	          table_name,
	          pg_size_pretty(pg_total_relation_size(quote_ident(table_name))),
	          pg_total_relation_size(quote_ident(table_name))
	        from information_schema.tables
	        where table_schema = 'public'
	      order by 3 desc
	      )
	      select 
	        t2.table_name as name_t
	        ,t1.table_name as name_hst
	        ,t2.pg_size_pretty as size_t
	        ,t1.pg_size_pretty as size_hst
	        ,t2.pg_total_relation_size as sizeb_t
	        ,t1.pg_total_relation_size as sizeb_hst
	        ,case when round((t1.pg_total_relation_size-t2.pg_total_relation_size)::numeric/t2.pg_total_relation_size,4)*100 < 0 
	        	then 0 
	        	else round((t1.pg_total_relation_size-t2.pg_total_relation_size)::numeric/t2.pg_total_relation_size,4)*100 end 
	        	as perc_inc
	      from t_tab t1
	      left join t_tab t2 on t2.table_name=replace(t1.table_name,'zst_','')
	      where t1.table_name like 'zst_%'
	      	and t1.table_name not in (
	      		 'zst_1_table_list'
		      	,'zst_2_table_list_stat'
		      	,'zst_3_table_list_stat_size')
	      order by perc_inc desc;
	end;
	raise info 'end calc table zst_3_table_list_stat_size';
end if;
    --
		is_success = true;
    return is_success;
   	--
end;
$function$
;