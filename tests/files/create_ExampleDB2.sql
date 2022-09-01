IF NOT EXISTS(
  SELECT name
  FROM sys.databases
  WHERE name = 'ExampleDB2'
)
BEGIN
  PRINT 'Creating the ExampleDB2 database';
  CREATE DATABASE ExampleDB2;
  PRINT 'The ExampleDB2 database created successfully';
END
ELSE
BEGIN
  PRINT 'The ExampleDB2 database already exists, skipping';
END
GO

USE ExampleDB2;
GO

IF NOT EXISTS (
  SELECT name, xtype
  FROM sysobjects
  WHERE name='Inventory' and xtype='U'
)
BEGIN
  PRINT 'Adding the Inventory table to the ExampleDB2 database';
  CREATE TABLE Inventory (id INT, name NVARCHAR(50), quantity INT);
  INSERT INTO Inventory VALUES (1, 'pineapple', 100);
  INSERT INTO Inventory VALUES (2, 'grapefruit', 150);
  INSERT INTO Inventory VALUES (3, 'cucumber', 154);
  INSERT INTO Inventory VALUES (4, N'バナナ', 170);
  PRINT 'The Inventory table created successfully';
END
ELSE
BEGIN
  PRINT 'The Inventory table already exists, skipping';
END
GO
