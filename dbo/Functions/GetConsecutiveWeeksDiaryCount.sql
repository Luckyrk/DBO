CREATE FUNCTION [dbo].GetConsecutiveWeeksDiaryCount (
	@PanelName VARCHAR(100)
	,@RecievedDateStart VARCHAR(20)
	,@RecievedDateEnd VARCHAR(20)
	,@BusinessId VARCHAR(10)
	)
RETURNS TABLE
AS
RETURN

SELECT DISTINCT COUNT(*) AS 'ConsecutiveDiaries'
	
FROM DiaryEntry de
INNER JOIN Panel p ON p.GUIDReference = de.PanelId
WHERE de.ReceivedDate BETWEEN @RecievedDateStart
		AND @RecievedDateEnd
	AND de.BusinessId = @BusinessId
	AND de.NumberOfDaysLate <> 1
	AND de.NumberOfDaysEarly <> 1

GROUP BY de.BusinessId
	