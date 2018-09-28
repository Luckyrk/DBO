USE [GPS_PM]
GO

/****** Object:  View [dbo].[FullGroupAttributesES]    Script Date: 02/06/2015 15:20:18 ******/
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

IF object_id(N'dbo.FullGroupAttributesES', 'V') IS NOT NULL
	DROP VIEW dbo.FullGroupAttributesES
GO
USE [GPS_PM]
GO

CREATE VIEW [dbo].[FullGroupAttributesES]
AS 

select *
FROM (SELECT [CountryISO2A]
      ,[GroupId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullGroupIntAttributesAsRows] where CountryISO2A = 'ES'

  UNION ALL
  SELECT [CountryISO2A]
      ,[GroupId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullGroupBooleanAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[GroupId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullGroupDateAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[GroupId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullGroupFloatAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[GroupId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullGroupStringAttributesAsRows] where CountryISO2A = 'ES'
  UNION ALL
  SELECT [CountryISO2A]
      ,[GroupId]
      ,[Key]
      ,CAST([Value] as nvarchar(500)) as [Value]
  FROM [dbo].[FullGroupEnumAttributesAsRows] where CountryISO2A = 'ES') AS source
PIVOT
(
    MAX([Value])
    FOR [Key] IN (
				[ActividadFisica],
				[Agua],
				[Aire],
				[ANYPROXNAC_Next_birth],
				[Aspiradora],
				[balanza_cocina],
				[BDL_Bathroom],
				[Cable],
				[Cable_internet],
				[Cable_telefonia],
				[Cable_TV],
				[CafeteraCapsulas],
				[CafeteraExpresso],
				[CafeteraFiltro],
				[Calefaccion],
				[CanalPlus],
				[CepilloElectrico],
				[ClaseSocial_Clajur],
				[ClaseSocial_Clasof],
				[Cocina],
				[cod_entrevistador],
				[Colesterol],
				[Compete],
				[Conexion_internet],
				[Congelador],
				[Consola],
				[ConsolaTV],
				[contacto_mañana],
				[contacto_mediodia],
				[contacto_tarde],
				[Decodificador_otros],
				[Diabetes],
				[DigitalPlus],
				[Dir1],
				[Dir2],
				[Dir3],
				[DVD],
				[Ebook],
				[EmailCommunication],
				[ENVIONUEVAS_Initial_send_to_new_panelists],
				[Estrenimineto],
				[FFP_olas],
				[FrecuenciaUso_internet],
				[Frigorifico],
				[FuenteCaptacion],
				[Gluten],
				[Hogar],
				[Homecinema],
				[Lactosa],
				[Lavadora],
				[Lavavajilla],
				[Licuadora],
				[Lifecycle],
				[LugarTrabajo_panelista],
				[MesProxNac],
				[Microondas],
				[Musica],
				[Ninguno],
				[NivelEstudios_cabezafamilia_IT],
				[NpanHogar],
				[OPTH_cradle_type],
				[OPTH_price_noprice],
				[Otros],
				[PC],
				[PC_hogar],
				[Pccuantos],
				[Portatil_netbook_hogar],
				[Portatiles],
				[Posee_segunda_residencia],
				[Profesion_cabezafamilia],
				[propuesta_smartphone],
				[RECIBIDO_Mobile_Phone_Census],
				[Recruitment_Source],
				[Robot],
				[Secadora],
				[ServicioDomestico],
				[SMSCommunication],
				[Status_QS],
				[Tablet],
				[Tamaño_familiar_IT],
				[telefono_movil],
				[Tension],
				[Tipo_3D],
				[tipo_instalación],
				[TV_Internet],
				[TVCable],
				[TVcolor],
				[TVHD],
				[TVPlasma],
				[UsaInternet],
				[USAINTERNETO],
				[USAINTERNETT],
				[Usb_internet],
				[Video],
				[web_QS],
				[WebPanelist],
				[WIFI])
				) AS PivotTable

GO



GRANT SELECT ON [FullGroupAttributesES] TO GPSBusiness

GO

