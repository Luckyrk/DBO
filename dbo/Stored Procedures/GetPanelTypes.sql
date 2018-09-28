 CREATE PROCEDURE [dbo].[GetPanelTypes] (
        @pCountryGUID uniqueidentifier
     
       )
AS
BEGIN

Select  distinct 
 pnl.GUIDReference  as PanelGuidVal
 ,PanelCode 
  ,pnl.[Name] as PanelName
from Panel pnl
inner join Panelist pnlist on pnlist.Panel_Id=pnl.GUIDReference 
where pnl.Country_Id=@pCountryGUID
order by PanelName
 End