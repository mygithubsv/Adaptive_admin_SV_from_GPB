--// SPDX-License-Identifier: Unlicense
create or replace function public.zst_6_compress_snapshot(table_name text, days_keep integer default 14, id_column_name text default 'id'::text)
 returns boolean
 language plpgsql
as $function$
--функция сжатия размера таблиц хранения версионирования за счёт изменения периода хранения изменений через перенос опорной даты расчёта версионирования на более позднюю дату с удалением предыдущей опорной даты и имплементацией всех изменений в промежутке от старой отпорной даты до новой опорной даты
--только для таблиц с ID для partition by
declare
    is_corr boolean;
    is_exist bool;
    dat_snapshot_text varchar;
    rn_mode varchar;
		default_schema varchar default 'public';
begin
--
if length(id_column_name)>0 then
    rn_mode = 'partition by '||id_column_name||' ';
else
    rn_mode = '';
end if;
--
raise info '- - - - - - - - - - - - - - - - - - - - - - - - - - - - ';
raise info '1. zst_6_compress_snapshot execute';
--
is_corr := false;
--
execute('select left((current_date - '||days_keep::text||' * interval ''1 day'')::text,10)') into dat_snapshot_text;
--#1
raise info '# # # # # # # # # # # # # # # # # # # # # # # # # # ';
raise info 'start: % ', table_name;
raise info 'date new snapshot: % ', dat_snapshot_text;
raise info '#1 создание временной таблицы buf';
execute('select '||default_schema||'.is_table_exist('''||default_schema||''','''||table_name||'_buf'');') into is_exist;
if is_exist = True
then
    execute('
            drop table '||default_schema||'.'||table_name||'_buf;
    ');
end if;
--
execute('
    create table '||default_schema||'.'||table_name||'_buf as
    select * from '||default_schema||'.'||table_name||' where 1=3;
');
execute ('
    alter table '||default_schema||'.'||table_name||'_buf add column rn bigint;
');
--#2
raise info '#2 вставка в buf снапшота с исходной таблицы zst';
execute('
    insert into '||default_schema||'.'||table_name||'_buf
    --формирование снапшота таблицы на дату
    with
    t_opt as (
    --дата снапшота
        select date'''||dat_snapshot_text||''' as dat_snapshot
    ),
    t_rn as (
    --последнее изменение и последнее удаление
      select
        h.*
        ,row_number() over ('||rn_mode||'order by time_op desc) as rn
      from '||default_schema||'.'||table_name||' h
      join t_opt t on 1=1
      where time_op <= t.dat_snapshot
    ),
    t_new_snapshot_example as (
        --итоговая таблица формата hst с данными актуальными на снапшот
        select *
        from t_rn r
        where r.rn = 1
        and type_op not in (''delete'')
    )
    select * from t_new_snapshot_example;
');
execute ('
    alter table '||default_schema||'.'||table_name||'_buf drop column rn;
');
--#3.1
raise info '#3.1 смена в таблице buf события на insert и времени для опорного снапшота';
execute('
        update '||default_schema||'.'||table_name||'_buf
        set type_op = ''insert''
            ,time_op = date'''||dat_snapshot_text||'''
        where time_op < date'''||dat_snapshot_text||''';
');
--#3.2
raise info '#3.2 дополнение истории изменений в buf из исходной таблицы zst';
execute('
        insert into '||default_schema||'.'||table_name||'_buf
        select * from '||default_schema||'.'||table_name||'
        where time_op >= date'''||dat_snapshot_text||''';
');
--#4
raise info '#4 сброс исходной таблицы zst перед вставкой из buf';
execute('
        truncate table '||default_schema||'.'||table_name||'
');
--#5
raise info '#5 вставка снапшота и истории из buf в исходную таблицу zst';
execute('
        insert into '||default_schema||'.'||table_name||'
        select * from '||default_schema||'.'||table_name||'_buf;
');
--#6
raise info '#6 удаление временной таблицы buf';
execute('
        drop table '||default_schema||'.'||table_name||'_buf;
');
--
raise info '2. zst_6_compress_snapshot finish with state: %', is_corr;
--
is_corr = true;
return is_corr;
end;
$function$
;