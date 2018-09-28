CREATE TABLE [dbo].[DiaryInsertLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [uniqueidentifier] NOT NULL,
	[CreatedTimeStamp] [datetime] NOT NULL,
	[InsertCount] [int] NOT NULL,
	[User] [nvarchar](600) NULL,
	[DiaryBeforeCount] [int] NOT NULL,
	[DiaryAfterCount] [int] NOT NULL,
	[Comments] [nvarchar](3000) NULL
) ON [PRIMARY]

GO