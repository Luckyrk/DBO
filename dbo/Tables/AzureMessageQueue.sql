CREATE TABLE [dbo].[AzureMessageQueue] (
    [id]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [from_endpoint]  VARCHAR (50)  NOT NULL,
    [to_endpoint]    VARCHAR (50)  NOT NULL,
    [subqueue]       CHAR (1)      NOT NULL,
    [insert_time]    DATETIME      NOT NULL,
    [last_processed] DATETIME      NULL,
    [retry_count]    INT           NOT NULL,
    [retry_time]     DATETIME      NOT NULL,
    [error_info]     TEXT          NULL,
    [correlation_id] VARCHAR (100) NULL,
    [label]          VARCHAR (100) NULL,
    [msg_text]       VARCHAR (MAX) NULL,
    [msg_headers]    VARCHAR (MAX) NULL,
    [unique_id]      VARCHAR (40)  NULL,
    CONSTRAINT [PK_AzureMessageQueue] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_AzureMessageQueue_subqueue_retry_time]
    ON [dbo].[AzureMessageQueue]([subqueue] ASC, [retry_time] ASC)
    INCLUDE([id]);