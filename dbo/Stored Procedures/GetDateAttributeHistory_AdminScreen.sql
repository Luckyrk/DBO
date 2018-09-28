create PROCEDURE GetDateAttributeHistory_AdminScreen
@pCountrycode varchar(5)
AS
BEGIN
	declare @a varchar(max) =  DB_NAME()
	set @a  = (select concat(@a,'_AttributeHistoryData'))
	Declare @Date DateTime
	SET @Date = (select LastRun   from JobStatus
	WHERE [name] = @a )
		
	DECLARE @countryid uniqueidentifier 
	set @countryid = (select CountryId from country where CountryISO2A=@pCountrycode) 
		(select dbo.GetLocalDateTimeByCountryId(@Date,@countryid) as LastRun) 

	END
