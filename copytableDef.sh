export DATE_TIME=`date +%d_%m_%Y`
export FILE_NAME=$HOME"/createtbl"$DATE_TIME".sql"
$ORACLE_HOME/bin/sqlplus /nolog << __EOF__ > /dev/null 2>&1
connect / as sysdba
set serveroutput on
set lines 555
SPOOL $$

declare
	  tableStmt varchar2(4000);
BEGIN
  -- Select all tablespaces with blocksize 2k expect system and sysaux
  FOR schemauser IN (select username from dba_users where username in ('HR'))
	LOOP
		for usertable in (select table_name, TABLESPACE_NAME from dba_tables where owner=''||schemauser.username||'')
		LOOP
			tableStmt:='create table '||schemauser.username||'.'||usertable.table_name||'8k tablespace '||usertable.tablespace_name||'8k as select * from '||schemauser.username||'.'||usertable.table_name||' where 1=0;';
			dbms_output.put_line(tableStmt);
		END LOOP;
	END LOOP;
END;
/
spool off;
__EOF__

cat $$.lst | grep ^create > ${FILE_NAME}
rm $$.lst

export OUTPUT_FILE=$HOME"/copytblDef"$DATE_TIME".log"
$ORACLE_HOME/bin/sqlplus /nolog << __EOF__ > /dev/null 2>&1
connect / as sysdba
set serveroutput on
set lines 555
SPOOL ${OUTPUT_FILE}
@${FILE_NAME}
spool off;
__EOF__
exit

