create view FullOrderItems 
AS
select o.[OrderId]
      ,c.CountryISO2A
      ,p.PanelCode
      ,p.Name PanelName
         ,i.IndividualId
      ,o.[OrderedDate]
      ,o.[DispatchedDate]
      ,s.Code OrderState
         ,st.Code as StockCode
         ,st.Name as StockName
         ,it.Quantity
      ,at.State ActionTaskState
      ,ot.Code Type
      ,at.ActionComment
      ,o.[Comments]
      ,o.[GPSUser]
      ,o.[GPSUpdateTimestamp]
      ,o.[CreationTimeStamp]      
from [Order] o
inner join OrderItem it on it.Order_Id = o.OrderId
inner join OrderType ot on ot.Id = o.[Type_Id]
inner join StockType st on st.GUIDReference = it.StockType_Id
inner join ActionTask at on o.ActionTask_Id=at.GUIDReference
inner join Individual i on at.Candidate_Id=i.GUIDReference
inner join Country c on at.Country_Id=c.CountryId
left join Panel p on at.Panel_Id=p.GUIDReference
left join StateDefinition s on s.Id = o.State_Id
