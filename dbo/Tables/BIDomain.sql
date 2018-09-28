CREATE TABLE [dbo].[BIDomain]
(
	[GUIDReference] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, 
    [Country_Id] UNIQUEIDENTIFIER NOT NULL,
    [Domain] NVARCHAR(60) NOT NULL, 
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [FK_BIDomain_Country] FOREIGN KEY (Country_Id) REFERENCES [dbo].Country(CountryId) ON DELETE CASCADE
)
