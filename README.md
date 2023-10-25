db_info extension
======================================

This PostgreSQL extension implements  functions and views  to get information about the database: size, owner, name,tablespces, ext,  obj count,etc

#Tested  11+

IMPORTANT: There're bugs in the existing version, please contact to me.


Building and install
--------
Run: `make install` 
In postgresql execute: `CREATE EXTENSION db_info;`

--It create schema db_info
              




Example of use
-------
```sql
--VIEWS:
SELECT * FROM db_info.db_details; --details from db (name, owner, size, encoding, collate)
SELECT * FROM db_info.db_obj_count; -- count schemas, tables, sequences, function, triggers, rules, constraints, indexes, views

--FUNCTIONS:
SELECT db_info.get_datatype_used()	--	Get datatype used 
SELECT db_info.get_db_roles()	        --	Get Roles in Databases, Roles related with (tables, index,views, sequence,type and proc )
SELECT db_info.get_extension_installed()--	Get extension installed in current database
SELECT db_info.get_language_installed()	--	Get languages
SELECT db_info.get_tb_names()	        --	Get tables_spaces names related with (table, index, mat. view)

```
Anthony R. Sotolongo leon
asotolongo@gmail.com

