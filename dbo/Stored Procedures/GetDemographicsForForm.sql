CREATE PROCEDURE [dbo].[GetDemographicsForForm]
@pFormId UNIQUEIDENTIFIER,
@pCultureCode INT
AS
BEGIN
SET NOCOUNT ON;
SELECT 
	SA.Demographic_Id AS DemographicId
	,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS AttributeName       
FROM FormPage FP
	INNER JOIN Form F ON F.GUIDReference = FP.Form_Id
	INNER JOIN PageColumn PC ON FP.Id = PC.Page_Id
	INNER JOIN PageSection PS ON PS.Column_Id = PC.PageColumnId
	INNER JOIN SortAttribute SA ON SA.PageSection_Id = PS.Id
	INNER JOIN Attribute A ON A.GUIDReference = SA.Demographic_Id
	INNER JOIN ATtributeScope ATS ON ATS.GUIDReference = A.Scope_Id
WHERE F.GUIDReference = @pFormId
        AND A.Active = 1
        AND ATS.Type IN 
		(
            'Individual'
            ,'HouseHold'
        )
END
