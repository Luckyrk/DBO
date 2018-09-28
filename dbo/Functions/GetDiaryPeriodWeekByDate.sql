CREATE FUNCTION [dbo].[GetDiaryPeriodWeekByDate]
( 
 @TargetDate datetime,
 @CalendarId uniqueidentifier
)
returns varchar(20)
as
BEGIN
DECLARE @listStr VARCHAR(MAX)   

SELECT @listStr = COALESCE(CAST(@listStr AS VARCHAR)+ '.' ,'') + CAST(PeriodValue  AS VARCHAR) FROM CalendarPeriod C
JOIN PeriodType PT ON PT.PeriodTypeId=C.PeriodTypeId
where 
CalendarId=@CalendarId
and CAST(@TargetDate AS DATE) between CAST(StartDate AS DATE) and CAST(EndDate AS DATE)
order  by PeriodGroupSequence ASC

return @listStr

END