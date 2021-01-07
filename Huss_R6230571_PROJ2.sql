/*
	Name:		Raza Hussain
	Project #:	2
	PantherID:	6230571
	Semester:	Fall 2020
*/

Use Huss_R6230571
GO

INSERT INTO master.dbo.assignments
(pantherId, firstname, lastname, databasename, assignment)
VALUES
('6230571', 'Raza', 'Hussain', 'Huss_R6230571', 2)
GO

CREATE TABLE ProjectMain (
	projectId char(4) NOT NULL,
	projectName varchar(50) NULL,
	fundedbudget decimal(16,2) NULL,
	projectTypeCode char(5) NULL,
	projectStartDate date NULL,
	projectedEndDate date NULL,
	projectStatus varchar(25) NULL,
	projectManager char(8) NULL,
	firmFedID char(9) NULL,
	PRIMARY KEY (projectId)
)
GO

CREATE TABLE ActivityMain (
	projectId char(4) NOT NULL,
	activityId char(4) NOT NULL,
	activityName varchar(5) NULL,
	startDate date NULL,
	endDate date NULL,
	activityStatus varchar(25) NULL,
	costToDate decimal(16,2) NULL
	PRIMARY KEY (projectId, activityId)
)
GO

CREATE TABLE ProjectType (
	projectTypeCode char(5) NOT NULL,
	projectTypeDesc varchar(50) NULL
	PRIMARY KEY (projectTypeCode)
)
GO

CREATE TABLE Firm (
	firmFedID char(9) NOT NULL,
	firmName varchar(50) NOT NULL,
	firmAddress varchar(50) NULL
	PRIMARY KEY (firmFedID)
)
GO

CREATE TABLE ProjectBilling (
	projectBillID char(6) NOT NULL,
	TransAmount decimal(16,9) NULL,
	TransDesc varchar(255) NULL,
	TransDate datetime NULL,
	projectID char(4) NULL,
	accountMgr char(8) NULL,
	PRIMARY KEY (projectBillID)
)
GO

CREATE PROCEDURE SP_AddUpdateProjectBill 
	@projectBillId char(6),
	@TransAmount decimal(16,9),
	@projectId char(4)
AS
BEGIN
	IF EXISTS (SELECT * FROM ProjectBilling WHERE projectBillID = @projectBillId)
		BEGIN
			UPDATE ProjectBilling SET TransAmount = @TransAmount, projectID = @projectId WHERE projectBillID = @projectBillID
		END
	ELSE
		BEGIN
			INSERT INTO ProjectBilling (projectBillID, TransAmount, projectId)
			VALUES (@projectBillId, @TransAmount, @projectId)
		END
END
GO

CREATE PROCEDURE SP_DeleteProjectBill
	@ProjectBillID char(6)
AS
BEGIN
	IF EXISTS (SELECT * FROM ProjectBilling WHERE projectBillID = @projectBillID)
		BEGIN
			DELETE FROM ProjectBilling WHERE projectBillID = @projectBillID
		END
END
GO

CREATE PROCEDURE SP_ProcessProjectDelay 
(
	-- parameter
	@projectID char(4)
)
AS
BEGIN

	-- declare variables
	DECLARE @projectedEndDate date
	DECLARE @fundedbudget decimal(16,9)
	DECLARE @endDate date
	DECLARE @LateDays INT

	IF EXISTS (SELECT * FROM ProjectMain WHERE projectId = @projectID)
	BEGIN
		SET @projectedEndDate = (SELECT projectedEndDate FROM ProjectMain WHERE projectId = @projectID)
		SET @fundedbudget = (SELECT fundedbudget FROM ProjectMain WHERE projectId = @projectID)
	END

	DECLARE FirstCursor CURSOR FOR 
		SELECT endDate FROM ActivityMain
	OPEN FirstCursor
	FETCH FirstCursor INTO @endDate
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @projectedEndDate < @endDate
		BEGIN
			SET @LateDays = DATEDIFF(day, @projectedEndDate, @endDate)
			SELECT @fundedbudget = @fundedbudget + (@LateDays * 1050)
			SET @projectedEndDate = @endDate
		END

		UPDATE ProjectMain 
		SET projectedEndDate = @projectedEndDate, fundedbudget = @fundedbudget 
		WHERE projectId = @projectId

		FETCH FirstCursor INTO @endDate
	END

	CLOSE FirstCursor
	DEALLOCATE FirstCursor
	
END