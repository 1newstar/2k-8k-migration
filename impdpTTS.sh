#/bin/bash

export DATE_TIME=`date +%d_%m_%Y`
export IMPDPCMD=$HOME"/impdp_"$DATE_TIME".sh"
export LOGFILE=$HOME"/changeToreadonly_"$DATE_TIME".log"

##
## Create export command
##

export ORACLE_SID=orcl
$ORACLE_HOME/bin/sqlplus /nolog << __EOF__ > /dev/null 2>&1
connect / as sysdba
set serveroutput on
SPOOL $$
set lines 555
DECLARE 
  expdpCMD varchar2(1000);
  counter number(5);
BEGIN
  -- Select all tablespaces with blocksize 8k expect system and sysaux
  counter := 1;
  expdpCMD :='impdp \"/ as sysdba\" directory=dump_dir dumpfile=tts1st.dmp logfile=impd_expdptts.log TRANSPORT_DATAFILES="';
  --dbms_output.put_line('impdp \"/ as sysdba\" directory=dump_dir dumpfile=tts1st.dmp logfile=impdp_expdptts.log \');
  FOR schemauser IN (select tablespace_name, file_name, block_size from dba_tablespaces join dba_data_files using(tablespace_name) where block_size=8192)
    LOOP
	if counter > 1
	   THEN
		expdpCMD := expdpCMD||','||schemauser.file_name;
	else
		expdpCMD := expdpCMD||schemauser.file_name;
	end if;
	counter := counter +1;
    END LOOP;
  dbms_output.put_line(expdpCMD||'"');
END;
/
spool off;
__EOF__

$ORACLE_HOME/bin/sqlplus /nolog << __EOF__ > /dev/null 2>&1
connect / as sysdba
set serveroutput on
SPOOL shutdown$DATE_TIME.log
select name, open_mode, database_role from v\$database;
shutdown immediate;
spool off;
__EOF__


##
## preprocess the expdp script and filter blank spaces
##
cat $$.lst | sed -e '1,22d' | head -n -3 | sed -n 's/ \+/ /gp' > ${IMPDPCMD}
rm $$.lst
chmod +x `echo $IMPDPCMD`
export ORACLE_SID=ora8k
echo $ORACLE_SID
nohup $IMPDPCMD > impdpTTS.log &
echo "Monitor Process :"$$

exit
