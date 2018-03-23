#/bin/bash

export DATE_TIME=`date +%d_%m_%Y`
export EXPDPCMD=$HOME"/expdp_"$DATE_TIME".sh"
export LOGFILE=$HOME"/changeToreadonly_"$DATE_TIME".log"


##
## Change the status of all 8k tablespaces to read only
##

$ORACLE_HOME/bin/sqlplus /nolog << __EOF__ > /dev/null 2>&1
connect / as sysdba
set serveroutput on
SPOOL ${LOGFILE}
set lines 555
BEGIN
  -- Select all tablespaces with blocksize 8k expect system and sysaux
  FOR tts IN (select TABLESPACE_NAME from dba_tablespaces where block_size=8192 and contents='PERMANENT' and TABLESPACE_NAME not in ('SYSTEM','SYSAUX'))
    LOOP
	EXECUTE IMMEDIATE 'ALTER tablespace '||tts.TABLESPACE_NAME||' read only';
    END LOOP;
END;
/
spool off;
__EOF__


##
## Create export command
##

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
  expdpCMD :='expdp \"/ as sysdba\" directory=dump_dir dumpfile=tts1st.dmp logfile=expdptts.log TRANSPORT_TABLESPACES="';
  --dbms_output.put_line('expdp \"/ as sysdba\" directory=dump_dir dumpfile=tts1st.dmp logfile=expdptts.log \');
  FOR schemauser IN (select TABLESPACE_NAME from dba_tablespaces where block_size=8192 and contents='PERMANENT' and TABLESPACE_NAME not in ('SYSTEM','SYSAUX'))
    LOOP
	if counter > 1
	   THEN
		expdpCMD := expdpCMD||','||schemauser.TABLESPACE_NAME;
	else
		expdpCMD := expdpCMD||schemauser.TABLESPACE_NAME;
	end if;
	counter := counter +1;
    END LOOP;
  dbms_output.put_line(expdpCMD||'" TRANSPORT_FULL_CHECK=y');
END;
/
spool off;
__EOF__

##
## preprocess the expdp script and filter blank spaces
##
cat $$.lst | sed -e '1,22d' | head -n -3 | sed -n 's/ \+/ /gp' > ${EXPDPCMD}
rm $$.lst
chmod +x `echo $EXPDPCMD`
nohup $EXPDPCMD > exportTTS.log &
echo "Monitor Process :"$$

exit
