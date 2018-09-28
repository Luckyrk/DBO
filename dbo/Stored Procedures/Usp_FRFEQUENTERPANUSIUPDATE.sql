GO
CREATE PROCEDURE [dbo].[Usp_FRFEQUENTERPANUSIUPDATE]
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
	DECLARE @Getdate DATETIME
		SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),'FR'))
	
	DELETE FROM FRS.FREQUENTER_PAN_USI WHERE idfoyer=@pidfoyer ANd pan_no_individu=@ppan_no_individu

	INSERT INTO FRS.FREQUENTER_PAN_USI (idfoyer,pan_no_individu,usi_code,freq_no_ordre,freq_dt_update,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
	SELECT @pidfoyer,@ppan_no_individu,usi_code,freq_no_ordre,@pfreq_dt_update,@pGPSUser,@Getdate,@Getdate FROM @pFreqPanRecords T1
	--WHERE NOT EXISTS(SELECT * FROM FRS.FREQUENTER_PAN_USI T2 WHERE T2.idfoyer=@pidfoyer AND T2.pan_no_individu=T1.pan_no_individu AND T2.usi_code=T1.usi_code)
	SELECT 1 AS Success,'Success' AS [Message],'' AS BusinessId

END
GO
