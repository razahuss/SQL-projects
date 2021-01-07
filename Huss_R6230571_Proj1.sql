/*
	Name:		Raza Hussain
	Project #:	1
	PantherID:	6230571
	Semester:	Fall 2020
*/

Use Huss_R6230571
GO

INSERT INTO master.dbo.assignments
(pantherId, firstname, lastname, databasename, assignment)
VALUES
('6230571', 'Raza', 'Hussain', 'Huss_R6230571', 1)
GO

CREATE TABLE Job (
	jobCode char(4) NOT NULL,
	jobdesc varchar(50) NULL,
	CONSTRAINT PK_JobCode PRIMARY KEY (jobCode),
	CONSTRAINT JOB_JOBCODE CHECK (jobCode IN ('SOFT', 'QAEN', 'INSP', 'PRMG'))
	)
GO

CREATE TABLE Employee (
	empNumber char(8) NOT NULL,
	firstName varchar(25) NULL,
	lastName varchar(25) NULL,
	ssn char(9) NULL,
	address varchar(50) NULL,
	state char(2) NULL,
	zip char(5) NULL,
	jobCode char(4) NULL,
	dateOfBirth date NULL,
	certification bit NULL,
	salary money NULL,
	CONSTRAINT PK_EmpNumber PRIMARY KEY (empNumber),
	CONSTRAINT FK_JOB FOREIGN KEY (jobCode) REFERENCES Job(jobCode),
	CONSTRAINT EMP_STATECHECK CHECK (state='NY' OR state='PA')
	)
GO

INSERT INTO Employee 
VALUES	
	('1', 'Daniel', 'Morales', '123456789', '3805 Forbes Ave', 'PA', '15213', 'INSP', '1991-04-30', '0', '43000'),
	('2', 'Jorge', 'Ramos	', '592340009', '301 South Hills Ave', 'PA', '15241', 'QAEN', '1995-11-29', '1', '70000'),
	('3', 'Roberto', 'Arias', '489197883', '575 Market Street', 'NY', '94105', 'PRMG', '1991-02-17', '1', '96000')
GO

INSERT INTO Job 
VALUES 
	('SOFT', 'Software Engineer'),
	('QAEN', 'Quality Engineer'),
	('INSP', 'Inspector'),
	('PRMG', 'Project Manager')
GO

CREATE VIEW vw_CertifiedDevelopers AS
SELECT empNumber, firstName, lastName, jobDesc
FROM Employee, Job
WHERE Employee.jobCode = Job.jobCode AND jobDesc = 'Software Engineer' AND certification = 1
GO

CREATE VIEW vw_RetireEmp AS
SELECT empNumber, firstName, lastName
FROM Employee
WHERE (DATEDIFF(yy, dateOfBirth, GETDATE())) > 65;
GO

CREATE VIEW vw_EmpAvgSalary (jobCode, salAverage) AS
SELECT jobCode, avg(salary) 
FROM Employee
GROUP BY jobCode
GO

CREATE INDEX IDX_LastName ON Employee (lastName)
CREATE INDEX IDX_SSN ON EMPLOYEE (ssn)
GO