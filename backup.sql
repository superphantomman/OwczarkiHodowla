USE master
GO


CREATE PROCEDURE [dbo].[IsBackupValid] 
@BackupFilePath NVARCHAR(MAX), 
@IsValid BIT OUTPUT
AS
BEGIN
   BEGIN TRY
       RESTORE VERIFYONLY FROM DISK = @BackupFilePath;
       SET @IsValid = 1;
   END TRY
   BEGIN CATCH
       SET @IsValid = 0;
   END CATCH
END
GO



CREATE OR ALTER PROCEDURE [dbo].[KopiaPelnaOwczarkiHodowla] 
AS
BEGIN

	DBCC CHECKDB( [OwczarkiHodowla] ) WITH	NO_INFOMSGS

    PRINT("Procedure pass checkdb test");

    -- Sprawdzenie czy katalog istnieje potrzebny do backup
    IF NOT EXISTS (SELECT 1 FROM sys.dm_os_file_exists(N'C:\BAK\owczarki_hodowla') WHERE file_is_a_directory = 1)
    BEGIN
        RAISERROR('Abort full backup. \n ERROR : There is no catalog like C:\BAK\owczarki_hodowla ', 16, 1);
        RETURN;
    END;

    -- Czyszczenie foldera z poprzednich kopii zapasowych 
    EXEC master.sys.xp_delete_files N'C:\BAK\owczarki_hodowla\*';

    -- Pełna kopia zapasowa
    BACKUP DATABASE OwczarkiHodowla
        TO DISK = N'C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak'
        WITH NOFORMAT, NOINIT, NAME = N'Full backup OwczarkiHodowla'
        , NOREWIND, NOUNLOAD, CHECKSUM;
END


CREATE OR ALTER PROCEDURE [dbo].[KopiaDziennikaOwczarkiHodowla] 
AS
BEGIN

    -- Sprawdzenie czy pełna kopia zapasowa istnieje
    IF NOT EXISTS (SELECT 1 FROM sys.dm_os_file_exists(N'C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak') WHERE file_exists = 1)
    BEGIN
        RAISERROR('Abort log backup. \n ERROR : There is no full backup like C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak', 16, 1);
        RETURN;
    END;

	 -- Sprawdzenie poprawności pełnej kopii zapasowej
    DECLARE @IsValid BIT;
    EXEC IsBackupValid N'C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak', @IsValid OUTPUT;
    IF @IsValid = 0
    BEGIN
        RAISERROR('Backup: C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak is not valid. Administrator must resolve the problem.', 16, 1);
        RETURN;
    END;

    DECLARE @numerKopiiDziennika INT;
    DECLARE @sqlCommand NVARCHAR(MAX);

    -- Tworzenie tabeli tymczasowej
    IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL
        DROP TABLE #TempTable;

    CREATE TABLE #TempTable (SubDirectory NVARCHAR(255), Depth SMALLINT, FileFlag BIT);

    -- Wypełnianie tabeli tymczasowej wynikami procedury xp_dirtree
    INSERT INTO #TempTable EXEC xp_dirtree N'C:\BAK\owczarki_hodowla\', 1, 1;

    SELECT @numerKopiiDziennika = COUNT(*) FROM #TempTable WHERE FileFlag = 1;

    -- Kopia zapasowa dziennika w formie dynamicznego polecenia
    SET @sqlCommand = N'BACKUP LOG OwczarkiHodowla
        TO DISK = N''C:\BAK\owczarki_hodowla\owczarki_hodowla_log0' + CAST(@numerKopiiDziennika AS NVARCHAR(10)) + '.trn''
        WITH NOFORMAT, NOINIT, NAME = N''Log backup ' + CAST(@numerKopiiDziennika AS NVARCHAR(10)) + 'OwczarkiHodowla''
        , NOREWIND, NOUNLOAD, CHECKSUM';

    EXEC sp_executesql @sqlCommand;

END;



CREATE OR ALTER PROCEDURE [dbo].[PrzywrocBazeDanychOwczarkiHodowla] 
AS
BEGIN
    --Sprawdzamy czy plik z kopią znajduje się
    IF NOT EXISTS (SELECT 1 FROM sys.dm_os_file_exists(N'C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak') WHERE file_exists = 1)
    BEGIN
        RAISERROR('Abort recovery. \n ERROR : There is no full backup like C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak', 16, 1);
        RETURN;
    END;

    DECLARE @IsValid BIT;
    EXEC IsBackupValid N'C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak', @IsValid OUTPUT;
    IF @IsValid = 0
    BEGIN
        RAISERROR('Abort recovery. \n ERROR : Backup: C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak is not valid.', 16, 1);
        RETURN;
    END

    RESTORE DATABASE OwczarkiHodowla 
        FROM DISK = N'C:\BAK\owczarki_hodowla\owczarki_hodowla_full.bak' 
        WITH FILE = 1, 
            NORECOVERY, 
            REPLACE;

    -- Przywracamy każdy dziennik transakcyjny w kolejności chronologicznej
    DECLARE @filename NVARCHAR(255);
    DECLARE @i INT;
    SET @i = 1;

    WHILE @i <= 3
    BEGIN
    SET @filename = N'C:\BAK\owczarki_hodowla\owczarki_hodowla_log0' + CAST(@i AS NVARCHAR(10)) + '.trn';

    IF EXISTS (SELECT * FROM sys.master_files WHERE name = @filename)
    BEGIN
        RESTORE LOG OwczarkiHodowla 
            FROM DISK = @filename 
            WITH NORECOVERY;
    END
    SET @i = @i + 1;
    END;

    -- Ostatecznie przywracamy bazę danych
    RESTORE DATABASE OwczarkiHodowla WITH RECOVERY;

END


--Widok został utworzony na podstawie zapytania ze strony : https://glennsqlperformance.com/
-- Look at recent Full backups for the current database (Query 89) (Recent Full Backups)
CREATE VIEW dbo.WidokPelnekopieDanych
AS
SELECT TOP (30) bs.machine_name, bs.server_name, bs.database_name AS [Database Name], bs.recovery_model,
CONVERT (BIGINT, bs.backup_size / 1048576 ) AS [Uncompressed Backup Size (MB)],
CONVERT (BIGINT, bs.compressed_backup_size / 1048576 ) AS [Compressed Backup Size (MB)],
CONVERT (NUMERIC (20,2), (CONVERT (FLOAT, bs.backup_size) /
CONVERT (FLOAT, bs.compressed_backup_size))) AS [Compression Ratio], bs.compression_algorithm,
bs.has_backup_checksums, bs.is_copy_only, bs.encryptor_type,
DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS [Backup Elapsed Time (sec)],
bs.backup_finish_date AS [Backup Finish Date], bmf.physical_device_name AS [Backup Location], 
bmf.physical_block_size,  bs.last_valid_restore_time
FROM msdb.dbo.backupset AS bs WITH (NOLOCK)
INNER JOIN msdb.dbo.backupmediafamily AS bmf WITH (NOLOCK)
ON bs.media_set_id = bmf.media_set_id  
WHERE bs.database_name = DB_NAME(DB_ID())
AND bs.[type] = 'D' -- Change to L if you want Log backups
ORDER BY bs.backup_finish_date DESC ;