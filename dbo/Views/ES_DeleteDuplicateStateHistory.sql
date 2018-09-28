DECLARE @CountryID UNIQUEIDENTIFIER
DECLARE @CountryISO2A NVARCHAR(2)


SET @CountryISO2A = 'ES'
SELECT @CountryID = CountryID FROM Country WHERE CountryISO2A = @CountryISO2A
--PRINT @CountryID


if exists (	select * from tempdb.dbo.sysobjects o	where o.xtype in ('U') 	and o.id = object_id(N'tempdb..#t1')) 
	BEGIN  
		DROP TABLE #t1
	END


SELECT GUIDReference, Panelist_ID, From_ID, To_ID, DupCount 
	INTO #t1
	FROM
	(
		SELECT GUIDReference, sdh.Panelist_ID, sdh.From_Id, sdh.To_ID, ROW_NUMBER() OVER(Partition By sdh.Panelist_ID ORDER BY sdh.Panelist_ID DESC) AS DupCount
		FROM StateDefinitionHistory sdh
			INNER JOIN
			(
				select Panelist_ID, To_ID, Count(To_ID) AS CountToID
					FROM StateDefinitionHistory
					WHERE Panelist_ID IS NOT NULL
					AND Country_Id = @CountryID
					GROUP BY Panelist_ID, From_ID, To_ID
				Having Count(Panelist_ID) > 1 

			) c ON sdh.Panelist_Id = c.Panelist_Id and sdh.To_ID = c.To_Id
		WHERE sdh.Panelist_ID IS NOT NULL
		--where Panelist_Id='198f4c36-4bdb-4405-a014-fc3da84a1f1e' order by CreationDate desc
	) d
	ORDER BY Panelist_Id
--	WHERE dupCount = 2

DELETE FROM StateDefinitionHistory WHERE GUIDReference IN 
(
	SELECT d.GUIDReference FROM
	(
		SELECT sdh.GUIDReference, t.DupCount, t.Panelist_Id FROM StateDefinitionHistory sdh
			INNER JOIN #t1 t ON sdh.Panelist_Id = t.Panelist_Id
				AND sdh.To_Id = t.To_Id
				AND sdh.From_Id = t.From_Id
				AND sdh.GUIDReference = t.GUIDReference
	) d
	WHERE DupCount = 2
) 
