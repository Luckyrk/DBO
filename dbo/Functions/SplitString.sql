
/*##########################################################################    
-- Name    : SplitString.sql    
-- Date             : 2014-12-23
-- Author           : GopiChand Parimi
-- Company          : Cognizant Technology Solution    
-- Purpose          : Split year,month and week based on Period
-- Usage   : From the Stored Procedure
-- Impact   : Other stored procedures.    
-- Required grants  :     
-- Called by        : Stored Procedure      
-- Params Defintion :    
   @Input NVARCHAR(MAX) -- Period value
	,@Character CHAR(1) -- split character	
  
-- Sample Execution :
 EXEC	[dbo].[SplitString] '2014.12.1', '.'		
 EXEC	[dbo].[SplitString] '2014.12', '.'		
 EXEC	[dbo].[SplitString] '2014', '.'		
##########################################################################    
-- ver  user			date        change     
-- 1.0  GopiChand     2014-12-23   initial    
##########################################################################*/
CREATE FUNCTION [dbo].[SplitString] (
	@Input NVARCHAR(MAX)
	,@Character CHAR(1)
	)
RETURNS @Output TABLE (
	Id INT IDENTITY(1, 1)
	,Item NVARCHAR(1000)
	)
AS
BEGIN
	DECLARE @StartIndex INT
		,@EndIndex INT

	SET @StartIndex = 1

	IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
	BEGIN
		SET @Input = @Input + @Character
	END

	WHILE CHARINDEX(@Character, @Input) > 0
	BEGIN
		SET @EndIndex = CHARINDEX(@Character, @Input)

		INSERT INTO @Output (Item)
		SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)

		SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
	END

	RETURN
END