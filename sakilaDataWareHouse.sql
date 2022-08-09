-- SELECT p.payment_id, p.rental_id, sum(p.amount), r.inventory_id, i.film_id, f.title FROM payment p
-- JOIN rental r on p.rental_id = r.rental_id
-- JOIN inventory i on r.inventory_id = i.inventory_id
-- JOIN film f on f.film_id = i.film_id
-- group by f.title;

CREATE DATABASE sakilaDataWareHouse;
use sakilaDataWareHouse;
DROP TABLE dimdate;
DROP TABLE dimcustomer;
DROP TABLE dimfilm;
DROP TABLE dimstore;
DROP TABLE factsales;
CREATE TABLE dimDate(
					dateKey int UNIQUE NOT NULL PRIMARY KEY,
                    fullDate DATE NOT NULL,
                    dayOfWeek TINYINT NOT NULL,
                    dayName VARCHAR(10) NOT NULL,
                    dayAbbver CHAR(3) NOT NULL,
                    dayOfMonth TINYINT NOT NULL,
                    dayOfYear SMALLINT NOT NULL,
                    weekOfYear TINYINT NOT NULL,
					monthOfYear TINYINT NOT NULL,
                    monthName VARCHAR(10) NOT NULL,
                    monthAbbver CHAR(3) NOT NULL,
                    quarter TINYINT NOT NULL,
                    year SMALLINT NOT NULL,
                    isWeekend CHAR(1) NOT NULL
                    );

CREATE TABLE dimCustomer(
						customerKey INT UNIQUE NOT NULL PRIMARY KEY,
                        customerID SMALLINT NOT NULL,
                        firstName VARCHAR(45) NOT NULL,
                        lastName VARCHAR(45) NOT NULL,
                        address1 VARCHAR(50) NOT NULL,
                        address2 VARCHAR(50) NOT NULL,
                        district VARCHAR(20) NOT NULL,
                        city VARCHAR(50) NOT NULL,
                        country VARCHAR(50) NOT NULL,
						postalCode VARCHAR(10) NOT NULL,
                        location GEOMETRY NOT NULL,
                        phone VARCHAR(20) NOT NULL, 
                        email VARCHAR(50) NOT NULL,
                        createDate DATETIME NOT NULL
                        );
CREATE TABLE dimFilm(
					filmKey INT UNIQUE NOT NULL PRIMARY KEY,
                    filmID SMALLINT NOT NULL,
                    title VARCHAR(128) NOT NULL,
                    category VARCHAR(25) NOT NULL,
                    firstNameActor VARCHAR(45),
                    lastNameActor VARCHAR(45),
                    description TEXT NOT NULL,
                    releaseYear YEAR NOT NULL,
                    rentalDuration TINYINT NOT NULL,
                    rentalRate DECIMAL(4,2) NOT NULL,
                    length SMALLINT NOT NULL,
                    language CHAR(20) NOT NULL,
                    originalLanguage  CHAR(20) NOT NULL,
                    replacementCost DECIMAL(5,2) NOT NULL
                    );
CREATE TABLE dimStore(
					storeKey INT UNIQUE NOT NULL PRIMARY KEY,
                    storeID TINYINT NOT NULL,
                    managerStaffID TINYINT NOT NULL,
                    firstNameManager VARCHAR(45) NOT NULL,
                    lastNameManager VARCHAR(45) NOT NULL,
                    address1 VARCHAR(50) NOT NULL,
                    address2 VARCHAR(50) NOT NULL,
                    district VARCHAR(20) NOT NULL,
                    city VARCHAR(50) NOT NULL,
                    country VARCHAR(50) NOT NULL
					);
CREATE TABLE factSales(
						salesKey INT AUTO_INCREMENT UNIQUE NOT NULL PRIMARY KEY,
                        dateKey INT NOT NULL,
                        customerKey INT NOT NULL,
                        storeKey INT NOT NULL,
                        filmKey INT NOT NULL,
                        amountRevenue DECIMAL(5,2),
                        CONSTRAINT FK_dimCustomer FOREIGN KEY (customerKey) REFERENCES dimCustomer(customerKey),
						CONSTRAINT FK_dimDate FOREIGN KEY (dateKey) REFERENCES dimDate(dateKey),
                        CONSTRAINT FK_dimFilm FOREIGN KEY (filmKey) REFERENCES dimFilm(filmKey),
                        CONSTRAINT FK_dimStore FOREIGN KEY (storeKey) REFERENCES dimStore(storeKey)
                        );
CREATE TABLE factInventory(
						inventoryKey INT AUTO_INCREMENT UNIQUE NOT NULL PRIMARY KEY,
                        dateKey INT NOT NULL,
                        storeKey INT NOT NULL,
                        filmKey INT NOT NULL,
						CONSTRAINT FK_Inventory_dimDate FOREIGN KEY (dateKey) REFERENCES dimDate(dateKey),
                        CONSTRAINT FK_Inventory_dimFilm FOREIGN KEY (filmKey) REFERENCES dimFilm(filmKey),
                        CONSTRAINT FK_Inventory_dimStore FOREIGN KEY (storeKey) REFERENCES dimStore(storeKey)
                        );
                        
-- INSERT DATA

INSERT INTO dimDate(dateKey, fullDate, dayOfWeek, dayName, dayAbbver, dayOfMonth, dayOfYear, weekOfYear, monthOfYear, monthName, monthAbbver, quarter, year, isWeekend)
SELECT
		DISTINCT DATE_FORMAT(payment_date, '%Y%m%d')*1 as dateKey,
		date(payment_date) as fullDate,
        dayofweek(payment_date)  as dayOfWeek,
        dayname(payment_date) as dayName,
        left(dayname(payment_date),3) as dayAbbver,
        dayofmonth(payment_date) as dayOfMonth,
        dayofyear(payment_date) as dayOfYear,
        weekofyear(payment_date) as weekOfYear,
        month(payment_date) as monthOfYear,
        monthname(payment_date) as monthName,
        left(monthname(payment_date),3) as monthAbbver,
        quarter(payment_date) as quarter,
        year(payment_date) as year,
        case when dayofweek(payment_date) = 1 then 'Y' else 'N' end
        
from sakila.payment;



INSERT INTO dimcustomer(customerKey, customerID, firstName, lastName, address1, address2, district, city, country, postalCode, location, phone, email, createDate)
SELECT
		c.customer_id as customerKey,
        c.customer_id as customerID,
        c.first_name as firstName,
        c.last_name as lastName,
        a.address as address1,
        a.address2 as address2,
        a.district as district,
        ci.city as city,
        co.country as country,
        a.postal_code as postalCode,
        a.location as location,
        a.phone as phone,
        c.email as email,
        c.create_date as createDate
from sakila.customer as c
JOIN sakila.address as a ON c.address_id = a.address_id
JOIN sakila.city as ci ON a.city_id = ci.city_id
JOIN sakila.country as co ON ci.country_id = co.country_id;

INSERT INTO dimfilm(filmKey, filmID, title, category,firstNameActor, lastNameActor,description, releaseYear, rentalDuration, rentalRate, length, language, originalLanguage, replacementCost)

SELECT
		f.film_id as filmKey,
        f.film_id as filmID,
        f.title as title,
        c.name as category,
        a.first_name as firstNameActor,
        a.last_name as lastNameActor,
        f.description  as description,
        f.release_year as releaseYear,
        f.rental_duration as rentalDuration,
        f.rental_rate asrentalRate,
        f.length as length,
        l.name as language,
        l.name as originalLanguage,
        f.replacement_cost as replacementCost
FROM sakila.film as f
JOIN sakila.film_category as fc ON f.film_id = fc.film_id
JOIN sakila.film_actor as fa ON f.film_id = fa.film_id
JOIN sakila.actor as a ON fa.actor_id = a.actor_id
JOIN sakila.category as c ON fc.category_id = c.category_id
JOIN sakila.language as l ON  f.language_id = l.language_id;


INSERT INTO dimstore(storeKey, storeID, managerStaffID, firstNameManager, lastNameManager, address1, address2, district, city, country)

SELECT
		s.store_id as storeKey,
        s.store_id as storeID,
        s.manager_staff_id as managerStaffID,
        st.first_name firstNameManager,
        st.last_name as lastNameManager,
        a.address as address1,
        case when a.address2 is null then 'NA' else   a.address2 end,
        a.district as district,
        c.city as city,
        co.country as country
        
FROM sakila.store as s
JOIN sakila.staff as st ON s.store_id = st.store_id
JOIN sakila.address as a ON s.address_id = a.address_id
JOIN sakila.city as c ON a.city_id = c.city_id
JOIN sakila.country as co ON  c.country_id = co.country_id;

INSERT INTO factsales(dateKey, customerKey, storeKey, filmKey, amountRevenue)

SELECT
		DISTINCT date_format(p.payment_date, '%Y%m%d')*1 as dateKey,
        p.customer_id as customerKey,
        i.store_id as storeKey,
        i.film_id as filmKey,
        p.amount as amountRevenue
        
FROM sakila.payment as p
JOIN sakila.rental as r ON p.rental_id = r.rental_id
JOIN sakila.inventory as i ON i.inventory_id = r.inventory_id
;                   




