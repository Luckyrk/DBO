create function [dbo].[fn_PanelMember_id_businessId](@PanelId uniqueidentifier,@IndividualId varchar(20))
returns uniqueidentifier as
begin
declare @Panelmember_id uniqueidentifier
if exists (select 1 from Panel where GUIDReference=@PanelId)
begin
    declare @Country_id uniqueidentifier
    set @Country_id=(select Country_Id from Panel where GUIDReference=@PanelId)
	declare @PanelType varchar(100)
	select @PanelType=Type from Panel where GUIDReference=@PanelId
	if(@PanelType='HouseHold')
	begin
		set @Panelmember_id= (select cm.Group_Id from Individual i
								join Candidate c on c.GUIDReference=i.GUIDReference and c.Country_Id=@Country_id
								join CollectiveMembership cm on cm.Individual_Id=c.GUIDReference
								where i.IndividualId=@IndividualId)
	end
	else
	begin
	 set @Panelmember_id=
	   (select i.GUIDReference from Individual i 
	   join Candidate c on i.GUIDReference=c.GUIDReference and c.Country_Id=@Country_id
	    where i.IndividualId=@IndividualId)
	 end
	 return @Panelmember_id
end
 return CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
end