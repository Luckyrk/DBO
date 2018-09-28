CREATE TABLE [dbo].[FieldConfiguration](
	[Id] BIGINT NOT NULL IDENTITY,
	[CountryConfiguration_Id] [uniqueidentifier] NOT NULL,
	[Key] [varchar](100) NOT NULL,
	[Required] [bit] NOT NULL,
	[Visible] [bit] NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
	CONSTRAINT [PK_FieldConfiguration] PRIMARY KEY CLUSTERED([Id]),
	CONSTRAINT [FK_dbo.FieldConfiguration_dbo.CountryConfiguration_CountryConfiguration_Id] FOREIGN KEY ([CountryConfiguration_Id]) REFERENCES [dbo].[CountryConfiguration] ([Id])
 ) ON [PRIMARY]

GO

CREATE TRIGGER dbo.trgFieldConfiguration_D
ON dbo.[FieldConfiguration] FOR delete 
AS 
insert into audit.[FieldConfiguration](	 [Id]	 ,[CountryConfiguration_Id]	 ,[Key]	 ,[Required]	 ,[Visible]	 ,AuditOperation) select 	 d.[Id]	 ,d.[CountryConfiguration_Id]	 ,d.[Key]	 ,d.[Required]	 ,d.[Visible],'D' from deleted d
GO

CREATE TRIGGER dbo.trgFieldConfiguration_I
ON dbo.[FieldConfiguration] FOR insert 
AS 
insert into audit.[FieldConfiguration](	 [Id]	 ,[CountryConfiguration_Id]	 ,[Key]	 ,[Required]	 ,[Visible]	 ,AuditOperation) select 	 i.[Id]	 ,i.[CountryConfiguration_Id]	 ,i.[Key]	 ,i.[Required]	 ,i.[Visible],'I' from inserted i
GO

CREATE TRIGGER dbo.trgFieldConfiguration_U 
ON dbo.[FieldConfiguration] FOR update 
AS 
insert into audit.[FieldConfiguration](	 [Id]	 ,[CountryConfiguration_Id]	 ,[Key]	 ,[Required]	 ,[Visible]	 ,AuditOperation) select 	 d.[Id]	 ,d.[CountryConfiguration_Id]	 ,d.[Key]	 ,d.[Required]	 ,d.[Visible],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[FieldConfiguration](	 [Id]	 ,[CountryConfiguration_Id]	 ,[Key]	 ,[Required]	 ,[Visible]	 ,AuditOperation) select 	 i.[Id]	 ,i.[CountryConfiguration_Id]	 ,i.[Key]	 ,i.[Required]	 ,i.[Visible],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO

--ALTER TABLE [dbo].[FieldConfiguration]  ADD  CONSTRAINT [FK_FieldConfiguration_CountryConfiguration] FOREIGN KEY([CountryConfiguration_Id])
--REFERENCES [dbo].[CountryConfiguration] ([Id])
--GO

--ALTER TABLE [dbo].[FieldConfiguration] CHECK CONSTRAINT [FK_FieldConfiguration_CountryConfiguration]
--GO

