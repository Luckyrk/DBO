CREATE TABLE [dbo].[FormRuleParameters](
	[GUIDReference] [uniqueidentifier] NOT NULL,
	[FormRule_Id] [uniqueidentifier] NOT NULL,
	[Demographic_Id] [uniqueidentifier] NOT NULL,
	[AttributeName] [nvarchar](150) NOT NULL,
	[Property_Id] [nvarchar](150) NOT NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUser] [nvarchar](50) NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
	CONSTRAINT [PK_dbo.FormRuleParameters] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.FormRuleParameters_dbo.FormRule_FormRule_Id] FOREIGN KEY ([FormRule_Id]) REFERENCES [dbo].[FormRule] ([GUIDReference]) ON DELETE CASCADE
 );

GO

CREATE TRIGGER [dbo].[trgFormRuleParameters_U] 
ON [dbo].[FormRuleParameters] FOR update 
AS 
insert into audit.[FormRuleParameters](
	 [GUIDReference]     
	,[FormRule_Id]		
	,[Demographic_Id]
	,[AttributeName]      	
	,[Property_Id]       
	,[CreationTimeStamp] 
	,[GPSUser]           
	,[GPSUpdateTimestamp]
	,AuditOperation
	 ) select 
	  d.[GUIDReference]     
	 ,d.[FormRule_Id]		
	 ,d.[Demographic_Id]
	 ,d.[AttributeName]      	
	 ,d.[Property_Id]       
	 ,d.[CreationTimeStamp] 
	 ,d.[GPSUser]           	 
	 ,d.[GPSUpdateTimestamp]
	 ,'O'
	   from 
	 deleted d join inserted i on d.[GUIDReference] = i.[GUIDReference] 

insert into audit.[FormRuleParameters](
	 [GUIDReference]     
	,[FormRule_Id]		
	,[Demographic_Id]	
	,[AttributeName]  
	,[Property_Id]       
	,[CreationTimeStamp] 
	,[GPSUser]           
	,[GPSUpdateTimestamp]
	,AuditOperation) select 
	  i.[GUIDReference]     
	 ,i.[FormRule_Id]		
	 ,i.[Demographic_Id]	
	 ,i.[AttributeName]  
	 ,i.[Property_Id]       
	 ,i.[CreationTimeStamp] 
	 ,i.[GPSUser]           
	 ,i.[GPSUpdateTimestamp]
	 ,'N'  from 
	 deleted d join inserted i on d.[GUIDReference] = i.[GUIDReference]
GO
CREATE TRIGGER [dbo].[trgFormRuleParameters_I]
ON [dbo].[FormRuleParameters] FOR insert 
AS 
insert into audit.[FormRuleParameters](
	 [GUIDReference]     
	,[FormRule_Id]		
	,[Demographic_Id]	
	,[AttributeName]  
	,[Property_Id]       
	,[CreationTimeStamp] 
	,[GPSUser]           
	,[GPSUpdateTimestamp]		
	,AuditOperation) select 
	  i.[GUIDReference]     
	 ,i.[FormRule_Id]		
	 ,i.[Demographic_Id]
	 ,i.[AttributeName]  	
	 ,i.[Property_Id]       
	 ,i.[CreationTimeStamp] 
	 ,i.[GPSUser]           
	 ,i.[GPSUpdateTimestamp]
	 ,'I' from inserted i
GO
CREATE TRIGGER dbo.trgFormRuleParameters_D
ON dbo.[FormRuleParameters] FOR delete 
AS 
insert into audit.[FormRuleParameters](
	 [GUIDReference]     
	,[FormRule_Id]		
	,[Demographic_Id]
	,[AttributeName]  	
	,[Property_Id]       
	,[CreationTimeStamp] 
	,[GPSUser]           
	,[GPSUpdateTimestamp]
	,AuditOperation) select 
	  d.[GUIDReference]     
	 ,d.[FormRule_Id]		
	 ,d.[Demographic_Id]
	 ,d.[AttributeName]  	
	 ,d.[Property_Id]       
	 ,d.[CreationTimeStamp] 
	 ,d.[GPSUser]           
	 ,d.[GPSUpdateTimestamp]
	 ,'D' from deleted d