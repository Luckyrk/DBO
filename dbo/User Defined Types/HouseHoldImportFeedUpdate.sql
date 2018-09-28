CREATE TYPE [dbo].[HouseHoldImportFeedUpdate] AS TABLE (
    [Rownumber]       INT            NULL,
    [GroupContact]    NVARCHAR (300) NULL,
    [HeadOfHouseHold] NVARCHAR (300) NULL,
    [MainShopper]     NVARCHAR (200) NULL,
    [HomeAddressLine1]    NVARCHAR (200) NULL,
    [HomeAddressLine2]    NVARCHAR (200) NULL,
    [HomeAddressLine3]    NVARCHAR (200) NULL,
    [HomeAddressLine4]    NVARCHAR (200) NULL,
    [HomePostCode]        NVARCHAR (100) NULL,
    [BusinessId]      NVARCHAR (300) NULL,
	[FullRow]         NVARCHAR (MAX) NULL,
    [GACode]          NVARCHAR (100) NULL,
	[InterviewerCode] [bigint] NULL);

