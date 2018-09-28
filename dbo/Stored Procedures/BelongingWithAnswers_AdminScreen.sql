
Create Procedure BelongingWithAnswers_AdminScreen(

@pBelongingType varchar(max),
@pCountryIso2A varchar(Max),
@pCultureCode int ,
@pIndividualId  uniqueidentifier
)
AS
BEGIN

BEGIN TRY
Declare @countryId uniqueidentifier
set @countryId =(select CountryId from Country where CountryISO2A=@pCountryIso2A)
DECLARE @TEMP table(ID INT IDENTITY(1,1),BelongingTypeId varchar(max))
insert into @TEMP  
select Item from dbo.SplitString(@pBelongingType,',')






select b.GUIDReference as BelongingId,bt.[Type] as BelongingType,bt.Id as BelongingTypeId,b.BelongingCode	 from Belonging b
join BelongingType bt on bt.Id=b.TypeId
join Individual i on i.GUIDReference=b.CandidateId
join Country C on i.CountryId=@countryId
join @temp t on t.BelongingTypeId=b.GUIDReference
where i.GUIDReference=@pIndividualId



select b.GUIDReference as BelongingId,bt.[Type] as BelongingType,bt.Id as BelongingTypeId,b.BelongingCode
,sa.Id,i.IndividualId,tt.Value as StateName,sd.Id as StateId, sd.DisplayBehaviorFullyQualifiedTypeName as DisplayBehavior,av.DemographicId as AttributeId
from Belonging b
join BelongingType bt on bt.Id=b.TypeId
join SortAttribute sa on sa.BelongingType_Id=bt.Id
join AttributeConfiguration ac on ac.BelongingTypeId=bt.Id
join AttributeValue av on av.DemographicId=ac.AttributeId and av.RespondentId=b.GUIDReference
inner join StateDefinition sd on sd.Id=b.State_Id	
join TranslationTerm tt on tt.Translation_Id=sd.Label_Id and tt.CultureCode=@pCultureCode
join Individual i on i.GUIDReference=b.CandidateId
join Country C on i.CountryId=@countryId 
join @temp t on t.BelongingTypeId=b.GUIDReference
where i.GUIDReference=@pIndividualId



select b.GUIDReference as BelongingId,bt.[Type] as BelongingType,bt.Id as BelongingTypeId,b.BelongingCode
,av.DemographicId as AttributeId,ttatt.Value as Name,ac.IsRequired as [Required],ob.[Order] as [Order],
a.ShortCode,ac.UseShortCode
from Belonging b
join BelongingType bt on bt.Id=b.TypeId
join SortAttribute sa on sa.BelongingType_Id=bt.Id
join AttributeConfiguration ac on ac.BelongingTypeId=bt.Id
join AttributeValue av on av.DemographicId=ac.AttributeId and av.RespondentId=b.GUIDReference
join OrderedBelonging ob on ob.Belonging_Id=b.GUIDReference
join Attribute a on a.GUIDReference=av.DemographicId 
join TranslationTerm ttatt on ttatt.Translation_Id=a.Translation_Id and ttatt.CultureCode=@pCultureCode
inner join StateDefinition sd on sd.Id=b.State_Id	
join TranslationTerm tt on tt.Translation_Id=sd.Label_Id and tt.CultureCode=@pCultureCode
join Individual i on i.GUIDReference=b.CandidateId
join Country C on i.CountryId=@countryId
join @temp t on t.BelongingTypeId=b.GUIDReference
where i.GUIDReference=@pIndividualId


select sa.id as SortAttributeId,a.GUIDReference as Id,i.GUIDReference as CandidateId,b.GUIDReference as RespondentId,case when av.Value is null then 1 else 0 end as HasValue,
av.Value as AttributeValue,a.GUIDReference as DemographicId
from Belonging b
join BelongingType bt on bt.Id=b.TypeId
join SortAttribute sa on sa.BelongingType_Id=bt.Id
join AttributeConfiguration ac on ac.BelongingTypeId=bt.Id
join AttributeValue av on av.DemographicId=ac.AttributeId and av.RespondentId=b.GUIDReference
join OrderedBelonging ob on ob.Belonging_Id=b.GUIDReference
join Attribute a on a.GUIDReference=av.DemographicId 
join TranslationTerm ttatt on ttatt.Translation_Id=a.Translation_Id and ttatt.CultureCode=@pCultureCode
inner join StateDefinition sd on sd.Id=b.State_Id	
join TranslationTerm tt on tt.Translation_Id=sd.Label_Id and tt.CultureCode=@pCultureCode
join Individual i on i.GUIDReference=b.CandidateId
join Country C on i.CountryId=@countryId
join @temp t on t.BelongingTypeId=b.GUIDReference
where i.GUIDReference=@pIndividualId
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