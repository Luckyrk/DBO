
/*##########################################################################
-- Name				: GetIsFieldRequiredOrFieldVisible
-- Date             : 2014-11-05
-- Author           : Teena Areti
-- Purpose          : To identify supplied field is required or can be visible
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : SP
-- PARAM Definitions
			@pCountryId UNIQUEIDENTIFIER  -- guid of country
			,@pKey NVARCHAR(100)		-- Key that needs to be validated
			,@pRequiredOrVisible BIT    -- Bit to identify whether key si required or not and can be visible or not
											1  is to check the functionality for required
											0 is to check for visibility

EXEC GetIsFieldRequiredOrFieldVisible '17D348D8-A08D-CE7A-CB8C-08CF81794A86','GiftOrderValidation',0
##########################################################################
-- version  user                  date        change 

-- 1.0   Venkata Ramana			2014-11-28   Initial

##########################################################################*/
CREATE PROCEDURE GetIsFieldRequiredOrFieldVisible
@pCountryId UNIQUEIDENTIFIER,
@pKey NVARCHAR(200),
@pRequiredOrVisible BIT
AS
BEGIN
	SELECT ISNULL(dbo.[IsFieldRequiredOrFieldVisible](@pCountryId,@pKey,@pRequiredOrVisible),0) AS IsFieldRequiredOrFieldVisible
END