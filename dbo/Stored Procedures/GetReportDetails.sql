CREATE PROCEDURE [dbo].[GetReportDetails]
	@pReportId UNIQUEIDENTIFIER

	
AS
begin
DECLARE @pCountryId UNIQUEIDENTIFIER
SET @pCountryId=(SELECT Country_id FROM Reports WHERE ReportsId =@pReportId)
 declare @reportPath Nvarchar(500)
 	select @reportPath=
		 (CASE
		WHEN KV.Value IS NULL THEN KS.DefaultValue
		ELSE KV.Value
		END)
		from KeyAppSetting KS
		LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryId
		WHERE KS.KeyName='SSRSReportPath' 
		

 select ReportPath,ReportType ,@reportPath as SavedPath,ISNULL(SaveReportPath,'') AS SaveReportPath from Reports where ReportsId =@pReportId

  end