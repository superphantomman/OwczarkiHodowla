ALTER DATABASE [DatabaseOne] SET QUERY_STORE = ON;


CREATE VIEW dbo.NajdrozszeOperacjeCPU
AS
SELECT TOP 20
    qs.sql_handle,
    qs.execution_count,
    qs.total_worker_time AS Total_CPU,
    total_CPU_inSeconds = qs.total_worker_time/1000000,
    average_CPU_inSeconds = (qs.total_worker_time/1000000) / qs.execution_count,
    qs.total_elapsed_time,
    total_elapsed_time_inSeconds = qs.total_elapsed_time/1000000,
    st.text,
    qp.query_plan
FROM
    sys.dm_exec_query_stats AS qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY
    sys.dm_exec_query_plan (qs.plan_handle) AS qp
ORDER BY 
    qs.total_worker_time DESC



CREATE VIEW dbo.PodsumowanieZapytan 
AS
SELECT 
    q.query_id,
    qt.query_sql_text
    q.execution_count,
    q.total_worker_time,
    q.last_worker_time,
    q.min_worker_time,
    q.max_worker_time,
    q.total_elapsed_time,
    q.last_elapsed_time,
    q.min_elapsed_time,
    q.max_elapsed_time
FROM 
    sys.query_store_query q
INNER JOIN 
    sys.query_store_query_text AS qt
ON 
    q.query_text_id = qt.query_text_id;

