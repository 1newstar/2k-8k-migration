export DATE_TIME=`date +%d_%m_%Y`
export FILE_NAME=$HOME"/checktableredef_"$DATE_TIME".sql"

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
		for usertable in (select table_name from dba_tables where table_name not like '%8K' and owner=''||schemauser.username||'')
		LOOP
			dbms_output.put_line('');
			dbms_output.put_line('--## Script for tablespace: '||usertable.table_name);
			dbms_output.put_line('execute sys.DBMS_REDEFINITION.CAN_REDEF_TABLE('''||schemauser.username||''', '''||usertable.table_name||''', DBMS_REDEFINITION.CONS_USE_ROWID);');
			dbms_output.put_line('');
		END LOOP;
	END LOOP;
END;
/
spool off;
__EOF__


##
## Move the output to file
##
cat $$.lst | grep ^exe |  sed -n 's/ \+/ /gp' > $FILE_NAME
rm $$.lst


##
## Now verify the redefination
##
export LOGFILE=verifytableredef_"$DATE_TIME".log
$ORACLE_HOME/bin/sqlplus /nolog << __EOF__ > /dev/null 2>&1
connect / as sysdba
set serveroutput on
SPOOL ${LOGFILE}
@$FILE_NAME
spool off;
__EOF__
exit
