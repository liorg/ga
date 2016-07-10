/****** Object:  Table [dbo].[RecipeViewsLogs]    Script Date: 7/10/2016 4:57:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RecipeViewsLogs](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[RecipeId] [int] NOT NULL,
	[IpAddress] [nvarchar](50) NULL,
	[Browser] [nvarchar](100) NULL,
	[Platform] [nvarchar](100) NULL,
	[IsMobile] [bit] NOT NULL,
	[IsCrawler] [bit] NOT NULL,
	[CookieId] [nvarchar](128) NULL,
	[IdentityName] [nvarchar](max) NULL,
	[IsAuthenticated] [bit] NOT NULL,
	[Path] [nvarchar](max) NULL,
	[QueryString] [nvarchar](max) NULL,
	[TimeStamp] [datetime] NOT NULL,
	[Year] [smallint] NOT NULL,
	[Month] [smallint] NOT NULL,
 CONSTRAINT [PK_dbo.RecipeViewsLogs] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
