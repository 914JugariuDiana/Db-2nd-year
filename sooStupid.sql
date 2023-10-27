use soooStupid

CREATE TABLE Restaurant(
	restaurant_id INT PRIMARY KEY IDENTITY,
	restaurant_name VARCHAR(30),
	restaurant_address VARCHAR(50),
	phone_number VARCHAR(15),
);

CREATE TABLE Customer(
	customer_id	INT PRIMARY KEY IDENTITY,
	customer_name VARCHAR(50),
	customer_address VARCHAR(50),
	phone_number VARCHAR(15),
);

CREATE TABLE Waiter(
	waiter_CNP VARCHAR(13) PRIMARY KEY,
	waiter_name VARCHAR(50),
	salary INT,
);

CREATE TABLE CustomerWaiter(
	customer_id	INT FOREIGN KEY REFERENCES Customer(customer_id),
	waiter_id VARCHAR(13) FOREIGN KEY REFERENCES Waiter(waiter_CNP),
);

CREATE TABLE Driver(
	driver_CNP VARCHAR(13) PRIMARY KEY,
	driver_name VARCHAR(30),
	car VARCHAR(30),
);

CREATE TABLE Food_order(
	order_id INT PRIMARY KEY IDENTITY,
	delivery BIT,
	preparation_time INT,
	waiter_id VARCHAR(13) FOREIGN KEY REFERENCES Waiter(waiter_CNP),
	driver_id VARCHAR(13) FOREIGN KEY REFERENCES Driver(driver_CNP),
	customer_id INT FOREIGN KEY REFERENCES Customer(customer_id),
);

CREATE TABLE Bill(
	bill_id INT PRIMARY KEY IDENTITY,
	price INT,
	order_id INT FOREIGN KEY REFERENCES Food_order(order_id),
);


CREATE TABLE Chef(
	chef_CNP VARCHAR(13) PRIMARY KEY,
	chef_name VARCHAR(50),
	salary INT,
);

CREATE TABLE Dish(
	dish_id	INT PRIMARY KEY IDENTITY,
	dish_name VARCHAR(30),
	chef_id VARCHAR(13) FOREIGN KEY REFERENCES Chef(chef_CNP),
);

CREATE TABLE Ingredient(
	ingredient_id INT PRIMARY KEY IDENTITY,
	ingredient_name VARCHAR(30),
	quantity INT,
	min_necesary_cuantity INT,
);

CREATE TABLE DishIncredient(
	ingredient_id INT FOREIGN KEY REFERENCES Ingredient(ingredient_id),
	dish_id	INT FOREIGN KEY REFERENCES Dish(dish_id),
	UNIQUE(dish_id, ingredient_id),
);

CREATE TABLE Feedback(
	feedback_id INT PRIMARY KEY IDENTITY,
	feedback_date DATETIME,
	content VARCHAR(100),
	customer_id INT FOREIGN KEY REFERENCES Customer(customer_id),
);
CREATE TABLE OrderDishes(
	order_id INT FOREIGN KEY REFERENCES Food_order(order_id) NOT NULL,
	dish_id	INT FOREIGN KEY REFERENCES Dish(dish_id) NOT NULL,
	UNIQUE(order_id, dish_id),
);

CREATE TABLE RestaurantCustomer(
	restaurant_id INT FOREIGN KEY REFERENCES Restaurant(restaurant_id),
	customer_id	INT FOREIGN KEY REFERENCES Customer(customer_id),
	UNIQUE(restaurant_id, customer_id),
);

ALTER TABLE Customer
ADD City VARCHAR(20);

ALTER TABLE Restaurant
ADD City VARCHAR(20);

INSERT INTO Restaurant(restaurant_name, restaurant_address, phone_number) VALUES ('Shadow', 'str.Mihali nr 30', '0720055434'),
																				('Times', 'str.Babes nr 30', '0715666434'),
																				('Einstein', 'str.Bolyai nr 30', '0727589434'),
																				('Slow Death', 'str.Brancoveanu nr 30', '0721155434');
INSERT INTO Restaurant(restaurant_name, restaurant_address, phone_number, City) VALUES ('VIVA', 'str.Mihali nr 3', '0720055999', 'Alba'),
																					  ('New Times', 'str.Babes nr 5', '0715666999', 'Cluj'),
																					  ('Stein', 'str.Bolyai nr 20', '0727599999', 'Cluj'),
																					  ('Death', 'str.Brancoveanu nr 35', '0721199994', 'Brasov');

INSERT INTO Customer(customer_name, customer_address, phone_number) VALUES ('Ana Maria', 'str.Mihali nr 10', '0721115434'),
																		  ('Veronica Miclea', 'str.Babes nr 40', '0715622224'),
																		  ('Einstein Pop', 'str.Bolyai nr 3', '0777779434'),
																		  ('Horea What', 'str.Brancoveanu nr 20', '0788899934');

INSERT INTO Customer(customer_name, customer_address, phone_number, City) VALUES ('Maria Ana', 'str.Mihali nr 10', '0733115434', 'Cluj'),
																		  ('Vero Miclea', 'str.Babes nr 40', '0744622224', 'Oradea'),
																		  ('Stein Pop', 'str.Bolyai nr 3', '0755779434', 'Pitesti'),
																		  ('Horea Stan', 'str.Brancoveanu nr 20', '0766899934', 'Baia Mare');

INSERT INTO Customer(customer_name) VALUES ('Viorel Iugan'),
										   ('Ion Neagu'),
										   ('Gheorghe Matei'),
										   ('Valentin Trif');

INSERT INTO RestaurantCustomer(restaurant_id, customer_id) VALUES (1, 1), (1, 4), (4, 2), (3, 1), (2, 3);

INSERT INTO RestaurantCustomer(restaurant_id, customer_id) VALUES (5, 9), (8, 10), (8, 11), (7, 12), (6, 1);

INSERT INTO Waiter(waiter_CNP, waiter_name, salary) VALUES ('789545654585', 'Vasile Vasilescu', 2500),
														   ('125841565854', 'Veronica Einstein',  4000),
														   ('651474414744', 'Iclea Pop', 2000),
														   ('111222333344', 'Joseph What', 1934);
INSERT INTO Waiter(waiter_CNP, waiter_name, salary) VALUES ('780005654585', 'Ion Vasilescu', 3000),
														   ('125000565854', 'Mircea Viorel',  4000),
														   ('651400014744', 'Vasile Pop', 2000);
INSERT INTO Waiter(waiter_CNP, waiter_name, salary) VALUES ('700005654585', 'Ion Vasi', 6000);

INSERT INTO CustomerWaiter(customer_id, waiter_id) VALUES (1, '111222333344'), (1, '651474414744'), 
														  (4, '789545654585'), (3, '125841565854'),
														  (2, '789545654585');

INSERT INTO CustomerWaiter(customer_id, waiter_id) VALUES (9, '780005654585'), (12, '651474414744'), 
														  (10, '125000565854'), (8, '651400014744'),
														  (11, '789545654585');

INSERT INTO Ingredient(ingredient_name, quantity, min_necesary_cuantity) VALUES ('Salt', 150, 50),
													('Pasta', 200, 100), ('Tomato paste', 500, 100),
													('Chicken breast', 550, 100), ('Patatoes', 750, 150),
													('Fish', 450, 100);

INSERT INTO Chef(chef_CNP, chef_name, salary) VALUES ('782225654585', 'Vasile Marinescu', 3000),
													 ('121111565854', 'Maria Marinescu',  4000),
													 ('653334414744', 'Zizin Popa', 5000),
													 ('115552333344', 'Jose What', 3500);
INSERT INTO Chef(chef_CNP, chef_name, salary) VALUES ('121111565777', 'Adrian Marinescu',  2000),
													 ('653334414666', 'Leo Radish', 2800),
													 ('115552333555', 'Jose Pablo', 2700);
INSERT INTO Chef(chef_CNP, chef_name, salary) VALUES ('222211565777', 'Adi Marin',  4000);

INSERT INTO Dish(dish_name, chef_id) VALUES ('Pizza', '782225654585'), ('Soup', '653334414744'),
											('Pancakes', '121111565854'), ('Hamburger', '653334414744'), 
											('Pasta', '782225654585'), ('Chicken Pesto Panini', '115552333344'),
											('Tiramisu', '121111565854'), ('Chicken Shawarma with Potatoes', '115552333344');

INSERT INTO DishIncredient(dish_id, ingredient_id) VALUES (1, 1), (8, 1), (6, 1), (2, 1), (5, 2), (8, 4), (4, 3), (1, 3), (8, 5);

INSERT INTO Feedback(feedback_date, content, customer_id) VALUES ('2020-11-10 13:03:44', 'Extraordinary', 1),
																 ('2021-12-1 13:20:44', 'Slow service', 2), 
																 ('2022-11-1 19:23:44', 'Cold food', 4),
																 ('2020-1-11 20:23:44', 'Very tasty and nice waiters', 3)

INSERT INTO Driver(driver_CNP, driver_name, car) VALUES ('782225600000', 'Vasile Popa', 'Mercedes'),
														('121111511111', 'Ana Marinescu',  'BMW'),
														('653334422222', 'Zizin Marinescu', 'Opel'),
														('115552333333', 'Denis Croft', 'Audi');

INSERT INTO Driver(driver_CNP, driver_name, car) VALUES ('782225601110', 'Marian Popa', 'Mercedes'),
														('121111511122', 'Mircea Marinescu', NULL),
														('653334422333', 'Opra Lidl', NULL);
select * from customer
INSERT INTO Food_order(delivery, preparation_time, waiter_id, driver_id, customer_id) VALUES
	(1, 20, NULL, '115552333333', 13), (0, 15, '111222333344', NULL, 24),
	(0, 20, '125841565854', NULL, 14), (0, 15, '125841565854', NULL, 23);

INSERT INTO Food_order(delivery, preparation_time, waiter_id, driver_id, customer_id) VALUES
	(1, 25, NULL, '782225601110', 17), (1, 5, NULL, '782225601110', 22),
	(0, 30, '125000565854', NULL, 21), (0, 45, '125000565854', NULL, 19);

INSERT INTO OrderDishes(order_id, dish_id) VALUES (4, 1), (2, 5), (3, 7), (1, 2), (2, 3), (1, 7), (4, 8), (3, 6);

INSERT INTO Bill(price, order_id) VALUES (150, 2), (100, 1), (200, 3);
INSERT INTO Bill(price, order_id) VALUES (250, 4), (50, 5), (300, 6);
/*-------------------------------------------------------------------------------------------- */
INSERT INTO RestaurantCustomer(restaurant_id, customer_id) 
VALUES (10, 1)

ALTER TABLE Ingredient 
ADD CONSTRAINT min_necesary_cuantity CHECK (min_necesary_cuantity >= 50);

INSERT INTO Ingredient (ingredient_name, quantity, min_necesary_cuantity)
VALUES ('Zahar', 500, 20);


UPDATE Customer 
SET phone_number = '0723456789'
WHERE customer_address LIKE '%3';

UPDATE Bill 
SET price = 175
WHERE price > 150;

UPDATE Feedback
SET content = 'Awfull'
WHERE feedback_date NOT BETWEEN '2020' AND '2021';

DELETE FROM Chef 
WHERE salary IN (2700, 2800, 2900);

DELETE FROM DishIncredient
WHERE ingredient_id >= 5 OR ingredient_id = 1;

DELETE FROM Driver
WHERE car IS NULL;

SELECT DISTINCT restaurant_address
FROM Restaurant
ORDER BY restaurant_address

--a. 2 queries with the union operation; use UNION [ALL] and OR;
SELECT chef_CNP, chef_name, salary 
FROM Chef 
WHERE chef_name < 'JZ' OR chef_name > 'ZA'
UNION 
SELECT waiter_CNP, waiter_name, salary 
FROM Waiter
ORDER BY salary;

SELECT restaurant_address, phone_number
FROM Restaurant
UNION ALL
SELECT customer_address, phone_number
FROM Customer
WHERE customer_address IS NOT NULL
ORDER BY restaurant_address;

--b. 2 queries with the intersection operation; use INTERSECT and IN; *******************
SELECT salary
FROM Waiter
INTERSECT
SELECT salary
FROM Chef
ORDER BY salary DESC;

SELECT ingredient_name
FROM Ingredient 
WHERE ingredient_id IN
	(SELECT ingredient_id
	 FROM DishIncredient)

----------------------------------------------------------- 

UPDATE Customer
SET City = 'Iasi'
WHERE customer_id = 4;
UPDATE Customer 
SET City = 'Alba' 
WHERE customer_id = 2;
UPDATE Customer
SET City = 'Bucuresti'
WHERE customer_id = 3;
UPDATE Customer 
SET City = 'Cluj' 
WHERE customer_id = 1;


UPDATE Restaurant
SET City = 'Iasi'
WHERE restaurant_id = 1;
UPDATE Restaurant 
SET City = 'Alba' 
WHERE restaurant_id = 2;
UPDATE Restaurant 
SET City = 'Bucuresti'
WHERE restaurant_id = 3;
UPDATE Restaurant 
SET City = 'Cluj' 
WHERE restaurant_id = 4;
------------------------------------------------------------------------------

--c. 2 queries with the difference operation; use EXCEPT and NOT IN;
SELECT City
FROM Customer
WHERE City IS NOT NULL
EXCEPT
SELECT City
FROM Restaurant
WHERE City IS NOT NULL

SELECT dish_id, dish_name
FROM Dish 
WHERE dish_id NOT IN 
	(SELECT dish_id
	 FROM DishIncredient)
ORDER BY dish_name

--d. 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator); 
--one query will join at least 3 tables, while another one will join at least two many-to-many relationships;

SELECT dish_name, ingredient_name
FROM  Dish
INNER JOIN DishIncredient
ON Dish.dish_id = DishIncredient.dish_id
INNER JOIN Ingredient
ON DishIncredient.ingredient_id = Ingredient.ingredient_id;

SELECT chef_CNP, chef_name, dish_name, ingredient_name 
FROM Chef
LEFT JOIN Dish
ON Dish.chef_id = chef_CNP
LEFT JOIN DishIncredient
ON Dish.dish_id = DishIncredient.dish_id
LEFT JOIN Ingredient
ON DishIncredient.ingredient_id = Ingredient.ingredient_id

SELECT Food_order.order_id, dish_name, ingredient_name
FROM Food_order
FULL JOIN OrderDishes
ON Food_order.order_id = OrderDishes.order_id
FULL JOIN Dish
ON OrderDishes.dish_id = Dish.dish_id
FULL JOIN DishIncredient
ON DishIncredient.dish_id = Dish.dish_id
FULL JOIN Ingredient
ON DishIncredient.ingredient_id = Ingredient.ingredient_id

SELECT restaurant_name, restaurant_address, Restaurant.phone_number, content, customer_name
FROM Restaurant
RIGHT JOIN RestaurantCustomer
ON Restaurant.restaurant_id = RestaurantCustomer.restaurant_id
RIGHT JOIN Customer
ON Customer.customer_id = RestaurantCustomer.customer_id
RIGHT JOIN Feedback
ON Feedback.customer_id = Customer.customer_id

--e. 2 queries with the IN operator and a subquery in the WHERE clause; in at least one case, the subquery must include a subquery in its own WHERE clause;

SELECT waiter_name
FROM Waiter
WHERE waiter_CNP NOT IN (
	SELECT waiter_id
	FROM CustomerWaiter
	WHERE customer_id IN (
		SELECT customer_id 
		FROM RestaurantCustomer
		WHERE restaurant_id IN(
			SELECT restaurant_id 
			FROM Restaurant
			WHERE City = 'Cluj')))

SELECT driver_name
FROM Driver
WHERE driver_CNP IN (
	SELECT driver_id
	FROM Food_order
	WHERE order_id IN (
		SELECT order_id
		FROM Bill
		WHERE price < 150))

--f. 2 queries with the EXISTS operator and a subquery in the WHERE clause;

SELECT order_id
FROM Food_order
WHERE EXISTS (
	SELECT order_id
	FROM Bill
	WHERE Bill.order_id = Food_order.order_id AND price >= 150)

SELECT driver_CNP, driver_name
FROM Driver
WHERE EXISTS(
	SELECT order_id
	FROM Food_order
	WHERE Driver.driver_CNP = Food_order.driver_id AND preparation_time < 30)

--g. 2 queries with a subquery in the FROM clause;  

SELECT TOP 2 I.ingredient_name AS "Useless ingredients"
FROM ( SELECT ingredient_name
	   FROM Ingredient
	   WHERE ingredient_id NOT IN ( SELECT ingredient_id
									FROM DishIncredient)) AS I

SELECT A.driver_id
FROM (SELECT driver_id
	  FROM Food_order
	  WHERE order_id IN (SELECT order_id
						 FROM Bill
						 WHERE Bill.bill_id < 5)) AS A
WHERE A.driver_id IS NOT NULL

SELECT DISTINCT A.salary
FROM (SELECT salary
		FROM Waiter
		UNION
		SELECT salary
		FROM Chef) AS A
ORDER BY salary DESC

--h. 4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause; 2 of the latter will also have a subquery 
--in the HAVING clause; use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;

SELECT COUNT(waiter_CNP), salary
FROM Waiter
GROUP BY salary
ORDER BY COUNT(waiter_CNP) DESC

SELECT COUNT(Chef_CNP), salary
FROM Chef
GROUP BY salary
HAVING Chef.salary > (SELECT AVG(salary) FROM Chef);

SELECT COUNT(waiter_CNP), salary
FROM Waiter 
GROUP BY salary
HAVING Waiter.salary > (SELECT MIN(salary) FROM Chef)

SELECT COUNT(restaurant_id), City
FROM Restaurant
GROUP BY City
HAVING City LIKE '[ABC]%'

--i. 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator); rewrite 2 of them with 
--aggregation operators, and the other 2 with IN / [NOT] IN.

SELECT restaurant_name
FROM Restaurant
WHERE restaurant_id = ANY(
			SELECT restaurant_id
			FROM RestaurantCustomer
			WHERE Restaurant.restaurant_id = RestaurantCustomer.restaurant_id AND customer_id IN (
									SELECT customer_id
									FROM Customer
									WHERE customer_address LIKE 'str.B%'))

SELECT restaurant_name
FROM Restaurant
WHERE restaurant_id  IN(
			SELECT restaurant_id
			FROM RestaurantCustomer
			WHERE Restaurant.restaurant_id = RestaurantCustomer.restaurant_id AND customer_id IN (
									SELECT customer_id
									FROM Customer
									WHERE customer_address LIKE 'str.B%'))

SELECT chef_name, chef_CNP
FROM Chef
WHERE chef_CNP = ANY(
		SELECT chef_CNP
		FROM Chef
		WHERE chef_CNP > '5%')

SELECT chef_name, chef_CNP
FROM Chef
WHERE chef_CNP NOT IN(
		SELECT chef_CNP
		FROM Chef
		WHERE chef_CNP < '5%')

SELECT order_id, preparation_time
FROM Food_order
WHERE order_id = ALL (SELECT order_id
					 FROM Bill
					 WHERE price = 50)

SELECT order_id, preparation_time
FROM Food_order
WHERE order_id IN (SELECT order_id
					 FROM Bill
					 WHERE price = 50)

SELECT order_id, preparation_time
FROM Food_order
WHERE preparation_time < ALL (SELECT preparation_time
					 FROM Food_order
					 WHERE preparation_time > 5)

SELECT waiter_CNP, waiter_name
FROM Waiter 
WHERE salary > ALL(SELECT DISTINCT salary
				   FROM Chef)

SELECT waiter_CNP, waiter_name
FROM Waiter
WHERE salary > (SELECT MAX(salary)
				FROM Chef)


select * from Feedback