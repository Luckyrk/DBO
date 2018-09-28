CREATE FUNCTION replacedoublespacewithSingle(@text NVARCHAR(1000))
RETURNS NVARCHAR(1000) AS 
BEGIN 
while charindex('  ',@text  ) > 0
begin
   set @text = replace(@text, '  ', ' ')
end

RETURN @text
END