USE soooStupid 

--Write SQL scripts that:
--a. modify the type of a column;

CREATE PROCEDURE a1 AS
	ALTER TABLE Food_order
	ALTER COLUMN preparation_time TINYINT
GO

CREATE PROCEDURE b1 AS
	ALTER TABLE Food_order
	ALTER COLUMN preparation_time INT
GO

--b. add / remove a column;

CREATE PROCEDURE a2 AS
	ALTER TABLE Feedback
	ADD rating TINYINT;
GO

CREATE PROCEDURE b2 AS
	ALTER TABLE Feedback
	DROP COLUMN rating;
GO

--c. add / remove a DEFAULT constraint;

CREATE PROCEDURE a3 AS
	ALTER TABLE Food_order
	ADD CONSTRAINT Ndelivery
	DEFAULT 0 FOR delivery;
GO

CREATE PROCEDURE b3 AS
	ALTER TABLE Food_order
	DROP CONSTRAINT Ndelivery;
GO
--d. add / remove a primary key;
CREATE PROCEDURE a4 AS
	ALTER TABLE DishIncredient
	ADD id TINYINT IDENTITY
	ALTER TABLE DishIncredient
	ADD CONSTRAINT PK_id PRIMARY KEY (id);
GO

CREATE PROCEDURE b4 AS
	ALTER TABLE DishIncredient
	DROP CONSTRAINT [PK_id]
	ALTER TABLE DishIncredient
	DROP COLUMN id
GO 

--e. add / remove a candidate key;
CREATE PROCEDURE a5 AS
	ALTER TABLE DishIncredient
	ADD CONSTRAINT CK_key
	UNIQUE (ingredient_id, dish_id)
GO

CREATE PROCEDURE b5 AS
	ALTER TABLE DishIncredient
	DROP CONSTRAINT CK_key
GO

--f. add / remove a foreign key;
--g. create / drop a table.

CREATE PROCEDURE a6 AS
	CREATE TABLE Supplier(
		s_id INT IDENTITY PRIMARY KEY,
		s_name VARCHAR(50),
		city VARCHAR(50)
	)
GO

CREATE PROCEDURE a7 AS
	ALTER TABLE Ingredient
	ADD supplier_id INT
	ALTER TABLE Ingredient
	ADD CONSTRAINT FK_supplierID
	FOREIGN KEY (supplier_id) REFERENCES Supplier(s_id);
GO

CREATE PROCEDURE b7 AS
	ALTER TABLE Ingredient
	DROP CONSTRAINT [FK_supplierID];
	ALTER TABLE Ingredient
	DROP COLUMN supplier_id
GO

CREATE PROCEDURE b6 AS
	DROP TABLE Supplier
GO

CREATE TABLE currentVersion(
	version INT
);

INSERT INTO currentVersion(version) VALUES (0)

CREATE PROCEDURE run @version NVARCHAR(50) AS
	exec @version
GO

CREATE OR ALTER PROCEDURE getToVersion @ver INT AS
	DECLARE @CPoz INT
	DECLARE @Counter VARCHAR(3)
	SET @CPoz = (SELECT * FROM currentVersion)
	IF (@ver > 0 AND @ver < 8)
	BEGIN
		WHILE ( @ver < @CPoz AND @ver > 0)
			BEGIN
				SET @Counter='b'
				SET @Counter += CAST(@CPoz AS VARCHAR(2))
				Exec run @version =  @Counter
				SET @CPoz = @CPoz - 1
		END
		WHILE ( @ver > @CPoz AND @ver < 8)
			BEGIN
				SET @Counter='a'
				SET @CPoz = @CPoz + 1
				SET @Counter += CAST(@CPoz AS VARCHAR(2))
				Exec run @version =  @Counter
		END
		DELETE currentVersion
		INSERT INTO currentVersion(version) VALUES (@CPoz)
	END
	ELSE
		PRINT ('Incorect version');
GO
select * from currentVersion
DROP PROCEDURE getToVersion
EXEC getToVersion @ver = -1

/*For each of the scripts above, write another one that reverts the operation. Place each script in a stored procedure. Use a simple, intuitive naming convention.
Create a new table that holds the current version of the database schema. Simplifying assumption: the version is an integer number.
Write a stored procedure that receives as a parameter a version number and brings the database to that version.
Useful references:*/

SELECT * FROM OrderDishes;
select * from Customer;
SELECT * FROM Food_order;
select * from Dish;
select * from Feedback;
select * from DishIncredient;
select * from Chef;
select * from Ingredient;
select * from Restaurant;
select * from RestaurantCustomer;
select * from Waiter;
select * from Driver;
select * from CustomerWaiter;
