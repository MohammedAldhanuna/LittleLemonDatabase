# Little Lemon Restaurant Management System

- [Little Lemon Restaurant Management System](#little-lemon-restaurant-management-system)
  - [Project Description](#project-description)
  - [Entity-Relationship Diagram](#entity-relationship-diagram)
  - [Installation and Setup](#installation-and-setup)
  - [Stored Procedures](#stored-procedures)
    - [GetMaxQuantity()](#getmaxquantity)
    - [CheckBooking()](#checkbooking)
    - [UpdateBooking()](#updatebooking)
    - [AddBooking()](#addbooking)
    - [CancelBooking()](#cancelbooking)
    - [AddValidBooking()](#addvalidbooking)
    - [CancelOrder()](#cancelorder)
  - [Data Analysis with Tableau](#data-analysis-with-tableau)
    - [Customers sales](#customers-sales)
    - [Profit chart](#profit-chart)
    - [Sales Bubble Chart](#sales-bubble-chart)
    - [Cuisine Sales and Profits](#cuisine-sales-and-profits)
    - [Dashboard](#dashboard)

## Project Description

This project is designed to manage the operations of the Little Lemon fast-food restaurant and is a part of the **Meta Database Engineer Certificate** course on Coursera. The project uses MySQL for database modeling and Tableau for data analysis. The `Preparation` folder contains all the initial files used to start working on this project.

## Entity-Relationship Diagram

To view the Entity-Relationship Diagram, click here or see the image below.

![Diagram](./Images/diagram.png)

## Installation and Setup

To set up the database, do the following:

1. **Install MySQL**: Download and install MySQL on your machine if you haven't done so.

2. **Download SQL File**: Obtain the [LittleLemonDB.sql](./LittleLemonDB.sql) file from this repository.

3. **Import and Execute in MySQL Workbench**:
    - Open MySQL Workbench.
    - Navigate to `Server` > `Data Import`.
    - Choose `Import from Self-Contained File` and load the `LittleLemonDB.sql` file.
    - Click `Start Import` to both import and execute the SQL commands from the file.

Your database should now be set up and populated with tables and stored procedures.

## Stored Procedures

### GetMaxQuantity()
This stored procedure retrieves the maximum quantity of a specific item that has been ordered. It's useful for inventory management.

```sql
CREATE PROCEDURE GetMaxQuantity()
BEGIN
  DECLARE maxQty INT;

  SELECT MAX(Quantity) INTO maxQty FROM `LittleLemonDB`.`Orders`;

  SELECT maxQty AS 'Maximum Ordered Quantity';
END;
```

```sql
CALL GetMaxQuantity()
```

### CheckBooking()

The CheckBooking stored procedure validates whether a table is already booked on a specified date. It will output a status message indicating whether the table is available or already booked.

```sql
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
```

```sql
CALL CheckBooking('2022-11-12', 3);
```
### UpdateBooking()
This stored procedure updates the booking details in the database. It takes the booking ID and new booking date as parameters, making sure the changes are reflected in the system.

```sql
CREATE PROCEDURE `LittleLemonDB`.`UpdateBooking`(
    IN booking_id_to_update INT, 
    IN new_booking_date DATE)
BEGIN
    UPDATE `LittleLemonDB`.`Bookings`
    SET `Date` = new_booking_date
    WHERE `BookingID` = booking_id_to_update;

    SELECT CONCAT('Booking ', booking_id_to_update, ' updated') AS 'Confirmation';
END;
```
```sql
CALL `LittleLemonDB`.`UpdateBooking`(9, '2022-11-15');
```

### AddBooking() 
This procedure adds a new booking to the system. It accepts multiple parameters like booking ID, customer ID, booking date, and table number to complete the process.

```sql
CREATE PROCEDURE `LittleLemonDB`.`AddBooking`(
    IN new_booking_id INT, 
    IN new_customer_id INT, 
    IN new_booking_date DATE, 
    IN new_table_number INT, 
    IN new_staff_id INT)
BEGIN
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
```
```sql
CALL `LittleLemonDB`.`AddBooking`(17, 1, '2022-10-10', 5, 2);
```

### CancelBooking()
This stored procedure deletes a specific booking from the database, allowing for better management and freeing up resources.
```sql
CREATE PROCEDURE `LittleLemonDB`.`CancelBooking`(IN booking_id_to_cancel INT)
BEGIN
    DELETE FROM `LittleLemonDB`.`Bookings`
    WHERE `BookingID` = booking_id_to_cancel;

    SELECT CONCAT('Booking ', booking_id_to_cancel, ' cancelled') AS 'Confirmation';
END;
```
```sql
CALL `LittleLemonDB`.`CancelBooking`(9);
```
### AddValidBooking()
The AddValidBooking stored procedure aims to securely add a new table booking record. It starts a transaction and attempts to insert a new booking record, checking the table's availability.

```sql
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
```
```sql
CALL AddValidBooking('2022-10-10', 5, 1, 1);
```


### CancelOrder()
The CancelOrder stored procedure cancels or removes a specific order by its Order ID. It executes a DELETE statement to remove the order record from the Orders table.

```sql
CREATE PROCEDURE CancelOrder(IN orderIDToDelete INT)
BEGIN
  DECLARE orderExistence INT;

  SELECT COUNT(*) INTO orderExistence FROM `LittleLemonDB`.`Orders` WHERE OrderID = orderIDToDelete;

  IF orderExistence > 0 THEN
    DELETE FROM `LittleLemonDB`.`OrderDeliveryStatuses` WHERE OrderID = orderIDToDelete;

    DELETE FROM `LittleLemonDB`.`Orders` WHERE OrderID = orderIDToDelete;

    SELECT CONCAT('Order ', orderIDToDelete, ' is cancelled') AS 'Confirmation';
  ELSE
    SELECT CONCAT('Order ', orderIDToDelete, ' does not exist') AS 'Confirmation';
  END IF;
END;
```
```sql
CALL CancelOrder(5);
```

## Data Analysis with Tableau
A Tableau workbook has been created, containing various charts and dashboards to facilitate data analysis. Download the workbook [here](./tableau.twb)

### Customers sales
![Customers sales](./Images/tableau-task1.png)

### Profit chart
![Profit chart](./Images/tableau-task2.png)

### Sales Bubble Chart
![Sales Bubble Chart](./Images/tableau-task3.png)

###  Cuisine Sales and Profits
![ Cuisine Sales and Profits](./Images/tableau-task4.png)

### Dashboard
![dashboard](./Images/tableau-task5.png)


