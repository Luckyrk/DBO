
CREATE VIEW [dbo].[DevicePollingHistory]
AS
SELECT a.Device_Serial_Char
	,b.COMMS_DATE
	,CONCAT (
		Day(b.Comms_Date)
		,'/'
		,Month(b.Comms_Date)
		,'/'
		,Year(b.Comms_Date)
		) AS [Date]
	,CONCAT (
		DATEPART(HOUR, b.Comms_Date)
		,':'
		,DATEPART(MINUTE, b.Comms_Date)
		,':'
		,DATEPART(SECOND, b.Comms_Date)
		) AS [Time]
	,CASE 
		WHEN spl.Panelist_Id IS NOT NULL
			THEN (
					CASE 
						WHEN c.Sequence IS NOT NULL
							THEN cast(c.Sequence AS NVARCHAR)
						ELSE ind.IndividualId
						END
					)
		ELSE gsl.Location
		END AS Location
	,call_end_status AS STATUS
	,call_type AS Reason
	,Comments
	,si.GPSUser AS ModifiedBy
FROM [Isec].[PT0255] a
INNER JOIN [Isec].[PT0260] b ON a.Call_Number = b.Call_Number
INNER JOIN StockItem si ON a.Device_Serial_Char = si.SerialNumber
INNER JOIN StockLocation sl ON si.Location_Id = sl.GuidReference
LEFT JOIN StockPanelistLocation spl ON sl.GuidReference = spl.GuidReference
LEFT JOIN GenericStockLocation gsl ON sl.GuidReference = gsl.GuidReference
LEFT JOIN panelist pan ON spl.Panelist_Id = pan.GuidReference
LEFT JOIN collective c ON pan.panelmember_id = c.Guidreference
LEFT JOIN individual ind ON pan.panelmember_id = ind.Guidreference