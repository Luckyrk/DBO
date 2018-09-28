﻿CREATE TABLE [dbo].[RuleParameters] (
    [GUIDReference]    UNIQUEIDENTIFIER NOT NULL,
    [Name]             NVARCHAR (50)    NULL,
    [IsInputParameter] BIT              NOT NULL,
    [TypeName]         NVARCHAR (500)   NULL,
    [RuleContext_Id]   UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RuleParameters] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.RuleParameters_dbo.BusinessRulesContext_RuleContext_Id] FOREIGN KEY ([RuleContext_Id]) REFERENCES [dbo].[BusinessRulesContext] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_RuleContext_Id]
    ON [dbo].[RuleParameters]([RuleContext_Id] ASC);


GO
CREATE TRIGGER dbo.trgRuleParameters_U 
ON dbo.[RuleParameters] FOR update 
AS 
insert into audit.[RuleParameters](
insert into audit.[RuleParameters](
GO
CREATE TRIGGER dbo.trgRuleParameters_I
ON dbo.[RuleParameters] FOR insert 
AS 
insert into audit.[RuleParameters](
GO
CREATE TRIGGER dbo.trgRuleParameters_D
ON dbo.[RuleParameters] FOR delete 
AS 
insert into audit.[RuleParameters](