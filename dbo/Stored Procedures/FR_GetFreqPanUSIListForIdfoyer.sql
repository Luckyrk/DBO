GO
CREATE PROCEDURE [dbo].[FR_GetFreqPanUSIListForIdfoyer]
@pidfoyer INT,
@ppan_no_individu INT,
@ppostalcode NVARCHAR(20)
AS
BEGIN
	SELECT P.freq_no_ordre,P.usi_code,U.usi_shortname,U.usi_longname,P.freq_dt_update,P.usi_code AS usicode_dummy,@ppostalcode AS PostCode
	FROM FRS.FREQUENTER_PAN_USI P
	JOIN FRS.USI U ON  U.usi_code=P.usi_code
	WHERE P.idfoyer=@pidfoyer AND P.pan_no_individu=@ppan_no_individu
	ORDER BY P.freq_no_ordre
END
GO