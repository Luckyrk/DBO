
CREATE VIEW [dbo].[IndividualIdSplitter]
AS
SELECT DISTINCT IndividualId
	,cast(PARSENAME(REPLACE(IndividualId, '-', '.'), 2) AS INT) AS GroupId
	,PARSENAME(REPLACE(IndividualId, '-', '.'), 1) AS IndividualNumber
	,cast(PARSENAME(REPLACE(IndividualId, '-', '.'), 1) AS INT) AS IndividualOrder
FROM dbo.individual