expdp \"/ as sysdba\" directory=dump_dir dumpfile=appmeta.dmp logfile=expmeta.log schemas=hr content=metadata_only exclude=table
