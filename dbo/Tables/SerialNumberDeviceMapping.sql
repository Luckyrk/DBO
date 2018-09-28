CREATE TABLE [dbo].[SerialNumberDeviceMapping]
(
	[GUIDReference] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, 
    [Country_Id] UNIQUEIDENTIFIER NOT NULL, 
    [KitName] NVARCHAR(50) NOT NULL, 
    [Expression] NVARCHAR(50) NOT NULL, 
	[Prefix] NVARCHAR(10), 
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [FK_SerialNumberDeviceMapping_Country] FOREIGN KEY (Country_Id) REFERENCES [dbo].Country(CountryId) ON DELETE CASCADE
)
