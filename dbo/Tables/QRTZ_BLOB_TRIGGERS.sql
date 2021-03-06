﻿CREATE TABLE [dbo].[QRTZ_BLOB_TRIGGERS] (
    [SCHED_NAME]    NVARCHAR (100) NOT NULL,
    [TRIGGER_NAME]  NVARCHAR (150) NOT NULL,
    [TRIGGER_GROUP] NVARCHAR (150) NOT NULL,
    [BLOB_DATA]     IMAGE          NULL,
    CONSTRAINT [PK_QRTZ_BLOB_TRIGGERS] PRIMARY KEY CLUSTERED ([SCHED_NAME] ASC, [TRIGGER_NAME] ASC, [TRIGGER_GROUP] ASC)
);

