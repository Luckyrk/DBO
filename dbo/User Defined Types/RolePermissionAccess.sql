CREATE TYPE [dbo].[RolePermissionAccess] AS TABLE (
	[Role] [nvarchar](50) NOT NULL,
	[Area] INT,
	[Name] [nvarchar](255) NOT NULL,
	[Path] [nvarchar](255) NOT NULL,
	[SystemOperation] INT,
	[GrantAccess] INT
)