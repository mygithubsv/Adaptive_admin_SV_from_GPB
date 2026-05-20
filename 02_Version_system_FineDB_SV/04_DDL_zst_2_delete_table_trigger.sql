--// SPDX-License-Identifier: Unlicense
create or replace function public.zst_2_delete_table_trigger(in_tablename text, drop_hst_table boolean default false, after_insert boolean default true, after_update boolean default true, after_delete boolean default true, in_src_schema text default 'public'::text, in_hst_schema text default 'public'::text)
 returns boolean
 language plpgsql
as $function$
--функция удаления таблицы, триггеров и зависимых функций для версионируемой таблицы
    declare
      is_success bool;
    begin
      begin
      --
      raise info '1 delete triggers';
      --
      raise info '1.1 trigger insert';
      if after_insert = true
      then
        begin
            execute 'drop trigger if exists zst_'||in_tablename||'_insert_trigger on '||in_src_schema||'.'||in_tablename||' cascade;';
            execute 'drop function if exists '||in_src_schema||'.zst_func_'||in_tablename||'_trg_ai();';
        end;
      end if;
      --
      raise info '1.2 trigger update';
      if after_update = true
      then
        begin
            execute 'drop trigger if exists zst_'||in_tablename||'_update_trigger on '||in_src_schema||'.'||in_tablename||' cascade;';
            execute 'drop function if exists '||in_src_schema||'.zst_func_'||in_tablename||'_trg_au();';
        end;
      end if;
      --
      raise info '1.3 trigger delete';
      if after_delete = true
      then
        begin
            execute 'drop trigger if exists zst_'||in_tablename||'_delete_trigger on '||in_src_schema||'.'||in_tablename||' cascade;';
            execute 'drop function if exists '||in_src_schema||'.zst_func_'||in_tablename||'_trg_ad();';
        end;
      end if;     
      --
      raise info '2 drop table hst';
        if drop_hst_table = true then
          execute 'drop table if exists '||in_hst_schema||'.zst_'||in_tablename||';';
        end if;
    --
    return true;
    --
    exception when others  
    then
        return false;
    end;
      --
    end;
$function$
;
