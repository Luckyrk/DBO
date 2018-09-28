CREATE VIEW [dbo].[PreAgreementView]
AS
SELECT
       IndividualId,
	   --StartDate,
	   ToolCode,
	   --ChangeToolDate,
       CAST([date_initialisation] AS datetime) AS [date_initialisation], 
       CAST([date_envoi_materiel] AS datetime) AS [date_envoi_materiel], 
	   --NextValue,
       [scp_cd_origine], 
       [reg_code], 
       [questionnaire_LAD], 
       [nb_prises_tel], 
       [abon_FT], 
       [conn_int], 
       [F_A_I], 
       [poss_box], 
       [equipement_clicker], 
       [poss_lign_fixe], 
       [dispo_ethernet]

       FROM 
       
(
	SELECT
		I.IndividualId,
		AV.CandidateID,
		AT.[Key],
		AV.Value,
		Y.ToolCode,
		Y.ChangeToolDate,
		Y.CreationDate As StartDate,
		Y.NextValue		  
	FROM Individual I
	JOIN AttributeValue AV on AV.CandidateID = I.GUIDReference
	JOIN Attribute AT on AT.GUIDReference = AV.DemographicId
	JOIN (
		select *, LEAD(ChangeToolDate) OVER(Partition BY PanelMember_Id ORDER BY ChangeToolDate ASC) NextValue
		 from
		(
		select  CH.[Date] As ChangeToolDate, CH.Panelist_Id, CM.Code AS ToolCode, p.PanelMember_Id, p.CreationDate
		 from
		 CollaborationMethodologyHistory CH 
		 join Panelist p on CH.Panelist_Id = p.Guidreference
		 join CollaborationMethodology CM on CM.GUIDReference = CH.NewCollaborationMethodology_Id
		 ) x
	 ) As Y on Y.PanelMember_Id = I.Guidreference
	   --and Y.CreationDate >= Y.ChangeToolDate
	   --and Y.CreationDate < ISNULL(Y.NextValue,'9999-12-31') 
	   and Y.NextValue is NULL
	WHERE 
	[AT].[Key] in ('date_initialisation', 'date_envoi_materiel', 'scp_cd_origine', 'reg_code', 'questionnaire_LAD', 'nb_prises_tel', 'abon_FT', 'conn_int', 'F_A_I', 'poss_box', 'equipement_clicker', 'poss_lign_fixe', 'dispo_ethernet')
) TBL
Pivot (Max(TBL.Value) for TBL.[Key] IN ([date_initialisation], [date_envoi_materiel], [scp_cd_origine], [reg_code], [questionnaire_LAD], [nb_prises_tel], [abon_FT], [conn_int], [F_A_I], [poss_box], [equipement_clicker], [poss_lign_fixe], [dispo_ethernet])) as PVT
