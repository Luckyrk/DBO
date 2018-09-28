CREATE VIEW [dbo].[FullGroupBelongingMotorVehiclesPH]
AS
SELECT CountryISO2A
	,GroupID
	,BelongingCode
	,MAX([Car_brand]) as 'Brand Code'
	,MAX(BrandDesc) as 'Brand Desc.'
	,MAX([Car_model])  as 'Model Code'
	,MAX(ModelDesc) as 'Model Desc.'	
	,MAX(YearMake) as 'Year Make'
	,[Status]
FROM (
		SELECT col.Sequence as GroupID
			,b.BelongingCode
			,c.CountryISO2A
			,aterm.Value as [Key]
			,ISNULL(av.Value, ed.Value) AS Value
			,
			--(CASE WHEN [Key] = 'Car_model' THEN edterm.Value ELSE NULL END)AS ModelDesc
			(CASE WHEN [Key] = 'Car_model' THEN 
			(
			CASE
			WHEN (ISNULL(ed.IsFreeTextRequired,0)=1 AND LEN(LTRIM(RTRIM(ISNULL(av.[FreeText],'')))) > 0) 
				THEN edterm.Value + ' - ' + av.[FreeText]
			ELSE edterm.Value
			END
			)
			 ELSE NULL END)AS ModelDesc
			,(CASE WHEN [Key] = 'Car_brand' THEN edterm.Value ELSE NULL END)AS BrandDesc
			,(CASE WHEN [Key] = 'Car_Year_Make' THEN av.Value ELSE NULL END)AS YearMake
			,sd.Code as 'Status'
		FROM dbo.AttributeValue av 
		INNER JOIN dbo.Attribute a ON av.DemographicId = a.GUIDReference
		INNER JOIN dbo.Respondent r ON av.RespondentId = r.GUIDReference AND av.CANDIDATEID IS NULL
		INNER JOIN dbo.Belonging b ON r.GUIDReference = b.GUIDReference --AND av.Candidateid = b.Candidateid
		INNER JOIN dbo.BelongingType bt ON bt.Id = b.TypeId AND b.[Type] = 'GroupBelonging'
		INNER JOIN dbo.StateDefinition sd on b.State_id = sd.id 
		INNER JOIN dbo.Candidate can ON b.CandidateId = can.GUIDReference
		INNER JOIN dbo.Collective col ON can.GUIDReference = col.GUIDReference 
		INNER JOIN dbo.Country c ON can.Country_Id = c.CountryId
		LEFT JOIN dbo.EnumDefinition ed ON ed.Id = av.EnumDefinition_Id
		LEFT JOIN dbo.Translation edt ON edt.TranslationId = ed.Translation_Id
		LEFT JOIN (
			SELECT *
			FROM dbo.TranslationTerm
			WHERE CultureCode = 2057
			) AS edterm ON edt.TranslationId = edterm.Translation_Id
		INNER JOIN dbo.Translation AS TRANSTYPE ON TRANSTYPE.TranslationId = bt.Translation_Id
		LEFT JOIN (
			SELECT *
			FROM dbo.TranslationTerm
			WHERE CultureCode = 2057
			) AS btterm ON TRANSTYPE.TranslationId = btterm.Translation_Id
		INNER JOIN dbo.Translation AS TRANSATTR ON TRANSATTR.TranslationId = a.Translation_Id
		LEFT JOIN (
			SELECT *
			FROM dbo.TranslationTerm
			WHERE CultureCode = 2057
			) AS aterm ON TRANSATTR.TranslationId = aterm.Translation_Id
		WHERE aterm.Value IN ('Car_brand','Car_model','Car_Year_Make')
				) BelKeys
 PIVOT (MAX([Value]) FOR [Key] IN ([Car_brand],[Car_model],[Car_Year_Make])) AS PivotTable
GROUP BY CountryISO2A,GroupID, BelongingCode,[Status]


GO
