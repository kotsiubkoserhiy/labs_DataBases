-- lab 3
Use ParkingDB;
-- 1. a Вибірка всіх авто певного кольору
select *from Car where Color = 'Синій';
-- b Вибірка авто певної марки та кольору
select *from Car where Brand = 'Jeep' and Color = 'Чорний';
-- b Вибірка паркувальних місць з певним тарифом або іншим номером:
select *from ParkingSpot where TariffID = 3 OR SpotNumber > 15;
-- b Вибірка осіб, які не є власниками авто:
select *from Person where PID NOT IN (SELECT OwnerPID FROM Car);
-- c Вибірка часу перебування авто на паркуванні:
select EntryTime, ExitTime, timestampdiff(HOUR, EntryTime, ExitTime) as ParkingHours from EntryExit;
-- d Вибірка авто за списком реєстраційних номерів (приналежність множині):
select * from Car where RegistrationNumber in ('AA1234AA', 'BB1234CC');
-- d Вибірка паркувань у певному часовому діапазоні (приналежність діапазону):
select *from EntryExit where EntryTime between '2023-01-01' and '2023-12-31';
-- d Вибірка авто, що відповідають певному шаблону номера (відповідність шаблону):
select * from Car where RegistrationNumber like 'BB%';
-- d Вибірка авто без вказаного власника (перевірка на невизначене значення):
select * from Car where OwnerPID is null;

-- 2. a Імена власників та кількість авто, які вони мають
select Name, (select count(*) from Car where Car.OwnerPID = Person.PID) as CarCount from Person;

SELECT 
    P.Name, 
    IFNULL(C.CarCount, 0) as CarCount
FROM 
    Person P, 
    (SELECT OwnerPID, COUNT(*) as CarCount FROM Car GROUP BY OwnerPID) C
WHERE 
    P.PID = C.OwnerPID;

-- b Особи, які паркували авто 
select *from Person where exists (select *from Car where Car.OwnerPID = Person.PID and RegistrationNumber in (select RegistrationNumber from EntryExit));
-- с Усі можливі пари осіб та авто
select *from Person, Car;
-- d Інформація про авто та їх власників
SELECT 
    Car.*, 
    Person.Name 
FROM 
    Car, Person 
WHERE 
    Car.OwnerPID = Person.PID;

-- e Авто та їх власники, де авто має певний колір
SELECT 
    Car.*, 
    Person.Name 
FROM 
    Car, Person 
WHERE 
    Car.OwnerPID = Person.PID AND 
    Car.Color = 'Чорний';

-- f Авто та його паркування
select Car.*, EntryExit.* from Car inner join EntryExit on Car.RegistrationNumber = EntryExit.RegistrationNumber;
-- g Усі власники та їх авто (навіть якщо вони їх не мають)
select Person.Name, Car.RegistrationNumber from Person left join Car on Person.PID = Car.OwnerPID;
-- h Усі авто та їх власників (навіть якщо авто не має власника)
select Person.Name, Car.RegistrationNumber from Car right join Person on Car.OwnerPID = Person.PID;
-- i Усі авто та паркувальні місця 
select 'Car' as TypeCar, RegistrationNumber from Car
union
select 'ParkingSpot' as TypeCar, SpotNumber from ParkingSpot;
-- i Авто з паркуваннями та без
select Car.RegistrationNumber, 'With Parking' as ParkingStatus from Car
where RegistrationNumber in (select RegistrationNumber from	EntryExit)
union
select Car.RegistrationNumber, 'Without Parking' as ParkingStatus from Car
where RegistrationNumber not in (select RegistrationNumber from	EntryExit);

-- 4. Для автомобілів, котрі знаходились на стоянці більше доби, вивести перелік людей (через кому), котрі мають доступ до них, власника та сам автомобіль.
SELECT 
    C.RegistrationNumber,
    (SELECT P.Name FROM Person P WHERE P.PID = C.OwnerPID) as OwnerName,
    (SELECT GROUP_CONCAT(P.Name SEPARATOR ', ') 
     FROM Person P, CarAccess CA 
     WHERE P.PID = CA.PersonID AND CA.RegistrationNumber = C.RegistrationNumber) as AccessPersons,
    C.Brand, 
    C.TypeCar, 
    C.Color
FROM 
    Car C, EntryExit EE
WHERE 
    C.RegistrationNumber = EE.RegistrationNumber AND
    TIMESTAMPDIFF(HOUR, EE.EntryTime, COALESCE(EE.ExitTime, NOW())) > 24;

-- 4. Власники Жовтих Автомобілів, що Паркувались Минулого Року
SELECT DISTINCT
    Person.Name as OwnerName
FROM
    Car,
    Person,
    EntryExit
WHERE
    Car.OwnerPID = Person.PID AND
    Car.RegistrationNumber = EntryExit.RegistrationNumber AND
    Car.Color = 'Жовтий' AND
    YEAR(EntryExit.EntryTime) = YEAR(CURDATE()) - 1;
