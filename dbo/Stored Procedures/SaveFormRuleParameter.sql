CREATE PROCEDURE [dbo].[SaveFormRuleParameter] @formRuleParameter [dbo].[FormRuleParameterDetails] READONLY
AS
BEGIN
	SET NOCOUNT ON;
	MERGE dbo.FormRuleParameters AS T
	USING @formRuleParameter AS S
		ON (
				T.FormRule_Id = S.FormRule_Id
				AND T.Demographic_Id = S.Demographic_Id
				AND T.AttributeName = S.AttributeName
				AND T.Property_Id = S.Property_Id
				)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				GUIDReference
				,FormRule_Id
				,Demographic_Id
				,AttributeName
				,Property_Id
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				)
			VALUES (
				NEWID()
				,S.FormRule_Id
				,S.Demographic_Id
				,s.AttributeName
				,S.Property_Id
				,GETDATE()
				,S.GPSUser
				,NULL
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET T.FormRule_Id = S.FormRule_Id
				,T.Demographic_Id = S.Demographic_Id
				,T.AttributeName = S.AttributeName
				,T.Property_Id = S.Property_Id
				,T.GPSUser = S.GPSUser
				,T.GPSUpdateTimestamp = getdate();
	
END
