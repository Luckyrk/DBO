CREATE TABLE [dbo].[Document] (
    [DocumentId]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocumentTypeId]     BIGINT           NOT NULL,
    [DocumentSubTypeId]  BIGINT           NOT NULL,
    [GPSUser]            NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [CountryId]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.Document] PRIMARY KEY CLUSTERED ([DocumentId] ASC),
    CONSTRAINT [FK_dbo.Document_dbo.DocumentSubType_DocumentSubTypeId] FOREIGN KEY ([DocumentSubTypeId]) REFERENCES [dbo].[DocumentSubType] ([DocumentSubTypeId]),
    CONSTRAINT [FK_dbo.Document_dbo.DocumentType_DocumentTypeId] FOREIGN KEY ([DocumentTypeId]) REFERENCES [dbo].[DocumentType] ([DocumentTypeId])
);








GO
CREATE NONCLUSTERED INDEX [IX_DocumentTypeId]
    ON [dbo].[Document]([DocumentTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DocumentSubTypeId]
    ON [dbo].[Document]([DocumentSubTypeId] ASC);


GO

CREATE TRIGGER [dbo].[trgDocument_D]
ON [dbo].[Document] FOR delete 
AS 
insert into [GPS_PM_GBR_Audit].[Audit].[Document](
       [DocumentId]
       ,[DocumentTypeId]
       ,[DocumentSubTypeId]
       ,[GPSUser]
       ,[GPSUpdateTimestamp]
       ,[CreationTimeStamp]
       ,[AuditOperation],[AuditModifiedBy],[__$operation],[AuditDate]) select 
        d.[DocumentId]
       ,d.[DocumentTypeId]
       ,d.[DocumentSubTypeId]
       ,SYSTEM_USER
       ,d.[GPSUpdateTimestamp]
       ,d.[CreationTimeStamp],'D',SYSTEM_USER,1,dbo.GetLocalDateTime(GETDATE(),'GB') from deleted d