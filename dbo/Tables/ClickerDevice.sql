CREATE TABLE [dbo].[ClickerDevice] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [SerialNumber]     NCHAR (50)    NOT NULL,
    [KitType]          SMALLINT      NULL,
    [HouseHoldNumber]  INT           NULL,
    [GPSUserName]      NVARCHAR (50) NULL,
    [WindowsUserName]  NVARCHAR (50) NULL,
    [CountryCode]      NCHAR (2)     NOT NULL,
    [CreationDateTime] DATETIME      NULL,
    CONSTRAINT [PK_History] PRIMARY KEY CLUSTERED ([ID] ASC)
);

