CREATE procedure dbo.GetAllGeographicAreasNoInterviewers
(@pcountrycode varchar(10),@pculturecode int,@pcityId int)
as
select ga.CreationTimeStamp,ga.Code as GeographicAreaCode,ga.GUIDReference as Id,case when tt.Value is null then '{' + T.KeyName + '}' else tt.Value end  as [Description] 
from GeographicArea ga
 join Respondent r on ga.GUIDReference=r.GUIDReference
 join Country c on c.CountryId=r.CountryID  and c.CountryISO2A=@pcountrycode
join citygeographics cg on ga.GUIDReference=cg.GeohgraphicAreaId
join city cc on cc.GUIDreference=cg.cityid 
left join TranslationTerm tt on tt.Translation_Id=ga.Translation_Id and tt.CultureCode=@pculturecode
left join Translation t on t.TranslationId=tt.Translation_Id
Where   cc.city_code=@pcityId and ga.Code  not in  
( select ga.code from InterviewerGeographicArea iga inner join GeographicArea ga on iga.GeographicArea_Id=ga.GUIDReference)    order by ga.Code