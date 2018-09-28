CREATE TABLE [dbo].[AuditConfig] (
    [TableName]              NVARCHAR (50) NULL,
    [AuditSchema]            NVARCHAR (10) NULL,
    [AuditTable]             NVARCHAR (50) NULL,
    [TriggerEnabledInsert]   BIT           NULL,
    [TriggerEnabledUpdate]   BIT           NULL,
    [TriggerEnabledDelete]   BIT           NULL,
    [TableCreateFlag]        BIT           NULL,
    [TableCreateIfStatement] NTEXT         NULL,
    [TableCreateStatement]   NTEXT         NULL,
    [ModificationTime]       DATETIME      NULL
);

