--FUNCTION's SCRIPTS END
/*****************************************************************************************************************/
--VIEWS SCRIPTS START
CREATE VIEW GetStockItemHistoryInfo
AS
SELECT  CountryISO2A
       ,SerialNumber
       ,[Description]
       ,GPSUser
       ,CreationTimeStamp
       --,GPSUpdateTimestamp
       ,StockTypeCode
       ,FromState
       ,ToState
       ,NAME AS PanelName
       ,Sequence AS PanelNumber
       ,Location
       ,[Status]
       ,IndividualId
       ,ReasonCode
       ,ReasonDescription
FROM (
       SELECT i2.IndividualId
              ,SerialNumber
              ,SS.STName AS [Type]
              ,dbo.GetTranslationValue(SS.SDLabel_Id, 2057) AS [Status]
              ,CASE 
                     WHEN SS.GSLLocation IS NOT NULL
                           THEN CAST(SS.GSLLocation AS VARCHAR)
                     WHEN c.GUIDReference IS NOT NULL
                           THEN dbo.[GetGroupSequence](c.Sequence, c.CountryId)
                     WHEN i2.IndividualId IS NOT NULL
                           THEN CAST(i2.IndividualId AS VARCHAR)
                     END AS Location
              ,CountryISO2A
              ,[Description]
              ,Ss.GPSUser
              ,SICreationTimeStamp AS CreationTimeStamp
              ,StockTypeCode
              ,FromState
              ,ToState
              ,SIGPSUpdateTimestamp AS GPSUpdateTimestamp
              ,Pnl.NAME
              ,C.Sequence
              ,ReasonCode
              ,ReasonDescription
       FROM (
              SELECT SI.GUIDReference AS SIGUIDReference
                     ,ST.GUIDReference AS STGUIDReference
                     ,SSDH.Panelist_Id                                           -- change from SDH to SSDH
                     ,ST.CountryId AS STCountryId
                     ,GSL.Location AS GSLLocation
                     ,SI.GUIDReference AS SIId
                     ,SerialNumber
                     ,ST.NAME AS STName
                     ,SDH.CreationDate AS SICreationTimeStamp
                     ,SD.Label_Id AS SDLabel_Id
                     ,SDH.GPSUpdateTimestamp AS SIGPSUpdateTimestamp
                     ,SL.GUIDReference AS SLGUIDReference
                     ,C.CountryISO2A
                     ,SI.[Description]
                     ,SDH.GPSUser
                     ,ST.Code AS StockTypeCode
                     ,sdfrom.Code AS FromState
                     ,SD.Code AS ToState
                     ,rs.Code as ReasonCode
                     ,tt.Value as ReasonDescription
              FROM StockItem SI
              INNER JOIN StockStateDefinitionHistory SSDH ON SI.GUIDReference = SSDH.StockItem_Id
              INNER JOIN StateDefinitionHistory SDH ON SSDH.GUIDReference = SDH.GUIDReference
              left join ReasonForChangeState rs on rs.Id=sdh.ReasonForchangeState_Id
              left join TranslationTerm tt on tt.Translation_Id=rs.Description_Id and tt.CultureCode=2057
              INNER JOIN StateDefinition SD ON SDH.To_Id = SD.Id
              INNER JOIN StateDefinition sdfrom ON sdfrom.Id = sdh.From_Id
              INNER JOIN StockType ST ON ST.GUIDReference = SI.Type_Id
              INNER JOIN StockLocation SL ON SL.GUIDReference = SSDH.Location_Id
              INNER JOIN Country C ON C.CountryId = SI.Country_Id
              LEFT JOIN GenericStockLocation GSL ON GSL.GUIDReference = SL.GUIDReference
              LEFT JOIN StockPanelistLocation SPL ON SPL.GUIDReference = SL.GUIDReference
                     --WHERE SI.GuidReference='5A1EC2F0-08C8-4075-8D1E-C1542C1BE0A6'
              ) AS SS
       LEFT JOIN Panelist p ON p.GUIDReference = SS.Panelist_Id
       LEFT JOIN Panel Pnl ON Pnl.GUIDReference = p.Panel_Id
       LEFT JOIN (
              SELECT DISTINCT Group_Id
              FROM CollectiveMembership
              ) cm ON cm.Group_Id = p.PanelMember_Id
       LEFT JOIN Collective c ON c.GUIDReference = cm.Group_Id
       LEFT JOIN Individual i2 ON i2.GUIDReference = p.PanelMember_Id
       ) AS TEMPTABLE



