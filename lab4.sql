-- lab 4
-- Підрахунок кількості автомобілів кожної марки
select Brand, COUNT(*) as NumberOfCars
from Car
group by Brand;
-- Сумарна вартість всіх тарифів
select SUM(Price) as TotalPrice
from Tariff;
-- Групування паркувальних місць за тарифом та підрахунок кількості місць у кожній групі
select TariffID, COUNT(SpotNumber) as NumberOfSpots
from ParkingSpot
group by TariffID;
-- Вибір марок авто, якиї більше ніж або дорівнює 3 автомобілям
select Brand
from Car
group by Brand
having COUNT(*) >= 3;
-- Формування загальної кількості автомобілів, якщо вона більша за 10
select COUNT(*) as TotalCars
from Car
having COUNT(*) > 10;
-- Нумерація автомобілів за кольором та маркою
select row_number() over (order by Color, Brand) as RowNum, RegistrationNumber, TypeCar, Brand, Color, OwnerPID
from Car;
-- Сортування автомобілів за маркою та кольором
select *
from Car
order by Brand, Color;
-- Найпопулярніше місце серед власників автомобілів BMW минулого тижня
select SpotNumber, COUNT(SpotNumber) as Frequency
from EntryExit
join Car on EntryExit.RegistrationNumber = Car.RegistrationNumber
where Brand = 'BMW'
and week(EntryTime) = week(CURDATE()) - 1
and year(EntryTime) = year(CURDATE())
group by SpotNumber
order by Frequency desc
limit 1;
-- Власники автомобілів жовтого кольору, котрі найдовше залишили свій автомобіль на парковці.
select 
    Person.Name,
    ANY_VALUE(Car.RegistrationNumber) AS RegistrationNumber,
    MAX(timestampdiff(hour, EntryTime, ExitTime)) As MaxHours 
from EntryExit
join Car on EntryExit.RegistrationNumber = Car.RegistrationNumber
join Person on Car.OwnerPID = Person.PID
where Car.Color = 'Жовтий'
group by Person.Name, Car.OwnerPID
order by MaxHours desc;

-- Створення представлення з декількох таблиць
create view CarOwnersView as
select p.Name, c.RegistrationNumber, c.Brand, c.Color
from Person p
join Car c on p.PID = c.OwnerPID;

select * from CarOwnersView;
-- Створення представлення, яке використовує інше представлення
create view ExtendedCarOwnersView AS
select v.Name, v.RegistrationNumber, v.Brand, v.Color, ps.SpotNumber, t.Price
from CarOwnersView v
join EntryExit ee on v.RegistrationNumber = ee.RegistrationNumber
join ParkingSpot ps on ee.SpotNumber = ps.SpotNumber
join Tariff t on ps.TariffID = t.TariffID;

select * FROM ExtendedCarOwnersView;
-- Модифікація представлення за допомогою команди ALTER VIEW
alter view CarOwnersView as
select p.Name, c.RegistrationNumber, c.Brand, c.Color, c.TypeCar
from Person p
join Car c on p.PID = c.OwnerPID;

select * from CarOwnersView;

-- Довідкова інформація про представлення
select * from INFORMATION_SCHEMA.VIEWS
where table_name = 'CarOwnersView' 
union
select * from INFORMATION_SCHEMA.VIEWS
where table_name = 'ExtendedCarOwnersView' ;

