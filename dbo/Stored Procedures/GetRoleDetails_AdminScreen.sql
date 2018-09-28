create Procedure GetRoleDetails_AdminScreen(@pRoleid int, @pCountry varchar(20))
as
BEGIN

select SystemRoleTypeId,[Description] from systemroletype
where SystemRoleTypeId=@pRoleid

select RA.RestrictedAccessAreaTypeId,RA.RestrictedAccessAreaSubTypeId,RST.[Description] from AccessRights AR
inner join AccessContext AC on AC.AccessContextId = AR.AccessContextId
inner join RestrictedAccessArea RA on RA.RestrictedAccessAreaId = AR.RestrictedAccessAreaId  
inner join RestrictedAccessAreaSubType  RST on RA.RestrictedAccessAreaTypeId = RST.RestrictedAccessAreaTypeId and RA.RestrictedAccessAreaSubTypeId =RST.RestrictedAccessAreaSubTypeId
where AR.SystemRoleTypeId=3 and AR.IsPermissionGranted=1 and AC.[Description]=@pCountry

select RestrictedAccessAreaTypeId,RestrictedAccessAreaSubTypeId,[Description] from RestrictedAccessAreaSubType 

END
