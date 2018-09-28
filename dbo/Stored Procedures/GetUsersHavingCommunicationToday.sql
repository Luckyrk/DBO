
/*##########################################################################
-- Name             : GetUsersHavingCommunicationToday
-- Date             : 2014-11-21
-- Author           : Jagadeesh B
-- Purpose          : To Get UsersHaving Communication Today
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
       @pCountryId NVARCHAR(10) -- Country Id
       @pToday DATETIME  - curent date (short date)

-- Sample Execution :
SET STATISTICS TIME ON
exec GetUsersHavingCommunicationToday '3558A18E-CCEB-CADC-CB8C-08CF81794A86','2014-01-01 00:00:00'
##########################################################################
-- version  user                                       date        change 
-- 1.0     Jagadeesh B                            2014-11-21       Initial
##########################################################################*/
CREATE PROCEDURE GetUsersHavingCommunicationToday
(
 @pCountryId UNIQUEIDENTIFIER,
 @pToday DATETIME
)
AS
BEGIN 
 SELECT distinct [GPSUser]  AS [GPSUser] 
 FROM [dbo].[CommunicationEvent] 
 WHERE Country_Id=@pCountryId AND [CreationDate]>=@pToday
END