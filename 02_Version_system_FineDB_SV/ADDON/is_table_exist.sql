--// SPDX-License-Identifier: Unlicense
create or replace function public.is_table_exist(schema_name text, table_name text)
 returns boolean
 language plpgsql
 immutable
as $function$
begin
    return to_regclass(schema_name || '.' || table_name) is not null;
exception when others then
    return false;
end;
$function$
;