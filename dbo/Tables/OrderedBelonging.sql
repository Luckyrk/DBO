CREATE TABLE [dbo].[OrderedBelonging]
(
	[Id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, 
    [BelongingSection_Id] UNIQUEIDENTIFIER NOT NULL, 
    [Belonging_Id] UNIQUEIDENTIFIER NOT NULL, 
    [Order] INT NOT NULL, 
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [FK_dbo.OrderedBelonging_dbo.SortAttribute_Id] FOREIGN KEY ([BelongingSection_Id]) REFERENCES [dbo].[SortAttribute] ([Id]), 
    CONSTRAINT [FK_dbo.OrderedBelonging_dbo.Belonging_GUIDReference] FOREIGN KEY ([Belonging_Id]) REFERENCES [dbo].[Belonging] ([GUIDReference])
)