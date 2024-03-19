-- Task 1

CREATE VIEW `OrdersView` AS
SELECT OrderID, Quantity, TotalCost as Cost FROM littlelemondb.orders
where quantity > 2

-- Task 2

CREATE TABLE `littlelemondb`.`menuitems` (
  `MenuItemsID` INT NOT NULL AUTO_INCREMENT,
  `CourseName` VARCHAR(45) NULL,
  `StarterName` VARCHAR(45) NULL,
  `DesertName` VARCHAR(45) NULL,
  PRIMARY KEY (`MenuItemsID`));

-- Insert data
INSERT INTO `littlelemondb`.`menuitems` (`CourseName`, `StarterName`, `DesertName`)
VALUES
('Grilled Chicken', 'Caesar Salad', 'Cheesecake'),
('Beef Steak', 'Tomato Soup', 'Chocolate Mousse'),
('Vegetarian Pizza', 'Garlic Bread', 'Fruit Salad'),
('Spaghetti Carbonara', 'Bruschetta', 'Tiramisu'),
('Fish and Chips', 'Coleslaw', 'Apple Pie'),
('Sushi Platter', 'Miso Soup', 'Green Tea Ice Cream'),
('BBQ Ribs', 'Cornbread', 'Peach Cobbler'),
('Chicken Curry', 'Samosas', 'Gulab Jamun'),
('Lobster Tail', 'Oysters', 'Key Lime Pie'),
('Vegan Burger', 'Sweet Potato Fries', 'Vegan Brownie');

UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '1' WHERE (`MenuID` = '1');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '2' WHERE (`MenuID` = '2');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '3' WHERE (`MenuID` = '3');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '4' WHERE (`MenuID` = '4');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '5' WHERE (`MenuID` = '5');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '6' WHERE (`MenuID` = '6');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '7' WHERE (`MenuID` = '7');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '8' WHERE (`MenuID` = '8');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '9' WHERE (`MenuID` = '9');
UPDATE `littlelemondb`.`menus` SET `MenuItemsID` = '10' WHERE (`MenuID` = '10');

ALTER TABLE `littlelemondb`.`menus` 
ADD CONSTRAINT `menus_items_menu_fk`
  FOREIGN KEY (`MenuItemsID`)
  REFERENCES `littlelemondb`.`menuitems` (`MenuItemsID`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

----
SELECT cd.CustomerID, cd.Name as FullName, o.OrderID, o.TotalCost as Cost, m.Name as MenuName, mi.CourseName
FROM littlelemondb.customerdetails as cd
INNER JOIN littlelemondb.orders as o on o.CustomerID = cd.CustomerID
INNER JOIN littlelemondb.menus as m on o.MenuItemID = m.MenuItemsID
INNER JOIN littlelemondb.menuitems as mi on m.MenuItemsID = mi.MenuItemsID
ORDER BY o.TotalCost ASC

USE `littlelemondb`;
CREATE  OR REPLACE VIEW `ordersview2` AS
SELECT cd.CustomerID, cd.Name as FullName, o.OrderID, o.TotalCost as Cost, m.Name as MenuName, mi.CourseName
FROM littlelemondb.customerdetails as cd
INNER JOIN littlelemondb.orders as o on o.CustomerID = cd.CustomerID
INNER JOIN littlelemondb.menus as m on o.MenuItemID = m.MenuItemsID
INNER JOIN littlelemondb.menuitems as mi on m.MenuItemsID = mi.MenuItemsID
ORDER BY o.TotalCost ASC;

-- Task 3

SELECT m.Name AS MenuName
FROM littlelemondb.menus as m
WHERE m.MenuItemsID = ANY (
    SELECT o.MenuItemID
    FROM littlelemondb.orders as o
    GROUP BY o.MenuItemID
    HAVING SUM(o.Quantity) > 2
);

USE `littlelemondb`;
CREATE  OR REPLACE VIEW `ordersview3` AS
SELECT m.Name AS MenuName
FROM littlelemondb.menus as m
WHERE m.MenuItemsID = ANY (
    SELECT o.MenuItemID
    FROM littlelemondb.orders as o
    GROUP BY o.MenuItemID
    HAVING SUM(o.Quantity) > 2
);

ALTER TABLE `littlelemondb`.`customerdetails` 
ADD COLUMN `ContactNumber` VARCHAR(45) NOT NULL AFTER `ContactDetail`,
ADD COLUMN `Email` VARCHAR(45) NOT NULL AFTER `ContactNumber`;


-- Update customers table
UPDATE `littlelemondb`.`customerdetails` 
SET `ContactNumber` = CASE `CustomerID`
    WHEN 1 THEN '555-1234'
    WHEN 2 THEN '555-2345'
    WHEN 3 THEN '555-3456'
    WHEN 4 THEN '555-4567'
    WHEN 5 THEN '555-5678'
    WHEN 6 THEN '555-6789'
    WHEN 7 THEN '555-7890'
    WHEN 8 THEN '555-8901'
    WHEN 9 THEN '555-9012'
    WHEN 10 THEN '555-0123'
    ELSE '555-1111'
END,
`Email` = CASE `CustomerID`
    WHEN 1 THEN 'customer1@email.com'
    WHEN 2 THEN 'customer2@email.com'
    WHEN 3 THEN 'customer3@email.com'
    WHEN 4 THEN 'customer4@email.com'
    WHEN 5 THEN 'customer5@email.com'
    WHEN 6 THEN 'customer6@email.com'
    WHEN 7 THEN 'customer7@email.com'
    WHEN 8 THEN 'customer8@email.com'
    WHEN 9 THEN 'customer9@email.com'
    WHEN 10 THEN 'customer10@email.com'
    ELSE 'unknown@email.com'
END;
ALTER TABLE `littlelemondb`.`customerdetails` 
DROP COLUMN `ContactDetail`;


-- Exercise: Create optimized queries to manage and analyze data
-- Task 1

DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
  DECLARE maxQty INT;

  SELECT MAX(Quantity) INTO maxQty FROM `LittleLemonDB`.`Orders`;

  SELECT maxQty AS 'Maximum Ordered Quantity';
END;
//
DELIMITER ;

CALL GetMaxQuantity();

-- Task 2

PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, TotalCost FROM LittleLemonDB.Orders WHERE CustomerID = ?';
SET @id = 1;
EXECUTE GetOrderDetail USING @id;
DEALLOCATE PREPARE GetOrderDetail;

-- Task 3

DELIMITER //
CREATE PROCEDURE CancelOrder(IN orderIDToDelete INT)
BEGIN
  DECLARE orderExistence INT;

  -- Check if the order exists in the database
  SELECT COUNT(*) INTO orderExistence FROM `LittleLemonDB`.`Orders` WHERE OrderID = orderIDToDelete;

  -- If the order exists, delete it
  IF orderExistence > 0 THEN
    -- First delete related records from OrderDeliveryStatuses table
    DELETE FROM `LittleLemonDB`.`OrderDeliveryStatuses` WHERE OrderID = orderIDToDelete;

    -- Then delete the order from the Orders table
    DELETE FROM `LittleLemonDB`.`Orders` WHERE OrderID = orderIDToDelete;

    SELECT CONCAT('Order ', orderIDToDelete, ' is cancelled') AS 'Confirmation';
  ELSE
    SELECT CONCAT('Order ', orderIDToDelete, ' does not exist') AS 'Confirmation';
  END IF;
END;
//
DELIMITER ;


CALL CancelOrder(5);

-- Exercise: Create SQL queries to check available bookings based on user input
-- Task 1

INSERT INTO `LittleLemonDB`.`Bookings` (`BookingID`, `Date`, `TableNumber`, `CustomerID`, `StaffID`) VALUES
(11, '2022-10-10', 5, 1, 1),
(12, '2022-11-12', 3, 3, 2),
(13, '2022-10-11', 2, 2, 3),
(14, '2022-10-13', 2, 1, 1);

-- Task 2
DELIMITER //
CREATE PROCEDURE `LittleLemonDB`.`CheckBooking`(IN booking_date DATE, IN table_number INT)
BEGIN
    DECLARE table_status VARCHAR(50);

    SELECT COUNT(*) INTO @table_count
    FROM `LittleLemonDB`.`Bookings`
    WHERE `Date` = booking_date AND `TableNumber` = table_number;

    IF (@table_count > 0) THEN
        SET table_status = 'Table is already booked.';
    ELSE
        SET table_status = 'Table is available.';
    END IF;

    SELECT table_status AS 'Table Status';
END;
//
DELIMITER ;
CALL `LittleLemonDB`.`CheckBooking`('2022-10-10', 5);

-- Task 3

DELIMITER //
CREATE PROCEDURE `LittleLemonDB`.`AddValidBooking`(IN new_booking_date DATE, IN new_table_number INT, IN new_customer_id INT, IN new_staff_id INT)
BEGIN
    DECLARE table_status INT;
    START TRANSACTION;

    SELECT COUNT(*) INTO table_status
    FROM `LittleLemonDB`.`Bookings`
    WHERE `Date` = new_booking_date AND `TableNumber` = new_table_number;

    IF (table_status > 0) THEN
        ROLLBACK;
        SELECT 'Booking could not be completed. Table is already booked on the specified date.' AS 'Status';
    ELSE
        INSERT INTO `LittleLemonDB`.`Bookings`(`Date`, `TableNumber`, `CustomerID`, `StaffID`)
        VALUES(new_booking_date, new_table_number, new_customer_id, new_staff_id);

        COMMIT;
        SELECT 'Booking completed successfully.' AS 'Status';
    END IF;
END;
//
DELIMITER ;

CALL `LittleLemonDB`.`AddValidBooking`('2022-10-10', 5, 1, 1);

-- Exercise: Create SQL queries to add and update bookings
-- Task 1

DELIMITER //
CREATE PROCEDURE `LittleLemonDB`.`AddBooking`(
    IN new_booking_id INT, 
    IN new_customer_id INT, 
    IN new_booking_date DATE, 
    IN new_table_number INT, 
    IN new_staff_id INT)
BEGIN
    -- Insert the new booking record
    INSERT INTO `LittleLemonDB`.`Bookings`(
        `BookingID`, 
        `CustomerID`, 
        `Date`, 
        `TableNumber`, 
        `StaffID`)
    VALUES(
        new_booking_id, 
        new_customer_id, 
        new_booking_date, 
        new_table_number,
        new_staff_id
    );

    SELECT 'New booking added' AS 'Confirmation';
END;
//
DELIMITER ;


CALL `LittleLemonDB`.`AddBooking`(17, 1, '2022-10-10', 5, 2);

-- Task 2

DELIMITER //
CREATE PROCEDURE `LittleLemonDB`.`UpdateBooking`(
    IN booking_id_to_update INT, 
    IN new_booking_date DATE)
BEGIN
    -- Update the booking record
    UPDATE `LittleLemonDB`.`Bookings`
    SET `Date` = new_booking_date
    WHERE `BookingID` = booking_id_to_update;

    SELECT CONCAT('Booking ', booking_id_to_update, ' updated') AS 'Confirmation';
END;
//
DELIMITER ;

CALL `LittleLemonDB`.`UpdateBooking`(9, '2022-11-15');

-- Task 3

DELIMITER //
CREATE PROCEDURE `LittleLemonDB`.`CancelBooking`(IN booking_id_to_cancel INT)
BEGIN
    -- Delete the booking record
    DELETE FROM `LittleLemonDB`.`Bookings`
    WHERE `BookingID` = booking_id_to_cancel;

    SELECT CONCAT('Booking ', booking_id_to_cancel, ' cancelled') AS 'Confirmation';
END;
//
DELIMITER ;

CALL `LittleLemonDB`.`CancelBooking`(9);

