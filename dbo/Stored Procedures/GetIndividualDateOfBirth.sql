CREATE PROCEDURE [dbo].[GetIndividualDateOfBirth] @pIndividualId UNIQUEIDENTIFIER
AS      

BEGIN      

 SET NOCOUNT ON  

select CONVERT(VARCHAR(10),p.DateOfBirth,103) AS OldDateOfBirth  FROM Individual I

		INNER JOIN PersonalIdentification P ON P.PersonalIdentificationId = I.PersonalIdentificationId

		INNER JOIN IndividualSex INSS ON INSS.GUIDReference = I.Sex_Id

		INNER JOIN Candidate C ON C.GUIDReference = I.GUIDReference

		WHERE I.GUIDReference = @pIndividualId

END