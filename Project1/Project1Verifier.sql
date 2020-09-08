if exists(select * from sys.objects where name = 'spProject1Verifier' and type ='P')
begin
	drop procedure spProject1Verifier
end
go
create procedure spProject1Verifier
as
begin
	--

IF OBJECT_ID('DBObjects ') IS NOT NULL
	DROP TABLE DBObjects 
create table DBObjects (
	id int primary key identity(1,1),
	objectname varchar(50) not null,
	objecttype varchar(50) not null,
	objectcolumn varchar(50) null,
	objectparam varchar(50) null,
	objectdatatype varchar(50) null,
	objectparamrequired bit null
)



insert into DBObjects
values
('Employee','User_Table',null,null,null,null),
('Job','User_Table',null,null,null,null),
('FK_JOB','FOREIGN_KEY_CONSTRAINT',null,null,null,null),
('EMP_STATECHECK','CHECK_CONSTRAINT',null,null,null,null),
('JOB_JOBCODE','CHECK_CONSTRAINT',null,null,null,null),
('vw_CertifiedDevelopers','View',null,null,null,null),
('vw_RetireEmp','View',null,null,null,null),
('vw_EmpAvgSalary','View',null,null,null,null),
('IDX_LastName','Index',null,null,null,null),
('IDX_ssn','Index',null,null,null,null)


IF OBJECT_ID('tempdb..#DBObjects ') IS NOT NULL
	DROP TABLE #DBObjects 

create table #DBObjects  (
	RowId int Identity(1,1),
	objectname varchar(50) not null,
	objecttype varchar(50) not null,
	objectcolumn varchar(50) null,
	objectparam varchar(50) null,
	objectdatatype varchar(50) null,
	objectparamrequired bit null
)

declare @NumberRecords int
declare @RowCount int
SET @RowCount = 1


insert into #DBObjects (objectname, objecttype, objectcolumn,objectparam,objectdatatype,objectparamrequired)
	select objectname, objecttype, objectcolumn,objectparam,objectdatatype,objectparamrequired from DBObjects

SET @NumberRecords = @@ROWCOUNT


-- loop through all records in the temporary table
print ' '
print ' '
print 'Results of verifier for this Assignment. '
print 'An "ERROR" means that the database object was not found as specified. Please review.'
print ''

declare @ObjectHeaderflag bit
set @ObjectHeaderflag  = 1

declare @ParamHeaderflag bit
set @ParamHeaderflag  = 1

WHILE @RowCount <= @NumberRecords
begin

	declare @objectname varchar(50) ,
	@objecttype varchar(50) ,
	@objectcolumn varchar(50) ,
	@objectparam varchar(50),
	@objectdatatype varchar(50),
	@objectparamrequired bit

	SELECT @objectname= objectname, 
			@objecttype = objecttype, 
			@objectcolumn = objectcolumn,
			@objectparam = objectparam,
			@objectdatatype = objectdatatype,
			@objectparamrequired = objectparamrequired
	FROM #DBObjects
	WHERE RowID = @RowCount
	
	if (@ObjectHeaderflag = 1)
	begin
		print 'VERIFY OBJECTS'
		print '-------------------------------------'
		set @ObjectHeaderflag  = 0
	end

	--do logic
	if (@objectcolumn is null and @objectparam is null)
	begin
		if (@objecttype = 'Index')
		begin
			if exists(select * from sys.indexes where name = @objectname)
				print 'SUCCESS: Found '+ @objecttype + ' '  + @objectname
			else
				print 'ERROR: ' + @objecttype + ' ' + @objectname + ' was not found' 
		end
		else if exists(select * from sys.objects where name = @objectname and type_desc = @objecttype )
			print 'SUCCESS: Found '+ @objecttype + ' '  + @objectname
		else
			print 'ERROR: ' + @objecttype + ' ' + @objectname + ' was not found' 
	end

	
	
	if (@objectparam is not null)
	begin

		if (@ParamHeaderflag = 1)
	begin
		print ''
		print 'VERIFY SP Parameters'
		print '-------------------------------------'
		set @ParamHeaderflag  = 0
	end

		if exists(select * FROM sys.procedures sp JOIN sys.parameters p 
					ON sp.object_id = p.object_id JOIN sys.types t
					ON p.system_type_id = t.system_type_id
					WHERE sp.name = @objectname  and p.name = @objectparam and t.name = @objectdatatype)
			print 'SUCCESS: Found parameter '+  @objectparam + ' in ' +  @objectname
		else
			print 'ERROR: ' + @objecttype + ' ' + @objectname + ' PARAM ' + @objectparam + ' was not found' 
	end

	if (@objectparamrequired is not null)
	begin
		--print ''
		--print 'VERIFY SP REquired Parameters'
		--print '-------------------------------------'
		if @objectparamrequired != (select top 1 has_default_value FROM sys.procedures sp JOIN sys.parameters p 
					ON sp.object_id = p.object_id JOIN sys.types t
					ON p.system_type_id = t.system_type_id
					WHERE sp.name = @objectname  and p.name = @objectparam and t.name = @objectdatatype)
			print 'SUCCESS: Required parameter '+ @objectparam + ' found in ' +  @objectname
		else
			print 'ERROR: Parameter ' + @objectparam + ' is optional but SP ' + @objectname + ' has it as required'
	end

	SET @RowCount = @RowCount + 1
end



DROP TABLE #DBObjects
end
go

--Run the Stored Procedure
exec spProject1Verifier

