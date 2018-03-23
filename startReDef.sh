#/bin/bash

export DATE_TIME=`date +%d_%m_%Y`
export FILE_NAME=$HOME"/redef2k_8k"$DATE_TIME".sql"

##
## Generate scripts to check table redefinition feasibility
##

$ORACLE_HOME/bin/sqlplus /nolog << __EOF__ > /dev/null 2>&1
connect / as sysdba
set serveroutput on
SPOOL $$
set lines 555
BEGIN
  -- Select all tablespaces with blocksize 2k expect system and sysaux
  FOR schemauser IN (select username from dba_users where username in ('HR'))
    LOOP
      for usertable in (select table_name from dba_tables where owner=''||schemauser.username||'' and table_name not like''||'%8K'||'')
        LOOP
          dbms_output.put_line('');
          dbms_output.put_line('execute sys.DBMS_REDEFINITION.START_REDEF_TABLE('''||schemauser.username||''', '''||usertable.table_name||''', '''||usertable.table_name||'8k'||''',NULL, DBMS_REDEFINITION.CONS_USE_ROWID);');
          dbms_output.put_line('declare');
          dbms_output.put_line('num_errors pls_integer;');
	  dbms_output.put_line('begin');
	  dbMS_output.put_liNe('sys.DBMS_REDEFINITION.copy_table_dependents('''||schemauser.username||''', '''||usertable.table_name||''', '''||usertable.table_name||'8k'',dbms_redefinition.cons_orig_params,num_errors=>num_errors);');
          dbms_output.put_line('dbms_output.put_line(num_errors);');
	  dbms_output.put_line('end;');
	  dbms_output.put_line('/');
	  dbms_output.put_line('execute sys.DBMS_REDEFINITION.sync_interim_table('''||schemauser.username||''', '''||usertable.table_name||''', '''||usertable.table_name||'8k'||''');');
          dbms_output.put_line('execute sys.DBMS_REDEFINITION.finish_redef_table('''||schemauser.username||''', '''||usertable.table_name||''', '''||usertable.table_name||'8k'||''');');
          dbms_output.put_line('drop table '||schemauser.username||'.'||usertable.table_name||'8k;');
          dbms_output.put_line('purge dba_recyclebin;');
	  for useridx in (select index_name, table_name,TABLESPACE_NAME from dba_indexes where owner=''||schemauser.username||'' and table_name=''||usertable.table_name||'')
	    LOOP
	      dbms_output.put_line('alter index '||schemauser.username||'.'||useridx.index_name||' rebuild tablespace '||useridx.tablespace_name||'8k online;');
	    END LOOP;
        END LOOP;
     END LOOP;
END;
/
spool off;
__EOF__
#exit

cat $$.lst | sed -e '1,28d' > $$
head -n -3 $$ > ${FILE_NAME}
rm $$.lst $$

$ORACLE_HOME/bin/sqlplus /nolog << __EOF__ > /dev/null 2>&1
connect / as sysdba
set serveroutput on
SPOOL redfLogfile.log
set lines 555
@${FILE_NAME}
purge dba_recyclebin;
spool off;
__EOF__
