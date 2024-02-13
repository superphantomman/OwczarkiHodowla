--Sesje wewnetrze SQL Servera
CREATE VIEW dbo.SesjeWewnetrzne
AS
SELECT session_id, login_time, security_id, status
FROM sys.dm_exec_sessions
WHERE host_name IS NULL;

--Sesje zewewnetrze SQL Servera
CREATE VIEW dbo.SesjeZewnetrzne
AS
SELECT session_id, login_time, security_id, status
FROM sys.dm_exec_sessions
WHERE host_name IS NOT NULL;

--Sesje uzytkownika
CREATE VIEW dbo.SesjeUzytkownika
AS
SELECT session_id, login_time, security_id, status
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;


--Widok udostępniający informacje na temat pamieci oraz alokacji stron na dany moment
--Widok został utworzony na podstawie zapytania ze strony : https://glennsqlperformance.com/
CREATE VIEW dbo.InformacjeZuzyciePamieciSerwera
AS
SELECT physical_memory_in_use_kb/1024 AS [SQL Server Memory Usage (MB)],
	   locked_page_allocations_kb/1024 AS [SQL Server Locked Pages Allocation (MB)],
       large_page_allocations_kb/1024 AS [SQL Server Large Pages Allocation (MB)], 
	   page_fault_count, memory_utilization_percentage, available_commit_limit_kb, 
	   process_physical_memory_low, process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);


CREATE VIEW dbo.InformacjeOperacjeWejscieWyjscie
AS
SELECT DB_NAME(fs.database_id) AS [Database Name], CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_latency_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_latency_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_io_latency_ms],
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], mf.physical_name, mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, 
fs.io_stall_write_ms, fs.num_of_writes, fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls], fs.num_of_reads + fs.num_of_writes AS [total_io],
io_stall_queued_read_ms AS [Resource Governor Total Read IO Latency (ms)], io_stall_queued_write_ms AS [Resource Governor Total Write IO Latency (ms)] 
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
ORDER BY avg_io_latency_ms DESC OPTION (RECOMPILE);

CREATE VIEW dbo.InformacjeBazySerwera
AS
SELECT DB_NAME(database_id) AS DatabaseName, 
       COUNT(*) AS NumTasks, 
       SUM(cpu_time) / 1000.0 AS TotalCPUTimeInSeconds 
FROM sys.dm_exec_requests 
GROUP BY DB_NAME(database_id) 
ORDER BY TotalCPUTimeInSeconds DESC;



--sql server diagnostic query

--querry store

--widoki zarządce