-- lab 5
Use ParkingDB;

-- a запит для створення тимчасової таблиці через змінну типу TABLE;
-- (не пітримується через змінну типу TABLE у MySQL)
delimiter //
create procedure CreateTempTable()
begin
	create temporary table if not exists TempTable1 (
		id int,
		value_is varchar (255)
    );
end //
delimiter ;
CALL CreateTempTable();
select *from TempTable1;

-- b запит з використанням умовної конструкції IF
delimiter //
create procedure CheckAvailableParking()
begin
	if (select count(*) from ParkingSpot where TariffID is null)>0 then
		select 'There are available spots';
	else
		select 'No available spots';
	end if;
end //
delimiter ;

CALL CheckAvailableParking();

-- с запит з використанням циклу WHILE;
delimiter //

create procedure Add5UANToPrice()
begin
    declare v_counter int default 1;
    declare v_maxID int;

    -- Знайти максимальний ID в таблиці Tariff
    select max(TariffID) into v_maxID from Tariff;

    -- Використовувати цикл WHILE для інкрементації ціни для кожного TariffID
    while v_counter <= v_maxID do
        -- Перевірка, чи існує TariffID, який потрібно оновити
        if exists(select 1 from Tariff where TariffID = v_counter) then
            -- Оновлення ціни на 5 грн
            update Tariff set Price = Price + 5 where TariffID = v_counter;
        end if;
        -- Інкрементувати лічильник
        set v_counter = v_counter + 1;
    end while;
end //
delimiter ;

select *from Tariff;
Call Add5UANToPrice ();

-- d створення процедури без параметрів;
delimiter //
create procedure GetAllCars()
begin
	select *from Car;
end //
delimiter ;

Call GetAllCars();

-- e створення процедури з вхідним параметром;
delimiter //
create procedure GetCarByOwner (in ownerID int)
begin
	select *from Car where OwnerPID = ownerID;
end //
delimiter ;

Call GetCarByOwner (3);

-- f створення процедури з вхідним параметром та RETURN (return не підтримується). використаємо out 
delimiter //
create procedure GetTariffPrice(in tariffID int, out price decimal(10,2))
begin
    select Price into price from Tariff where TariffID = tariffID limit 1;
end //
DELIMITER ;

set @price := 0;
call GetTariffPrice(4, @price);
select @price;

-- g створення процедури оновлення даних в деякій таблиці БД;
delimiter //

create procedure UpdateTariffPrice(in p_TariffID int, in p_NewPrice decimal(10,2))
begin
    update Tariff set Price = p_NewPrice where TariffID = p_TariffID;
end //

delimiter ;

Call UpdateTariffPrice (2,55);
select *from Tariff;

-- створення процедури, в котрій робиться вибірка даних. 
delimiter //
create procedure GetParkingSpotsByTariff (in p_TariffID int)
BEGIN
    select ps.SpotNumber, c.RegistrationNumber, c.TypeCar, c.Brand, c.Color
    from ParkingSpot ps
    left join EntryExit ee on ps.SpotNumber = ee.SpotNumber
    left join Car c on ee.RegistrationNumber = c.RegistrationNumber
    where ps.TariffID = p_TariffID;
end //
delimiter ;

Call GetParkingSpotsByTariff (10);

-- функції
-- створити функцію, котра повертає деяке скалярне значення;
delimiter //
create function GetAverageTariff() returns decimal(10,2)
deterministic
BEGIN
    declare averagePrice decimal(10,2);
    select avg(Price) into averagePrice from Tariff;
    return averagePrice;
end //
delimiter ;


-- b створити функцію, котра повертає таблицю з динамічним набором стовпців; (не підтримується)
delimiter //
create procedure GetCarDetails()
begin
    select RegistrationNumber, TypeCar, Brand, Color, OwnerPID from Car;
end //
delimiter ;

-- або через json
delimiter //
create function GetCarsAsJson() returns text
reads sql data 
begin
    declare json_result text;
    select JSON_ARRAYAGG(JSON_OBJECT('RegistrationNumber', RegistrationNumber, 'Brand', Brand, 'Color', Color)) into json_result from Car;
    return json_result;
END //
delimiter ;

SELECT GetCarsAsJson()

-- c створити функцію, котра повертає таблицю заданої структури. (не підтримується)
delimiter //

create procedure GetCarDetails()
begin	
    select RegistrationNumber, TypeCar, Brand, Color, OwnerPID from Car;
end //

delimiter ;

call GetCarDetails();

-- або через json
delimiter //
create function GetCarsAsJsonC() returns json
deterministic
reads sql data
begin
    -- Повертає дані всіх автомобілів у форматі JSON
    return (select JSON_ARRAYAGG(
                JSON_OBJECT(
                    'RegistrationNumber', RegistrationNumber,
                    'TypeCar', TypeCar,
                    'Brand', Brand,
                    'Color', Color,
                    'OwnerPID', OwnerPID
                )
            ) from Car);
end //
delimiter ;

SELECT GetCarsAsJsonC();

-- Робота з курсорами
delimiter //

create procedure FetchAllCars()
begin
    -- Спочатку визначаємо всі змінні
    declare v_registrationNumber varchar(255);
    declare v_typeCar varchar(50);
    declare v_brand varchar(50);
    declare v_color varchar(50);
    declare v_done int default false;

    -- Декларування курсору для вибірки даних з таблиці Car
    declare car_cursor cursor for select RegistrationNumber, TypeCar, Brand, Color from Car;

    -- Декларування обробника для визначення кінця даних
    declare continue handler for not found set v_done = true;

    -- Тепер можемо виконувати дії з тимчасовими таблицями та інші операції
    drop temporary table if exists TempCarDetails;
    create temporary table TempCarDetails (
        registrationNumber varchar(255),
        typeCar varchar(50),
        brand varchar(50),
        color varchar(50)
    );

    open car_cursor;

    fetch_loop: loop
        fetch car_cursor into v_registrationNumber, v_typeCar, v_brand, v_color;
        if v_done then
            leave fetch_loop;
        end if;
        insert into TempCarDetails (registrationNumber, typeCar, brand, color)
        values (v_registrationNumber, v_typeCar, v_brand, v_color);
    end loop;

    close car_cursor;
    select * from TempCarDetails;
    drop temporary table TempCarDetails;
END //
delimiter ;

CALL FetchAllCars();

-- тригери
create table AuditTable (
    id int auto_increment primary key,
    action varchar(50),
    description text,
    changed_by varchar(255),
    change_date timestamp
);
-- тригер, що спрацьовує при видаленні даних
delimiter //
create trigger CarDeleteTrigger
before delete on Car for each row
begin
	insert into AuditTable (action,description,changed_by, change_date)
	values ('Delete', concat('Deleted car with registration number ', OLD.RegistrationNumber), current_user(), now());
end //
delimiter ; 

-- тригер, що спрацьовує при модифікації даних
 delimiter //
create trigger CarUpdateTrigger
before update on Car for each row 
begin
    insert into AuditTable (action, description, changed_by, change_date)
    values ('Update', concat('Updated car with registration number ', OLD.RegistrationNumber), current_user(), now());
end //
delimiter ;

-- створити тригер, котрий буде спрацьовувати при додаванні даних
delimiter //
create trigger CarInsertTrigger
after insert on Car for each row 
begin
    insert into AuditTable (action, description, changed_by, change_date)
    values ('Insert', concat('Inserted new car with registration number ', NEW.RegistrationNumber), current_user(), now());
end //
delimiter ;

-- Додавання запису до таблиці Car
insert into Car (RegistrationNumber, TypeCar, Brand, Color) VALUES ('QQ1234QQ', 'Sedan', 'Ford', 'Blue');

-- Оновлення запису в таблиці Car
update Car set Brand = 'Honda' where RegistrationNumber = 'QQ1234QQ';

-- Видалення запису з таблиці Car
delete from Car where RegistrationNumber = 'QQ1234QQ';

select *from AuditTable;