USE [GPS_PM]
GO

/****** Object:  View [dbo].[FullIndividualAttributesES]    Script Date: 02/06/2015 13:41:16 ******/

SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

IF object_id(N'dbo.FullIndividualAttributesES', 'V') IS NOT NULL
	DROP VIEW dbo.FullIndividualAttributesES
GO


CREATE VIEW [dbo].[FullIndividualAttributesES]
AS 

select *
FROM (SELECT [CountryISO2A]
      ,[IndividualId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullIndividualIntAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[IndividualId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullIndividualBooleanAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[IndividualId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullIndividualDateAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[IndividualId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullIndividualFloatAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[IndividualId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullIndividualStringAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[IndividualId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullIndividualEnumAttributesAsRows] where CountryISO2A = 'ES') AS source
PIVOT
(
    MAX([Value])
    FOR [Key] IN (
 			  [AltaWeb],
				[AltaWebCom],
				[AltaWebMD],
				[Altura],
				[AnotaCompras],
				[AnySem],
				[CIFNIF],
				[codigo_madre],
				[CodigoProfesion],
				[ColaboracionOOH],
				[ColaboraEnPetrolprof],
				[CompraComidaAnimales],
				[Cuenta],
				[CuentaAjenaPropia],
				[DescTel3],
				[Email],
				[Email_consult],
				[Email_desc],
				[EncargadoCompras],
				[FECKM_Date_of_mileage_take],
				[FECKMPROF_Date_of_mileage_for_professionals],
				[Ingresos_individual],
				[KmsVehiculo],
				[KmsVehiculo_petrolprof],
				[Lugar],
				[MayoresIngresos],
				[MEDIA_MEDIA_survey_sent],
				[Metodologia],
				[ModeloSmartphone],
				[Motivobaja],
				[Movil],
				[Movil_individual],
				[NivelEstudios],
				[NN_All_panelista_data],
				[Npan_antiguo],
				[NumTel3],
				[NumTrabajadores],
				[PaisNacimiento],
				[PaisOrigen],
				[PC_individual],
				[Peso],
				[Procedencia],
				[Profesion],
				[Profesionales],
				[RECIBEEMAIL],
				[Rol],
				[SituacionLaboral],
				[Tablet_individual],
				[TELEF],
				[Tipo_consumidor],
				[Tipo_consumidor_Edu],
				[Tipo_consumidor_Edu2],
				[TipoIndividuo],
				[TipoIndividuo_SexoEdad]
				  )) AS PivotTable

GO


GRANT SELECT ON FullIndividualAttributesES TO GPSBusiness