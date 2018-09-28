﻿CREATE TABLE [dbo].[PTO255_copy] (
    [CALL_NUMBER]               NUMERIC (9)  NOT NULL,
    [HOUSEHOLD_NUMBER]          NUMERIC (8)  NOT NULL,
    [PANEL_SERVICE]             NUMERIC (2)  NOT NULL,
    [PHONE_NUMBER]              VARCHAR (20) NOT NULL,
    [CALL_TYPE]                 NUMERIC (2)  NOT NULL,
    [CALL_START_TIME]           DATETIME     NOT NULL,
    [CALL_END_TIME]             DATETIME     NOT NULL,
    [CALL_SUCCESS]              NUMERIC (1)  NOT NULL,
    [CALL_END_STATUS]           NUMERIC (4)  NOT NULL,
    [CALL_IN_OUT]               CHAR (1)     NOT NULL,
    [MODEM_NUMBER]              NUMERIC (8)  NOT NULL,
    [TERMINAL_NUMBER]           NUMERIC (8)  NOT NULL,
    [BROWNS_STATUS]             CHAR (1)     NULL,
    [MODEM_STATUS]              NUMERIC (2)  NOT NULL,
    [HOST_NAME]                 VARCHAR (15) NOT NULL,
    [PORT_NUMBER]               NUMERIC (5)  NOT NULL,
    [TERMINAL_FAILED_POLLS]     NUMERIC (4)  NOT NULL,
    [BYTES_SENT]                NUMERIC (6)  NOT NULL,
    [BYTES_RECEIVED]            NUMERIC (6)  NOT NULL,
    [BLOCKS_SENT]               NUMERIC (4)  NOT NULL,
    [BLOCKS_RECEIVED]           NUMERIC (4)  NOT NULL,
    [CALL_CONNECT_TIME]         NUMERIC (4)  NOT NULL,
    [RETRANSMITTED_BLOCKS]      NUMERIC (2)  NOT NULL,
    [CORRUPTED_BLOCKS_RECEIVED] NUMERIC (2)  NOT NULL,
    [WACKS_SENT]                NUMERIC (2)  NOT NULL,
    [WACKS_RECEIVED]            NUMERIC (2)  NOT NULL,
    [TDDS_SENT]                 NUMERIC (2)  NOT NULL,
    [TDDS_RECEIVED]             NUMERIC (2)  NOT NULL,
    [RECRUITER_NUMBER]          NUMERIC (6)  NULL,
    [SOCKET_REQUIRED]           CHAR (1)     NULL,
    [HOLIDAY_FLAG]              CHAR (1)     NULL,
    [TERMINAL_HOUSEHOLD]        NUMERIC (8)  NULL,
    [TERMINAL_PHONE_NUMBER]     VARCHAR (20) NULL,
    [TERMINAL_DATE_OLD]         DATETIME     NULL,
    [TERMINAL_DATE_NEW]         DATETIME     NULL,
    [TERMINAL_DAY_OLD]          NUMERIC (1)  NULL,
    [TERMINAL_DAY_NEW]          NUMERIC (1)  NULL,
    [SOFTWARE_VERSION_OLD]      CHAR (5)     NULL,
    [SOFTWARE_VERSION_NEW]      CHAR (5)     NULL,
    [REGULAR_MILK_OLD]          CHAR (1)     NULL,
    [REGULAR_MILK_NEW]          CHAR (1)     NULL,
    [CAM_VERSION_OLD]           CHAR (5)     NULL,
    [CAM_VERSION_NEW]           CHAR (5)     NULL,
    [CODEBOOK_VERSION_OLD]      CHAR (1)     NULL,
    [CODEBOOK_VERSION_NEW]      CHAR (1)     NULL,
    [CODEBOOK_2_VERSION_OLD]    CHAR (1)     NULL,
    [CODEBOOK_2_VERSION_NEW]    CHAR (1)     NULL,
    [GLOBAL_VERSION_OLD]        CHAR (1)     NULL,
    [GLOBAL_VERSION_NEW]        CHAR (1)     NULL,
    [USI_STATUS_OLD]            CHAR (1)     NULL,
    [USI_STATUS_NEW]            CHAR (1)     NULL,
    [MEMORY_LEFT]               NUMERIC (5)  NULL,
    [DIAL_FLAG]                 NUMERIC (1)  NULL,
    [TRANSFER_BUFFER_FLAG]      CHAR (1)     NULL,
    [OFF_HOOK_FLAG]             CHAR (1)     NULL,
    [ACTIVATE_USI_FLAG]         CHAR (1)     NULL,
    [LINETEST_UPDATE_FLAG]      CHAR (1)     NULL,
    [PANEL_UPDATE_FLAG]         CHAR (1)     NULL,
    [NVM_VERSION_OLD]           CHAR (5)     NULL,
    [NVM_VERSION_NEW]           CHAR (5)     NULL,
    [MODEM_DEVICE_CODE]         NUMERIC (2)  NULL,
    [TERMINAL_DEVICE_CODE]      NUMERIC (2)  NULL,
    [POLLER_NUMBER]             NUMERIC (2)  NULL,
    [LOGICAL_MODEM_NUMBER]      NUMERIC (4)  NULL,
    [DEVICE_SERIAL_CHAR]        VARCHAR (20) NULL,
    [PALM_FLAG]                 CHAR (1)     NULL,
    [PALM_FTP_OLD]              CHAR (5)     NULL,
    [PALM_FTP_NEW]              CHAR (5)     NULL,
    [PALM_PANELSCAN_OLD]        CHAR (5)     NULL,
    [PALM_PANELSCAN_NEW]        CHAR (5)     NULL,
    [PALM_CODEBOOK_OLD]         CHAR (5)     NULL,
    [PALM_CODEBOOK_NEW]         CHAR (5)     NULL,
    [PALM_SHOP_OLD]             CHAR (5)     NULL,
    [PALM_SHOP_NEW]             CHAR (5)     NULL,
    [PALM_CONNECT_OLD]          CHAR (5)     NULL,
    [PALM_CONNECT_NEW]          CHAR (5)     NULL,
    [PALM_OS_OLD]               CHAR (5)     NULL,
    [PALM_OS_NEW]               CHAR (5)     NULL,
    [BATTERY_STATUS]            VARCHAR (5)  NULL,
    [CONNECTION_TYPE]           CHAR (1)     NULL,
    PRIMARY KEY CLUSTERED ([CALL_NUMBER] ASC)
);




GO
CREATE TRIGGER dbo.trgPTO255_copy_U 
ON dbo.[PTO255_copy] FOR update 
AS 
insert into audit.[PTO255_copy](
insert into audit.[PTO255_copy](
GO
CREATE TRIGGER dbo.trgPTO255_copy_I
ON dbo.[PTO255_copy] FOR insert 
AS 
insert into audit.[PTO255_copy](
GO
CREATE TRIGGER dbo.trgPTO255_copy_D
ON dbo.[PTO255_copy] FOR delete 
AS 
insert into audit.[PTO255_copy](