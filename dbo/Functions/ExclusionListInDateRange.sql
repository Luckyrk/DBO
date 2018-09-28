GO
--SELECT * FROM ExclusionListInDateRange('2015-11-05 00:00:00.000','2015-11-07 00:00:00.000','1DD10EC5-6F4D-4588-B053-7857CFC0D040','3558A18E-CCEB-CADC-CB8C-08CF81794A86')
CREATE FUNCTION ExclusionListInDateRange(@fromDate DateTime,@ToDate DateTime,@individualId UniqueIdentifier,@CountryId UniqueIdentifier)
RETURNS @ExclusionItems TABLE (
   Exclusions nVARCHAR(MAX)
) 
AS
BEGIN
DECLARE @List NVARCHAR(MAX)
 SELECT @List = COALESCE(@List + ',', '') + CAST(Exclusion AS VARCHAR) FROM (

	SELECT E.Range_From,E.Range_To,dbo.GetTranslationValue(ET.Translation_Id,2057)  AS Exclusion,ET.Translation_Id 
	FROM ExclusionIndividual EI 
	JOIN Exclusion E ON E.GUIDReference=EI.Exclusion_Id
	JOIN ExclusionType ET ON ET.GUIDReference=E.[Type_Id] AND ET.Country_Id=@CountryId
	WHERE EI.Individual_Id=@IndividualId
	AND (((E.Range_From  BETWEEN @fromDate AND @ToDate) OR ( E.Range_To BETWEEN @fromDate AND @ToDate))
		OR ((@fromDate  BETWEEN E.Range_From AND E.Range_To)OR ( @ToDate BETWEEN E.Range_From AND E.Range_To)))
	UNION
	SELECT E.Range_From,E.Range_To,dbo.GetTranslationValue(ET.Translation_Id,2057)  AS Exclusion ,ET.Translation_Id
	FROM ExclusionPanelist EP
	JOIN Panelist P ON P.GUIDReference=EP.Panelist_Id
	JOIN Exclusion E ON E.GUIDReference=EP.Exclusion_Id
	JOIN ExclusionType ET ON ET.GUIDReference=E.[Type_Id] AND ET.Country_Id=@CountryId
	WHERE P.PanelMember_Id=@IndividualId
	AND (((E.Range_From  BETWEEN @fromDate AND @ToDate) OR ( E.Range_To BETWEEN @fromDate AND @ToDate))
		OR ((@fromDate  BETWEEN E.Range_From AND E.Range_To)OR ( @ToDate BETWEEN E.Range_From AND E.Range_To)))
) AS TT
     INSERT INTO @ExclusionItems (Exclusions)
	 SELECT ISNULL(@List,'')
   RETURN;
END;
