CREATE FUNCTION [dbo].[Split](@String NVARCHAR(MAX), @Delimiter char(1))       
returns @temptable TABLE (items NVARCHAR(MAX),
Id INT IDENTITY(1,1)
)       
as       
BEGIN      
    declare @idx int       
    declare @slice NVARCHAR(MAX)       

    select @idx = 1       
        if len(@String)<1 or @String is null  return       

    while @idx!= 0       
    begin       
        set @idx = charindex(@Delimiter,@String)       
        if @idx!=0       
            set @slice = left(@String,@idx - 1)       
        else       
            set @slice = @String       

        if(len(@slice)>0)  
            insert into @temptable(items) values(@slice)       

        set @String = right(@String,len(@String) - @idx)       
        if len(@String) = 0 break       
    end   
return 
END