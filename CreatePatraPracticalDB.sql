USE [master]
GO
/****** Object:  Database [PatraPractical]    Script Date: 9/13/2021 8:20:25 AM ******/
CREATE DATABASE [PatraPractical]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PatraPractical', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\PatraPractical.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PatraPractical_log', FILENAME = N'I:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\PatraPractical_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [PatraPractical] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PatraPractical].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PatraPractical] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PatraPractical] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PatraPractical] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PatraPractical] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PatraPractical] SET ARITHABORT OFF 
GO
ALTER DATABASE [PatraPractical] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PatraPractical] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PatraPractical] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PatraPractical] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PatraPractical] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PatraPractical] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PatraPractical] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PatraPractical] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PatraPractical] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PatraPractical] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PatraPractical] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PatraPractical] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PatraPractical] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PatraPractical] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PatraPractical] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PatraPractical] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PatraPractical] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PatraPractical] SET RECOVERY FULL 
GO
ALTER DATABASE [PatraPractical] SET  MULTI_USER 
GO
ALTER DATABASE [PatraPractical] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PatraPractical] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PatraPractical] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PatraPractical] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PatraPractical] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PatraPractical] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'PatraPractical', N'ON'
GO
ALTER DATABASE [PatraPractical] SET QUERY_STORE = OFF
GO
USE [PatraPractical]
GO
/****** Object:  Table [dbo].[Hierarchy]    Script Date: 9/13/2021 8:20:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hierarchy](
	[Parentage] [hierarchyid] NOT NULL,
	[AName] [varchar](150) NOT NULL,
	[TypeID] [int] NULL,
	[ACode] [varchar](50) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk] PRIMARY KEY CLUSTERED 
(
	[Parentage] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Perms]    Script Date: 9/13/2021 8:20:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Perms](
	[PermID] [int] IDENTITY(1,1) NOT NULL,
	[ParentagePerm] [varchar](50) NOT NULL,
	[UserID] [int] NULL,
 CONSTRAINT [PK_Perms] PRIMARY KEY CLUSTERED 
(
	[PermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Types]    Script Date: 9/13/2021 8:20:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Types](
	[TypeID] [int] IDENTITY(1,1) NOT NULL,
	[AType] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Types] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 9/13/2021 8:20:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NOT NULL,
	[ClientID] [hierarchyid] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Hierarchy]  WITH CHECK ADD  CONSTRAINT [FK_Hierarchy_Types] FOREIGN KEY([TypeID])
REFERENCES [dbo].[Types] ([TypeID])
GO
ALTER TABLE [dbo].[Hierarchy] CHECK CONSTRAINT [FK_Hierarchy_Types]
GO
ALTER TABLE [dbo].[Perms]  WITH CHECK ADD  CONSTRAINT [FK_Perms_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Perms] CHECK CONSTRAINT [FK_Perms_Users]
GO
USE [master]
GO
ALTER DATABASE [PatraPractical] SET  READ_WRITE 
GO
