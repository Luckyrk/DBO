Create PROCEDURE [dbo].GetThreshold_AdminScreen (
	@pthreshold VARCHAR(10))
	As
	BEGIN
	Select ThresholdValue from [master].[dbo].[SetThreshold] where ThresholdName=@pthreshold
	END
		go