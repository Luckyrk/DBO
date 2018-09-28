﻿CREATE TABLE [dbo].[DashboardParameters](
	[GUIDReference] [uniqueidentifier] NOT NULL,
	[PanelId] [uniqueidentifier] NOT NULL,
	[NonCommunicating] [int] NULL,
	[_35DaysWithMe] [int] NULL,
	[NonCommunicatingOver35Days] [int] NULL,
	[NewHomes] [int] NULL,
	[DropOuts] [int] NULL,
	[KitOrders] [int] NULL,
	[KitToBeDespatched] [int] NULL,
	[NewClicker] [int] NULL,
	[ReplacementClicker] [int] NULL,
	[OutstandingEmails] [int] NULL,
	[DateOldest] [int] NULL,
	[MatchedEmails] [int] NULL,
	[UnmatchedEmails] [int] NULL,
	[CallsAnswered] [int] NULL,
	[Campaign] [int] NULL,
	[Non_Communicating] [int] NULL,
	[Ex_Homes] [int] NULL,
	[CourtesyCalls] [int] NULL,
	[New_Homes] [int] NULL,
	[Freeformbox] [int] NULL,
	[Recruitment] [int] NULL,
	[FamilyFoodDiscrepancy] [int] NULL,
	[SocialGrading] [int] NULL,
	[SocialGradingCB] [int] NULL,
	[CourtesyCalls13_29] [int] NULL,
	[CourtesyCalls65_] [int] NULL,
    CONSTRAINT [PK_DashboardParameters] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
	CONSTRAINT [FK_DashboardParameters_Panel] FOREIGN KEY([PanelId]) REFERENCES [dbo].[Panel] ([GUIDReference])
);