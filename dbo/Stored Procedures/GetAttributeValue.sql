Create procedure dbo.GetAttributeValue
@pbusinessId varchar(10),
@pAttributeKey varchar(500),
@pcountrycode varchar(10)
as
begin
--declare @sequenceno int
--set @sequenceno =(select top 1 c.sequence from individual i join collectivemembership cm on cm.Individual_Id=i.guidreference join collective c on c.guidreference=cm.Group_Id
--where i.individualid=@pbusinessId)
select av.Value from attributevalue av
join collective c on c.guidreference=av.candidateid
join attribute a on a.guidreference=av.DemographicId
join country ct on ct.CountryId=av.Country_Id
where c.sequence=@pbusinessId and ct.countryiso2a=@pcountrycode and a.[key]=@pAttributeKey
end
