/*##########################################################################    

-- Name                           : UpdateCollectiveSequenceBatchMaxValue.sql  

-- Date             : 2015-01-08    

-- Author           : Kattamuri Sunil Kumar    

-- Company          : Cognizant Technology Solution    

-- Purpose          : updates the max length of collective 

-- Usage   : From the UI once we click on the Individual Preallocated button   

-- Impact   : Change on this procedure Individual Preallocated gets impacted.    

-- Required grants  :     

-- Called by        : IndividualPrealloacted      

-- Params Defintion :    

    @pPreallocatedBatchcount -- number of individuals to preallocate

	,@pCountryId -- CountryId

-- Sample Execution :    

 exec UpdateCollectiveSequenceBatchMaxValue 1,'3558A18E-CCEB-CADC-CB8C-08CF81794A86'   

##########################################################################    

-- ver  user               date        change   

-- 1.0  Kattamuri     2014-05-20   initial    

-- 1.1  Kattamrui      2014-11-03   Revised as per Bug 31809

##########################################################################*/
CREATE PROCEDURE [dbo].[UpdateCollectiveSequenceBatchMaxValue] (
	@pPreallocatedBatchcount INT
	,@pCountryId UNIQUEIDENTIFIER
	)
AS
BEGIN
	SET XACT_ABORT ON

	BEGIN TRANSACTION

	BEGIN TRY
		IF NOT EXISTS (
				SELECT 1
				FROM CollectiveSequenceMaxValues
				WHERE Country_id = @pCountryId
				)
		BEGIN
			INSERT INTO CollectiveSequenceMaxValues
			SELECT NEWID()
				,(count(0)) + 1
				,CountryId
			FROM Collective
			GROUP BY CountryId
			HAVING Countryid = @pCountryId

			SELECT count(0)
			FROM Collective
			GROUP BY CountryId
			HAVING Countryid = @pCountryId
		END
		ELSE
		BEGIN
			DECLARE @maxValues INT = (
					SELECT TOP 1 MaxCollecitveSequencevalue
					FROM CollectiveSequenceMaxValues
					WHERE Country_id = @pCountryId
					)

			SELECT TOP 1 MaxCollecitveSequencevalue
			FROM CollectiveSequenceMaxValues
			WHERE Country_id = @pCountryId

			UPDATE CollectiveSequenceMaxValues
			SET MaxCollecitveSequencevalue = (@maxValues + @pPreallocatedBatchcount)
			WHERE Country_id = @pCountryId
		END
	END TRY

	BEGIN CATCH
		RAISERROR (
				'Error while updating the CollectiveSequenceMaxValues table'
				,16
				,1
				);
	END CATCH

	COMMIT TRANSACTION

	SET XACT_ABORT OFF
END