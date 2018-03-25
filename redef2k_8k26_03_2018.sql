execute sys.DBMS_REDEFINITION.START_REDEF_TABLE('HR', 'SEGMENTS', 'SEGMENTS8k',NULL, DBMS_REDEFINITION.CONS_USE_ROWID); 
declare 
num_errors pls_integer; 
begin 
sys.DBMS_REDEFINITION.copy_table_dependents('HR', 'SEGMENTS', 'SEGMENTS8k',dbms_redefinition.cons_orig_params,num_errors=>num_errors); 
dbms_output.put_line(num_errors); 
end; 
/ 
execute sys.DBMS_REDEFINITION.sync_interim_table('HR', 'SEGMENTS', 'SEGMENTS8k'); 
execute sys.DBMS_REDEFINITION.finish_redef_table('HR', 'SEGMENTS', 'SEGMENTS8k'); 
drop table HR.SEGMENTS8k; 
purge dba_recyclebin; 
execute sys.DBMS_REDEFINITION.START_REDEF_TABLE('HR', 'TABLES', 'TABLES8k',NULL, DBMS_REDEFINITION.CONS_USE_ROWID); 
declare 
num_errors pls_integer; 
begin 
sys.DBMS_REDEFINITION.copy_table_dependents('HR', 'TABLES', 'TABLES8k',dbms_redefinition.cons_orig_params,num_errors=>num_errors); 
dbms_output.put_line(num_errors); 
end; 
/ 
execute sys.DBMS_REDEFINITION.sync_interim_table('HR', 'TABLES', 'TABLES8k'); 
execute sys.DBMS_REDEFINITION.finish_redef_table('HR', 'TABLES', 'TABLES8k'); 
drop table HR.TABLES8k; 
purge dba_recyclebin; 
alter index HR.TBLINDX rebuild tablespace USERS8k online; 
execute sys.DBMS_REDEFINITION.START_REDEF_TABLE('HR', 'OBJECTS', 'OBJECTS8k',NULL, DBMS_REDEFINITION.CONS_USE_ROWID); 
declare 
num_errors pls_integer; 
begin 
sys.DBMS_REDEFINITION.copy_table_dependents('HR', 'OBJECTS', 'OBJECTS8k',dbms_redefinition.cons_orig_params,num_errors=>num_errors); 
dbms_output.put_line(num_errors); 
end; 
/ 
execute sys.DBMS_REDEFINITION.sync_interim_table('HR', 'OBJECTS', 'OBJECTS8k'); 
execute sys.DBMS_REDEFINITION.finish_redef_table('HR', 'OBJECTS', 'OBJECTS8k'); 
drop table HR.OBJECTS8k; 
purge dba_recyclebin; 
alter index HR.OBJINDEX rebuild tablespace USERS8k online; 
