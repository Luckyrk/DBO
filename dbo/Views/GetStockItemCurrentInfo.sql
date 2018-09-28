CREATE View [dbo].[GetStockItemCurrentInfo] 
As
Select *
FROM (
	SELECT ct.CountryISO2A
		,b.SerialNumber
		,st.NAME AS Description
		,c.GPSUser
		,b.CreationTimeStamp
		,c.CreationDate AS GPSUpdateTimestamp
		,st.Code
		,i.Code AS DeviceCode
		--,pa.NAME AS PanelName
		--,r.Sequence AS HH#
		,pan1.NAME AS PanelName
		,pan2.Sequence AS HH#
		,rs.Code AS ReasonCode
		,rs.Value
		,CASE 
			WHEN e.Location IS NOT NULL
				THEN e.Location
			ELSE IIF(pan2.sequence IS NOT NULL, cast(pan2.sequence AS NVARCHAR(50)), pan1.IndividualId)
			END AS Location		
		--,dbo.GetTranslationValue(i.Label_Id, 2057) AS [Status]
		,term.Value as [Status]
		,ROW_NUMBER() OVER (
			PARTITION BY CountryISO2A
			,SerialNumber ORDER BY c.CreationDate DESC
			) AS Row
	FROM StockItem b
	INNER JOIN StockType st ON st.GUIDReference = b.Type_Id
	INNER JOIN Country ct ON ct.CountryId = b.Country_Id
	INNER JOIN StateDefinition i ON i.Id = b.State_Id
	CROSS APPLY  [dbo].[GetTranslationValue_tbl](i.Label_Id, 2057) as term 
	LEFT JOIN [StockStateDefinitionHistory] a ON b.GUIDReference = a.StockItem_Id
	LEFT JOIN StateDefinitionHistory c ON c.GUIDReference = a.GUIDReference
	LEFT JOIN (
			SELECT rs1.Id , rs1.Code,  tt.Value
			FROM ReasonForChangeState rs1
			CROSS APPLY  [dbo].[GetTranslationValue_tbl](rs1.Description_Id, 2057) as tt 
		) as rs  ON  rs.Id = c.ReasonForchangeState_Id
			
	LEFT JOIN StockLocation d ON d.GUIDReference = a.Location_Id
	LEFT JOIN GenericStockLocation e ON e.GUIDReference = d.GUIDReference
	LEFT JOIN StockPanelistLocation f ON f.GUIDReference = d.GUIDReference

	--LEFT JOIN Panelist g ON g.GUIDReference = f.Panelist_Id
	--LEFT JOIN Collective h ON h.GUIDReference = g.PanelMember_Id
	--LEFT JOIN Individual ind ON ind.GUIDReference = g.PanelMember_Id
	LEFT JOIN (
				SELECT g.GUIDReference, ind.IndividualId, pa.Name  
				FROM Panelist g 
				JOIN Panel pa ON pa.GUIDReference = g.Panel_Id
				JOIN Individual ind ON ind.GUIDReference = g.PanelMember_Id 
			) as pan1 ON  pan1.GUIDReference = f.Panelist_Id  

	--LEFT JOIN Panelist p ON p.GUIDReference = b.Panelist_Id
	--LEFT JOIN Panel pa ON pa.GUIDReference = p.Panel_Id
	--LEFT JOIN Collective r ON r.GUIDReference = p.PanelMember_Id
	LEFT JOIN (
		SELECT p.GUIDReference,  r.sequence 
		from  Panelist p 
		JOIN Collective r ON r.GUIDReference = p.PanelMember_Id
		)as  pan2 ON pan2.GUIDReference = b.Panelist_Id 
	) x
WHERE Row = 1

GO