use nop

select * from CustomerWaiter

ALTER TABLE CustomerWaiter ADD cwID INT IDENTITY

ALTER TABLE CustomerWaiter
ALTER COLUMN cwID int NOT NULL;

ALTER TABLE CustomerWaiter
ADD CONSTRAINT ID PRIMARY KEY (cwID);

ALTER TABLE Customer ADD age INT 

ALTER TABLE Customer
ADD CONSTRAINT uage UNIQUE (age);

--CREATE CLUSTERED INDEX ageIndex
ON Customer(age ASC)


CREATE OR ALTER PROCEDURE populateCustomer(@rows INT) AS
	WHILE @rows > 0 BEGIN
		DECLARE @AGE INT
		SET @AGE = (20 * @rows - 10 * RAND())
		WHILE @AGE IN (SELECT age FROM Customer) BEGIN
			SET @AGE = (20 * @rows - 10 * RAND())
		END
		INSERT INTO Customer(customer_name, phone_number, age, City) VALUES ('NAME', 1110000*RAND(), @AGE, 'CITY' + CAST(@rows AS VARCHAR(4)))
		SET @rows = @rows - 1
	END

CREATE OR ALTER PROCEDURE populateWaiter(@rows INT) AS
	WHILE @rows > 0 BEGIN
		INSERT INTO Waiter(waiter_CNP, waiter_name, salary) VALUES (CAST(@rows AS VARCHAR(15)), 'NAME' + CAST(@rows AS VARCHAR(4)), RAND() * 1000)
		--PRINT @ROWS
		SET @rows = @rows - 1
	END

CREATE OR ALTER PROCEDURE populateCustomerWaiter(@rows INT) AS
	WHILE @rows > 0 BEGIN
		INSERT INTO CustomerWaiter(customer_id, waiter_id) VALUES ((select top 1 customer_id from Customer order by newid()), (select top 1 waiter_CNP from Waiter order by newid()))
		SET @rows = @rows - 1
	END

DELETE FROM CustomerWaiter

EXEC populateCustomer 500000
EXEC populateWaiter 200000
EXEC populateCustomerWaiter 8765


--a. Write queries on Ta such that their execution plans contain the following operators:

--clustered index scan;
	SELECT * FROM Customer 
	ORDER BY customer_id DESC

--clustered index seek;
	SELECT customer_id, customer_name, age FROM Customer 
	WHERE customer_id = 774100

--nonclustered index scan;
	CREATE INDEX iAGE ON Customer (age ASC)
	
	DROP INDEX Customer.iAGE 

	SELECT * FROM Customer
	ORDER BY age

--nonclustered index seek;
	SELECT * FROM Customer
	WHERE age = 50

--key lookup.
	SELECT * FROM Customer
	WHERE age = 16

	ALTER INDEX iAGE
	ON Customer DISABLE 

	ALTER INDEX iAGE
	ON Customer REBUILD 
	
--b. Write a query on table Tb with a WHERE clause of the form WHERE b2 = value and analyze its execution plan. Create a nonclustered index that can speed up 
--the query. Examine the execution plan again.
	DECLARE @S DATETIME
	SET @S = GETDATE()		

	SELECT * FROM Waiter
	WHERE salary = 343 -- 37 MS

	DECLARE @F DATETIME
	SET @F = GETDATE()	

	SELECT DATEDIFF(MS, @S, @F)

	CREATE NONCLUSTERED INDEX SINDEX ON Waiter (waiter_CNP, salary)
	
	ALTER INDEX SINDEX
	ON Waiter DISABLE 

	ALTER INDEX SINDEX
	ON Waiter REBUILD 

--c. Create a view that joins at least 2 tables. Check whether existing indexes are helpful; if not, reassess existing indexes / examine the cardinality of 
--the tables.

	CREATE OR ALTER VIEW informations AS
		SELECT Customer.customer_name, Waiter.waiter_CNP, Waiter.salary 
		FROM Customer 
		INNER JOIN CustomerWaiter
		ON Customer.customer_id = CustomerWaiter.customer_id
		INNER JOIN Waiter
		ON CustomerWaiter.waiter_id = Waiter.waiter_CNP
		WHERE age > 1000 AND salary < 500
		
	DECLARE @S DATETIME
	SET @S = GETDATE()		

	SELECT * FROM informations

	DECLARE @F DATETIME
	SET @F = GETDATE()	

	SELECT DATEDIFF(MS, @S, @F)

	-- NO INDEXES 340
	-- WITH INDEXES 303