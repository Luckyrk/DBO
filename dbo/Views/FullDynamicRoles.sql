CREATE VIEW [dbo].[FullDynamicRoles] AS
SELECT DISTINCT *
FROM
  ( SELECT cnt.CountryISO2A ,
           dr.Code ,
           tra.KeyName RoleName ,
           col.Sequence GroupId ,
           ind.IndividualId ,
           pan.PanelCode ,
           pan.Name PanelName ,
           CASE
               WHEN pan.Type = 'Individual' THEN ind.IndividualId
               ELSE cast(col.Sequence AS nvarchar)
           END AS PanelMemberId,
		   dra.GPSUser,
		   dra.CreationTimeStamp,
		   dra.GPSUpdateTimestamp
   FROM [dbo].[DynamicRoleAssignment] dra
   INNER JOIN dbo.DynamicRole dr ON dr.DynamicRoleId = dra.DynamicRole_Id
   INNER JOIN dbo.Translation tra ON tra.TranslationId = dr.Translation_Id
   INNER JOIN dbo.Individual ind ON ind.GUIDReference = dra.Candidate_Id
   LEFT JOIN dbo.CollectiveMembership cmem ON cmem.Individual_Id = ind.GUIDReference
   LEFT JOIN dbo.Collective col ON col.GUIDReference = cmem.Group_Id
   INNER JOIN dbo.Country cnt ON cnt.CountryId = dr.Country_Id
   INNER JOIN dbo.Panelist pst ON pst.GUIDReference = dra.Panelist_Id
   INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
   WHERE dra.Panelist_Id IS NOT NULL
   UNION ALL 
   SELECT cnt.CountryISO2A ,
                    dr.Code ,
                    tra.KeyName RoleName ,
                    col.Sequence GroupId ,
                    ind.IndividualId ,
                    NULL AS PanelCode ,
                    NULL AS PanelName ,
                    NULL AS PanelMemberId,
					 dra.GPSUser,
		   dra.CreationTimeStamp,
		   dra.GPSUpdateTimestamp
   FROM [dbo].[DynamicRoleAssignment] dra
   INNER JOIN dbo.DynamicRole dr ON dr.DynamicRoleId = dra.DynamicRole_Id
   INNER JOIN dbo.Translation tra ON tra.TranslationId = dr.Translation_Id
   INNER JOIN dbo.Collective col ON col.GUIDReference = dra.Group_Id
   INNER JOIN dbo.Country cnt ON cnt.CountryId = dr.Country_Id
   INNER JOIN dbo.Individual ind ON ind.GUIDReference = dra.Candidate_Id
   WHERE dra.Group_id IS NOT NULL ) a