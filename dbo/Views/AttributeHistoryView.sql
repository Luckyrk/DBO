CREATE VIEW [dbo].[AttributeHistoryView]
AS
WITH T AS (
	SELECT AHD.CountryISO2A, AHD.BusinessId, AHD.BelongingType, AHD.BelongingCode, AHD.AttributeKey, AHD.AuditOperation, AHD.History_Value, 
		IIF(AHD.AuditDate = T.AuditDate AND T.AuditOperation <> 'I', AV.CreationTimeStamp, AHD.AuditDate) AS FromDate, 
		AHD.AuditDate AS ToDate, AHD.GPSUser AS UpdateBy, AHD.CDCROW_Id AS Row_Id,
		ROW_NUMBER() OVER(PARTITION BY AHD.GUIDReference, AHD.History_Value ORDER BY AHD.GUIDReference, AHD.AuditDate, AHD.CDCROW_Id) gn,
		ROW_NUMBER() OVER(ORDER BY AHD.GUIDReference, AHD.AuditDate, AHD.CDCROW_Id) as rn
	FROM AttributeHistoryDenorm AHD
	JOIN AttributeValue AV ON AV.GUIDReference = AHD.GUIDReference
	JOIN (
		SELECT GUIDReference, AuditDate, AuditOperation, ROW_NUMBER() OVER (PARTITION BY GUIDReference ORDER BY AuditDate) AS ROWNUMBER
		FROM AttributeHistoryDenorm
	) T ON T.GUIDReference = AHD.GUIDReference AND T.ROWNUMBER = 1
)

SELECT T.CountryISO2A, T.BusinessId, T.BelongingType, T.BelongingCode, T.AttributeKey, T.History_Value, 
		MIN(T.FromDate) AS FromDate, MAX(T.ToDate) AS ToDate, MIN(T.UpdateBy) AS UpdateBy, MIN(T.Row_Id) AS Row_Id
FROM T
GROUP BY T.gn - T.rn, T.CountryISO2A, T.BusinessId, T.BelongingType, T.BelongingCode, T.AttributeKey, T.History_Value