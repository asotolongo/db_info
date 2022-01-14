

-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION db_info UPDATE TO '0.2.0'" to load this file. \quit
SET search_path = db_info;
drop view IF EXISTS db_obj_count;

CREATE VIEW  db_obj_count AS
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
          WHERE ((pr.prokind not in ('a','w')) AND (pr.pronamespace IN ( SELECT pg_namespace.oid
                   FROM pg_namespace
                  WHERE (((pg_namespace.nspname !~~ 'pg_%'::text) AND (pg_namespace.nspname <> 'information_schema'::name)) AND (pg_namespace.nspname <> 'db_info'::name)))))) AS "functions-procedures",
    ( SELECT count(distinct trigger_schema||'.'||trigger_name) AS count
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


                 
     

