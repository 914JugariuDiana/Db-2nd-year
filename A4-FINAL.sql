USE nop

USE soooStupid

ALTER TABLE Feedback 
DELETE CONSTRAINT PK_F PRIMARY KEY (feedback_id,feedback_date)


ALTER TABLE DishIncredient
	ADD CONSTRAINT PK_id PRIMARY KEY (id);
	
CREATE OR ALTER PROCEDURE addTables (@tName VARCHAR(50)) AS
	IF @tName IN (SELECT Name FROM Tables) BEGIN
		PRINT 'Table already in Tables'
		RETURN
	END
	IF @tName NOT IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES) BEGIN
		PRINT 'Table does not exist'
		RETURN
	END
	INSERT INTO Tables (Name) VALUES (@tName)

CREATE OR ALTER PROCEDURE addView (@vName VARCHAR(50)) AS
	IF @vName IN (SELECT Name FROM Views) BEGIN
		PRINT 'View already in Views'
		RETURN
	END
	IF @vName NOT IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS) BEGIN
		PRINT 'View does not exist'
		RETURN
	END
	INSERT INTO Views (Name) VALUES (@vName)

CREATE OR ALTER PROCEDURE addTest (@tName VARCHAR (50)) AS 
	IF @tName IN (SELECT Name FROM Tests) BEGIN
		PRINT 'Test already in Tests'
		RETURN 
	END
	INSERT INTO Tests (Name) VALUES (@tName)

CREATE OR ALTER PROCEDURE connectTestToTables(@testName VARCHAR(50), @tableName VARCHAR(50), @rows INT, @pos INT) AS
	IF @testName NOT IN (SELECT Name FROM Tests) BEGIN
		PRINT 'Test not in Tests'
		RETURN 
	END
	IF @tableName NOT IN (SELECT Name FROM Tables) BEGIN
		PRINT 'Table not in Tables'
		RETURN 
	END
	IF EXISTS ( SELECT * FROM TestTables T1
				JOIN Tests T2 ON T1.TestID = T2.TestID
				WHERE T2.Name = @testName AND Position = @pos) BEGIN
		PRINT 'Position is not correct'
		RETURN
	END
	INSERT INTO TestTables (TestID, TableID, NoOfRows, Position) VALUES(
		(SELECT Tests.TestID FROM Tests WHERE Name = @testName),
		(SELECT Tables.TableID FROM Tables WHERE Name=@tableName),
		@rows, @pos)

CREATE OR ALTER PROCEDURE connectTestToViews(@viewName VARCHAR (50), @testName VARCHAR(50)) AS
	IF @testName NOT IN (SELECT Name FROM Tests) BEGIN
		PRINT 'Test not in Tests'
		RETURN
	END
	IF @viewName NOT IN (SELECT Name FROM Views) BEGIN
		PRINT 'View not in ViewS'
		RETURN
	END
	INSERT INTO TestViews (TestID, ViewID) VALUES (
		(SELECT Tests.TestID FROM Tests WHERE Name = @testName),
		(SELECT Views.ViewID FROM Views WHERE Name = @viewName))

CREATE OR ALTER PROCEDURE runTest(@testName VARCHAR (50)) AS
	IF @testName NOT IN (SELECT Name FROM Tests) BEGIN
		PRINT 'Test not in Tests'
		RETURN
	END

	DECLARE @command VARCHAR(100)
	DECLARE @table VARCHAR(50)
	DECLARE @view VARCHAR(50)
	DECLARE @testStartTime DATETIME2 
	DECLARE @startTime DATETIME2 
	DECLARE @endTime DATETIME2
	DECLARE @rows INT
	DECLARE @pos INT
	DECLARE @testRunId INT
	DECLARE @testId INT

	SELECT @testId = TestID FROM Tests WHERE Name = @testName
	SET @testRunId = (SELECT MAX(TestRunId)+1 FROM TestRuns)
	IF @testRunId IS NULL
		SET @testRunId = 0
	
	PRINT 1 

	DECLARE tableCursor CURSOR SCROLL FOR
		SELECT T1.Name, T2.NoOfRows, T2.Position
		FROM Tables T1 
		JOIN TestTables T2 ON T1.TableID = T2.TableID
		WHERE T2.TestID = @testId
		ORDER BY T2.TestID
		
	PRINT 2

	DECLARE viewCursor CURSOR FOR
		SELECT V.Name
		FROM Views V
		JOIN TestViews TV ON V.ViewID = TV.ViewID
		WHERE TV.TestID = @testId

	SET @testStartTime = SYSDATETIME()
	
	PRINT 3

	OPEN tableCursor 
	FETCH LAST FROM tableCursor INTO @table , @rows, @pos
	WHILE @@FETCH_STATUS = 0 BEGIN
		EXEC ('delete from ' + @table)
		FETCH PRIOR FROM tableCursor INTO @table, @rows, @pos
	END

	CLOSE tableCursor
	OPEN tableCursor
	SET IDENTITY_INSERT TestRuns ON
	INSERT INTO TestRuns (TestRunID, Description, StartAt) VALUES (@testRunId, 'Test results for: ' + @testName, @testStartTime)


	SET IDENTITY_INSERT TestRuns OFF
	FETCH tableCursor INTO @table, @rows, @pos

	PRINT 4

	WHILE @@FETCH_STATUS = 0 BEGIN
		SET @command = 'populateTable' + @table
		IF @command NOT IN (SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES) BEGIN
			PRINT @command + 'does not exist'
			RETURN
		END

		SET @startTime = SYSDATETIME()
		EXEC @command @rows
		SET @endTime = SYSDATETIME()
		INSERT INTO TestRunTables (TestRunID, TableId, StartAt, EndAt) VALUES (@testRunId, (SELECT TableID FROM Tables WHERE Name = @table), @startTime, @endTime)
		FETCH tableCursor INTO @table, @rows, @pos
	END
	PRINT 4

	CLOSE tableCursor
	DEALLOCATE tableCursor

	OPEN viewCursor
	FETCH viewCursor INTO @view
	WHILE @@FETCH_STATUS = 0 BEGIN
		SET @command = 'SELECT * FROM ' + @view
		SET @startTime = SYSDATETIME()
		EXEC (@command)
		SET @endTime = SYSDATETIME()
		INSERT INTO TestRunViews (TestRunID, ViewID, StartAt, EndAt) VALUES (@testRunId, (SELECT ViewID FROM VIEws WHERE Name = @view), @startTime, @endTime)
		FETCH viewCursor INTO @view
	END
	CLOSE viewCursor
	DEALLOCATE viewCursor

	UPDATE TestRuns
	SET EndAt = SYSDATETIME()
	WHERE TestRunID = @testRunId
GO



CREATE OR ALTER PROCEDURE RandomStringMaker @length smallInt, @tempString VARCHAR(50) OUTPUT 
	AS BEGIN
	DECLARE @Counter smallint
	SET @tempString = ''
	SET @Counter = 1;
	WHILE @Counter < @length + 1 
		BEGIN 
			Set @tempString = @tempString + CHAR(CAST((122 - 97 )*RAND() + 97  as integer))
			Set @Counter = @Counter + 1;
		END
	END
GO
-----------------------------------------------------------------------------------



CREATE OR ALTER VIEW getIngredientsDetails AS
	SELECT ingredient_name, quantity, min_necesary_cuantity
	FROM Ingredient
	WHERE quantity - min_necesary_cuantity < 50

CREATE OR ALTER VIEW getDishesIngredients AS
	SELECT dish_name, ingredient_name
	FROM  Dish
	INNER JOIN DishIncredient
	ON Dish.dish_id = DishIncredient.dish_id
	INNER JOIN Ingredient
	ON DishIncredient.ingredient_id = Ingredient.ingredient_id;

CREATE OR ALTER VIEW getIngredientFromDishes AS
	SELECT COUNT(AA.dish_name) AS NumberDishes, AA.ingredient_name
	FROM  (SELECT dish_name, ingredient_name
		FROM Dish
		INNER JOIN DishIncredient
		ON Dish.dish_id = DishIncredient.dish_id
		INNER JOIN Ingredient
		ON DishIncredient.ingredient_id = Ingredient.ingredient_id) AS AA
	GROUP BY AA.ingredient_name


CREATE OR ALTER PROCEDURE populateTableDish(@rows INT) AS
	WHILE @rows > 0 BEGIN
		INSERT INTO Dish(dish_name, chef_id) VALUES ('NAME' + CAST(@rows AS VARCHAR(4)), (select top 1 chef_CNP from Chef order by newid()))
		SET @rows = @rows - 1
	END

CREATE OR ALTER PROCEDURE populateTableDishIncredient(@rows INT) AS
	WHILE @rows > 0 BEGIN
		DECLARE @DID INT
		DECLARE @IID INT
		SET @DID = (select top 1 dish_id from Dish order by newid())
		SET @IID = (select top 1 ingredient_id from Ingredient order by newid())
		WHILE @DID IN (SELECT dish_id FROM DishIncredient WHERE @IID = ingredient_id) BEGIN
			SET @DID = (select top 1 dish_id from Dish order by newid())
			SET @IID = (select top 1 ingredient_id from Ingredient order by newid())
		END
		INSERT INTO DishIncredient(dish_id, ingredient_id) VALUES (@DID, @IID)
		SET @rows = @rows - 1
	END

CREATE OR ALTER PROCEDURE populateTableIngredient(@rows INT) AS
	WHILE @rows > 0 BEGIN
		INSERT INTO Ingredient(ingredient_name, min_necesary_cuantity, quantity) VALUES (CAST(@rows AS VARCHAR(4)) + 'NAME', RAND() * 10, RAND() * 1000)
		SET @rows = @rows - 1
	END

CREATE OR ALTER PROCEDURE populateTableChef(@rows INT) AS
	WHILE @rows > 0 BEGIN
		INSERT INTO Chef(chef_CNP, chef_name, salary) VALUES (@rows, CAST(@rows AS VARCHAR(4)) + 'NAME', RAND() * 1000)
		SET @rows = @rows - 1
	END

delete from Chef
exec populateTableChef 1000


delete from Dish
exec populateTableDish 900


delete from Ingredient 
exec populateTableIngredient 700


delete from DishIncredient
exec populateTableDishIncredient 500


select * from Tests

EXEC addTables 'Ingredient'
EXEC addView 'getIngredientsDetails'
EXEC addTest 'test3'
EXEC connectTestToTables 'test1', 'Ingredient', 700, 4
EXEC connectTestToViews 'getIngredientsDetails', 'test3'
	
EXEC addTables 'Chef'
EXEC addTest 'test2'
EXEC connectTestToTables 'test2', 'Chef', 1000, 3

EXEC addTables 'Dish'
EXEC addTest 'test1'
EXEC connectTestToTables 'test1', 'Dish', 900, 2

exec runTest 'test1'

EXEC addTables 'DishIncredient'
EXEC addView 'getDishesIngredients'
EXEC addView 'getIngredientFromDishes'
EXEC addTest 'test0'
EXEC connectTestToTables 'test0', 'DishIncredient', 500, 1
EXEC connectTestToViews 'getDishesIngredients', 'test0'
EXEC connectTestToViews 'getIngredientFromDishes', 'test0'

exec runTest 'test0'

select * from DishIncredient
select * from Ingredient
select * from Dish
select * from Chef
select * from TestViews
delete from Dish
delete from Ingredient
delete from DishIncredient
delete from DishIncredient

select * from TestRuns
select * from TestRunViews
select * from TestRunTables
select * from TestRunViews

DELETE FROM TestTables



ALTER TABLE OrderDishes
ADD CONSTRAINT PK_id PRIMARY KEY (order_id, dish_id);


/*Tests – holds data about different tests;
Tables – holds data about tables that can take part in tests;
TestTables – junction table between Tests and Tables (which tables take part in which tests);
Views – holds data about a set of views from the database, used to assess the performance of certain SQL queries;
TestViews – junction table between Tests and Views (which views take part in which tests);
TestRuns – contains data about different test runs;
– a test can be run multiple times; running test T involves:

deleting the data from test T’s tables, in the order specified by the Position field in table TestTables;
inserting data into test T’s tables in reverse deletion order; the number of records to insert into each table is stored in the NoOfRows field in table TestTables;
evaluating test T’s views;
TestRunTables – contains performance data for INSERT operations for each table in each test run;
TestRunViews – contains performance data for each view in each test run. See example here.

Your task is to implement a set of stored procedures to run tests and store their results. Your tests must include at least 3 tables:

a table with a single-column primary key and no foreign keys;
a table with a single-column primary key and at least one foreign key;
a table with a multicolumn primary key,
and 3 views:

a view with a SELECT statement operating on one table;
a view with a SELECT statement that operates on at least 2 different tables and contains at least one JOIN operator;
a view with a SELECT statement that has a GROUP BY clause, operates on at least 2 different tables and contains at least one JOIN operator.
Obs. The way you implement the stored procedures and / or functions is up to you. Results which allow the system to be extended to new tables / views with minimal or no code at all will be more appreciated.

The script for creating the relational structure above can be downloaded here: Lab4Script.
Test1's configuration:
- table T1: NoOfRows = 10000, Position = 1
- table T2: NoOfRows = 2000, Position = 2
- table T3: NoOfRows = 500, Position = 3
- views V1, V2


run Test1 => test run with TestRunId = 7
- delete all rows from T1
- delete all rows from T2
- delete all rows from T3
- insert 500 rows into T3
- insert 2000 rows into T2
- insert 10000 rows into T1
- SELECT * FROM V1
- SELECT * FROM V2

For test run with TestRunId = 7: 
- store its "StartAt", "EndAt" in TestRuns
- for the INSERT on T3: store its "StartAt", "EndAt" in TestRunTables
- for the INSERT on T2: store its "StartAt", "EndAt" in TestRunTables
- for the INSERT on T1: store its "StartAt", "EndAt" in TestRunTables
- for the SELECT on V1: store its "StartAt", "EndAt" in TestRunViews
- for the SELECT on V2: store its "StartAt", "EndAt" in TestRunViews*/

if exists (select * from dbo.sysobjects where id = object_id(N'[FK_TestRunTables_Tables]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [TestRunTables] DROP CONSTRAINT FK_TestRunTables_Tables
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[FK_TestTables_Tables]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [TestTables] DROP CONSTRAINT FK_TestTables_Tables
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[FK_TestRunTables_TestRuns]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [TestRunTables] DROP CONSTRAINT FK_TestRunTables_TestRuns
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[FK_TestRunViews_TestRuns]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [TestRunViews] DROP CONSTRAINT FK_TestRunViews_TestRuns
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[FK_TestTables_Tests]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [TestTables] DROP CONSTRAINT FK_TestTables_Tests
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[FK_TestViews_Tests]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [TestViews] DROP CONSTRAINT FK_TestViews_Tests
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[FK_TestRunViews_Views]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [TestRunViews] DROP CONSTRAINT FK_TestRunViews_Views
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[FK_TestViews_Views]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [TestViews] DROP CONSTRAINT FK_TestViews_Views
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[Tables]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Tables]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[TestRunTables]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TestRunTables]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[TestRunViews]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TestRunViews]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[TestRuns]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TestRuns]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[TestTables]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TestTables]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[TestViews]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TestViews]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[Tests]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Tests]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[Views]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Views]
GO

CREATE TABLE [Tables] (
	[TableID] [int] IDENTITY (1, 1) NOT NULL ,
	[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [TestRunTables] (
	[TestRunID] [int] NOT NULL ,
	[TableID] [int] NOT NULL ,
	[StartAt] [datetime] NOT NULL ,
	[EndAt] [datetime] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [TestRunViews] (
	[TestRunID] [int] NOT NULL ,
	[ViewID] [int] NOT NULL ,
	[StartAt] [datetime] NOT NULL ,
	[EndAt] [datetime] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [TestRuns] (
	[TestRunID] [int] IDENTITY (1, 1) NOT NULL ,
	[Description] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[StartAt] [datetime] NULL ,
	[EndAt] [datetime] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [TestTables] (
	[TestID] [int] NOT NULL ,
	[TableID] [int] NOT NULL ,
	[NoOfRows] [int] NOT NULL ,
	[Position] [int] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [TestViews] (
	[TestID] [int] NOT NULL ,
	[ViewID] [int] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [Tests] (
	[TestID] [int] IDENTITY (1, 1) NOT NULL ,
	[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [Views] (
	[ViewID] [int] IDENTITY (1, 1) NOT NULL ,
	[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [Tables] WITH NOCHECK ADD 
	CONSTRAINT [PK_Tables] PRIMARY KEY  CLUSTERED 
	(
		[TableID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [TestRunTables] WITH NOCHECK ADD 
	CONSTRAINT [PK_TestRunTables] PRIMARY KEY  CLUSTERED 
	(
		[TestRunID],
		[TableID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [TestRunViews] WITH NOCHECK ADD 
	CONSTRAINT [PK_TestRunViews] PRIMARY KEY  CLUSTERED 
	(
		[TestRunID],
		[ViewID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [TestRuns] WITH NOCHECK ADD 
	CONSTRAINT [PK_TestRuns] PRIMARY KEY  CLUSTERED 
	(
		[TestRunID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [TestTables] WITH NOCHECK ADD 
	CONSTRAINT [PK_TestTables] PRIMARY KEY  CLUSTERED 
	(
		[TestID],
		[TableID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [TestViews] WITH NOCHECK ADD 
	CONSTRAINT [PK_TestViews] PRIMARY KEY  CLUSTERED 
	(
		[TestID],
		[ViewID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [Tests] WITH NOCHECK ADD 
	CONSTRAINT [PK_Tests] PRIMARY KEY  CLUSTERED 
	(
		[TestID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [Views] WITH NOCHECK ADD 
	CONSTRAINT [PK_Views] PRIMARY KEY  CLUSTERED 
	(
		[ViewID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [TestRunTables] ADD 
	CONSTRAINT [FK_TestRunTables_Tables] FOREIGN KEY 
	(
		[TableID]
	) REFERENCES [Tables] (
		[TableID]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_TestRunTables_TestRuns] FOREIGN KEY 
	(
		[TestRunID]
	) REFERENCES [TestRuns] (
		[TestRunID]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO

ALTER TABLE [TestRunViews] ADD 
	CONSTRAINT [FK_TestRunViews_TestRuns] FOREIGN KEY 
	(
		[TestRunID]
	) REFERENCES [TestRuns] (
		[TestRunID]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_TestRunViews_Views] FOREIGN KEY 
	(
		[ViewID]
	) REFERENCES [Views] (
		[ViewID]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO

ALTER TABLE [TestTables] ADD 
	CONSTRAINT [FK_TestTables_Tables] FOREIGN KEY 
	(
		[TableID]
	) REFERENCES [Tables] (
		[TableID]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_TestTables_Tests] FOREIGN KEY 
	(
		[TestID]
	) REFERENCES [Tests] (
		[TestID]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO

ALTER TABLE [TestViews] ADD 
	CONSTRAINT [FK_TestViews_Tests] FOREIGN KEY 
	(
		[TestID]
	) REFERENCES [Tests] (
		[TestID]
	),
	CONSTRAINT [FK_TestViews_Views] FOREIGN KEY 
	(
		[ViewID]
	) REFERENCES [Views] (
		[ViewID]
	)
GO
