﻿/*##########################################################################    
-- Name    : DeleteCollectiveSequenceBatch.sql    
-- Date             : 2014-12-01    
-- Author           : GPSDeveloper    
-- Company          : Cognizant Technology Solution    
-- Purpose          : Inserts Data into CollectiveSequence Batch on click of preallocated
-- Usage   : From the UI once we click on the preallocated Button 
-- Impact   : Change on this procedure the preallocated gets impacted.    
-- Required grants  :     
-- Called by        : Preallocated      
-- Params Defintion :    
    @pcollectivesequencerecords -- CollectiveSequenceBatchRecords Type
    @pcountryid -- Guid of country
-- Sample Execution :    
 
##########################################################################    
-- ver  user   date        change     
-- 1.0  Kattamuri     2014-12-01   InitialVersion
##########################################################################*/

CREATE PROCEDURE [dbo].[DeleteCollectiveSequenceBatch] (
	@pcollectivesequencerecords dbo.CollectiveSequenceBatchRecords READONLY
	,@pcountryid UNIQUEIDENTIFIER
	)
AS
BEGIN
	DELETE cb
	FROM CollectiveSequenceBatch cb
	INNER JOIN @pcollectivesequencerecords pcs ON pcs.sequenceid = cb.CollectiveSequenceBatchId
		AND cb.Country_Id = Country_Id
END