-- =============================================
-- Author:		Fernandez, Matias
-- Create date: Nov 02 2015
-- Description:	Rebuilds FullGroupAttributes Views
-- =============================================
CREATE PROCEDURE [dbo].[RebuildCountryRelatedViews]
	@ForCountryId UNIQUEIDENTIFIER = NULL

	/*** Example calls:
		EXEC RebuildCountryRelatedViews -- Execute for all countries.
		EXEC RebuildCountryRelatedViews '70387977-88F8-40C4-BCD0-1173F1AAFFC4' -- Execute for a single country.
	***/
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
	DECLARE @CountryId UNIQUEIDENTIFIER;
	DECLARE @DynamicQuery AS NVARCHAR(MAX);
	DECLARE @ViewName NVARCHAR(100);
	DECLARE @AttributeColumns AS NVARCHAR(MAX)

	DECLARE db_cursor CURSOR FOR SELECT CountryId FROM Country WHERE @ForCountryId IS NULL OR @ForCountryId=CountryId

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @CountryId   

	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		DECLARE @CountryCode NVARCHAR(5); SELECT @CountryCode = CountryISO2A FROM Country WHERE CountryId=@CountryId

		

		/****** FullGroupAttributes ******/
		SET @ViewName = 'FullGroupAttributes' + @CountryCode;
		SET @AttributeColumns = STUFF((SELECT distinct ', ' + QUOTENAME(A.[Key]) 
			FROM Attribute A  WITH (NOLOCK)  JOIN AttributeScope AAS ON AAS.GUIDReference=A.[Scope_Id]
			WHERE AAS.[Type] LIKE 'HouseHold' AND @CountryId = A.Country_Id FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')

		SET @DynamicQuery = 
'ALTER VIEW [dbo].' + @ViewName + N' AS 
SELECT * FROM (	SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key], (
					CASE 
						WHEN A.[Type] = ''Date''
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING ''en-US''), ''yyyy-MM-dd hh:mm:ss'')
						WHEN A.[Type]=''Enum''
							THEN ED.Value
						ELSE AV.Value
					END) Value
				FROM Country
				JOIN Collective C on C.CountryId=Country.CountryId
				LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
				WHERE CountryISO2A = '''+ @CountryCode +'''
				UNION
				SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key], (
					CASE 
						WHEN A.[Type] = ''Date''
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING ''en-US''), ''yyyy-MM-dd hh:mm:ss'')
						WHEN A.[Type]=''Enum''
							THEN ED.Value
						ELSE AV.Value
					END) Value
				FROM Country
				JOIN Collective C on C.CountryId=Country.CountryId
				LEFT JOIN AttributeValue AV ON AV.RespondentID=C.GuidReference
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
				WHERE CountryISO2A = '''+ @CountryCode +'''
) AS Source PIVOT (MAX([Value]) FOR [Key] IN (' + @AttributeColumns + N')) AS PivotTable'		
		IF (@DynamicQuery IS NOT NULL AND EXISTS(SELECT NAME FROM sys.views WHERE NAME LIKE @ViewName))
			EXEC (@DynamicQuery)



		/****** FullGeographicAreaAttributes ******/
		SET @ViewName = 'FullGeographicAreaAttributes' + @CountryCode;
		SET @AttributeColumns = STUFF((SELECT distinct ', ' + QUOTENAME(A.[Key]) 
			FROM Attribute A  WITH (NOLOCK)  JOIN AttributeScope AAS ON AAS.GUIDReference=A.[Scope_Id]
			WHERE AAS.[Type] LIKE 'GeographicArea' AND @CountryId = A.Country_Id FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')

		SET @DynamicQuery = 
'ALTER VIEW [dbo].' + @ViewName + N' AS 
SELECT * FROM (	SELECT [CountryISO2A], ga.Code AS [Code], A.[Key], (
					CASE 
						WHEN A.[Type] = ''Date''
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING ''en-US''), ''yyyy-MM-dd hh:mm:ss'')
						WHEN A.[Type]=''Enum''
							THEN ED.Value
						ELSE AV.Value
					END) Value
				FROM Country C
				JOIN Attribute A WITH (NOLOCK) ON A.Country_ID = C.CountryId
				JOIN AttributeValue AV ON A.GUIDReference = AV.DemographicId
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				JOIN GeographicArea GA on GA.GUIDReference=AV.RespondentId
				WHERE CountryISO2A = '''+ @CountryCode +'''
) AS Source PIVOT (MAX([Value]) FOR [Key] IN (' + @AttributeColumns + N')) AS PivotTable'	
		IF (@DynamicQuery IS NOT NULL AND EXISTS(SELECT NAME FROM sys.views WHERE NAME LIKE @ViewName))
			EXEC (@DynamicQuery)

			
		/****** FullIndividualAttributes ******/
		SET @ViewName = 'FullIndividualAttributes' + @CountryCode;
		SET @AttributeColumns = STUFF((SELECT distinct ', ' + QUOTENAME(A.[Key]) 
			FROM Attribute A  WITH (NOLOCK) JOIN AttributeScope AAS ON AAS.GUIDReference=A.[Scope_Id]
			WHERE AAS.[Type] LIKE 'Individual' AND @CountryId = A.Country_Id FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')

		SET @DynamicQuery = 
'ALTER VIEW [dbo].' + @ViewName + N' AS 
SELECT *
FROM ( SELECT [CountryISO2A], [IndividualId], A.[Key], (
					CASE 
						WHEN A.[Type] = ''Date''
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING ''en-US''), ''yyyy-MM-dd hh:mm:ss'')
						WHEN A.[Type]=''Enum''
							THEN ED.Value
						ELSE AV.Value
					END) Value
		FROM Country
		JOIN Individual C on C.CountryId=Country.CountryId
		LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference
		LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id	
		LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
		WHERE CountryISO2A = '''+ @CountryCode +'''
		UNION
		SELECT [CountryISO2A], [IndividualId], A.[Key], (
					CASE 
						WHEN A.[Type] = ''Date''
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING ''en-US''), ''yyyy-MM-dd hh:mm:ss'')
						WHEN A.[Type]=''Enum''
							THEN ED.Value
						ELSE AV.Value
					END) Value
		FROM Country
		JOIN Individual C on C.CountryId=Country.CountryId
		LEFT JOIN AttributeValue AV ON AV.RespondentID=C.GuidReference
		LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id	
		LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
		WHERE CountryISO2A = '''+ @CountryCode +'''
) AS Source PIVOT (MAX([Value]) FOR [Key] IN (' + @AttributeColumns + N')) AS PivotTable'		
		IF (@DynamicQuery IS NOT NULL AND EXISTS(SELECT NAME FROM sys.views WHERE NAME LIKE @ViewName))
			EXEC (@DynamicQuery)			


		/****** FullIndividualAlias ******/
		SET @ViewName = 'FullIndividualAlias' + @CountryCode;
		SET @AttributeColumns = STUFF((SELECT distinct ', ' + QUOTENAME(C.Name)
			FROM (SELECT DISTINCT Name FROM dbo.NamedAliasContext WHERE Country_Id = @CountryId) C
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')
		SET @DynamicQuery = 
'ALTER VIEW [dbo].' + @ViewName + N' AS 
SELECT * FROM (	SELECT [CountryISO2A], [IndividualId], [Context], [Alias]
				FROM [dbo].[FullIndividualAliasAsRows] WHERE CountryISO2A = ''' + @CountryCode + '''
) AS source PIVOT(MAX([Alias]) FOR [Context] IN (' + @AttributeColumns + ')) AS PivotTable'
		IF (@DynamicQuery IS NOT NULL AND EXISTS(SELECT NAME FROM sys.views WHERE NAME LIKE @ViewName))
			EXEC (@DynamicQuery)
		
		/****** Rebuild all related SPs ******/
		DECLARE @Rebuild NVARCHAR(MAX) = STUFF((SELECT distinct '
BEGIN TRY EXEC sp_refreshview ''dbo.' + QUOTENAME([Name]) +'''; END TRY BEGIN CATCH END CATCH'
			FROM sys.views WHERE [name] LIKE '%' + @CountryCode AND ([name] LIKE '%Attributes%' OR [name] LIKE '%Alias%')
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,1,1,'')
		EXEC (@Rebuild)
																																  		
		FETCH NEXT FROM db_cursor INTO @CountryId   																			  
	END																															  			
	CLOSE db_cursor
	DEALLOCATE db_cursor	
	END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH																									  		
	SET NOCOUNT OFF
END

GO


