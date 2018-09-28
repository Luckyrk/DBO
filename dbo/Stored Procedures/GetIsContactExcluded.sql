/*##########################################################################
-- Name				: GetIsContactExcluded 
-- Date             : 2014-11-27
-- Author           : GPS Developer
-- Purpose          : 
					  param definitions
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : Called from UI
-- PARAM Definitions
			-- @pCountryId guid reference of country
			
			-- EXEC GetIsContactExcluded  'D5672E53-297F-478B-859C-FBF7F79D6BA1','70387977-88F8-40C4-BCD0-1173F1AAFFC4'
##########################################################################
-- version  user                  date        change 
-- 1.0  GPS Developer			2014-11-27   Initial

##########################################################################*/
CREATE PROCEDURE [dbo].[GetIsContactExcluded] @pIndividualGUID UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @Date DATETIME
		,@Count BIT = 0
			DECLARE @GetDate DATETIME
	SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))
	SET @Date = @GetDate
	SET @Count = (
			SELECT count(1)
			FROM Exclusion exc
			INNER JOIN Individual ind ON ind.GUIDReference = exc.Parent_Id
				AND ind.GUIDReference = @pIndividualGUID
			INNER JOIN ExclusionType exctype ON exctype.GUIDReference = exc.[Type_Id]
			WHERE exc.Range_From < @Date
				AND exc.Range_To > @Date
				AND exctype.AllowedContact = 0
				AND exctype.Country_Id = @pCountryId
			)

	SELECT @Count AS isContactExcluded
END