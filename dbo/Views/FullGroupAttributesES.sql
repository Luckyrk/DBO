CREATE VIEW [dbo].FullGroupAttributesES AS 

SELECT * FROM (	SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key]
					, (CASE
							WHEN a.[Type] = 'Date'
								THEN FORMAT(TRY_PARSE(av.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
							WHEN A.[Type]='Enum' 
								THEN ED.Value ELSE AV.value END
						) AS Value
				FROM Country
				JOIN Collective C on C.CountryId=Country.CountryId
				LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference OR AV.RespondentID=C.GuidReference
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
				WHERE CountryISO2A = 'ES'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [ActividadFisica], [Agua], [Aire], [ANYPROXNAC_Next_birth], [Aspiradora], [balanza_cocina], [BDL_Bathroom], [Cable], [Cable_internet], [Cable_telefonia], [Cable_TV], [CafeteraCapsulas], [CafeteraExpresso], 
[CafeteraFiltro], [Calefaccion], [CanalPlus], [CepilloElectrico], [ClaseSocial_Clajur], [ClaseSocial_Clasof], [Cocina], [cod_entrevistador], [Colesterol], [Compete], [Conexion_internet], [Congelador], [Consola], [ConsolaTV], [Cont_Censo_Calc], 
[contacto_mañana], [contacto_mediodia], [contacto_tarde], [Decodificador_otros], [Diabetes], [DigitalPlus], [Dir1], [Dir2], [Dir3], [DVD], [Ebook], [EmailCommunication], [ENVIONUEVAS_Initial_send_to_new_panelists], [Estrenimineto], [FFP_olas], 
[FrecuenciaUso_internet], [Frigorifico], [FuenteCaptacion], [Gluten], [Groupmobile_Calc], [Hogar], [Homecinema], [Lactosa], [Lavadora], [Lavavajilla], [Licuadora], [Lifecycle], [LugarTrabajo_panelista], [MesProxNac], [Metod_Calc], [Microondas], [Migradopetrolprof], 
[Musica], [NF_0A15_Calc], [NF_0A5_Calc], [NF_Calc], [Ninguno], [NivelEstudios_cabezafamilia_IT], [NpanHogar], [OPTH_cradle_type], [OPTH_price_noprice], [Otros], [PC], [PC_hogar], [Pccuantos], [Portatil_netbook_hogar], [Portatiles], [Posee_segunda_residencia], 
[Profesion_cabezafamilia], [propuesta_smartphone], [RECIBIDO_Mobile_Phone_Census], [Recompt], [Recruitment_Source], [Referrer_Calc], [Robot], [Secadora], [ServicioDomestico], [SMSCommunication], [Social_Class_Ca], [Social_Class_Calc], [Social_Class_Range_Calc], 
[Status_QS], [Tablet], [Tamaño_familiar_IT], [telefono_movil], [Tension], [Tipo_3D], [Tipo_3D_Calc], [tipo_instalación], [TV_Internet], [TV_PAGO], [TV_PANTALLA0], [TV_PANTALLA1], [TV_PANTALLA2], [TV_PANTALLA3], [TV_PULGADAS], [TVCable], [TVcolor], [TVHD], 
[TVPlasma], [UsaInternet], [USAINTERNETO], [USAINTERNETT], [Usb_internet], [Video], [web_QS], [WebPanelist], [WIFI])) AS PivotTable