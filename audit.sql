USE master
GO

--Tworzenie audytu instancji serwera
CREATE SERVER AUDIT [Instance_Audit]
TO FILE 
(	FILEPATH = N'C:\AUDIT\INSTANCE'
	,MAXSIZE = 256 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)
WHERE object_name = 'sysadmin';


--Tworzenie audytu instancji serwera
CREATE SERVER AUDIT [Hodowla_Data_Modification_audit]
TO FILE 
(	FILEPATH = N'C:\AUDIT\INSTANCE'
	,MAXSIZE = 256 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)


--Tworzenie audytu instancji serwera
CREATE SERVER AUDIT [Magazyn_Data_Modification_audit]
TO FILE 
(	FILEPATH = N'C:\AUDIT\INSTANCE'
	,MAXSIZE = 256 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)


--Tworzenie audytu instancji serwera
CREATE SERVER AUDIT [Klienci_Data_Modification_audit]
TO FILE 
(	FILEPATH = N'C:\AUDIT\INSTANCE'
	,MAXSIZE = 256 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)

--Aktywuje audyty instancji
ALTER SERVER AUDIT [Instance_Audit] WITH (STATE = ON)
GO

ALTER SERVER AUDIT [Hodowla_Data_Modification_audit] WITH (STATE = ON)
GO

ALTER SERVER AUDIT [Magazyn_Data_Modification_audit] WITH (STATE = ON)
GO

ALTER SERVER AUDIT [Klienci_Data_Modification_audit] WITH (STATE = ON)
GO


CREATE SERVER AUDIT SPECIFICATION [Instance_Audit_Change]
FOR SERVER AUDIT [Instance_Audit]
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP);

USE OwczarkiHodowla
GO

--Tworzenie specyfikacji dla schematu hodowli w ramach hodowli
CREATE DATABASE AUDIT SPECIFICATION Hodowla_Data_Modification
FOR SERVER AUDIT [Hodowla_Data_Modification_audit]
ADD ( INSERT, UPDATE, DELETE ON SCHEMA::hodowla BY Hodowca)
WITH (STATE = ON);  

--Tworzenie specyfikacji dla schematu magazynu w ramach hodowli
CREATE DATABASE AUDIT SPECIFICATION Magazyn_Data_Modification
FOR SERVER AUDIT [Magazyn_Data_Modification_audit]
ADD ( INSERT, UPDATE, DELETE ON SCHEMA::magazyn BY Zaopatrzeniowiec)
WITH (STATE = ON);  

--Tworzenie specyfikacji dla schematu magazynu w ramach hodowli
CREATE DATABASE AUDIT SPECIFICATION Klienci_Data_Modification
FOR SERVER AUDIT [Klienci_Data_Modification_audit]
ADD ( INSERT, UPDATE, DELETE ON SCHEMA::klienci BY SpecjalistaMediow)
WITH (STATE = ON);  

USE master
GO

ALTER SERVER AUDIT [Instance_Audit] WITH (STATE = OFF)
GO

ALTER SERVER AUDIT [Hodowla_Data_Modification_audit] WITH (STATE = OFF)
GO

ALTER SERVER AUDIT [Magazyn_Data_Modification_audit] WITH (STATE = OFF)
GO

ALTER SERVER AUDIT [Klienci_Data_Modification_audit] WITH (STATE = OFF)
GO
