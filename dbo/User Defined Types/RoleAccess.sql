CREATE TYPE [dbo].[RoleAccess] AS TABLE(
	[AccessContextId] [bigint] NULL,
	[RestrictedAccessAreaId] [bigint] NULL,
	[SystemRoleTypeId] [bigint] NULL,
	[SystemOperationId] [bigint] NULL,
	[IsPermissionGranted] [bit] NULL,
	[ActiveFrom] [datetime] NULL,
	[ActiveTo] [datetime] NULL
)
GO