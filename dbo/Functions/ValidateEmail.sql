CREATE FUNCTION [dbo].[ValidateEmail]

(

	@email NVARCHAR(MAX)

)

RETURNS BIT AS

BEGIN
declare @returnvalue bit=0
if(@email is null or LEN(LTRIM(RTRIM(@email)))<=0 )
	set @returnvalue=1
else
	set @returnvalue= IIF(PATINDEX('%[ &,":;!+=\/()<>]%', @email) > 0 -- Invalid characters
						OR PATINDEX ('[@.-_]%', @email) > 0 -- Valid but cannot be starting character
						OR PATINDEX ('%[@.-_]', @email) > 0 -- Valid but cannot be ending character
						OR @email NOT LIKE '%_@_%._%' -- Must contain at least one @ and one .
						OR @email like '%..%' -- Cannot have two periods in a row
						OR @email like '%@%@%' -- Cannot have two @ anywhere
						OR @email like '%.@%' OR @email LIKE '%@.%', 0, 1) -- Cannot have @ and . next to each other

return @returnvalue

END
