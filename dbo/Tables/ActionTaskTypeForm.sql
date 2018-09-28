CREATE TABLE [dbo].[ActionTaskTypeForm]
(
    [FormId]  UNIQUEIDENTIFIER NOT NULL,
    [ActionTaskTypeId] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ActionTaskTypeForm] PRIMARY KEY CLUSTERED ([FormId] ASC, [ActionTaskTypeId] ASC),
    CONSTRAINT [FK_dbo.ActionTaskTypeForm_dbo.Form_Form_Id] FOREIGN KEY ([FormId]) REFERENCES [dbo].[Form] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.ActionTaskTypeForm_dbo.ActionTaskType_ActionTaskType_Id] FOREIGN KEY ([ActionTaskTypeId]) REFERENCES [dbo].[ActionTaskType] ([GUIDReference]) ON DELETE CASCADE
);

GO
CREATE NONCLUSTERED INDEX [IX_FormId]
    ON [dbo].[ActionTaskTypeForm]([FormId] ASC);