﻿CREATE TABLE [dbo].[Panel] (
    [GUIDReference]           UNIQUEIDENTIFIER NOT NULL,
    [Name]                    NVARCHAR (50)    NOT NULL,
    [CreationDate]            DATETIME         NOT NULL,
    [PanelCode]               INT              NOT NULL,
    [Total_Target_Population] INT              NOT NULL,
    [GPSUser]                 NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]      DATETIME         NULL,
    [CreationTimeStamp]       DATETIME         NULL,
    [Panels_Order]            INT              NOT NULL,
    [TypeTranslation_Id]      UNIQUEIDENTIFIER NULL,
    [ExpectedKit_Id]          UNIQUEIDENTIFIER NULL,
    [Country_Id]              UNIQUEIDENTIFIER NOT NULL,
    [Type]                    NVARCHAR (128)   NOT NULL,
    [EndDate] DATETIME NULL, 
    [StartDate] DATETIME NULL, 
    CONSTRAINT [PK_dbo.Panel] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Panel_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.Panel_dbo.StockKit_ExpectedKit_Id] FOREIGN KEY ([ExpectedKit_Id]) REFERENCES [dbo].[StockKit] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Panel_dbo.Translation_TypeTranslation_Id] FOREIGN KEY ([TypeTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueName] UNIQUE NONCLUSTERED ([Name] ASC, [Country_Id] ASC),
    CONSTRAINT [UniqueOrder] UNIQUE NONCLUSTERED ([Country_Id] ASC, [Panels_Order] ASC)
);








GO
CREATE NONCLUSTERED INDEX [IX_TypeTranslation_Id]
    ON [dbo].[Panel]([TypeTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Panel]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanel_U 
ON dbo.[Panel] FOR update 
AS 
insert into audit.[Panel](
insert into audit.[Panel](
GO
CREATE TRIGGER dbo.trgPanel_I
ON dbo.[Panel] FOR insert 
AS 
insert into audit.[Panel](
GO
CREATE TRIGGER dbo.trgPanel_D
ON dbo.[Panel] FOR delete 
AS 
insert into audit.[Panel](
GO
CREATE TRIGGER [dbo].[updatePaneltrg]
ON [dbo].[Panel] FOR UPDATE
AS
BEGIN

  SET NOCOUNT ON;
 
    declare @countrycode nvarchar(max)
    declare @panelName nvarchar(max)
    select @PanelName= Name,@countrycode=Country_Id  from deleted 

    
    
    update dbo.TemplateMessageScheme 
    set Description=i.Name
    from inserted i
    where TemplateMessageScheme.CountryId=@countrycode And TemplateMessageScheme.Description=@PanelName
END
GO

CREATE TRIGGER [dbo].[trgAfterPanel_Insert]
ON [dbo].[Panel] FOR insert 
AS 
insert into TemplateMessageScheme(
	 
	 [Description]
	 ,CountryId
	) select 
	
	 i.[Name]
	 ,i.[Country_Id]
	 from inserted i