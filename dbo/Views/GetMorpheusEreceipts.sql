

CREATE VIEW GetMorpheusEReceipts

AS

select 

c.Sequence,EmailAddress,dbo.gettranslationvalue(sd.Label_Id,2057) as [State],co.CountryISO2A,m.GPSUser,m.CreationTimeStamp,m.GPSUpdateTimestamp

from MorpheusEReceipts m 

inner join Collective c on c.GUIDReference=m.CandidateId

inner join country co on co.CountryId=m.CountryId

inner join statedefinition sd on sd.Id=m.StateId
