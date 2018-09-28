/****** Object:  StoredProcedure [dbo].[checkSamplePointCountry_AdminScreen]    Script Date: 20/06/2018 15:37:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[checkSamplePointCountry_AdminScreen] (
	@pCountryCode VARCHAR(20)
	,@pUserName VARCHAR(200)
	)
AS
BEGIN
	IF EXISTS (
			SELECT 1
			FROM IDENTITYUSER IU
			JOIN SYSTEMUSERROLE SUR ON IU.ID = SUR.IDENTITYUSERID
			JOIN SYSTEMROLETYPE SRT ON SUR.SystemRoleTypeId = SRT.SystemRoleTypeId
			JOIN COUNTRY C ON SUR.CountryId = C.CountryId
			WHERE IU.USERNAME = @pUserName
				AND C.CountryISO2A = @pCountryCode
				AND SRT.[Description] IN (
					'CityOfficer'
					,'GeographicUser'
					,'LocalOfficer'
					,'RegionOfficer'
					)
				AND C.CountryISO2A='QL'
			)
		SELECT 1
	ELSE
		SELECT 0
END


GO