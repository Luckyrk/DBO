Create View [dbo].[GpsUserRoles] 
As
       SELECT     distinct   dbo.IdentityUser.UserName, dbo.Country.CountryISO2A,dbo.IdentityUser.GPSUser, dbo.SystemUserRole.SystemRoleTypeId,dbo.SystemRoleType.Description
		FROM        dbo.Country INNER JOIN
                         dbo.IdentityUser ON dbo.Country.CountryId = dbo.IdentityUser.Country_Id INNER JOIN
                                         dbo.SystemUserRole ON dbo.SystemUserRole.IdentityUserId=dbo.IdentityUser.Id INNER JOIN
                                         dbo.SystemRoleType ON      dbo.SystemRoleType.SystemRoleTypeId=dbo.SystemUserRole.SystemRoleTypeId    

                                         