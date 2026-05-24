-- ============================================================
-- Final Project — Cinema Domain
-- Database: cinema_db  /  Schema: cinema
-- ============================================================

-- =====  DATABASE + SCHEMA  =====

CREATE DATABASE cinemaDB
   

CREATE SCHEMA IF NOT EXISTS cinema;

-- ============================================================
-- PART 2: CREATE TABLE
-- ============================================================

DROP TABLE IF EXISTS
    cinema.reviews,
    cinema.payments,
    cinema.staff_sessions,
    cinema.tickets,
    cinema.sessions,
    cinema.staff,
    cinema.films,
    cinema.customers,
    cinema.halls,
    cinema.genres
CASCADE;

CREATE TABLE IF NOT EXISTS cinema.genres (
    genre_id   SERIAL PRIMARY KEY,
    name       VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS cinema.halls (
    hall_id    SERIAL PRIMARY KEY,
    name       VARCHAR(60) NOT NULL UNIQUE,
    -- Non-negative capacity: a hall cannot seat fewer than 0 people
    capacity   INT NOT NULL CHECK (capacity >= 0)
);

CREATE TABLE IF NOT EXISTS cinema.customers (
    customer_id   SERIAL PRIMARY KEY,
    email         VARCHAR(120) NOT NULL UNIQUE,
    full_name     VARCHAR(150) NOT NULL,
    -- Enumerated gender values only
    gender        VARCHAR(10)  NOT NULL CHECK (gender IN ('M', 'F', 'Other')),
    birth_date    DATE,
    status        VARCHAR(20)  NOT NULL DEFAULT 'regular'
                               CHECK (status IN ('regular', 'premium', 'vip')),
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cinema.staff (
    staff_id    SERIAL PRIMARY KEY,
    full_name   VARCHAR(150) NOT NULL,
    -- Enumerated role values
    role        VARCHAR(40)  NOT NULL CHECK (role IN ('cashier', 'usher', 'projectionist', 'manager')),
    -- Hire date must be after 2026-01-01
    hire_date   DATE         NOT NULL CHECK (hire_date > DATE '2026-01-01'),
    -- Non-negative salary
    salary      NUMERIC(12,2) NOT NULL CHECK (salary >= 0)
);

CREATE TABLE IF NOT EXISTS cinema.films (
    film_id           SERIAL PRIMARY KEY,
    title             VARCHAR(200) NOT NULL,
    duration_minutes  INT          NOT NULL CHECK (duration_minutes > 0),
    release_date      DATE,
    rating            NUMERIC(3,1) CHECK (rating BETWEEN 1 AND 10),
    genre_id          INT NOT NULL REFERENCES cinema.genres(genre_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS cinema.sessions (
    session_id   SERIAL PRIMARY KEY,
    film_id      INT           NOT NULL REFERENCES cinema.films(film_id)  ON DELETE RESTRICT,
    hall_id      INT           NOT NULL REFERENCES cinema.halls(hall_id)  ON DELETE RESTRICT,
    -- Session date must be after 2026-01-01
    start_time   TIMESTAMP     NOT NULL CHECK (start_time > TIMESTAMP '2026-01-01 00:00:00'),
    price        NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    status       VARCHAR(20)   NOT NULL DEFAULT 'scheduled'
                               CHECK (status IN ('scheduled', 'ongoing', 'finished', 'cancelled'))
);

CREATE TABLE IF NOT EXISTS cinema.tickets (
    ticket_id     SERIAL PRIMARY KEY,
    session_id    INT           NOT NULL REFERENCES cinema.sessions(session_id)   ON DELETE RESTRICT,
    customer_id   INT           NOT NULL REFERENCES cinema.customers(customer_id) ON DELETE RESTRICT,
    seat_number   VARCHAR(10)   NOT NULL,
    quantity      INT           NOT NULL DEFAULT 1 CHECK (quantity > 0),
    total_price   NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    status        VARCHAR(20)   NOT NULL DEFAULT 'booked'
                                CHECK (status IN ('booked', 'used', 'cancelled')),
    UNIQUE (session_id, seat_number)
);

CREATE TABLE IF NOT EXISTS cinema.staff_sessions (
    staff_session_id   SERIAL PRIMARY KEY,
    staff_id           INT       NOT NULL REFERENCES cinema.staff(staff_id)      ON DELETE RESTRICT,
    session_id         INT       NOT NULL REFERENCES cinema.sessions(session_id) ON DELETE CASCADE,
    assigned_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (staff_id, session_id)
);

CREATE TABLE IF NOT EXISTS cinema.payments (
    payment_id   SERIAL PRIMARY KEY,
    ticket_id    INT           NOT NULL REFERENCES cinema.tickets(ticket_id) ON DELETE RESTRICT,
    amount       NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    -- GENERATED: tax is always 12% of the payment amount
    tax          NUMERIC(12,2) GENERATED ALWAYS AS (amount * 0.12) STORED,
    -- Payment date must be after 2026-01-01
    paid_at      TIMESTAMP     NOT NULL CHECK (paid_at > TIMESTAMP '2026-01-01 00:00:00'),
    method       VARCHAR(30)   NOT NULL DEFAULT 'card'
                               CHECK (method IN ('card', 'cash', 'online'))
);

CREATE TABLE IF NOT EXISTS cinema.reviews (
    review_id    SERIAL PRIMARY KEY,
    customer_id  INT       NOT NULL REFERENCES cinema.customers(customer_id) ON DELETE CASCADE,
    film_id      INT       NOT NULL REFERENCES cinema.films(film_id)         ON DELETE CASCADE,
    -- Rating must be between 1 and 10
    rating       INT       NOT NULL CHECK (rating BETWEEN 1 AND 10),
    comment      TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (customer_id, film_id)
);

-- ============================================================
-- PART 3: ALTER TABLE — schema evolution
-- ============================================================

-- 1. phone numbers can be longer for international customers
ALTER TABLE cinema.customers ADD COLUMN IF NOT EXISTS phone VARCHAR(20);

-- 2. discount column was forgotten in the initial CREATE; added after pricing feature request
ALTER TABLE cinema.tickets ADD COLUMN IF NOT EXISTS discount NUMERIC(5,2) NOT NULL DEFAULT 0.00;

-- 3. rename 'comment' to 'review_text' for clarity — 'comment' is too generic
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'cinema' AND table_name = 'reviews' AND column_name = 'comment'
    ) THEN
        ALTER TABLE cinema.reviews RENAME COLUMN comment TO review_text;
    END IF;
END $$;

-- 4. widen staff role column after adding more granular role names in the HR system
ALTER TABLE cinema.staff ALTER COLUMN role TYPE VARCHAR(60);

-- 5. drop default on payments.method — method must now always be provided explicitly
ALTER TABLE cinema.payments ALTER COLUMN method DROP DEFAULT;

-- ============================================================
-- PART 4: INSERT — re-runnable reset
-- ============================================================

TRUNCATE TABLE
    cinema.reviews,
    cinema.payments,
    cinema.staff_sessions,
    cinema.tickets,
    cinema.sessions,
    cinema.staff,
    cinema.films,
    cinema.customers,
    cinema.halls,
    cinema.genres
RESTART IDENTITY CASCADE;

INSERT INTO cinema.genres (name) VALUES
    ('Action'),
    ('Drama'),
    ('Comedy'),
    ('Thriller'),
    ('Animation'),
    ('Horror'),
    ('Science Fiction');

INSERT INTO cinema.halls (name, capacity) VALUES
    ('Hall A',   120),
    ('Hall B',    80),
    ('Hall VIP',  40);

INSERT INTO cinema.customers (email, full_name, gender, birth_date) VALUES
    ('sanzharT@gmail.com',  'Sanzhar Turlanov',    'M', DATE '1997-04-23'),
    ('raiymbekS@gmail.com', 'Rayimbek Salamat',    'M', DATE '1995-08-15'),
    ('ayatS@gmail.com',     'Ayat Shaymardanov',   'M', DATE '2000-02-10'),
    ('zarinaS@gmail.com',   'Zarina Sultanova',    'F', DATE '1998-11-05'),
    ('dinaraA@gmail.com',   'Dinara Abenova',      'F', DATE '2000-01-18');

INSERT INTO cinema.staff (full_name, role, hire_date, salary) VALUES
    ('Temirlan Gizatov', 'manager',       DATE '2026-02-01', 350000.00),
    ('Temirlan Sadykov', 'cashier',       DATE '2026-02-15', 180000.00),
    ('Damir Gabitov',    'projectionist', DATE '2026-03-01', 200000.00),
    ('Rakhim Kilibay',   'usher',         DATE '2026-03-10', 150000.00);

INSERT INTO cinema.films (title, duration_minutes, release_date, rating, genre_id) VALUES
    ('Avengers',   143, DATE '2026-02-10', 8.5,
        (SELECT genre_id FROM cinema.genres WHERE name = 'Action')),
    ('Thor',       115, DATE '2026-03-01', 7.8,
        (SELECT genre_id FROM cinema.genres WHERE name = 'Action')),
    ('Hulk',       112, DATE '2026-03-20', 7.2,
        (SELECT genre_id FROM cinema.genres WHERE name = 'Action')),
    ('Iron Man',   126, DATE '2026-04-05', 8.9,
        (SELECT genre_id FROM cinema.genres WHERE name = 'Science Fiction')),
    ('Spider-Man', 133, DATE '2026-04-15', 9.0,
        (SELECT genre_id FROM cinema.genres WHERE name = 'Action'));

INSERT INTO cinema.sessions (film_id, hall_id, start_time, price, status) VALUES
    (
        (SELECT film_id FROM cinema.films WHERE title = 'Avengers'),
        (SELECT hall_id FROM cinema.halls WHERE name  = 'Hall A'),
        TIMESTAMP '2026-05-01 14:00:00', 2500.00, 'finished'
    ),
    (
        (SELECT film_id FROM cinema.films WHERE title = 'Thor'),
        (SELECT hall_id FROM cinema.halls WHERE name  = 'Hall B'),
        TIMESTAMP '2026-05-02 18:00:00', 2000.00, 'finished'
    ),
    (
        (SELECT film_id FROM cinema.films WHERE title = 'Hulk'),
        (SELECT hall_id FROM cinema.halls WHERE name  = 'Hall VIP'),
        TIMESTAMP '2026-05-03 20:00:00', 4000.00, 'finished'
    ),
    (
        (SELECT film_id FROM cinema.films WHERE title = 'Iron Man'),
        (SELECT hall_id FROM cinema.halls WHERE name  = 'Hall A'),
        TIMESTAMP '2026-05-10 16:00:00', 3000.00, 'scheduled'
    ),
    (
        (SELECT film_id FROM cinema.films WHERE title = 'Spider-Man'),
        (SELECT hall_id FROM cinema.halls WHERE name  = 'Hall B'),
        TIMESTAMP '2026-05-11 12:00:00', 1800.00, 'scheduled'
    );

INSERT INTO cinema.tickets (session_id, customer_id, seat_number, quantity, status)
SELECT s.session_id, c.customer_id, x.seat, x.qty, 'booked'
FROM (VALUES
    ('sanzharT@gmail.com',  'Avengers',   'A01', 1),
    ('sanzharT@gmail.com',  'Thor',       'B03', 1),
    ('raiymbekS@gmail.com', 'Avengers',   'A02', 2),
    ('zarinaS@gmail.com',   'Hulk',       'V05', 1),
    ('ayatS@gmail.com',     'Iron Man',   'A10', 1),
    ('dinaraA@gmail.com',   'Spider-Man', 'B07', 3)
) AS x(email, film_title, seat, qty)
JOIN cinema.customers c ON c.email = x.email
JOIN cinema.films     f ON f.title = x.film_title
JOIN cinema.sessions  s ON s.film_id = f.film_id;

INSERT INTO cinema.staff_sessions (staff_id, session_id)
SELECT st.staff_id, s.session_id
FROM (VALUES
    ('Temirlan Gizatov', 'Avengers'),
    ('Temirlan Sadykov', 'Avengers'),
    ('Damir Gabitov',    'Avengers'),
    ('Rakhim Kilibay',   'Thor'),
    ('Temirlan Sadykov', 'Hulk'),
    ('Damir Gabitov',    'Hulk'),
    ('Temirlan Gizatov', 'Iron Man')
) AS x(staff_name, film_title)
JOIN cinema.staff    st ON st.full_name = x.staff_name
JOIN cinema.films     f ON f.title      = x.film_title
JOIN cinema.sessions  s ON s.film_id   = f.film_id;

INSERT INTO cinema.payments (ticket_id, amount, paid_at, method)
SELECT
    t.ticket_id,
    s.price * t.quantity,
    s.start_time - INTERVAL '30 minutes',
    x.method
FROM (VALUES
    ('sanzharT@gmail.com',  'Avengers',   'A01', 'card'),
    ('sanzharT@gmail.com',  'Thor',       'B03', 'online'),
    ('raiymbekS@gmail.com', 'Avengers',   'A02', 'cash'),
    ('zarinaS@gmail.com',   'Hulk',       'V05', 'card'),
    ('ayatS@gmail.com',     'Iron Man',   'A10', 'online'),
    ('dinaraA@gmail.com',   'Spider-Man', 'B07', 'card')
) AS x(email, film_title, seat, method)
JOIN cinema.customers c ON c.email        = x.email
JOIN cinema.films     f ON f.title        = x.film_title
JOIN cinema.sessions  s ON s.film_id      = f.film_id
JOIN cinema.tickets   t ON t.session_id   = s.session_id
                       AND t.customer_id  = c.customer_id
                       AND t.seat_number  = x.seat;

INSERT INTO cinema.reviews (customer_id, film_id, rating, review_text) VALUES
    (
        (SELECT customer_id FROM cinema.customers WHERE email = 'sanzharT@gmail.com'),
        (SELECT film_id     FROM cinema.films     WHERE title = 'Avengers'),
        9, 'Epic action from start to finish. Best Marvel film yet!'
    ),
    (
        (SELECT customer_id FROM cinema.customers WHERE email = 'sanzharT@gmail.com'),
        (SELECT film_id     FROM cinema.films     WHERE title = 'Thor'),
        7, 'Good visuals but the story felt a bit rushed in the second half.'
    ),
    (
        (SELECT customer_id FROM cinema.customers WHERE email = 'raiymbekS@gmail.com'),
        (SELECT film_id     FROM cinema.films     WHERE title = 'Avengers'),
        8, 'Watched it with friends — incredible atmosphere in the hall.'
    ),
    (
        (SELECT customer_id FROM cinema.customers WHERE email = 'zarinaS@gmail.com'),
        (SELECT film_id     FROM cinema.films     WHERE title = 'Hulk'),
        6, 'Decent movie but Hulk deserves more screen time.'
    ),
    (
        (SELECT customer_id FROM cinema.customers WHERE email = 'dinaraA@gmail.com'),
        (SELECT film_id     FROM cinema.films     WHERE title = 'Spider-Man'),
        10, 'Absolutely loved it. The ending had the whole hall cheering!'
    );

-- ============================================================
-- PART 5: UPDATE
-- ============================================================

-- Business reason: customers who bought 2+ tickets in one booking
-- receive premium status for loyalty rewards.
UPDATE cinema.customers
SET status = 'premium'
WHERE customer_id IN (
    SELECT customer_id FROM cinema.tickets WHERE quantity >= 2
);

-- Business reason: ticket totals must reflect the real session price;
-- recalculate from sessions table after any price corrections.
UPDATE cinema.tickets t
SET total_price = sub.real_total
FROM (
    SELECT t2.ticket_id, s.price * t2.quantity AS real_total
    FROM cinema.tickets  t2
    JOIN cinema.sessions s ON s.session_id = t2.session_id
) sub
WHERE t.ticket_id = sub.ticket_id;

-- ============================================================
-- PART 5: DELETE
-- ============================================================

-- Business reason: remove cancelled tickets for sessions older than 30 days.
-- Wrapped in BEGIN ... ROLLBACK so demo data survives for the defense.
BEGIN;
    DELETE FROM cinema.tickets
    WHERE status = 'cancelled'
      AND ticket_id IN (
          SELECT t.ticket_id
          FROM cinema.tickets t
          JOIN cinema.sessions s ON s.session_id = t.session_id
          WHERE s.start_time < CURRENT_TIMESTAMP - INTERVAL '30 days'
      )
    RETURNING ticket_id, customer_id, seat_number, status;
ROLLBACK;

-- ============================================================
-- PART 6: GRANT / REVOKE
-- ============================================================

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'cinema_readonly') THEN
        REASSIGN OWNED BY cinema_readonly TO CURRENT_USER;
        DROP OWNED BY cinema_readonly;
        DROP ROLE cinema_readonly;
    END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'cinema_writer') THEN
        REASSIGN OWNED BY cinema_writer TO CURRENT_USER;
        DROP OWNED BY cinema_writer;
        DROP ROLE cinema_writer;
    END IF;
END $$;

CREATE ROLE cinema_readonly;
CREATE ROLE cinema_writer;

-- Schema USAGE is required before table-level GRANTs work
GRANT USAGE ON SCHEMA cinema TO cinema_readonly, cinema_writer;

-- cinema_readonly: reporting dashboard — read-only access
GRANT SELECT ON ALL TABLES IN SCHEMA cinema TO cinema_readonly;

-- cinema_writer: ticketing service — can create and modify tickets and payments
GRANT INSERT, UPDATE ON cinema.tickets  TO cinema_writer;
GRANT INSERT         ON cinema.payments TO cinema_writer;

-- REVOKE explanation: the cinema_writer role is used by the self-service kiosk.
-- After a security review, kiosks must not UPDATE existing tickets;
-- corrections go through the back-office service with a full audit trail.
REVOKE UPDATE ON cinema.tickets FROM cinema_writer;

SELECT * FROM cinema.genres;
SELECT * FROM cinema.halls;
SELECT * FROM cinema.customers;
SELECT * FROM cinema.staff;
SELECT * FROM cinema.films;
SELECT * FROM cinema.sessions;
SELECT * FROM cinema.tickets;
SELECT * FROM cinema.staff_sessions;
SELECT * FROM cinema.payments;
SELECT * FROM cinema.reviews;
