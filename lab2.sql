-- lab 2
CREATE DATABASE ParkingDB;

-- Створення таблиці для Особи
CREATE TABLE Person (
    PID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL
);

-- Створення таблиці для Авто
CREATE TABLE Car (
    RegistrationNumber VARCHAR(255) NOT NULL PRIMARY KEY,
    TypeCar VARCHAR(50),
    Brand VARCHAR(50),
    Color VARCHAR(50),
    OwnerPID INT,
    FOREIGN KEY (OwnerPID) REFERENCES Person(PID)
);

-- Створення таблиці для Тарифу
CREATE TABLE Tariff (
    TariffID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Price DECIMAL(10, 2) NOT NULL
);

-- Створення таблиці для Паркувального місця
CREATE TABLE ParkingSpot (
    SpotNumber INT NOT NULL PRIMARY KEY,
    TariffID INT,
    FOREIGN KEY (TariffID) REFERENCES Tariff(TariffID)
);

-- Створення таблиці для В'їзду-Виїзду
CREATE TABLE EntryExit (
    EntryExitID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    EntryTime DATETIME NOT NULL,
    ExitTime DATETIME,
    SpotNumber INT,
    RegistrationNumber VARCHAR(255),
    FOREIGN KEY (SpotNumber) REFERENCES ParkingSpot(SpotNumber),
    FOREIGN KEY (RegistrationNumber) REFERENCES Car(RegistrationNumber)
);
-- Таблиця доступу до авто
-- Створення таблиці для Доступу
CREATE TABLE CarAccess (
    AccessID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    RegistrationNumber VARCHAR(255) NOT NULL,
    PersonID INT NOT NULL,
    FOREIGN KEY (RegistrationNumber) REFERENCES Car(RegistrationNumber),
    FOREIGN KEY (PersonID) REFERENCES Person(PID)
);
INSERT INTO CarAccess (RegistrationNumber, PersonID)
SELECT RegistrationNumber, OwnerPID FROM Car WHERE OwnerPID IS NOT NULL;

-- Зміни в структурах таблиць
ALTER TABLE Car CHANGE Type TypeCar VARCHAR(50);
ALTER TABLE EntryExit_New RENAME TO EntryExit;
ALTER TABLE Person ADD Phone VARCHAR (50);
ALTER TABLE EntryExit DROP FOREIGN KEY entryexit_ibfk_2;
ALTER TABLE Car MODIFY RegistrationNumber VARCHAR (100);
ALTER TABLE EntryExit ADD CONSTRAINT entryexit_ibfk_2 FOREIGN KEY (RegistrationNumber) REFERENCES Car(RegistrationNumber);
ALTER TABLE Person ADD UNIQUE (Phone);
ALTER TABLE Person MODIFY Phone VARCHAR(50) NULL;
ALTER TABLE Tariff ADD CONSTRAINT CheckPrice CHECK (Price > 0);
ALTER TABLE Car ADD INDEX idx_Brand (Brand);
ALTER TABLE Car MODIFY Model VARCHAR(50) DEFAULT 'Benz' ;

-- Видалення даних
ALTER TABLE Person DROP COLUMN Phone;
ALTER TABLE EntryExit DROP FOREIGN KEY entryexit_ibfk_2;
ALTER TABLE Car ALTER COLUMN Model DROP DEFAULT;
ALTER TABLE Practise DROP COLUMN EMAIL;
ALTER TABLE Tariff DROP CONSTRAINT CheckPrice;
DROP TABLE EntryExit;
DROP INDEX idx_Brand ON Car;
ALTER TABLE Practise DROP COLUMN DATEID;
ALTER TABLE Car DROP CONSTRAINT Check_YEAR_CAR;
DROP TABLE Practise;
DROP DATABASE Practise;

-- Створення ролей
CREATE ROLE 'admin';
GRANT ALL PRIVILEGES ON ParkingDB.* TO 'admin';

CREATE ROLE 'manager';
GRANT SELECT, INSERT, UPDATE ON ParkingDB.* TO 'manager';

CREATE ROLE 'analyst';
GRANT SELECT ON ParkingDB.* TO 'analyst';

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin1';
GRANT 'admin' TO 'admin'@'localhost';

CREATE USER 'manager'@'localhost' IDENTIFIED BY 'manager1';
GRANT 'manager' TO 'manager'@'localhost';

CREATE USER 'analyst'@'localhost' IDENTIFIED BY 'analyst1';
GRANT 'analyst' TO 'analyst'@'localhost';

-- Застосування змін
FLUSH PRIVILEGES;

select *from Car;


-- Імпорт даних в таблицю Person
LOAD DATA INFILE '/Users/macuser/Documents/Data bases/Laboratory work 2/Person.csv'
INTO TABLE Person
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Імпорт даних в таблицю Car
LOAD DATA INFILE '/Users/macuser/Documents/Data bases/Laboratory work 2/Car.csv'
INTO TABLE Car
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Імпорт даних в таблицю Tariff
LOAD DATA INFILE '/Users/macuser/Documents/Data bases/Laboratory work 2/Tariff.csv'
INTO TABLE Tariff
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Імпорт даних в таблицю ParkingSpot
LOAD DATA INFILE '/Users/macuser/Documents/Data bases/Laboratory work 2/ParkingSpot.csv'
INTO TABLE ParkingSpot
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Імпорт даних в таблицю EntryExit
LOAD DATA INFILE '/Users/macuser/Documents/Data bases/Laboratory work 2/EntryExit.csv'
INTO TABLE EntryExit
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';


select *from mysql.user;
show grants for 'manager'@'localhost';

