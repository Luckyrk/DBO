CREATE TABLE [JobCountryMapper](
	[JobId] [int] IDENTITY(1,1) NOT NULL,
	[ProcessName] [nvarchar](200) NOT NULL,		-- Only Mandatory Param for new process ; (Discussed with Mega; No need to restrict to certain finite values for now)
	 
	[CountryISO2A] [nvarchar](40) NOT NULL,	
)