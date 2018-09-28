﻿CREATE TABLE [dbo].[PTO260_copy] (
    [HOUSEHOLD_NUMBER]    NUMERIC (6)   NOT NULL,
    [COMMS_EVENT_CODE]    NUMERIC (3)   NOT NULL,
    [COMMS_DATE]          DATETIME      NOT NULL,
    [COMMS_EVENT_OUTCOME] NUMERIC (1)   NOT NULL,
    [INSERT_DATE]         DATETIME      NOT NULL,
    [COMMENTS]            VARCHAR (256) NULL,
    [CALL_NUMBER]         NUMERIC (8)   NULL,
    PRIMARY KEY CLUSTERED ([HOUSEHOLD_NUMBER] ASC, [COMMS_EVENT_CODE] ASC, [COMMS_DATE] ASC)
);




GO
CREATE TRIGGER dbo.trgPTO260_copy_U 
ON dbo.[PTO260_copy] FOR update 
AS 
insert into audit.[PTO260_copy](
insert into audit.[PTO260_copy](
GO
CREATE TRIGGER dbo.trgPTO260_copy_I
ON dbo.[PTO260_copy] FOR insert 
AS 
insert into audit.[PTO260_copy](
GO
CREATE TRIGGER dbo.trgPTO260_copy_D
ON dbo.[PTO260_copy] FOR delete 
AS 
insert into audit.[PTO260_copy](