CREATE VIEW panelisttransactions 
AS 
  SELECT I.countryiso2a, 
         I.individualid, 
         Substring(I.individualid, 0, Charindex('-', I.individualid, 0)) AS 
            GroupId, 
         I.titledescription, 
         I.firstorderedname, 
         I.middleorderedname, 
         I.lastorderedname, 
         T.creationdate, 
         T.code, 
         T.description, 
         T.type, 
         Isnull(T.amount, 0) AS Amount, 
         T.gpsuser 
  FROM   [dbo].[fullindividualpid] I 
         LEFT JOIN (SELECT countryiso2a, 
                           individualid, 
                           creationdate, 
                           amount, 
                           code, 
                           description, 
                           'Incentive' AS [Type], 
                           gpsuser 
                    FROM   [dbo].[fullindividualincentives] 
                    UNION ALL 
                    SELECT countryiso2a, 
                           individualid, 
                           creationdate, 
                           -amount      AS Amount, 
                           code, 
                           description, 
                           'Redemption' AS [Type], 
                           gpsuser 
                    FROM   [dbo].[fullindividualredemptions]) AS T 
                ON I.individualid = T.individualid 
                   AND I.countryiso2a = T.countryiso2a 