CREATE VIEW [dbo].FullIndividualAttributesES

AS

SELECT *

FROM (

	SELECT [CountryISO2A]

		,[IndividualId]

		,A.[Key]

		,(

		CASE 

			WHEN A.[Type] = 'Date'

				THEN FORMAT(TRY_PARSE(av.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')

			When A.[Type]='Enum'

				THEN ED.Value

			ELSE AV.value

			END

		) Value

	FROM Country

	INNER JOIN Individual C ON C.CountryId = Country.CountryId

	LEFT JOIN AttributeValue AV ON AV.CandidateID = C.GuidReference

		OR AV.RespondentID = C.GuidReference

	LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id

	LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId = A.GUIDReference

	WHERE CountryISO2A = 'ES'

	) AS Source

PIVOT(MAX([Value]) FOR [Key] IN (

			[Rol]

			,[Altura]

			,[FECALTA]

			,[Originallabeltest123]

			,[Rol_Calc]

			,[Worktype_Calc]

			,[TALLA]

			,[Region_Mat_Petrolprof]

			,[Maximum_Weight_Code_Petrolprof]

			,[Mobilemodel]

			,[AltaWebCom]

			,[NivelEstudios]

			,[CIFNIF]

			,[codigo_madre]

			,[Ingresos_individual]

			,[Motivobaja]

			,[TipoIndividuo]

			,[AnotaCompras]

			,[EncargadoCompras]

			,[TipoIndividuo_SexoEdad]

			,[SituacionLaboral]

			,[MayoresIngresos]

			,[AltaWeb]

			,[Email_desc]

			,[Email_consult]

			,[RECIBEEMAIL]

			,[Tipo_consumidor_Edu]

			,[Cuenta]

			,[KmsVehiculo_petrolprof]

			,[Npan_antiguo]

			,[KmsVehiculo]

			,[Peso]

			,[CodigoProfesion]

			,[CuentaAjenaPropia]

			,[PaisNacimiento]

			,[PaisOrigen]

			,[Tipo_consumidor_Edu2]

			,[Lugar]

			,[ColaboraEnPetrolprof]

			,[Email]

			,[Metodologia]

			,[ColaboracionOOH]

			,[Procedencia]

			,[Tipo_consumidor]

			,[MEDIA_MEDIA_survey_sent]

			,[NumTrabajadores]

			,[Profesionales]

			,[ModeloSmartphone]

			,[Tablet_individual]

			,[PC_individual]

			,[TELEF]

			,[NumTel3]

			,[AnySem]

			,[AltaWebMD]

			,[NN_All_panelista_data]

			,[Movil]

			,[DescTel3]

			,[FECKM_Date_of_mileage_take]

			,[FECKMPROF_Date_of_mileage_for_professionals]

			,[Movil_individual]

			,[Profesion]

			,[CompraComidaAnimales]

			)) AS PivotTable


