Create PROCEDURE [dbo].SetThresHold_AdminScreen (
	@minimum int 
	,@maximum int )
	As
	BEGIN
	if(@maximum<>0)
	begin
	update [master].[dbo].[SetThreshold] set ThresholdValue=@maximum where ThresholdName='Maximum'
	end
	if(@minimum<>0)
	begin
		update [master].[dbo].[SetThreshold] set ThresholdValue=@minimum where ThresholdName='Minimum'
		end

	END