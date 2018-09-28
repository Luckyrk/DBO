Create PROCEDURE [dbo].GetSqlQuery_AdminScreen (
	@psessionId INT
	,@pStartTime varchar(max)
	)
AS
BEGIN
Declare @error bit 
set @error =1
	IF EXISTS (
			SELECT TEXT
			FROM sys.dm_exec_requests dr
			INNER JOIN sys.dm_exec_sessions se ON dr.session_id = se.session_id
			CROSS APPLY sys.Dm_exec_sql_text(sql_handle)
			WHERE dr.database_id NOT IN (
					1
					,2
					,3
					,4
					)
				AND dr.session_id = @psessionId
				AND dr.start_time = @pStartTime
			)
        Begin
		set @error=0
		SELECT text
		FROM sys.dm_exec_requests dr
		INNER JOIN sys.dm_exec_sessions se ON dr.session_id = se.session_id
		CROSS APPLY sys.Dm_exec_sql_text(sql_handle)
		WHERE dr.database_id NOT IN (
				1
				,2
				,3
				,4
				)
			AND dr.session_id = @psessionId
			AND dr.start_time = @pStartTime
	    END

	  If (@error =1)
      if exists (select [Query] from [master].[dbo].[MonitorLongRunningQueries] where [StartTime]=@pStartTime and [Session_Id]=@psessionId)
	  Begin
	 	set @error=0
	  select [Query] as text from [master].[dbo].[MonitorLongRunningQueries] where [StartTime]=@pStartTime and [Session_Id]=@psessionId
	  END

	  if(@error=1)
	  select 'Query Expired Please Refresh' as text
END