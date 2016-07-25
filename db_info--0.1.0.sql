

CREATE SCHEMA db_info;




SET search_path = db_info, pg_catalog;


CREATE FUNCTION get_datatype_used() RETURNS SETOF text
    LANGUAGE sql
    AS $$SELECT string_agg(DISTINCT data_type,',') FROM information_schema.columns  WHERE table_schema NOT LIKE 'pg_%' AND table_schema <> 'information_schema';$$;



COMMENT ON FUNCTION get_datatype_used() IS 'Get datatype used ';



CREATE FUNCTION get_db_roles() RETURNS text
    LANGUAGE sql
    AS $$WITH db_roles as (

SELECT 
      
       (aclexplode(relacl)).grantee
FROM pg_class c JOIN  pg_namespace nm ON (c.relnamespace=nm.oid)

WHERE relacl IS NOT NULL AND nm.nspname NOT LIKE 'pg_%'  AND nspname != 'information_schema' 

UNION

SELECT 
      
       (aclexplode(proacl)).grantee
FROM pg_proc p JOIN  pg_namespace nm ON (p.pronamespace=nm.oid)

WHERE proacl IS NOT NULL AND nm.nspname NOT LIKE 'pg_%'  AND nspname != 'information_schema'
UNION
SELECT 
      
       (aclexplode(typacl)).grantee
FROM pg_type t JOIN  pg_namespace nm ON (t.typnamespace=nm.oid)

WHERE typacl IS NOT NULL AND nm.nspname NOT LIKE 'pg_%'  AND nspname != 'information_schema'

 )

SELECT string_agg( DISTINCT rolname,',') FROM db_roles join pg_roles on grantee=oid; 

$$;




COMMENT ON FUNCTION get_db_roles() IS 'Get Roles in Databases, Roles related with (tables, index,views, sequence,type and proc )';



CREATE FUNCTION get_extension_installed() RETURNS text
    LANGUAGE sql
    AS $$SELECT  string_agg(name,',') FROM  pg_available_extensions  WHERE installed_version IS NOT NULL;$$;



COMMENT ON FUNCTION get_extension_installed() IS 'Get extension installed in current database';




CREATE FUNCTION get_language_installed() RETURNS SETOF text
    LANGUAGE sql
    AS $$SELECT string_agg(DISTINCT lanname,',') FROM pg_language  ;$$;




COMMENT ON FUNCTION get_language_installed() IS 'Get languages';



CREATE FUNCTION get_tb_names() RETURNS text
    LANGUAGE sql
    AS $$SELECT   string_agg(DISTINCT  COALESCE(pg_tablespace.spcname,(SELECT pg_tablespace.spcname   FROM pg_database,pg_tablespace WHERE   dattablespace=pg_tablespace.oid AND datname=current_database())),',') AS table_spacea 
FROM pg_class LEFT JOIN pg_tablespace ON (reltablespace=pg_tablespace.oid) 
JOIN pg_namespace ON  (pg_class.relnamespace=pg_namespace.oid)
WHERE nspname <> 'pg_catalog' AND nspname <> 'information_schema'  AND  relkind='r' OR relkind='i' OR relkind='m';


$$;




COMMENT ON FUNCTION get_tb_names() IS 'Get tables_spaces names  related with (table, index, mat. view)';




CREATE VIEW db_details AS
 SELECT db.datname AS name,
    r.rolname AS owner,
    round((((pg_database_size(db.datname))::numeric / (1024)::numeric) / (1024)::numeric), 2) AS size_mb,
    pg_encoding_to_char(db.encoding) AS encoding,
    db.datcollate AS "collate"
   FROM (pg_database db
     JOIN pg_roles r ON ((db.datdba = r.oid)))
  WHERE (db.datname = current_database());






CREATE VIEW db_obj_count AS
 SELECT ( SELECT count(*) AS count
           FROM pg_namespace
          WHERE (((pg_namespace.nspname !~~ 'pg_%'::text) AND (pg_namespace.nspname <> 'information_schema'::name)) AND (pg_namespace.nspname <> 'db_info'::name))) AS schemas,
    ( SELECT count(*) AS count
           FROM pg_tables
          WHERE (((pg_tables.tablename !~~ 'pg_%'::text) AND (pg_tables.schemaname <> 'information_schema'::name)) AND (pg_tables.schemaname <> 'db_info'::name))) AS tables,
    ( SELECT count(*) AS count
           FROM information_schema.sequences) AS sequences,
    ( SELECT count(*) AS count
           FROM (((pg_proc pr
             JOIN pg_type tp ON ((tp.oid = pr.prorettype)))
             LEFT JOIN pg_stat_user_functions pgst ON ((pr.oid = pgst.funcid)))
             JOIN pg_namespace nm ON ((pr.pronamespace = nm.oid)))
          WHERE ((pr.proisagg = false) AND (pr.pronamespace IN ( SELECT pg_namespace.oid
                   FROM pg_namespace
                  WHERE (((pg_namespace.nspname !~~ 'pg_%'::text) AND (pg_namespace.nspname <> 'information_schema'::name)) AND (pg_namespace.nspname <> 'db_info'::name)))))) AS functions,
    ( SELECT count(*) AS count
           FROM information_schema.triggers) AS triggers,
    ( SELECT count(*) AS count
           FROM pg_rules
          WHERE ((pg_rules.schemaname <> 'pg_catalog'::name) AND (pg_rules.schemaname <> 'db_info'::name))) AS rules,
    ( SELECT count(*) AS count
           FROM pg_constraint) AS constraints,
    ( SELECT count(*) AS count
           FROM pg_indexes
          WHERE ((pg_indexes.schemaname !~~ 'pg_%'::text) AND ((pg_indexes.schemaname)::text <> 'db_info'::text))) AS indexes,
    ( SELECT sum(total.count) AS total_vs
           FROM ( SELECT count(*) AS count
                   FROM pg_views
                  WHERE (((pg_views.schemaname <> 'pg_catalog'::name) AND (pg_views.schemaname <> 'information_schema'::name)) AND (pg_views.schemaname <> 'db_info'::name))
                UNION ALL
                 SELECT count(*) AS count
                   FROM pg_matviews
                  WHERE (((pg_matviews.schemaname <> 'pg_catalog'::name) AND (pg_matviews.schemaname <> 'information_schema'::name)) AND (pg_matviews.schemaname <> 'db_info'::name))) total) AS views;




