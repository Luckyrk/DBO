GO
CREATE PROCEDURE [dbo].[Usp_Frozen_CL_Delta_All]
AS
BEGIN
DECLARE @GetDate DATETIME,@CountryCode VARCHAR(10)='CL'
SET @GetDate=GETDATE()

 EXEC Usp_Frozen_Demographic_CL_Delta @GetDate,@CountryCode
 EXEC Usp_Frozen_HouseHold_CL_Delta @GetDate,@CountryCode
 EXEC Usp_Frozen_Individual_CL_Delta @GetDate,@CountryCode
 EXEC Usp_Frozen_Paineis_Domicilios_CL_Delta @GetDate,@CountryCode
 EXEC Usp_Frozen_Paineis_individuos_CL_Delta @GetDate,@CountryCode
 EXEC Usp_Frozen_Pet_CL_Delta @GetDate,@CountryCode
END

GO