CREATE TABLE [dbo].[CritxlValue]
(
	[Year] INT NOT NULL,
	[Period] INT NOT NULL,
	[AttributeKey] NVARCHAR(200) NOT NULL,
	[Candidate_Id] UNIQUEIDENTIFIER NOT NULL,
	[Value] NVARCHAR(255),
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CritxlValue] PRIMARY KEY CLUSTERED ([Year], [Period], [Candidate_Id], [AttributeKey] ASC),
	CONSTRAINT [FK_dbo.CritxlValue_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference])
);
GO

CREATE NONCLUSTERED INDEX IX_Period
ON [dbo].[CritxlValue] ([Year],[Period],[AttributeKey])
INCLUDE ([Candidate_Id],[Value])
GO