CREATE FUNCTION [dbo].[GetFullName] 
( @FirstName NVARCHAR(500), @MiddleName NVARCHAR(500), @LastName NVARCHAR(500)) RETURNS NVARCHAR(MAX) AS 

BEGIN 
RETURN LTRIM(RTRIM(ISNULL(@FirstName,'')+ISNULL(' '+@MiddleName,'')+ISNULL(' '+@LastName,'')))
END
