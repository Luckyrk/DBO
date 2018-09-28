CREATE PROCEDURE [dbo].[GetBusinessIDLength] (
        @pCountryGUID uniqueidentifier
     
       )
AS
BEGIN

select  top 1
CntryConfig.GroupBusinessIdDigits as  GroupBusinessId
 From CountryConfiguration CntryConfig
 Inner join Country Cntry on cntry.Configuration_Id=CntryConfig.Id
 where cntry.CountryId=@pCountryGUID
 End