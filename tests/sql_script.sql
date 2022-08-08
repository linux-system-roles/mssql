IF NOT EXISTS (
  SELECT name
  FROM master.sys.server_principals
  WHERE name = 'MyLogin'
)
BEGIN
  PRINT 'Creating the MyLogin login';
  CREATE LOGIN MyLogin WITH PASSWORD = 'p@55w0rD'
  PRINT 'The MyLogin login created successfully';
END
ELSE
BEGIN
  PRINT 'The MyLogin login already exists, skipping';
END

IF NOT EXISTS (
  SELECT name
  FROM sys.database_principals
  WHERE name = 'MyUser')
BEGIN
  PRINT 'Creating the MyUser user';
  CREATE USER MyUser FOR LOGIN MyLogin
  PRINT 'The MyUser user created successfully';
END
ELSE
BEGIN
  PRINT 'The MyUser user already exists, skipping';
END

IF NOT EXISTS(
  SELECT name
  FROM sys.databases
  WHERE name = 'ExampleDB'
)
BEGIN
  PRINT 'Creating the ExampleDB database';
  CREATE DATABASE ExampleDB;
  PRINT 'The ExampleDB database created successfully';
END
ELSE
BEGIN
  PRINT 'The ExampleDB database already exists, skipping';
END
GO

USE ExampleDB;
GO

IF NOT EXISTS (
  SELECT name, xtype
  FROM sysobjects
  WHERE name='Inventory' and xtype='U'
)
BEGIN
  PRINT 'Adding the Inventory table to the ExampleDB database';
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