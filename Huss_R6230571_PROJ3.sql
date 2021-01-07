/*
	Name:		Raza Hussain
	Project #:	3
	PantherID:	6230571
	Semester:	Fall 2020
*/

Use Huss_R6230571
GO

INSERT INTO master.dbo.assignments
(pantherId, firstname, lastname, databasename, assignment)
VALUES
('6230571', 'Raza', 'Hussain', 'Huss_R6230571', 3)
GO

SELECT * INTO EmployeeAudit FROM Employee
WHERE 0 = 1;
ALTER TABLE EmployeeAudit
ADD Operation varchar(50),
	DateTimeStamp datetime
GO

SELECT * INTO JobAudit FROM Job 
WHERE 0 = 1;
ALTER TABLE JobAudit
ADD Operation varchar(50),
	DateTimeStamp datetime
GO

SELECT * INTO ProjectMainAudit FROM ProjectMain
WHERE 0 = 1;
ALTER TABLE ProjectMainAudit
ADD Operation varchar(50),
	DateTimeStamp datetime
GO

SELECT * INTO ActivityMainAudit FROM ActivityMain
WHERE 0 = 1;
ALTER TABLE ActivityMainAudit
ADD Operation varchar(50),
	DateTimeStamp datetime
GO

CREATE TRIGGER trgEmployee ON Employee
FOR INSERT, UPDATE, DELETE
AS
BEGIN
IF EXISTS (SELECT * FROM inserted)
BEGIN
	INSERT INTO EmployeeAudit (
		empNumber,
		firstName,
		lastName,
		ssn,
		address,
		state,
		zip,
		jobCode,
		dateOfBirth,
		certification,
		salary,
		Operation,
		DateTimeStamp
		)
	SELECT empNumber, firstName, lastName, ssn, address, state, zip, jobCode, dateOfBirth, certification, salary, 'INSERTED', CURRENT_TIMESTAMP
	FROM inserted
END
IF EXISTS (SELECT * FROM deleted)
BEGIN
	INSERT INTO EmployeeAudit (
		empNumber,
		firstName,
		lastName,
		ssn,
		address,
		state,
		zip,
		jobCode,
		dateOfBirth,
		certification,
		salary,
		Operation,
		DateTimeStamp
		)
	SELECT empNumber, firstName, lastName, ssn, address, state, zip, jobCode, dateOfBirth, certification, salary, 'DELETED', CURRENT_TIMESTAMP
	FROM deleted
END
IF (UPDATE(empNumber) OR UPDATE(firstName) OR UPDATE(lastName) OR UPDATE(ssn) OR UPDATE(address) OR UPDATE(state)
	OR UPDATE(zip) OR UPDATE(jobCode) OR UPDATE(dateOfBirth) OR UPDATE(certification) OR UPDATE(salary))
BEGIN
	INSERT INTO EmployeeAudit (
		empNumber,
		firstName,
		lastName,
		ssn,
		address,
		state,
		zip,
		jobCode,
		dateOfBirth,
		certification,
		salary,
		Operation,
		DateTimeStamp
		)
	SELECT empNumber, firstName, lastName, ssn, address, state, zip, jobCode, dateOfBirth, certification, salary, 'DELETED', CURRENT_TIMESTAMP
	FROM deleted
	SELECT empNumber, firstName, lastName, ssn, address, state, zip, jobCode, dateOfBirth, certification, salary, 'INSERTED', CURRENT_TIMESTAMP
	FROM inserted
END
END
GO

CREATE TRIGGER trgJob ON Job
FOR INSERT, UPDATE, DELETE
AS
BEGIN
IF EXISTS (SELECT * FROM inserted)
BEGIN
	INSERT INTO JobAudit (
		jobCode,
		jobDesc,
		Operation,
		DateTimeStamp
		)
	SELECT jobCode, jobDesc, 'INSERTED', CURRENT_TIMESTAMP
	FROM inserted
END
IF EXISTS (SELECT * FROM deleted)
BEGIN
	INSERT INTO JobAudit (
		jobCode,
		jobDesc,
		Operation,
		DateTimeStamp
		)
	SELECT jobCode, jobDesc, 'DELETED', CURRENT_TIMESTAMP
	FROM deleted
END
IF (UPDATE(jobCode) OR UPDATE(jobDesc))
BEGIN
	INSERT INTO JobAudit (
		jobCode,
		jobDesc,
		Operation,
		DateTimeStamp
		)
	SELECT jobCode, jobDesc, 'DELETED', CURRENT_TIMESTAMP
	FROM deleted
	SELECT jobCode, jobDesc, 'INSERTED', CURRENT_TIMESTAMP
	FROM inserted
END
END
GO

CREATE TRIGGER trgProjectMain ON ProjectMain
FOR INSERT, UPDATE, DELETE
AS
BEGIN
IF EXISTS (SELECT * FROM inserted)
BEGIN
	INSERT INTO ProjectMainAudit (
		projectId,
		projectName,
		firmFedID,
		fundedbudget,
		projectStartDate,
		projectStatus,
		projectTypeCode,
		projectedEndDate,
		projectManager,
		Operation,
		DateTimeStamp
		)
	SELECT projectId, projectName, firmFedID, fundedbudget, projectStartDate, projectStatus, projectTypeCode, projectedEndDate, projectManager, 'INSERTED', CURRENT_TIMESTAMP
	FROM inserted
END
IF EXISTS (SELECT * FROM deleted)
BEGIN
	INSERT INTO ProjectMainAudit (
		projectId,
		projectName,
		firmFedID,
		fundedbudget,
		projectStartDate,
		projectStatus,
		projectTypeCode,
		projectedEndDate,
		projectManager,
		Operation,
		DateTimeStamp
		)
	SELECT projectId, projectName, firmFedID, fundedbudget, projectStartDate, projectStatus, projectTypeCode, projectedEndDate, projectManager, 'DELETED', CURRENT_TIMESTAMP
	FROM deleted
END
END
GO

CREATE TRIGGER trgActivityMain ON ActivityMain
FOR INSERT, UPDATE, DELETE
AS
BEGIN
IF EXISTS (SELECT * FROM inserted)
BEGIN
	INSERT INTO ActivityMainAudit (
		activityId,
		activityname,
		projectId,
		costToDate,
		activityStatus,
		startDate,
		endDate,
		Operation,
		DateTimeStamp
		)
	SELECT activityId, activityName, projectId, costToDate, activityStatus, startDate, endDate, 'INSERTED', CURRENT_TIMESTAMP
	FROM inserted
END
IF EXISTS (SELECT * FROM deleted)
BEGIN
	INSERT INTO ActivityMainAudit (
		activityId,
		activityname,
		projectId,
		costToDate,
		activityStatus,
		startDate,
		endDate,
		Operation,
		DateTimeStamp
		)
	SELECT activityId, activityName, projectId, costToDate, activityStatus, startDate, endDate, 'DELETED', CURRENT_TIMESTAMP
	FROM deleted
END
END
GO

CREATE VIEW vw_TableNoIndexes 
AS
SELECT name, create_date
FROM sys.objects
WHERE (type = 'U') AND (object_id NOT IN (SELECT object_id FROM sys.indexes));
GO

CREATE VIEW vw_ProjectIdTables 
AS
SELECT SO.name, create_date
FROM sys.objects SO INNER JOIN sys.columns SC ON SO.object_id = SC.object_id
WHERE SC.name LIKE '%projectiD%'
GO

CREATE VIEW vw_Last7Obj 
AS
SELECT name, modify_date
FROM sys.objects
WHERE modify_date > GETDATE() - 7
GO

CREATE VIEW vw_ProjectProcs
AS
SELECT name, SM.definition, create_date
FROM sys.objects SO INNER JOIN sys.sql_modules SM ON SM.object_id = SO.object_id
WHERE SM.definition LIKE '%project%'
GO

CREATE PROCEDURE Sp_ActiveConnections
	@databasename varchar(250)
AS
SELECT db_name(dbid) DatabaseName, count(spid) NumberOfConnections, LogiName
FROM sys.sysprocesses
WHERE db_name(dbid) = @databasename
GROUP BY db_name(dbid), LogiName
GO

EXEC Sp_ActiveConnections 'Huss_R6230571'
GO

CREATE PROCEDURE Sp_LogFileStatus
	@databasename varchar(250)
AS
SELECT db_name(database_id) DatabaseName, sum(size*iif(type_desc = 'LOG', 1, 0)) LogSize, sum(size) DataSize
FROM sys.master_files
WHERE (db_name(database_id) = @databasename)
GROUP BY db_name(database_id)
GO

EXEC Sp_LogFileStatus 'Huss_R6230571'
GO
