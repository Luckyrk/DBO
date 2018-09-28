CREATE FUNCTION dbo.GetLocalDateTimeByCountryId
(
@UTCDate DATETIME,
--@TimeZoneID SMALLINT
@CountryId UniqueIdentifier
)

RETURNS NVARCHAR(500)
AS
BEGIN

--DECLARE @TimeZoneID SMALLINT
DECLARE @LocalDateTime DATETIME
DECLARE @DltBiasFactor SMALLINT

DECLARE @Display NVARCHAR(50)
DECLARE @Bias INT
DECLARE @DltBias INT
DECLARE @StdMonth SMALLINT
DECLARE @StdDow SMALLINT
DECLARE @StdWeek SMALLINT
DECLARE @StdHour SMALLINT
DECLARE @DltMonth SMALLINT
DECLARE @DltDow SMALLINT
DECLARE @DltWeek SMALLINT
DECLARE @DltHour SMALLINT

DECLARE @DaylightDate DATETIME
DECLARE @StandardDate DATETIME

SET @DltBiasFactor = 0

SELECT 
@Display = Display,
@Bias = (-1 * Bias), 
@DltBias = (-1 * DltBias) ,
@StdMonth  = StdMonth,
@StdDow = StdDayOfWeek + 1,
@StdWeek = StdWeek,
@StdHour = StdHour,
@DltMonth = DltMonth,
@DltDow = DltDayOfWeek + 1,
@DltWeek = DltWeek,
@DltHour = DltHour
FROM 
tbTimeZoneInfo 
WHERE 
CountryId = @CountryId


IF @StdMonth = 0
BEGIN
	SET @LocalDateTime = DateAdd( minute, @Bias , @UTCDate)
END
ELSE
BEGIN
	SET @StandardDate =  dbo.GetDaylightStandardDateTime( DATEPART( year, @UTCDate ), @StdMonth, @StdDow, @StdWeek, @StdHour )
	SET @DaylightDate = dbo. GetDaylightStandardDateTime( DATEPART( year, @UTCDate ), @DltMonth, @DltDow, @DltWeek, @DltHour )

	
	IF (  @StandardDate > @DaylightDate )
	BEGIN
		IF ( DATEADD( minute, @Bias, @UTCDate )  BETWEEN @DaylightDate AND @StandardDate   )
		BEGIN
			SET @DltBiasFactor = 1
		END
	END
	ELSE
	BEGIN
		IF ( DATEADD( minute, @Bias, @UTCDate )  BETWEEN @StandardDate AND @DaylightDate )
		BEGIN
			SET @DltBiasFactor = 0
		END
	END

	SET @LocalDateTime = DATEADD( minute, @Bias + ( @DltBiasFactor * @DltBias ) , @UTCDate )

END

	--RETURN  'Time Zone ID:' + CAST( @CountryCode  AS CHAR(2) ) + ' - '  + @Display + ' - <UTC DT:' + CAST ( @UTCDate AS CHAR(20) ) + '> - <Local DT:' + CAST(  @LocalDateTime AS CHAR(20) ) + '>'
	RETURN CONVERT(VARCHAR(20),@LocalDateTime,120)

END 


GO