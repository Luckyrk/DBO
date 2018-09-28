CREATE TABLE ActionTaskPriorities
(
 [Id] INT,
 [Translation_Id] UNIQUEIDENTIFIER NOT NULL,
 [CountryId] UNIQUEIDENTIFIER NULL,
 GPSUser NVARCHAR(300),
 CreationTimeStamp DATETIME,
 GPSUpdateTimestamp DATETIME,
 CONSTRAINT [FK_dbo.ActionTaskPriorities_dbo.Country_Country_Id] FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
) 