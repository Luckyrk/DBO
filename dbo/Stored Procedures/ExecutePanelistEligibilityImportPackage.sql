/*##########################################################################
-- Name             : ExecutePanelistEligibilityImportPackage
-- Date             : 2015-01-06
-- Author           : GopiChand Parimi
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure used to trigger the PanelistEligibilityImport package
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        :
-- PARAM Definitions:
		@PackageName -- Name of the package to exeute
		@PackageServer -- Package Server
		@CountryCode -- CountryCode,
		@DTexePath -- Path to the supporting exe to execute the package
		@LogFilePath -- Path to log file

-- Sample Execution :
exec ExecutePanelistEligibilityImportPackage 'PanelistEligibilityImports' ,'KWLWGSQL002\MSSQLSERVER2012' ,'TW'

##########################################################################
-- ver  user               date        change 
-- 1.0  GopiChand		   2015-01-06  initial

##########################################################################*/
CREATE PROCEDURE [dbo].[ExecutePanelistEligibilityImportPackage] @PackageName NVARCHAR(100)
        ,@PackageServer NVARCHAR(100)
        ,@CountryCode NVARCHAR(100)
        ,@DTexePath NVARCHAR (500) = N'c: & cd\ & cd "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\"'
        ,@LogFilePath NVARCHAR(500) = N'E:\OFFSHORE\Imports\PanelistEligibility\DTEXECLogging.txt'
AS
BEGIN
        DECLARE @command NVARCHAR(MAX);
        DECLARE @ReturnCode INT;
        DECLARE @Msg NVARCHAR(1000);
        DECLARE @TB AS TABLE (Result NVARCHAR(MAX));

        SET @command = N'/SQL "\"\' + @PackageName + '\"" /SERVER "\"' + @PackageServer + '\"" /CHECKPOINTING OFF /REPORTING N';
        SET @command = @command + ' /SET \Package.Variables[User::CountryCode].Properties[Value];' + @CountryCode; 
        SET @Msg = @DTexePath + ' & DTexec.exe ' + @command;

        INSERT INTO @TB
        EXEC xp_cmdshell @Msg;

        SELECT Result
        FROM @TB;
END
GO

