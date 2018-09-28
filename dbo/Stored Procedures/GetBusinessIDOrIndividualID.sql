/*##########################################################################
       -- Name                           : GetBusinessIDOrIndividualID
       -- Date             : 2014-11-28
       -- Author           : GPS Developer
       -- Purpose          : To retrieve the Key or Value When supplied tranlsation id and culture code.
       -- Usage            : 
       -- Impact           : 
       -- Required grants  : 
       -- Called by        : SP

       -- PARAM Definitions
                                         @pBusinessId Varchar(10)
                                         ,@pIndividualGUID UniqueIdentifier 
       --Usage 
       Exec  GetBusinessIDOrIndividualID '000001-00', 'BC05A5FD-CB7E-C4F4-C1A6-08D11B004586','17D348D8-A08D-CE7A-CB8C-08CF81794A86'
       Exec  GetBusinessIDOrIndividualID '000001-00', '00000000-0000-0000-0000-000000000000','17D348D8-A08D-CE7A-CB8C-08CF81794A86'
       Exec  GetBusinessIDOrIndividualID null, 'BC05A5FD-CB7E-C4F4-C1A6-08D11B004586','17D348D8-A08D-CE7A-CB8C-08CF81794A86'
       Exec  GetBusinessIDOrIndividualID null, '00000000-0000-0000-0000-000000000000','17D348D8-A08D-CE7A-CB8C-08CF81794A86'
##########################################################################
       -- version  user                  date        change 
       -- 1.0  GPS Developer                    2014-11-28   Initial

########################################################################## */

CREATE PROCEDURE [dbo].[GetBusinessIDOrIndividualID] (
       @pBusinessId VARCHAR(60) 
       ,@pIndividualGUID UNIQUEIDENTIFIER 
	   ,@pCountryGUID UNIQUEIDENTIFIER
       )
AS
BEGIN
       SELECT Indv.GUIDReference AS IndividualID
              ,IndividualId AS BusinessID
       FROM Individual Indv
	   inner join Candidate Cand on cand.GUIDReference=indv.GUIDReference and Cand.Country_Id=@pCountryGUID
       WHERE (
                     indv.IndividualId = @pBusinessId
                     OR Indv.GUIDReference = @pIndividualGUID
                     )
END