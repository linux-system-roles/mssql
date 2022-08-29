IF NOT EXISTS(
  SELECT name
  FROM sys.databases
  WHERE name = 'ExampleDB1'
)
BEGIN
  PRINT 'Creating the ExampleDB1 database';
  CREATE DATABASE ExampleDB1;
  PRINT 'The ExampleDB1 database created successfully';
END
ELSE
BEGIN
  PRINT 'The ExampleDB1 database already exists, skipping';
END
GO

USE ExampleDB1;
GO

IF NOT EXISTS (
  SELECT name, xtype
  FROM sysobjects
  WHERE name='Inventory' and xtype='U'
)
BEGIN
  PRINT 'Adding the Inventory table to the ExampleDB1 database';
  CREATE TABLE Inventory (id INT, name NVARCHAR(50), quantity INT);
  INSERT INTO Inventory VALUES (1, 'apple', 100);
  INSERT INTO Inventory VALUES (2, 'orange', 150);
  INSERT INTO Inventory VALUES (3, 'banana', 154);
  INSERT INTO Inventory VALUES (4, N'バナナ', 170);
  PRINT 'The Inventory table created successfully';
END
ELSE
BEGIN
  PRINT 'The Inventory table already exists, skipping';
END
GO
