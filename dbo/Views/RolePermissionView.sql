CREATE VIEW RolePermissionView
AS
SELECT RT.[Description] AS [Role], RASA.[Path], 
MAX(IIF(RT.SystemRoleTypeId = AR.SystemRoleTypeId, AR.IsPermissionGranted, 0)) AS IsPermissionGranted
, AC.[Description] AS Context
FROM AccessRights AR
JOIN RestrictedAccessSystemArea RASA ON AR.RestrictedAccessAreaId = RASA.RestrictedAccessAreaId
JOIN AccessContext AC ON AC.AccessContextId = AR.AccessContextId
CROSS JOIN SystemRoleType RT
GROUP BY RT.[Description], RASA.[Path],AC.[Description]





