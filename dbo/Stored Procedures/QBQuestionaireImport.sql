CREATE PROCEDURE [dbo].[QBQuestionaireImport] (	
	@CountryISO2A NVARCHAR(100)
	,@ConnectionID NVARCHAR(100)
	,@FileName NVARCHAR(100)
	,@ProcessId UNIQUEIDENTIFIER 
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @CountryId AS UNIQUEIDENTIFIER,@Getdate DATETIME
		DECLARE @GPSUser AS NVARCHAR(100) = 'QBQuestionnaireImport'
		DECLARE @TotalCount AS INT  = 0;
		DECLARE @IntCount AS INT = 0;

		DECLARE @UID BIGINT = 0;
		DECLARE @QuestionnaireId INT=  0
		DECLARE @StateID AS UNIQUEIDENTIFIER ;
		DECLARE @Status AS INT =0;
		DECLARE @InvitationDate AS VARCHAR(100) ='' ;
		DECLARE @NoOfDays AS VARCHAR(5) ='0';
		DECLARE @AliasKey AS VARCHAR(50) = '';
		DECLARE @GroupContact AS VARCHAR(50) = '';

		DECLARE @ActiveStateID UNIQUEIDENTIFIER;
		DECLARE @InActiveStateID UNIQUEIDENTIFIER;
		DECLARE @DeleteStateID UNIQUEIDENTIFIER;
		DECLARE @TemporaryID UNIQUEIDENTIFIER;
		DECLARE @InvalidID  UNIQUEIDENTIFIER;

		DECLARE @PanelCode Varchar(10)
		DECLARE @ImportType Varchar(100) = 	'QBQuestionnaire'
		DECLARE @InsertedRows BIGINT = 0
		DECLARE @UpdatedRows BIGINT = 0
		

		SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryISO2A))--GetDate()
		SELECT @CountryId = CountryId FROM Country WHERE CountryISO2A = @CountryISO2A
		IF @CountryISO2A = 'FR'		
		BEGIN			
			DELETE FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging
			Where m_finvite = '0000-00-00'
		END 

		IF @CountryISO2A = 'ES'	
		BEGIN				
			DELETE FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging
			Where m_f0577 = '0000-00-00'

			UPDATE QB_DataImport.dbo.QB_Import_Questionnaire_Staging
			SET  Points =100
		END

		INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)
		SELECT 
			@FileName
			,@CountryISO2A
			,@PanelCode
			,@ImportType
			, [u_other_id]
			,0
			,'m_finvite is invalid : '+ m_finvite
			,@Getdate
			,@ProcessId
			FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging  
			Where  TRY_PARSE(m_finvite  AS DATE USING 'En-US') IS NULL
			AND CountryISO2A = 'FR'			

		UNION ALL 
		SELECT 
			@FileName
			,@CountryISO2A
			,@PanelCode
			,@ImportType
			, [u_other_id]
			,0
			,'m_f0577 is invalid : '+ m_f0577
			,@Getdate
			,@ProcessId
			FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging  
			Where  TRY_PARSE(m_f0577  AS DATE USING 'En-US') IS NULL
			AND CountryISO2A = 'ES'

		Union ALL
		SELECT 
			@FileName
			,@CountryISO2A
			,@PanelCode
			,@ImportType
			, [u_other_id] 
			,0
			,'Error: pstatus_date is invalid : ' + pstatus_date
			,@Getdate
			,@ProcessId
			FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging  
			Where  pstatus = 4 AND 
			TRY_PARSE(pstatus_date  AS DATE USING 'En-US') IS NULL;


		DELETE FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging
		Where  TRY_PARSE(m_finvite  AS DATE USING 'En-US') IS NULL;

		DELETE	FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging
		Where pstatus = 4 AND  TRY_PARSE(pstatus_date  AS DATE USING 'En-US') IS NULL;
		
		DELETE FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging
		where pstatus = 16

		/*
		DELETE FROM panel_export_ffp ;

		INSERT INTO panel_export_ffp ([uid], pseudonym, u_firstname, u_name, u_street, u_zip, u_city, u_phone, u_mobile, u_mobile2, u_email, 
						u_www, u_address, u_address2, u_address3, u_country, u_account, u_gender, u_other_id, u_passwd, pstatus, pinput, pcredit_points, pstatus_date,
						last_poll_date, n_poll, doub_stat, penter_date, panelist_code, md_status, md_update_date, md_num_updates, md_invite_date, md_num_invites,
						reg_code, invited_by, date_last_login, date_last_checkout, pci, site_id, last_mod_date, last_mod_user, dropout_date, mailstat, mail_validation_code,
						reg_ip, numinv, numrem, numcpl, numqut, numscn, numstr, numunl, numinc, numsam, numqul, relstr, relcpl, numinv1, numrem1, numcpl1, numqut1, numscn1,
						numstr1, numunl1, numsam1, numqul1, relstr1, relcpl1, numinv2, numrem2, numcpl2, numqut2, numscn2, numstr2, numunl2, numsam2, numqul2, relstr2, relcpl2,
						numinv3, numrem3, numcpl3, numqut3, numscn3, numstr3, numunl3, numsam3, numqul3, relstr3, relcpl3, modinv, modrem, modcpl, modqut, modscn, modstr, modunl,
						modsam, modqul, m_ftimeo, m_f0079, m_fcpl, m_fh01fn, m_fh02fn, m_fh03fn, m_fh04fn, m_fh05fn, m_fh06fn, m_fh07fn, m_fh08fn, m_fh09fn, m_fh10fn, m_fh01sn, 
						m_fh02sn, m_fh03sn, m_fh04sn, m_fh05sn, m_fh06sn, m_fh07sn, m_fh08sn, m_fh09sn, m_fh10sn, m_fh01sx, m_fh02sx, m_fh03sx, m_fh04sx, m_fh05sx, m_fh06sx, 
						m_fh07sx, m_fh08sx, m_fh09sx, m_fh10sx, m_fh01db, m_fh02db, m_fh03db, m_fh04db, m_fh05db, m_fh06db, m_fh07db, m_fh08db, m_fh09db, m_fh10db, m_fh01mb,
						m_fh02mb, m_fh03mb, m_fh04mb, m_fh05mb, m_fh06mb, m_fh07mb, m_fh08mb, m_fh09mb, m_fh10mb, m_fh01yb, m_fh02yb, m_fh03yb, m_fh04yb, m_fh05yb, m_fh06yb,
						m_fh07yb, m_fh08yb, m_fh09yb, m_fh10yb, m_fh01ag, m_fh02ag, m_fh03ag, m_fh04ag, m_fh05ag, m_fh06ag, m_fh07ag, m_fh08ag, m_fh09ag, m_fh10ag, m_f0005, 
						m_fsextd, m_f0831, m_f0826, m_fhnum, m_finvite, m_f0838, m_fweek2, m_fhwei, m_fh02hm, m_fh03hm, m_fh04hm, m_fh05hm, m_fh06hm, m_fh07hm, m_fh08hm, 
						m_fh09hm, m_fh19hm, m_fh02hc, m_fh03hc, m_fh04hc, m_fh05hc, m_fh06hc, m_fh07hc, m_fh08hc, m_fh09hc, m_fh19hc, m_fh02wk, m_fh03wk, m_fh04wk, m_fh05wk,
						m_fh06wk, m_fh07wk, m_fh08wk, m_fh09wk, m_fh19wk, m_fh02na, m_fh03na, m_fh04na, m_fh05na, m_fh06na, m_fh07na, m_fh08na, m_fh09na, m_fh10na, m_fh02hf,
						m_fh03hf, m_fh04hf, m_fh05hf, m_fh06hf, m_fh07hf, m_fh08hf, m_fh09hf, m_fh10hf, m_fh02hi, m_fh03hi, m_fh04hi, m_fh05hi, m_fh06hi, m_fh07hi, m_fh08hi, 
						m_fh09hi, m_fh10hi, m_fh02ws, m_fh03ws, m_fh04ws, m_fh05ws, m_fh06ws, m_fh07ws, m_fh08ws, m_fh09ws, m_fh10ws, m_fh02wp, m_fh03wp, m_fh04wp, m_fh05wp,
						m_fh06wp, m_fh07wp, m_fh08wp, m_fh09wp, m_fh10wp, m_fh02an, m_fh03an, m_fh04an, m_fh05an, m_fh06an, m_fh07an, m_fh08an, m_fh09an, m_fh10an, m_fh02mt, 
						m_fh03mt, m_fh04mt, m_fh05mt, m_fh06mt, m_fh07mt, m_fh08mt, m_fh09mt, m_fh10mt, m_fh02mc, m_fh03mc, m_fh04mc, m_fh05mc, m_fh06mc, m_fh07mc, m_fh08mc,
						m_fh09mc, m_fh10mc, m_fh02cm, m_fh03cm, m_fh04cm, m_fh05cm, m_fh06cm, m_fh07cm, m_fh08cm, m_fh09cm, m_fh10cm, m_fh02nm, m_fh03nm, m_fh04nm, m_fh05nm,
						m_fh06nm, m_fh07nm, m_fh08nm, m_fh09nm, m_fh10nm, m_fhmstm, m_fh02tm, m_fh03tm, m_fh04tm, m_fh05tm, m_fh06tm, m_fh07tm, m_fh08tm, m_fh09tm, m_fh10tm,
						m_fhmsbm, m_fh02bm, m_fh03bm, m_fh04bm, m_fh05bm, m_fh06bm, m_fh07bm, m_fh08bm, m_fh09bm, m_fh10bm, m_fhmsst, m_fh02st, m_fh03st, m_fh04st, m_fh05st,
						m_fh06st, m_fh07st, m_fh08st, m_fh09st, m_fh10st, m_fhmssc, m_fh02sc, m_fh03sc, m_fh04sc, m_fh05sc, m_fh06sc, m_fh07sc, m_fh08sc, m_fh09sc, m_fh10sc,
						m_fhmssb, m_fh02sb, m_fh03sb, m_fh04sb, m_fh05sb, m_fh06sb, m_fh07sb, m_fh08sb, m_fh09sb, m_fh10sb, m_fhsd, m_msfn, m_mssn, m_fhnih, md_0001, md_0003,
						m_pres1, m_pres2, m_pres3, m_pres4, m_pres5, m_pres6, m_pres7, m_pres8, m_pres9, m_pres10, m_presd1, m_presd2, m_presd3, m_presd4, m_presd5, m_presd6,
						m_presd7, m_presd8, m_presd9, m_presd10, m_fhmsitai, m_fh01itai, m_fh02itai, m_fh03itai, m_fh04itai, m_fh05itai, m_fh06itai, m_fh07itai, m_fh08itai,
						m_fh09itai, m_fh10itai, m_fhmsipds, m_fh01ipds, m_fh02ipds, m_fh03ipds, m_fh04ipds, m_fh05ipds, m_fh06ipds, m_fh07ipds, m_fh08ipds, m_fh09ipds,
						m_fh10ipds, m_fhmsnoind, m_fh01noind, m_fh02noind, m_fh03noind, m_fh04noind, m_fh05noind, m_fh06noind, m_fh07noind, m_fh08noind, m_fh09noind,
						m_fh10noind, m_semaine, m_panel, m_nfpresent, m_quitterfoyer, m_newfoyer, m_sel_ms, m_sel_01, m_sel_02, m_sel_03, m_sel_04, m_sel_05, m_sel_06,
						m_sel_07, m_sel_08, m_sel_09, m_sel_10, m_sport_ms, m_sport_01, m_sport_02, m_sport_03, m_sport_04, m_sport_05, m_sport_06, m_sport_07, m_sport_08,
						m_sport_09, m_sport_10, m_cafe_ms, m_cafe_01, m_cafe_02, m_cafe_03, m_cafe_04, m_cafe_05, m_cafe_06, m_cafe_07, m_cafe_08, m_cafe_09, m_cafe_10,
						m_the_ms, m_the_01, m_the_02, m_the_03, m_the_04, m_the_05, m_the_06, m_the_07, m_the_08, m_the_09, m_the_10, m_chocolat_ms, m_chocolat_01,
						m_chocolat_02, m_chocolat_03, m_chocolat_04, m_chocolat_05, m_chocolat_06, m_chocolat_07, m_chocolat_08, m_chocolat_09, m_chocolat_10,
						m_boissonfroide_ms, m_boissonfroide_01, m_boissonfroide_02, m_boissonfroide_03, m_boissonfroide_04, m_boissonfroide_05, m_boissonfroide_06,
						m_boissonfroide_07, m_boissonfroide_08, m_boissonfroide_09, m_boissonfroide_10, m_pain_ms, m_pain_01, m_pain_02, m_pain_03, m_pain_04,
						m_pain_05, m_pain_06, m_pain_07, m_pain_08, m_pain_09, m_pain_10, m_freqpain_ms, m_freqpain_01, m_freqpain_02, m_freqpain_03, m_freqpain_04,
						m_freqpain_05, m_freqpain_06, m_freqpain_07, m_freqpain_08, m_freqpain_09, m_freqpain_10, m_eaurobinet_ms, m_eaurobinet_01, m_eaurobinet_02,
						m_eaurobinet_03, m_eaurobinet_04, m_eaurobinet_05, m_eaurobinet_06, m_eaurobinet_07, m_eaurobinet_08, m_eaurobinet_09, m_eaurobinet_10,
						m_eaubouteille_ms, m_eaubouteille_01, m_eaubouteille_02, m_eaubouteille_03, m_eaubouteille_04, m_eaubouteille_05, m_eaubouteille_06,
						m_eaubouteille_07, m_eaubouteille_08, m_eaubouteille_09, m_eaubouteille_10, m_robot, m_mgcuisine, m_sante_ms, m_sante_01, m_sante_02,
						m_sante_03, m_sante_04, m_sante_05, m_sante_06, m_sante_07, m_sante_08, m_sante_09, m_sante_10, m_boissonconso_ms, m_boissonconso_01, 
						m_boissonconso_02, m_boissonconso_03, m_boissonconso_04, m_boissonconso_05, m_boissonconso_06, m_boissonconso_07, m_boissonconso_08,
						m_boissonconso_09, m_boissonconso_10, m_datecomplete_demo, m_pcode_consoclicker)
					(SELECT [uid], pseudonym, u_firstname, u_name, u_street, u_zip, u_city, u_phone, u_mobile, u_mobile2, u_email, 
									u_www, u_address, u_address2, u_address3, u_country, u_account, u_gender, u_other_id, u_passwd, pstatus, pinput, pcredit_points, pstatus_date,
									last_poll_date, n_poll, doub_stat, penter_date, panelist_code, md_status, md_update_date, md_num_updates, md_invite_date, md_num_invites,
									reg_code, invited_by, date_last_login, date_last_checkout, pci, site_id, last_mod_date, last_mod_user, dropout_date, mailstat, mail_validation_code,
									reg_ip, numinv, numrem, numcpl, numqut, numscn, numstr, numunl, numinc, numsam, numqul, relstr, relcpl, numinv1, numrem1, numcpl1, numqut1, numscn1,
									numstr1, numunl1, numsam1, numqul1, relstr1, relcpl1, numinv2, numrem2, numcpl2, numqut2, numscn2, numstr2, numunl2, numsam2, numqul2, relstr2, relcpl2,
									numinv3, numrem3, numcpl3, numqut3, numscn3, numstr3, numunl3, numsam3, numqul3, relstr3, relcpl3, modinv, modrem, modcpl, modqut, modscn, modstr, modunl,
									modsam, modqul, m_ftimeo, m_f0079, m_fcpl, m_fh01fn, m_fh02fn, m_fh03fn, m_fh04fn, m_fh05fn, m_fh06fn, m_fh07fn, m_fh08fn, m_fh09fn, m_fh10fn, m_fh01sn, 
									m_fh02sn, m_fh03sn, m_fh04sn, m_fh05sn, m_fh06sn, m_fh07sn, m_fh08sn, m_fh09sn, m_fh10sn, m_fh01sx, m_fh02sx, m_fh03sx, m_fh04sx, m_fh05sx, m_fh06sx, 
									m_fh07sx, m_fh08sx, m_fh09sx, m_fh10sx, m_fh01db, m_fh02db, m_fh03db, m_fh04db, m_fh05db, m_fh06db, m_fh07db, m_fh08db, m_fh09db, m_fh10db, m_fh01mb,
									m_fh02mb, m_fh03mb, m_fh04mb, m_fh05mb, m_fh06mb, m_fh07mb, m_fh08mb, m_fh09mb, m_fh10mb, m_fh01yb, m_fh02yb, m_fh03yb, m_fh04yb, m_fh05yb, m_fh06yb,
									m_fh07yb, m_fh08yb, m_fh09yb, m_fh10yb, m_fh01ag, m_fh02ag, m_fh03ag, m_fh04ag, m_fh05ag, m_fh06ag, m_fh07ag, m_fh08ag, m_fh09ag, m_fh10ag, m_f0005, 
									m_fsextd, m_f0831, m_f0826, m_fhnum, m_finvite, m_f0838, m_fweek2, m_fhwei, m_fh02hm, m_fh03hm, m_fh04hm, m_fh05hm, m_fh06hm, m_fh07hm, m_fh08hm, 
									m_fh09hm, m_fh19hm, m_fh02hc, m_fh03hc, m_fh04hc, m_fh05hc, m_fh06hc, m_fh07hc, m_fh08hc, m_fh09hc, m_fh19hc, m_fh02wk, m_fh03wk, m_fh04wk, m_fh05wk,
									m_fh06wk, m_fh07wk, m_fh08wk, m_fh09wk, m_fh19wk, m_fh02na, m_fh03na, m_fh04na, m_fh05na, m_fh06na, m_fh07na, m_fh08na, m_fh09na, m_fh10na, m_fh02hf,
									m_fh03hf, m_fh04hf, m_fh05hf, m_fh06hf, m_fh07hf, m_fh08hf, m_fh09hf, m_fh10hf, m_fh02hi, m_fh03hi, m_fh04hi, m_fh05hi, m_fh06hi, m_fh07hi, m_fh08hi, 
									m_fh09hi, m_fh10hi, m_fh02ws, m_fh03ws, m_fh04ws, m_fh05ws, m_fh06ws, m_fh07ws, m_fh08ws, m_fh09ws, m_fh10ws, m_fh02wp, m_fh03wp, m_fh04wp, m_fh05wp,
									m_fh06wp, m_fh07wp, m_fh08wp, m_fh09wp, m_fh10wp, m_fh02an, m_fh03an, m_fh04an, m_fh05an, m_fh06an, m_fh07an, m_fh08an, m_fh09an, m_fh10an, m_fh02mt, 
									m_fh03mt, m_fh04mt, m_fh05mt, m_fh06mt, m_fh07mt, m_fh08mt, m_fh09mt, m_fh10mt, m_fh02mc, m_fh03mc, m_fh04mc, m_fh05mc, m_fh06mc, m_fh07mc, m_fh08mc,
									m_fh09mc, m_fh10mc, m_fh02cm, m_fh03cm, m_fh04cm, m_fh05cm, m_fh06cm, m_fh07cm, m_fh08cm, m_fh09cm, m_fh10cm, m_fh02nm, m_fh03nm, m_fh04nm, m_fh05nm,
									m_fh06nm, m_fh07nm, m_fh08nm, m_fh09nm, m_fh10nm, m_fhmstm, m_fh02tm, m_fh03tm, m_fh04tm, m_fh05tm, m_fh06tm, m_fh07tm, m_fh08tm, m_fh09tm, m_fh10tm,
									m_fhmsbm, m_fh02bm, m_fh03bm, m_fh04bm, m_fh05bm, m_fh06bm, m_fh07bm, m_fh08bm, m_fh09bm, m_fh10bm, m_fhmsst, m_fh02st, m_fh03st, m_fh04st, m_fh05st,
									m_fh06st, m_fh07st, m_fh08st, m_fh09st, m_fh10st, m_fhmssc, m_fh02sc, m_fh03sc, m_fh04sc, m_fh05sc, m_fh06sc, m_fh07sc, m_fh08sc, m_fh09sc, m_fh10sc,
									m_fhmssb, m_fh02sb, m_fh03sb, m_fh04sb, m_fh05sb, m_fh06sb, m_fh07sb, m_fh08sb, m_fh09sb, m_fh10sb, m_fhsd, m_msfn, m_mssn, m_fhnih, md_0001, md_0003,
									m_pres1, m_pres2, m_pres3, m_pres4, m_pres5, m_pres6, m_pres7, m_pres8, m_pres9, m_pres10, m_presd1, m_presd2, m_presd3, m_presd4, m_presd5, m_presd6,
									m_presd7, m_presd8, m_presd9, m_presd10, m_fhmsitai, m_fh01itai, m_fh02itai, m_fh03itai, m_fh04itai, m_fh05itai, m_fh06itai, m_fh07itai, m_fh08itai,
									m_fh09itai, m_fh10itai, m_fhmsipds, m_fh01ipds, m_fh02ipds, m_fh03ipds, m_fh04ipds, m_fh05ipds, m_fh06ipds, m_fh07ipds, m_fh08ipds, m_fh09ipds,
									m_fh10ipds, m_fhmsnoind, m_fh01noind, m_fh02noind, m_fh03noind, m_fh04noind, m_fh05noind, m_fh06noind, m_fh07noind, m_fh08noind, m_fh09noind,
									m_fh10noind, m_semaine, m_panel, m_nfpresent, m_quitterfoyer, m_newfoyer, m_sel_ms, m_sel_01, m_sel_02, m_sel_03, m_sel_04, m_sel_05, m_sel_06,
									m_sel_07, m_sel_08, m_sel_09, m_sel_10, m_sport_ms, m_sport_01, m_sport_02, m_sport_03, m_sport_04, m_sport_05, m_sport_06, m_sport_07, m_sport_08,
									m_sport_09, m_sport_10, m_cafe_ms, m_cafe_01, m_cafe_02, m_cafe_03, m_cafe_04, m_cafe_05, m_cafe_06, m_cafe_07, m_cafe_08, m_cafe_09, m_cafe_10,
									m_the_ms, m_the_01, m_the_02, m_the_03, m_the_04, m_the_05, m_the_06, m_the_07, m_the_08, m_the_09, m_the_10, m_chocolat_ms, m_chocolat_01,
									m_chocolat_02, m_chocolat_03, m_chocolat_04, m_chocolat_05, m_chocolat_06, m_chocolat_07, m_chocolat_08, m_chocolat_09, m_chocolat_10,
									m_boissonfroide_ms, m_boissonfroide_01, m_boissonfroide_02, m_boissonfroide_03, m_boissonfroide_04, m_boissonfroide_05, m_boissonfroide_06,
									m_boissonfroide_07, m_boissonfroide_08, m_boissonfroide_09, m_boissonfroide_10, m_pain_ms, m_pain_01, m_pain_02, m_pain_03, m_pain_04,
									m_pain_05, m_pain_06, m_pain_07, m_pain_08, m_pain_09, m_pain_10, m_freqpain_ms, m_freqpain_01, m_freqpain_02, m_freqpain_03, m_freqpain_04,
									m_freqpain_05, m_freqpain_06, m_freqpain_07, m_freqpain_08, m_freqpain_09, m_freqpain_10, m_eaurobinet_ms, m_eaurobinet_01, m_eaurobinet_02,
									m_eaurobinet_03, m_eaurobinet_04, m_eaurobinet_05, m_eaurobinet_06, m_eaurobinet_07, m_eaurobinet_08, m_eaurobinet_09, m_eaurobinet_10,
									m_eaubouteille_ms, m_eaubouteille_01, m_eaubouteille_02, m_eaubouteille_03, m_eaubouteille_04, m_eaubouteille_05, m_eaubouteille_06,
									m_eaubouteille_07, m_eaubouteille_08, m_eaubouteille_09, m_eaubouteille_10, m_robot, m_mgcuisine, m_sante_ms, m_sante_01, m_sante_02,
									m_sante_03, m_sante_04, m_sante_05, m_sante_06, m_sante_07, m_sante_08, m_sante_09, m_sante_10, m_boissonconso_ms, m_boissonconso_01, 
									m_boissonconso_02, m_boissonconso_03, m_boissonconso_04, m_boissonconso_05, m_boissonconso_06, m_boissonconso_07, m_boissonconso_08,
									m_boissonconso_09, m_boissonconso_10, m_datecomplete_demo, m_pcode_consoclicker FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging) 
								*/
		UPDATE QB_DataImport.dbo.QB_Import_Questionnaire_Staging SET IsProcessed = 0 

		DECLARE @QuestionnaireType VARCHAR(200)='Online'
		DECLARE @CollaborationType VARCHAR(200)='Online'
		DECLARE @Client NVARCHAR(200) = 'FFP'
		DECLARE @SurveyName NVARCHAR(200) 
		DECLARE @Points VARCHAR(10)
		select top 1 @SurveyName = SurveyName , @Points = Points
		 from QB_DataImport.dbo.QB_Import_Questionnaire_Staging
		
		
		-- Questionnaire
		IF NOT EXISTS(SELECT Questionnaire_ID FROM  Questionnaire WHERE (SurveyName = @SurveyName OR @SurveyName IS NULL ) 
			and QuestionnaireType=@QuestionnaireType and CollaborationType=@CollaborationType )
		BEGIN
			INSERT INTO Questionnaire (SurveyName,ClientName,ClientTeamPerson,QuestionnaireType,Department,Comment,CreationTimestamp,GPSUPdateTimestamp,GPSUser,CollaborationType, Points)
			VALUES (ISNULL(@SurveyName,'FFP'),@Client,@Client,@QuestionnaireType,NULL,@Client,@Getdate,@Getdate,@GPSUser,@CollaborationType,@Points )
		END

		SELECT @QuestionnaireId = ISNULL(Questionnaire_ID,1) FROM  Questionnaire 
		WHERE SurveyName = @SurveyName 
		--and QuestionnaireType=@QuestionnaireType
		--and CollaborationType=@CollaborationType

		
		DECLARE   @AliasMapping as TABLE
		(
			u_other_id VARCHAR(100) COLLATE DATABASE_DEFAULT	,			
			Groupid VARCHAR(100) COLLATE DATABASE_DEFAULT	,  -- uniqueidentifier
			MainContactId VARCHAR(100) COLLATE DATABASE_DEFAULT	,
			panelistId VARCHAR(100) COLLATE DATABASE_DEFAULT
			,GroupSequence Varchar(100) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO @AliasMapping (u_other_id) 
		SELECT DISTINCT U_OTHER_ID FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging

		UPDATE A  SET GrouPid = N.Candidate_id, MainContactId = C.GroupContact_Id
				,GroupSequence = C.Sequence
				FROM [QB_DataImport].dbo.QB_Import_Questionnaire_Staging Q 
				INNER JOIN @AliasMapping A ON A.u_other_id=Q.U_OTHER_ID
				INNER JOIN namedalias N ON N.[Key] = Q.u_other_id 
				INNER JOIN Collective C ON C.Guidreference = N.Candidate_id

				update  A set A.panelistId=P.Guidreference 
				from  @AliasMapping A
				join panelist P  ON P.PanelMember_Id in (A.Groupid, A.MaincontactId)

				UPdate A		
				SET A.panelistId = V.Panelist_Id				
				from  @AliasMapping A
				Join 
				(
					select DRA.Panelist_Id, DRA.Candidate_Id as PanelMember_Id, CM.Group_Id, DRA.Country_Id
					FROM DynamicRoleAssignment DRA
					Join DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id   and DRA.Country_Id = DR.Country_Id
					Join Translation T ON T.TranslationId = DR.Translation_Id and T.KeyName = 'MainContactRoleName'
					JOIN Individual I ON I.GUIDReference = DRA.Candidate_Id  and DRA.Country_Id = I.CountryId
					Join CollectiveMembership CM ON CM.Individual_Id =  I.GUIDReference
					Where DRA.Panelist_Id is NOT NULL 
				) V ON A.Groupid = V.Group_Id and V.Country_Id = @CountryId 
				where A.panelistId is null

		UPDATE QB_DataImport.dbo.QB_Import_Questionnaire_Staging SET IsProcessed = 3 WHERE u_other_id IS NULL 

		UPDATE QB_DataImport.dbo.QB_Import_Questionnaire_Staging SET IsProcessed = 4 WHERE isnull(pstatus,'') = '' 

		UPDATE QB_DataImport.dbo.QB_Import_Questionnaire_Staging SET IsProcessed = 5 WHERE u_other_id  IN (SELECT u_other_id from @AliasMapping WHERE GroupId IS NULL)

		UPDATE QB_DataImport.dbo.QB_Import_Questionnaire_Staging SET IsProcessed = 6 WHERE LTRIM(RTRIM(pstatus)) NOT IN ('2','4','8','1', '6')

		IF EXISTS (SELECT 1 FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging WHERE u_other_id IS NULL )
		BEGIN

		INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)
			SELECT 
			@FileName
			,@CountryISO2A
			,@PanelCode
			,@ImportType
			,'Alias'
			,0
			,'Alias does not exist for '+ [u_other_id]
			,@Getdate
			,@ProcessId
			FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging WHERE IsProcessed = 3

		END

		IF EXISTS (SELECT 1 FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging WHERE IsProcessed IN ( 4,6)  )
		BEGIN
			INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)
			SELECT 
			@FileName
			,@CountryISO2A
			,@PanelCode
			,@ImportType
			,[u_other_id]
			,0
			,'Invalid Status :'+pstatus
			,@Getdate
			,@ProcessId
			FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging WHERE IsProcessed IN (4,6)
				 
		END
 
		IF EXISTS (select 1 from @AliasMapping WHERE GroupId IS NULL)
		BEGIN
			
			INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)
			SELECT 
			@FileName
			,@CountryISO2A
			,@PanelCode
			,@ImportType
			,[u_other_id]
			,0
			,'Alias does not Exist in GPS'
			,@Getdate
			,@ProcessId
			FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging WHERE IsProcessed = 5 
		END

		
		SELECT @TotalCount  = COUNT(0) FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging WHERE IsProcessed = 0;

		-- pstatus:	status of diary collaboration (2=active, 4=inactive, 6=invalid)

		SELECT @ActiveStateID = Id FROM StateDefinition WHERE Code = 'Active' AND Country_Id = @CountryId;
		SELECT @InActiveStateID = Id FROM StateDefinition WHERE Code = 'InActive' AND Country_Id = @CountryId;
		SELECT @DeleteStateID = Id FROM StateDefinition WHERE Code = 'Delete' AND Country_Id = @CountryId;
		SELECT @TemporaryID = Id FROM StateDefinition WHERE Code = 'Temporary' AND Country_Id = @CountryId;
		SELECT @InvalidID = Id FROM StateDefinition WHERE Code = 'Invalid' AND Country_Id = @CountryId;

		 DECLARE @INSERTTABLE as TABLE
		(
			[UID] BIGINT
			,[u_other_id] BIGINT	
			,CountryID UNIQUEIDENTIFIER ,
			QuestionnaireID BIGINT,
			InvitationDate VARCHAR(100),
			StateID UNIQUEIDENTIFIER,                            
			CompletetionDate VARCHAR(100),	
			NumberofDays varchar(50),
			GroupContactId UNIQUEIDENTIFIER
			,IsProcess int
			, panelistId VARCHAR(100)
			,panelist_code nvarchar(200)
			, QuestionnaireDate varchar(50)
		)

		INSERT INTO @INSERTTABLE ([UID],u_other_id,CountryID,QuestionnaireID,InvitationDate,StateID,CompletetionDate,
		NumberofDays,GroupContactId,IsProcess,panelistId,panelist_code ,QuestionnaireDate)
		
		SELECT QS.[UID],QS.u_other_id,@CountryId,@QuestionnaireId, 
		CASE WHEN @CountryISO2A = 'ES' THEN 
			IIF(RTRIM(LTRIM(ISNULL(m_f0577,'0000-00-00'))) = '0000-00-00', NULL ,m_f0577)
		WHEN @CountryISO2A = 'FR' THEN 
			IIF(RTRIM(LTRIM(ISNULL(m_finvite,'0000-00-00'))) = '0000-00-00', NULL ,m_finvite)
		END
		,(CASE WHEN QS.pstatus = '2' THEN @ActiveStateID 
		WHEN QS.pstatus = '4' THEN @InActiveStateID  
		WHEN QS.pstatus = '8' THEN @DeleteStateID 
		WHEN QS.pstatus='1' THEN @TemporaryID 
		WHEN QS.pstatus='6' THEN @InvalidID 
		END) as statId

		,(CASE WHEN QS.pstatus = '4'  THEN QS.pstatus_date ELSE NULL END) as CompletetionDate

		,CASE WHEN m_f0831 = '0' THEN NULL ELSE m_f0831 END ,A.MainContactId, 0 ,A.panelistId
		,panelist_code , 
		IIF(RTRIM(LTRIM(ISNULL(m_f0826,'0000-00-00'))) = '0000-00-00', NULL ,m_f0826) as QuestionnaireDate
		FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging QS 
		INNER JOIN @AliasMapping A ON A.u_other_id = QS.u_other_id  
		WHERE IsProcessed = 0;


		--DELETE TMP FROM @INSERTTABLE TMP 
		--INNER JOIN @AliasMapping A ON A.u_other_id = TMP.u_other_id
		--INNER JOIN QuestionnaireTransaction QC ON QC.GroupContactId = A.MainContactId and QC.StateID = TMP.StateID
		-- 


		UPDATE @INSERTTABLE SET InvitationDate = convert (datetime , InvitationDate,120) 
		UPDATE @INSERTTABLE SET CompletetionDate = convert (datetime , CompletetionDate,120) 

		UPDATE @INSERTTABLE SET IsProcess = 3  where ISDATE(InvitationDate)  = 0
		
		UPDATE TMP SET IsProcessed = 3 FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging TMP 
		INNER JOIN @INSERTTABLE IT ON  IT.u_other_id = tmp.u_other_id  WHERE IsProcess = 3


		IF EXISTS (select 1 from @INSERTTABLE WHERE IsProcess = 3)
		BEGIN
			INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)
			SELECT 
			@FileName
			,@CountryISO2A
			,@PanelCode
			,@ImportType
			,[u_other_id]
			,0
			,'InvitationDate is not Valid - ' + ISNULL(InvitationDate,'0000-00-00')
			,@Getdate
			,@ProcessId
			FROM @INSERTTABLE WHERE IsProcess = 3

		END
		
		-- QuestionnaireTransaction
		--INSERT INTO QuestionnaireTransaction ([UID],PanelistID,CountryID,QuestionnaireID,InvitationDate,StateID,GPSUser,GPSUPdateTimestamp
		--,CompletionDate,NumberofDays,GroupContactId, panelist_code , QuestionnaireDate)
		--SELECT [UID],panelistId,@CountryId,QuestionnaireID, InvitationDate,StateID,@GPSUser,@Getdate,CompletetionDate,NumberofDays,GroupContactId
		--,panelist_code , QuestionnaireDate
		--FROM @INSERTTABLE
		--WHERE IsProcess =0
		--and [UID] Not in (
		--					select [UID] from QuestionnaireTransaction where CountryID = @CountryId
		--				)
		
		IF @CountryISO2A <> 'ES'
		BEGIN 
			INSERT INTO QuestionnaireTransaction ([UID],PanelistID,CountryID,QuestionnaireID,InvitationDate,StateID,GPSUser,GPSUPdateTimestamp
			,CompletionDate,NumberofDays,GroupContactId, panelist_code , QuestionnaireDate)
			SELECT [UID],A.panelistId,@CountryId,QuestionnaireID, InvitationDate,StateID,@GPSUser,@Getdate,CompletetionDate,NumberofDays,GroupContactId
			,panelist_code , QuestionnaireDate
			FROM @INSERTTABLE TMP
			INNER JOIN @AliasMapping A ON A.u_other_id = TMP.u_other_id
			WHERE IsProcess = 0
			and Not exists (
								select 1 from QuestionnaireTransaction
								 where  A.MainContactId  = GroupContactId
								 AND InvitationDate = TMP.InvitationDate
								 AND CountryID = @CountryId
							)

		
			SET @InsertedRows = @@ROWCOUNT
		END
				
	-- UPDATE TMP SET IsProcessed = 1 FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging TMP INNER JOIN @INSERTTABLE IT ON IT.[UID]= TMP.[UID] WHERE IsProcess = 0
		UPDATE QS SET IsProcessed = 11 FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging QS 
		INNER JOIN @INSERTTABLE IT ON IT.[UID]= QS.[UID] AND
		(CASE WHEN QS.pstatus = '2' THEN @ActiveStateID 
		WHEN QS.pstatus = '4' THEN @InActiveStateID  
		WHEN QS.pstatus = '8' THEN @DeleteStateID 
		WHEN QS.pstatus='1' THEN @TemporaryID 
		WHEN QS.pstatus='6' THEN @InvalidID 
		END)  <> IT.StateID 
		WHERE IsProcess = 0
		
		 /*
		UPDATE ORG 
		SET  StateID = (CASE WHEN QS.pstatus = '2' THEN @ActiveStateID WHEN QS.pstatus = '4' THEN @InActiveStateID  WHEN QS.pstatus = '8' THEN @DeleteStateID
		WHEN QS.pstatus='6' THEN @InActiveStateID   WHEN QS.pstatus='1' THEN @TemporaryID END) 
		,NumberofDays = (CASE WHEN QS.m_f0831 = '0' THEN NULL ELSE QS.m_f0831 END)
		,GPSUPdateTimestamp = @Getdate 
		,ORG.CompletionDate= (CASE WHEN QS.pstatus = '4' THEN QS.pstatus_date Else null END) --   convert(datetime,QS.pstatus_date,103)
		FROM QuestionnaireTransaction ORG 
		INNER JOIN QB_DataImport.dbo.QB_Import_Questionnaire_Staging QS  ON ORG.[UID] = QS.[UID] 
		AND (CASE WHEN QS.pstatus = '2' THEN @ActiveStateID 
		WHEN QS.pstatus = '4' THEN @InActiveStateID  
		WHEN QS.pstatus = '8' THEN @DeleteStateID 
		WHEN QS.pstatus='1' THEN @TemporaryID 
		WHEN QS.pstatus='6' THEN @InvalidID 
		END)  <> ORG.StateID 
		WHERE  IsProcessed = 0
		and QS.[UID]  in 
		(
			select [UID] from QuestionnaireTransaction where CountryID = @CountryId
		)
		*/

		UPDATE ORG 
		SET  ORG.PanelistID  = TMP.panelistId
		--, QuestionnaireID
		, ORG.StateID = TMP.StateID
		, ORG.CompletionDate = TMP.CompletetionDate 
		, ORG.NumberofDays= TMP.NumberofDays 
		, ORG.[UID] =  TMP.[UID]
		, ORG.panelist_code = TMP.panelist_code 
		, ORG.QuestionnaireDate =  TMP.QuestionnaireDate
		FROM QuestionnaireTransaction ORG 
		jOIN @INSERTTABLE TMP  ON CAST(TMP.InvitationDate AS DATE)   = CAST( ORG.InvitationDate AS DATE)
		AND TMP.GroupContactId = ORG.GroupContactId 
		AND TMP.CountryID = ORG.CountryID
		Where NOT (
		ORG.PanelistID  = TMP.panelistId  
		AND ORG.StateID = TMP.StateID
		AND ORG.CompletionDate = TMP.CompletetionDate 
		AND ORG.NumberofDays= TMP.NumberofDays 
		AND ORG.[UID] =  TMP.[UID]
		AND ORG.panelist_code = TMP.panelist_code 
		AND ORG.QuestionnaireDate =  TMP.QuestionnaireDate)
				
			 

		SET @UpdatedRows = @@ROWCOUNT


			UPDATE TMP SET IsProcessed = 1
			FROM QB_DataImport.dbo.QB_Import_Questionnaire_Staging TMP 
			INNER JOIN QuestionnaireTransaction IT ON IT.[UID]= TMP.[UID] 
			WHERE  IsProcessed = 0;

			UPDATE QB_DataImport.dbo.QB_Import_Questionnaire_Staging 
			SET IsProcessed = 12 
			WHERE IsProcessed = 1;
 		
			
			IF @CountryISO2A = 'ES'
			BEGIN
				UPDATE [DBO].[FileImportAuditSummary] 
				SET  Comments = convert(varchar(20), @UpdatedRows) + ' Row(s) Processed.'  
				,[Status] = 'Completed'  
				WHERE  JobId = @ProcessId
			END 
			ELSE 
			BEGIN
				UPDATE [DBO].[FileImportAuditSummary] 
				SET  Comments = convert(varchar(20), @InsertedRows) + ' Row(s) Inserted. ' + convert(varchar(20), @UpdatedRows) + ' Row(s) Updated.'  
				,[Status] = 'Completed'  
				WHERE  JobId = @ProcessId
			END 
			
	END TRY		
	BEGIN CATCH

		INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)
			SELECT 
			@FileName
			,@CountryISO2A
			,@PanelCode
			,@ImportType
			,'GLOBAL ERROR'
			,ERROR_NUMBER()
			,'ERROR OCCURED -' + ERROR_MESSAGE()
			,@Getdate
			,@ProcessId
			  
			UPDATE [DBO].[FileImportAuditSummary] 
			SET  [Status] = 'Error'  
			,Comments = 'Input file has errors.'
			WHERE  JobId = @ProcessId

	END CATCH

END
GO