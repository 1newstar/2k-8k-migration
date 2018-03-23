expdp \"/ as sysdba\" directory=dump_dir dumpfile=tts1st.dmp logfile=expdptts.log TRANSPORT_TABLESPACES="USERS8K" TRANSPORT_FULL_CHECK=y 
