
Create function dbo.PanelistKitMap
(@BusinessId varchar(20),@ExpectedKitCode int,@CountryCode varchar(10))
returns int
as
begin
declare @result int=0;
if exists (select 1 from Panelist pl 
			join StockKit sk on sk.GUIDReference=pl.ExpectedKit_Id
			join Country c on c.CountryId=pl.Country_Id and c.CountryISO2A=@CountryCode
			join Panel p on p.GUIDReference=pl.Panel_Id
			join CollectiveMembership cm on (case when p.[Type]='Individual' then cm.Individual_Id else cm.Group_Id end )=pl.PanelMember_Id
			join Individual i on i.GUIDReference=cm.Individual_Id
			where i.IndividualId=@BusinessId and sk.Code=@ExpectedKitCode and c.CountryISO2A=@CountryCode
			)
	set @result=1

return @result
end