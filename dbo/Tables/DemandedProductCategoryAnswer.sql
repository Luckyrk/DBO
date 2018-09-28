CREATE TABLE [dbo].[DemandedProductCategoryAnswer] (
    [Id]                   UNIQUEIDENTIFIER NOT NULL,
    [AnswerCatCode]        NVARCHAR (5)     NOT NULL,
    [AnswerCatDescription] NVARCHAR (150)   NULL,
    [CallAgain]            BIT              NOT NULL,
    [GPSUser]              NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]   DATETIME         NULL,
    [CreationTimeStamp]    DATETIME         NULL,
    [Country_Id]           UNIQUEIDENTIFIER NOT NULL,
    [IsFreeTextRequired] BIT NULL, 
    CONSTRAINT [PK_dbo.DemandedProductCategoryAnswer] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.DemandedProductCategoryAnswer_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);








GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[DemandedProductCategoryAnswer]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgDemandedProductCategoryAnswer_U 
ON dbo.[DemandedProductCategoryAnswer] FOR update 
AS 
insert into audit.[DemandedProductCategoryAnswer](	 [Id]	 ,[AnswerCatCode]	 ,[AnswerCatDescription]	 ,[CallAgain]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[AnswerCatCode]	 ,d.[AnswerCatDescription]	 ,d.[CallAgain]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[DemandedProductCategoryAnswer](	 [Id]	 ,[AnswerCatCode]	 ,[AnswerCatDescription]	 ,[CallAgain]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[AnswerCatCode]	 ,i.[AnswerCatDescription]	 ,i.[CallAgain]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgDemandedProductCategoryAnswer_I
ON dbo.[DemandedProductCategoryAnswer] FOR insert 
AS 
insert into audit.[DemandedProductCategoryAnswer](	 [Id]	 ,[AnswerCatCode]	 ,[AnswerCatDescription]	 ,[CallAgain]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[AnswerCatCode]	 ,i.[AnswerCatDescription]	 ,i.[CallAgain]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDemandedProductCategoryAnswer_D
ON dbo.[DemandedProductCategoryAnswer] FOR delete 
AS 
insert into audit.[DemandedProductCategoryAnswer](	 [Id]	 ,[AnswerCatCode]	 ,[AnswerCatDescription]	 ,[CallAgain]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[AnswerCatCode]	 ,d.[AnswerCatDescription]	 ,d.[CallAgain]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'D' from deleted d