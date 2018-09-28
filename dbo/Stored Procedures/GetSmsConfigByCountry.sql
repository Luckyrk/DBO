--exec GetSmsConfigByCountry 'GB','1760002-01','699395868143','GPSUser','Hi Hello How Are You'

CREATE PROCEDURE GetSmsConfigByCountry @pCountryCode NVARCHAR(10)

        ,@pAccount NVARCHAR(100)

        ,@pDestination NVARCHAR(100)

        ,@psender NVARCHAR(100)

        ,@pMessage NVARCHAR(MAX)

AS

BEGIN

DECLARE @GetDate DATETIME
SET @GetDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))

        DECLARE @countryId UNIQUEIDENTIFIER = (  

                       SELECT TOP 1 CountryId

                       FROM Country

                       WHERE CountryISO2A = @pCountryCode

                       )

        DECLARE @intEndFlag INT = (

                       SELECT max(queryParameterOrder)

                       FROM smsconfiguration

                       WHERE Country_Id = @countryId

                       )

        DECLARE @intFlag INT = 2

        DECLARE @dataVal NVARCHAR(max) = (

                       SELECT queryParametervalue

                       FROM smsconfiguration

                       WHERE queryParameterOrder = 1

                               AND Country_Id = @countryId

                       )

        DECLARE @tempDat NVARCHAR(MAX) = ''

        DECLARE @queryParameterName NVARCHAR(100) = ''

        DECLARE @encodeType NVARCHAR(10) = 'N'



        SET @encodeType = (

                       SELECT TOP 1 EncodeType

                       FROM smsconfiguration

                       WHERE Country_Id = @countryId

                       )



        WHILE (@intFlag <= @intEndFlag)

        BEGIN

               --IF EXISTS (

               --                SELECT 1

               --                FROM smsconfiguration

               --                WHERE [type] = 'individualId'

               --                       AND queryParameterOrder = @intFlag

               --                       AND Country_Id = @countryId

               --                )

               --BEGIN

               --        SET @tempDat = (

               --                       SELECT queryParameterName + '=' + @pAccount + '&'

               --                       FROM smsconfiguration

               --                       WHERE queryParameterOrder = @intFlag

               --                               AND Country_Id = @countryId

               --                       )

               --        SET @dataVal += @tempDat

               --        SET @intFlag = @intFlag + 1

               --        --print @intFlag 

               --        SET @tempDat = ''



               --        PRINT @queryParameterName

               --END

               --ELSE

			    IF EXISTS (

                               SELECT 1

                               FROM smsconfiguration

                               WHERE [type] = 'toNo'

                                      AND queryParameterOrder = @intFlag

                                      AND Country_Id = @countryId

                               )

               BEGIN
					  DECLARE @CountryISDCode NVARCHAR(10)='' 

					  SELECT @CountryISDCode = value 
					  FROM   keyappsetting ka 
						   INNER JOIN keyvalueappsetting kva 
								   ON ka.guidreference = kva.keyappsetting_id 
									  AND kva.country_id = @countryId
					  WHERE  keyname = 'isdcounttrycode' 

                       SET @tempDat = (

                                      SELECT queryParameterName + '=' + 
									  (
									  CASE when LEN(@CountryISDCode)>0 
										  then (IIF(left(IIF(LEFT((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)),1)='0',SUBSTRING((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)),2,LEN((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)))),(IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination))),len(@CountryISDCode))=@CountryISDCode,IIF(LEFT((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)),1)='0',SUBSTRING((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)),2,LEN((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)))),(IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination))),@CountryISDCode+IIF(LEFT((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)),1)='0',SUBSTRING((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)),2,LEN((IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination)))),(IIF(left(@pDestination,1)='+',substring(@pDestination,2,len(@pDestination)),@pDestination))))) 
										  else @pDestination 
											end
									  ) + '&'

                                      FROM smsconfiguration

                                      WHERE queryParameterOrder = @intFlag

                                              AND Country_Id = @countryId

                                      )

                       SET @dataVal += @tempDat

                       SET @intFlag = @intFlag + 1

                       --print @intFlag 

                       SET @tempDat = ''

               END

               ELSE IF EXISTS (

                               SELECT 1

                               FROM smsconfiguration

                               WHERE [type] = 'smsText'

                                      AND queryParameterOrder = @intFlag

                                      AND Country_Id = @countryId

                               )

               BEGIN

                       SET @tempDat = (

                                      SELECT queryParameterName + '=' + @pMessage + '&'

                                      FROM smsconfiguration

                                      WHERE queryParameterOrder = @intFlag

                                              AND Country_Id = @countryId

                                      )

                       SET @dataVal += @tempDat

                       SET @intFlag = @intFlag + 1

                       --print @intFlag 

                       SET @tempDat = ''

               END

               ELSE IF EXISTS (

                               SELECT 1

                               FROM smsconfiguration

                               WHERE [type] = 'fromNo'

                                      AND queryParameterOrder = @intFlag

                                      AND Country_Id = @countryId

                               )

               BEGIN

                       SET @tempDat = (

                                      SELECT queryParameterName + '=' + @psender + '&'

                                      FROM smsconfiguration

                                      WHERE queryParameterOrder = @intFlag

                                              AND Country_Id = @countryId

                                      )

                       SET @dataVal += @tempDat

                       SET @intFlag = @intFlag + 1

                       --print @intFlag 

                       SET @tempDat = ''

               END

               ELSE IF EXISTS (

                               SELECT 1

                               FROM smsconfiguration

                               WHERE [type] = 'senddate'

                                      AND queryParameterOrder = @intFlag

                                      AND Country_Id = @countryId

                               )

               BEGIN

                       SET @tempDat = (

                                      SELECT queryParameterName + '=' + convert(VARCHAR, @GetDate, 120) + '&'

                                      FROM smsconfiguration

                                      WHERE queryParameterOrder = @intFlag

                                              AND Country_Id = @countryId

                                      )

                       SET @dataVal += @tempDat

                       SET @intFlag = @intFlag + 1

                       --print @intFlag 

                       SET @tempDat = ''

               END

               ELSE

               BEGIN

                       SET @tempDat = (

                                      SELECT queryParameterName + '=' + queryParametervalue + '&'

                                      FROM smsconfiguration

                                      WHERE queryParameterOrder = @intFlag

                                              AND Country_Id = @countryId

                                      )

                       SET @dataVal += @tempDat

                       SET @intFlag = @intFlag + 1

                       --print @intFlag 

                       SET @tempDat = ''

               END

        END



        SET @dataVal = LEFT(@dataVal, LEN(@dataVal) - 1)



        SELECT 'SmsServiceURL' AS KeyName

               ,@dataVal AS Value

        

        UNION ALL

        

        SELECT 'EncodeType' AS KeyName

               ,@encodeType AS Value

        

        UNION ALL

        

        SELECT ka.KeyName

               ,(

                       CASE 

                               WHEN kv.Value IS NULL

                                      OR kv.Value = ''

                                      THEN ka.DefaultValue

                               ELSE kv.Value

                               END

                       ) AS Value

        FROM KeyAppSetting ka

        LEFT JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id

               AND kv.Country_Id = @countryId

        WHERE KA.KeyName IN (

                       'SmsProxyPassword'

                       ,'SmsProxyUserName'

                       ,'SmsProxy'

                       )

END
