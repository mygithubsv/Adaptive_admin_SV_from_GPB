--// SPDX-License-Identifier: Unlicense
create or replace function public.zst_1_create_table_trigger(in_tablename text, drop_hst_table boolean default true, after_insert boolean default true, after_update boolean default true, after_delete boolean default true, force_drop boolean default true, in_src_schema text default 'public'::text, in_hst_schema text default 'public'::text)
 returns boolean
 language plpgsql
as $function$
--zst_1_create_table_trigger это функция автоматического создания версионности для таблицы: создание таблицы для хранения изменений + создание триггеров на версионируемую таблицу с выбором опций.
--функция zst_1_create_table_trigger вызывается функцией zst_3_auto_create_table_trigger для автоматического пакетного развертывания версионирования на таблицы из предварительно сформированного списка в таблице zst_1_table_list  
--параметры функции это флаги действий при операциях (опциональный выбор)
    declare
      prefix_header text;
      prefix_value text;
      prefix_create text;
      is_exist bool;
      is_exist_hst bool;
      agg_fields text;
      agg_fields_new text;
      agg_fields_old text;
      is_success bool;
      last_sql text default '';
      start_time timestamp;
      finish_time timestamp;
    begin
      begin
	    start_time = clock_timestamp(); --используем clock_timestamp чтобы получать актуальные значения времени на каждую операцию внутри функции (current_timestamp проставил бы каждой операции везде одинаковое время только по завершении всей функции)
	   	--
      prefix_header = 'type_op, time_op, login_op'; --дополнительные поля в начало таблицы хранения версионирования
      prefix_value = ',current_timestamp, current_user';
      prefix_create = '''insert'' as type_op, current_timestamp as time_op, current_user as login_op'; --значения дополнительных полей в начало таблицы хранения версионирования
      --
     	raise info '# # # # # # # # # # # # # # # # # # # # # # # # # # ';
      raise info '# start: %', start_time;
     	raise info '# in_hst_schema: %', in_hst_schema;
			raise info '# in_src_schema: %', in_src_schema;
			raise info '# in_tablename: %', in_tablename;
			raise info '# # # # # # # # # # # # # # # # # # # # # # # # # # ';
			--проверка существования таблицы источника версионирования на схеме
      execute ('select exists (
          select 1
          from information_schema.tables
          where table_schema = '''||in_src_schema||'''
          and table_name = '''||in_tablename||''')')
        into is_exist;
      raise info '1.1 table src exists: %', is_exist;
      --проверка существования таблицы хранения версионирования на схеме
      execute ('select exists (
          select 1
          from information_schema.tables
          where table_schema = '''||in_hst_schema||'''
          and table_name = ''zst_'||in_tablename||''')')
        into is_exist_hst;
      raise info '1.2 table hst exists: %', is_exist_hst;
      --формирование строки со столбцами исходной таблицы
      raise info '- - - - - - - - - - - - - - - - - - - - - - - - - - ';
			raise info '2 string_agg column_name into agg_fields';
      execute ('
        with
        t_buf as (
        select
             table_name
            ,column_name
            ,data_type
        from
            information_schema.columns c
        where table_name = '''||in_tablename||'''
				and table_schema = '''||in_src_schema||'''
        )
        select 
					string_agg(column_name,'','') as agg_fields
        from t_buf') into agg_fields;
      --
      raise info '# agg_fields: %', agg_fields;
      --
      raise info '- - - - - - - - - - - - - - - - - - - - - - - - - - ';
			raise info '3 if table hst exists';
      if is_exist_hst = true
      then
        raise info '3.1 hst exists: drop + create + insert';
        if drop_hst_table = true then
        	--#1
        	last_sql = 'drop table if exists '||in_src_schema||'.zst_'||in_tablename;
          raise info '----------------------------------------------------';
        	raise info '> last_sql:';
         	raise info '%', last_sql;
         	raise info '';
        	execute last_sql;
        	--#2
          last_sql = 'create table '||in_hst_schema||'.zst_'||in_tablename||' as select '||prefix_create||','||agg_fields||'  from '||in_src_schema||'.'||in_tablename||' t --where 1=3';
          raise info '----------------------------------------------------';
        	raise info '> last_sql:';
         	raise info '%', last_sql;
         	raise info '';
        	execute (last_sql);
--          execute 'insert into '||in_hst_schema||'.zst_'||in_tablename||' select '||prefix_create||','||agg_fields||'  from '||in_src_schema||'.'||in_tablename||' t';
        end if;
      else
        raise info '3.1 hst not exists: create + insert';
          last_sql = 'create table '||in_hst_schema||'.zst_'||in_tablename||' as select '||prefix_create||','||agg_fields||'  from '||in_src_schema||'.'||in_tablename||' t --where 1=3';
          raise info '----------------------------------------------------';
        	raise info '> last_sql:';
         	raise info '%', last_sql;
         	raise info '----------------------------------------------------';
        	execute last_sql;
--          execute 'insert into '||in_hst_schema||'.zst_'||in_tablename||' select '||prefix_create||','||agg_fields||'  from '||in_src_schema||'.'||in_tablename||' t';
      end if;
--
      last_sql = 'select exists (
          select 1
          from information_schema.tables
          where table_schema = '''||in_hst_schema||'''
          and table_name = ''zst_'||in_tablename||''')';
      raise info '----------------------------------------------------';
    	raise info '> last_sql:';
     	raise info '%', last_sql;
     	raise info '';
     	execute (last_sql)
        into is_exist_hst;
      raise info '3.3 table hst exists: %', is_exist_hst;
--
        agg_fields_new = replace(agg_fields,',',',new.');
        agg_fields_new = 'new.'||agg_fields_new;
        --agg_fields_new = substring(agg_fields_new,1,length(agg_fields_new)+1);
        agg_fields_old = replace(agg_fields_new,'new.','old.');
      --
      raise info '- - - - - - - - - - - - - - - - - - - - - - - - - - ';
			raise info '4 add triggers';
      --
      raise info '4.1 trigger insert';
      if after_insert = true
      then
        begin
          --# insert
          raise info '4.1.1 create function trigger insert';
          --
          if force_drop = true then
	          --#1
	          last_sql = 'drop trigger if exists zst_'||in_tablename||'_insert_trigger on '||in_src_schema||'.'||in_tablename||' cascade;';
	          raise info '----------------------------------------------------';
	        	raise info '> last_sql:';
	         	raise info '%', last_sql;
	         	raise info '';
	        	execute last_sql;
	          --#2
	        	last_sql = 'drop function if exists '||in_src_schema||'.zst_func_'||in_tablename||'_trg_ai();';
	          raise info '----------------------------------------------------';
	        	raise info '> last_sql:';
	         	raise info '%', last_sql;
	         	raise info '';
	        	execute last_sql;
          end if;
          --динамическое формирование функции при вызове триггера after insert
          execute 'create or replace function '||in_src_schema||'.zst_func_'||in_tablename||'_trg_ai()
            returns trigger as
          $$
          begin
          insert into '||in_hst_schema||'.zst_'||in_tablename||' (type_op, time_op, login_op, '||agg_fields||')
          values(''insert'', current_timestamp, current_user, '||agg_fields_new||');
          return new;
          end;
          $$
          language ''plpgsql'';';
          --динамическое формирование триггера after insert, вызывающего функцию с постфиксом _trg_ai
          raise info '4.1.2 create trigger insert';
          execute
          'create trigger zst_'||in_tablename||'_insert_trigger
            after insert
            on "'||in_tablename||'"
            for each row
            execute procedure '||in_src_schema||'.zst_func_'||in_tablename||'_trg_ai();';
        end; 
      end if;
      --
      raise info '4.2 trigger update';
      if after_update = true
      then
        begin
          --# update
          raise info '4.2.1 create function trigger update';
          --
          if force_drop = true then
            execute 'drop trigger if exists zst_'||in_tablename||'_update_trigger on '||in_src_schema||'.'||in_tablename||' cascade;';
            execute 'drop function if exists '||in_src_schema||'.zst_func_'||in_tablename||'_trg_au();';
          end if;
          --
          execute 'create or replace function '||in_src_schema||'.zst_func_'||in_tablename||'_trg_au()
            returns trigger as
          $$
          begin
          insert into '||in_hst_schema||'.zst_'||in_tablename||' (type_op, time_op, login_op, '||agg_fields||')
          values(''update'', current_timestamp, current_user, '||agg_fields_new||');
          return new;
          end;
          $$
          language ''plpgsql'';';
          --
          raise info '4.2.2 create trigger update';
          execute
          'create trigger zst_'||in_tablename||'_update_trigger
            after update
            on "'||in_tablename||'"
            for each row
            execute procedure '||in_src_schema||'.zst_func_'||in_tablename||'_trg_au();';
        end; 
      end if;
      --
      raise info '4.3 trigger delete';
      if after_delete = true
      then
        begin
          --# delete
          raise info '4.3.1 create function trigger delete';
          --
          if force_drop = true then
            execute 'drop trigger if exists zst_'||in_tablename||'_delete_trigger on '||in_src_schema||'.'||in_tablename||' cascade;';
            execute 'drop function if exists '||in_src_schema||'.zst_func_'||in_tablename||'_trg_ad();';
          end if;
          --
          execute 'create or replace function '||in_src_schema||'.zst_func_'||in_tablename||'_trg_ad()
            returns trigger as
          $$
          begin
          insert into '||in_hst_schema||'.zst_'||in_tablename||' (type_op, time_op, login_op, '||agg_fields||')
          values(''delete'', current_timestamp, current_user, '||agg_fields_old||');
          return old;
          end;
          $$
          language ''plpgsql'';';
          --
          raise info '4.3.2 create trigger delete';
          execute
          'create trigger zst_'||in_tablename||'_delete_trigger
            after delete
            on "'||in_tablename||'"
            for each row
            execute procedure '||in_src_schema||'.zst_func_'||in_tablename||'_trg_ad();';
        end; 
      end if;
    --
    finish_time = clock_timestamp();
	  raise info '# start: %', start_time;
	  raise info '# finish: %', finish_time;
    return true; --функция возвращает true, если не было ошибок
    --
    exception when others  
    then
        return false; --при любой ошибке функции возвращает false
    end;
      --
    end;
$function$
;
