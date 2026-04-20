CREATE TABLE IF NOT EXISTS car_rental_fix.Person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(10) NOT NULL DEFAULT 'Other',
 
    CONSTRAINT chk_person_gender CHECK (gender IN ('M', 'F', 'Other')),
    CONSTRAINT chk_birth_date    CHECK (birth_date < CURRENT_DATE)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.Branch (
    branch_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    opened_date DATE  NOT NULL DEFAULT '2026-01-02',
 
    CONSTRAINT chk_branch_opened CHECK (opened_date > DATE '2026-01-01')
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.CarBrand (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(50) NOT NULL UNIQUE,
    country  VARCHAR(50) NOT NULL,
    
    FOREIGN KEY (brand_id) REFERENCES car_rental_fix.CarBrand(brand_id)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.CarModel (
    model_id SERIAL PRIMARY KEY,
    brand_id INT  NOT NULL,
    model_name VARCHAR(50) NOT NULL,
    body_type  VARCHAR(30) NOT NULL DEFAULT 'Sedan',
    seats INT NOT NULL DEFAULT 5,
 
    CONSTRAINT chk_model_seats CHECK (seats > 0 AND seats <= 20),
    FOREIGN KEY (brand_id) REFERENCES car_rental_fix.CarBrand(brand_id)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.CarCategory (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(30)   NOT NULL UNIQUE,
    price_per_day NUMERIC(10,2) NOT NULL DEFAULT 25.00,
 
    CONSTRAINT chk_price_positive CHECK (price_per_day >= 0)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.Car (
    car_id  SERIAL PRIMARY KEY,
    model_id  INT  NOT NULL,
    brand_id  INT  NOT NULL,
    category_id INT NOT NULL,
    branch_id  INT NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    year  INT  NOT NULL,
    color  VARCHAR(30) NOT NULL DEFAULT 'White',
    status  VARCHAR(20) NOT NULL DEFAULT 'available',
    mileage  NUMERIC(10,2) NOT NULL DEFAULT 0,
 
    CONSTRAINT chk_car_mileage CHECK (mileage >= 0),
    CONSTRAINT chk_car_year    CHECK (year >= 1990 AND year <= 2030),
    CONSTRAINT chk_car_status  CHECK (status IN ('available', 'rented', 'maintenance', 'retired')),
 
    FOREIGN KEY (model_id)    REFERENCES car_rental_fix.CarModel(model_id),
    FOREIGN KEY (category_id) REFERENCES car_rental_fix.CarCategory(category_id),
    FOREIGN KEY (branch_id)   REFERENCES car_rental_fix.Branch(branch_id)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.Customer (
    customer_id SERIAL PRIMARY KEY,
    person_id  INT  NOT NULL UNIQUE,
    driver_license VARCHAR(50) NOT NULL UNIQUE,
    license_issued DATE NOT NULL,
    loyalty_points INT NOT NULL DEFAULT 0,
 
    CONSTRAINT chk_license_date CHECK (license_issued > '2026-01-01'),
    CONSTRAINT chk_loyalty_points CHECK (loyalty_points >= 0),
 
    FOREIGN KEY (person_id) REFERENCES car_rental_fix.Person(person_id)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.Employee (
    employee_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL UNIQUE,
    branch_id INT NOT NULL,
    POSITION VARCHAR(50) NOT NULL,
    salary NUMERIC(10,2) NOT NULL,
    hire_date DATE NOT NULL,
 
    CONSTRAINT chk_salary CHECK (salary >= 0),
    CONSTRAINT chk_hire_date CHECK (hire_date > '2026-01-01'),
 
    FOREIGN KEY (person_id) REFERENCES car_rental_fix.Person(person_id),
    FOREIGN KEY (branch_id) REFERENCES car_rental_fix.Branch(branch_id)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.Rental (
    rental_id   SERIAL PRIMARY KEY,
    customer_id INT  NOT NULL,
    car_id  INT NOT NULL,
    employee_id INT  NOT NULL,
    start_date  DATE NOT NULL,
    end_date DATE NOT NULL,
    rental_days INT GENERATED ALWAYS AS (end_date - start_date) STORED,

    CONSTRAINT chk_rental_dates CHECK (end_date > start_date),

    FOREIGN KEY (customer_id) REFERENCES car_rental_fix.Customer(customer_id),
    FOREIGN KEY (car_id)      REFERENCES car_rental_fix.Car(car_id),
    FOREIGN KEY (employee_id) REFERENCES car_rental_fix.Employee(employee_id)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.Payment (
    payment_id SERIAL PRIMARY KEY,
    rental_id INT   NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    tax_rate NUMERIC(5,2)  NOT NULL DEFAULT 0.12,
    total_charge NUMERIC(10,2) GENERATED ALWAYS AS (ROUND(amount + (amount * tax_rate), 2)) STORED,
    payment_date DATE  NOT NULL,
    method   VARCHAR(20)  NOT NULL DEFAULT 'cash',
 
    CONSTRAINT chk_amount_positive CHECK (amount >= 0),
    CONSTRAINT chk_tax_rate CHECK (tax_rate >= 0 AND tax_rate <= 1),
    CONSTRAINT chk_pay_method  CHECK (method IN ('cash', 'card', 'online', 'transfer')),
 
    FOREIGN KEY (rental_id) REFERENCES car_rental_fix.Rental(rental_id)
);
 
CREATE TABLE IF NOT EXISTS car_rental_fix.Maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    car_id  INT NOT NULL,
    service_date  DATE  NOT NULL,
    description  TEXT NOT NULL,
    cost  NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    service_type VARCHAR(30)  NOT NULL DEFAULT 'routine',
 
    CONSTRAINT chk_service_date CHECK (service_date > '2026-01-01'),
    CONSTRAINT chk_maint_cost   CHECK (cost >= 0),
    CONSTRAINT chk_service_type CHECK (service_type IN ('routine', 'repair', 'inspection', 'emergency')),
 
    FOREIGN KEY (car_id) REFERENCES car_rental_fix.Car(car_id)
);