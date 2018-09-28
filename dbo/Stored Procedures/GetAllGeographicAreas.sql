CREATE procedure dbo.GetAllGeographicAreas
(@pcountrycode varchar(10),@pculturecode int)
as
BEGIN
BEGIN TRY
select ga.CreationTimeStamp,ga.Code as GeographicAreaCode,ga.GUIDReference as Id,case when tt.Value is null then '{' + T.KeyName + '}' else tt.Value end  as [Description] from GeographicArea ga
join Respondent r on r.GUIDReference=ga.GUIDReference
join Country c on c.CountryId=r.CountryID
left join TranslationTerm tt on tt.Translation_Id=ga.Translation_Id and tt.CultureCode=@pculturecode
left join Translation t on t.TranslationId=tt.Translation_Id
where c.CountryISO2A=@pcountrycode
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END