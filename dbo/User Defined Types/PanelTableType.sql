CREATE TYPE [dbo].[PanelTableType] AS TABLE 
(
	 [Rownumber] INT NULL
	,[PanelCode] INT NULL
	,[GroupRoleCode] NVARCHAR(100) NULL
	,[PanelRoleCode] NVARCHAR(100) NULL
	,[PanelistStateCode] NVARCHAR(100) NULL
	,[PanelistCommunicationMethodology] NVARCHAR(100) NULL
	,[PanelistCommunicationMethodologyChangeReason] NVARCHAR(MAX) NULL
	,[PanelistCommunicationMethodologyChangeComment] NVARCHAR(MAX) NULL
	,[AddressLine1]                      NVARCHAR (200)  NULL
	,[AddressLine2]                      NVARCHAR (200)  NULL
	,[AddressLine3]                      NVARCHAR (200)  NULL
	,[AddressLine4]                      NVARCHAR (200)  NULL
	,[PostCode]                          NVARCHAR (100)  NULL
	,[AddressType]						 NVARCHAR (200)  NULL
	,[Order]							 INT
	,[HomePhone]                         NVARCHAR (200)  NULL
    ,[WorkPhone]                         NVARCHAR (200)  NULL
    ,[MobilePhone]                       NVARCHAR (200)  NULL
	,[PhoneOrder]						 INT
	,[PhoneType]						 NVARCHAR (200)  NULL
	,[Phone]						     NVARCHAR (200)  NULL
	,[EmailOrder]						 INT
	,[EmailType]						 NVARCHAR (200)  NULL
	,[Email]							 NVARCHAR (200)  NULL
)