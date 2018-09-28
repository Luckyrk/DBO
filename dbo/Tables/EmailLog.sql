CREATE TABLE [dbo].[EmailLog]
(
	[Country_Id] UNIQUEIDENTIFIER NOT NULL,
	[Timestamp] DATETIME NOT NULL, 
    [From] NVARCHAR(100) NOT NULL,
	[To] NVARCHAR(100) NOT NULL,
	[Subject] NVARCHAR(400) NOT NULL,
	[Message] NVARCHAR(400) NOT NULL,
	[Sent] BIT DEFAULT(0) NOT NULL,
    CONSTRAINT [FK_EmailLog_Country] FOREIGN KEY (Country_Id) REFERENCES [dbo].Country(CountryId) ON DELETE CASCADE
)

GO
CREATE NONCLUSTERED INDEX [IX_CountryDate]
    ON [dbo].[EmailLog]([Country_Id], [Sent], [Timestamp])