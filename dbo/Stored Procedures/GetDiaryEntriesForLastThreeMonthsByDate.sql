CREATE PROCEDURE [dbo].[GetDiaryEntriesForLastThreeMonthsByDate] (@pCurrentDate DATETIME, @pPanelId uniqueidentifier)
AS
BEGIN
       DECLARE @startDate DATETIME
              ,@endDate DATETIME

       SELECT @endDate = CONVERT(DATE, @pCurrentDate)

       SELECT @startDate = DATEADD(month, - 3, CONVERT(DATE, @pCurrentDate))

       SELECT DiaryDateYear
              ,DiaryDatePeriod
              ,DiaryDateWeek
              ,BusinessId
              ,PanelId
       FROM DiaryEntry
       WHERE  panelid=@pPanelId and ReceivedDate BETWEEN @startDate
                     AND @endDate
END
