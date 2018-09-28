create view ReCreatedGroups as

select   distinct G.Sequence as NewGroupId ,G.OldGroupId ,C.CountryISO2A ,cm.CreationTimeStamp
from Country C
inner join Collective G on G.CountryId=C.CountryId 
inner join collectivemembership CM on CM.Group_Id=G.GUIDReference where oldgroupid is not null