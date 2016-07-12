USE [imaotDb]
GO

/****** Object:  Table [dbo].[gaTrack]    Script Date: 7/12/2016 11:29:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[gaTrack](
	[gaid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
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
	[Track] [nvarchar](10) NOT NULL,
	[RecipeId] [int] NOT NULL,
	[SessionId] [nvarchar](max) NULL,
 CONSTRAINT [PK_gaTrack] PRIMARY KEY CLUSTERED 
(
	[gaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[gaTrack] ADD  CONSTRAINT [DF_gaTrack_gaid]  DEFAULT (newid()) FOR [gaid]
GO

