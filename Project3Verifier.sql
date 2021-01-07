if exists(select * from sys.objects where name = 'spProject3Verifier' and type ='P')
begin
	drop procedure spProject3Verifier
end
go
create procedure spProject3Verifier
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
	objectparamrequired bit null,
	objectParentName varchar(50) null
)




insert into DBObjects
values
('EmployeeAudit','User_Table',null,null,null,null,null),
('JobAudit','User_Table',null,null,null,null,null),
('ProjectMainAudit','User_Table',null,null,null,null,null),
('ActivityMainAudit','User_Table',null,null,null,null,null),
('trgEmployee','SQL_TRIGGER',null,null,null,null,null),
('trgJob','SQL_TRIGGER',null,null,null,null,null),
('trgProjectMain','SQL_TRIGGER',null,null,null,null,null),
('trgActivityMain','SQL_TRIGGER',null,null,null,null,null),
('vw_TableNoIndexes','VIEW',null,null,null,null,null),
('name','COLUMN',null,null,null,null,'vw_TableNoIndexes'),
('create_date','COLUMN',null,null,null,null,'vw_TableNoIndexes'),
('vw_ProjectIdTables','VIEW',null,null,null,null,null),
('name','COLUMN',null,null,null,null,'vw_ProjectIdTables'),
('create_date','COLUMN',null,null,null,null,'vw_ProjectIdTables'),
('vw_Last7Obj','VIEW',null,null,null,null,null),
('name','COLUMN',null,null,null,null,'vw_Last7Obj'),
('modify_date','COLUMN',null,null,null,null,'vw_Last7Obj'),
('vw_ProjectProcs','VIEW',null,null,null,null,null),
('name','COLUMN',null,null,null,null,'vw_ProjectProcs'),
('definition','COLUMN',null,null,null,null,'vw_ProjectProcs'),
('create_date','COLUMN',null,null,null,null,'vw_ProjectProcs'),
('sp_ActiveConnections','SQL_STORED_PROCEDURE',null,null,null,null,null),
('sp_LogFileStatus','SQL_STORED_PROCEDURE',null,null,null,null,null)



IF OBJECT_ID('tempdb..#DBObjects ') IS NOT NULL
	DROP TABLE #DBObjects 

create table #DBObjects  (
	RowId int Identity(1,1),
	objectname varchar(50) not null,
	objecttype varchar(50) not null,
	objectcolumn varchar(50) null,
	objectparam varchar(50) null,
	objectdatatype varchar(50) null,
	objectparamrequired bit null,
	objectParentName varchar(50) null
)

declare @NumberRecords int
declare @RowCount int
SET @RowCount = 1


insert into #DBObjects (objectname, objecttype, objectcolumn,objectparam,objectdatatype,objectparamrequired,objectParentName)
	select objectname, objecttype, objectcolumn,objectparam,objectdatatype,objectparamrequired,objectParentName from DBObjects

SET @NumberRecords = @@ROWCOUNT


-- loop through all records in the temporary table
print ' '
print ' '
print 'Results of verifier:'
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
	@objectparamrequired bit,
	@objectParentName varchar(50)

	SELECT @objectname= objectname, 
			@objecttype = objecttype, 
			@objectcolumn = objectcolumn,
			@objectparam = objectparam,
			@objectdatatype = objectdatatype,
			@objectparamrequired = objectparamrequired,
			@objectParentName = objectParentName
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
		if (@objecttype = 'column')
		begin
			if exists(select * from sys.columns where name = @objectname and object_name(object_id) = @objectparentname)
				--print 1
				print 'SUCCESS: Found '+ @objecttype + ' '  + @objectname + ' in parent object ' + @objectparentname
			else
				--print 2
				print 'ERROR: ' + @objecttype + ' ' + @objectname + ' was not found' + ' in parent object ' + @objectparentname
		end
		else if exists(select * from sys.objects where name = @objectname and type_desc = @objecttype )
			print 'SUCCESS: Found '+ @objecttype + ' '  + @objectname
		else
			print 'ERROR: ' + @objecttype + ' ' + @objectname + ' was not found' 
	end

	--select object_name(object_id), name from sys.columns where name = 'name'
	
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

exec spProject3Verifier
go
