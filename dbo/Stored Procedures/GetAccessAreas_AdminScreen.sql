CREATE PROCEDURE GetAccessAreas_AdminScreen
as 
Begin
select RestrictedAccessAreaSubTypeId,RestrictedAccessAreaTypeId,[Description] from RestrictedAccessAreaSubType where [Description] not in ('System - Menu')
End
