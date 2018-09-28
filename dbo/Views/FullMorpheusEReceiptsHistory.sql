CREATE VIEW FullMorpheusEReceiptsHistory
AS
select 
c.Sequence,mh.EmailAddress,co.CountryISO2A,dbo.gettranslationvalue(fsd.Label_Id,2057) as [From],dbo.gettranslationvalue(tsd.Label_Id,2057) as [To],mh.GPSUser,mh.CreationTimeStamp,mh.GPSUpdateTimestamp
from MorpheusEReceipts m
inner join MorpheusEReceiptsHistory mh on mh.MorpheusEReceiptsId=m.MorpheusEReceiptsId
inner join Collective c on c.GUIDReference=m.CandidateId
inner join country co on co.CountryId=m.CountryId
inner join statedefinition fsd on fsd.Id=mh.From_Id
inner join statedefinition tsd on tsd.Id=mh.To_Id
