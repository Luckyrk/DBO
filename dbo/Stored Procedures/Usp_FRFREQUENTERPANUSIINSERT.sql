CREATE PROCEDURE [dbo].[Usp_FRFREQUENTERPANUSIINSERT]
(
	@pidfoyer int,
	@ppan_no_individu VARCHAR(100),
	--@pusi_code bigint,
	@pfreq_dt_update Datetime,
	@pGPSUser VARCHAR(100),
	@pFreqPanRecords dbo.FreqPanRecords READONLY
)
AS
BEGIN
IF EXISTS(
SELECT 1 FROM (
SELECT IndividualId,(Select Top 1 items from dbo.Split(IndividualId,'-') WHERE id=1) AS  idfoyer
,(Select Top 1 items from dbo.Split(IndividualId,'-') WHERE id=2) AS  pan_no_individu FROM (
SELECT * FROM Individual WHERE IndividualId like '%'+CAST(@pidfoyer AS VARCHAR)+'%'
) TT 
) TT2 WHERE CAST(idfoyer AS INT)=CAST(@pidfoyer AS INT) AND CAST(pan_no_individu AS INT)=CAST(@ppan_no_individu AS INT)
)
BEGIN

	Declare @Getdate Datetime
		SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),'FR'))
	IF EXISTS(
				  SELECT 1 FROM  @pFreqPanRecords T1
				  JOIN FRS.FREQUENTER_PAN_USI T2 ON T2.idfoyer=@pidfoyer AND T2.pan_no_individu=@ppan_no_individu-- AND T2.usi_code=T1.usi_code
			  )
	BEGIN
		SELECT 0 AS Success,'Some of the records already exists. Please use the update screen.' AS [Message],'' AS BusinessId
	END
	ELSE
	BEGIN
		INSERT INTO FRS.FREQUENTER_PAN_USI(idfoyer,pan_no_individu,usi_code,freq_no_ordre,freq_dt_update,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
		SELECT @pidfoyer,@ppan_no_individu,usi_code,freq_no_ordre,@pfreq_dt_update,@pGPSUser,@Getdate,@Getdate 
		FROM @pFreqPanRecords T1
		WHERE NOT EXISTS(SELECT * FROM FRS.FREQUENTER_PAN_USI T2 WHERE T2.idfoyer=@pidfoyer AND T2.pan_no_individu=@ppan_no_individu AND T2.usi_code=T1.usi_code)
		SELECT 1 AS Success,'Success' AS [Message],'' AS BusinessId

	END
END
ELSE
BEGIN
 SELECT 0 AS Success,'Invalid businessId.' AS [Message],'' AS BusinessId
END
END
GO