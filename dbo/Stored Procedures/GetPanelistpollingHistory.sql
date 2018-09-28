CREATE PROCEDURE [GetPanelistpollingHistory] --GetPanelistpollingHistory '750444-00','GB'
	@pIndividualId VARCHAR(100)
	,@pCountryCode VARCHAR(5)
AS
BEGIN
	DECLARE @HouseHoldNumber VARCHAR(20)
	DECLARE @TSQL AS VARCHAR (8000);
	DECLARE @LinkedServer VARCHAR(15)

	SET @HouseHoldNumber = SUBSTRING(@pIndividualId, 0, CHARINDEX('-', @pIndividualId, 0))
	SET @LinkedServer = CASE @pCountryCode WHEN 'ES' THEN 'SPANES'
											WHEN 'GB' THEN 'SPAN'
											ELSE 'SPANIE' END
	IF EXISTS(SELECT * FROM   master..sysservers WHERE  srvname = @LinkedServer)
	BEGIN
		SELECT @TSQL = 'SELECT DISTINCT Comms_Date
			,CONVERT(VARCHAR(10), Comms_Date, 103) AS [Date]
			,CONVERT(VARCHAR(5), Comms_Date, 108) AS [Time]
			,CASE 
				   WHEN CALL_SUCCESS = 1
				   THEN ''Transmission OK''
				   ELSE ''Faulty Transmission''
			END AS [Status]
			,SerialNumber
			,COMMENTS
			FROM OPENQUERY(' + @LinkedServer + ',''
			Select B.Comms_Date
			,CALL_SUCCESS 
			,DEVICE_SERIAL_CHAR AS SerialNumber
			,B.COMMENTS
			FROM PT0255 A
			JOIN PT0260 B ON A.Call_Number = B.Call_Number
			WHERE A.HOUSEHOLD_NUMBER =''''' + @HouseHoldNumber +''''' Order by Comms_Date desc
			'') x           
			Order by Comms_Date desc'

		EXECUTE (@TSQL);
	END
END