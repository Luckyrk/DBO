CREATE TABLE [dbo].[Panel] (
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
insert into audit.[Panel](	 [GUIDReference]	 ,[Name]	 ,[CreationDate]	 ,[PanelCode]	 ,[Total_Target_Population]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panels_Order]	 ,[TypeTranslation_Id]	 ,[ExpectedKit_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Name]	 ,d.[CreationDate]	 ,d.[PanelCode]	 ,d.[Total_Target_Population]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panels_Order]	 ,d.[TypeTranslation_Id]	 ,d.[ExpectedKit_Id]	 ,d.[Country_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Panel](	 [GUIDReference]	 ,[Name]	 ,[CreationDate]	 ,[PanelCode]	 ,[Total_Target_Population]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panels_Order]	 ,[TypeTranslation_Id]	 ,[ExpectedKit_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Name]	 ,i.[CreationDate]	 ,i.[PanelCode]	 ,i.[Total_Target_Population]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panels_Order]	 ,i.[TypeTranslation_Id]	 ,i.[ExpectedKit_Id]	 ,i.[Country_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgPanel_I
ON dbo.[Panel] FOR insert 
AS 
insert into audit.[Panel](	 [GUIDReference]	 ,[Name]	 ,[CreationDate]	 ,[PanelCode]	 ,[Total_Target_Population]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panels_Order]	 ,[TypeTranslation_Id]	 ,[ExpectedKit_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Name]	 ,i.[CreationDate]	 ,i.[PanelCode]	 ,i.[Total_Target_Population]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panels_Order]	 ,i.[TypeTranslation_Id]	 ,i.[ExpectedKit_Id]	 ,i.[Country_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanel_D
ON dbo.[Panel] FOR delete 
AS 
insert into audit.[Panel](	 [GUIDReference]	 ,[Name]	 ,[CreationDate]	 ,[PanelCode]	 ,[Total_Target_Population]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panels_Order]	 ,[TypeTranslation_Id]	 ,[ExpectedKit_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Name]	 ,d.[CreationDate]	 ,d.[PanelCode]	 ,d.[Total_Target_Population]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panels_Order]	 ,d.[TypeTranslation_Id]	 ,d.[ExpectedKit_Id]	 ,d.[Country_Id]	 ,d.[Type],'D' from deleted d
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