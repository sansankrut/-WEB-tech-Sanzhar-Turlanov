BEGIN;

WITH new_movies AS (
SELECT
	'Game of Thrones' AS title,
	'Noble families fight for the Iron Throne of the Seven Kingdoms, '
        || 'while an ancient evil awakens beyond the northern border '
        || 'and a dragon queen rises across the sea.' AS description,
	2011 AS release_year,
	(
	SELECT
		language_id
	FROM
		LANGUAGE
	WHERE
		lower(name) = 'english') AS language_id,
	7 AS rental_duration,
	4.99 AS rental_rate,
	60 AS length,
	'R'::mpaa_rating AS rating
UNION ALL
SELECT
	'Breaking Bad' AS title,
	'A high school chemistry teacher diagnosed with cancer teams up '
        || 'with a former student to manufacture and sell crystal meth '
        || 'to secure his family''s future.' AS description,
	2008 AS release_year,
	(
	SELECT
		language_id
	FROM
		LANGUAGE
	WHERE
		lower(name) = 'english') AS language_id,
	14 AS rental_duration,
	9.99 AS rental_rate,
	47 AS length,
	'R'::mpaa_rating AS rating
UNION ALL
SELECT
	'Thor' AS title,
	'The powerful but arrogant god Thor is cast out of Asgard to live '
        || 'among humans in Midgard (Earth), where he soon becomes one of '
        || 'their finest defenders.' AS description,
	2011 AS release_year,
	(
	SELECT
		language_id
	FROM
		LANGUAGE
	WHERE
		lower(name) = 'english') AS language_id,
	21 AS rental_duration,
	19.99 AS rental_rate,
	115 AS length,
	'PG-13'::mpaa_rating AS rating
),

inserted_movies AS (
INSERT
	INTO
		film
        (title,
		description,
		release_year,
		language_id,
		rental_duration,
		rental_rate,
		length,
		rating,
		last_update)
		SELECT
			nm.title,
			nm.description,
			nm.release_year,
			nm.language_id,
			nm.rental_duration,
			nm.rental_rate,
			nm.length,
			nm.rating,
			CURRENT_DATE
		FROM
			new_movies nm
		WHERE
			NOT EXISTS (
			SELECT
				1
			FROM
				film f
			WHERE
				f.title = nm.title
				AND f.release_year = nm.release_year
    )
    RETURNING film_id,
			title,
			release_year,
			rental_duration,
			rental_rate,
			last_update
)
SELECT
	film_id,
	title,
	release_year,
	rental_duration,
	rental_rate,
	last_update
FROM
	inserted_movies;

SELECT
	film_id,
	title,
	release_year,
	rental_duration,
	rental_rate,
	rating,
	last_update
FROM
	film
WHERE
	title IN ('Game of Thrones', 'Breaking Bad', 'Thor')
	AND release_year IN (2011, 2008);

INSERT
	INTO
	actor (first_name,
	last_name,
	last_update)
SELECT
	'Peter',
	'Dinklage',
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		actor
	WHERE
		first_name = 'Peter'
		AND last_name = 'Dinklage');

INSERT
	INTO
	actor (first_name,
	last_name,
	last_update)
SELECT
	'Kit',
	'Harington',
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		actor
	WHERE
		first_name = 'Kit'
		AND last_name = 'Harington');

INSERT
	INTO
	actor (first_name,
	last_name,
	last_update)
SELECT
	'Emilia',
	'Clarke',
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		actor
	WHERE
		first_name = 'Emilia'
		AND last_name = 'Clarke');

INSERT
	INTO
	actor (first_name,
	last_name,
	last_update)
SELECT
	'Maisie',
	'Williams',
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		actor
	WHERE
		first_name = 'Maisie'
		AND last_name = 'Williams');

INSERT
	INTO
	actor (first_name,
	last_name,
	last_update)
SELECT
	'Richard',
	'Madden',
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		actor
	WHERE
		first_name = 'Richard'
		AND last_name = 'Madden');
-- Thor actors
INSERT
	INTO
	actor (first_name,
	last_name,
	last_update)
SELECT
	'Aidan',
	'Gillen',
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		actor
	WHERE
		first_name = 'Aidan'
		AND last_name = 'Gillen');

SELECT
	actor_id,
	first_name,
	last_name,
	last_update
FROM
	actor
WHERE
	(first_name = 'Peter'
		AND last_name = 'Dinklage')
	OR (first_name = 'Kit'
		AND last_name = 'Harington')
	OR (first_name = 'Emilia'
		AND last_name = 'Clarke')
	OR (first_name = 'Maisie'
		AND last_name = 'Williams')
	OR (first_name = 'Richard'
		AND last_name = 'Madden')
	OR (first_name = 'Aidan'
		AND last_name = 'Gillen');

INSERT
	INTO
	film_actor (actor_id,
	film_id,
	last_update)
SELECT
	(
	SELECT
		actor_id
	FROM
		actor
	WHERE
		first_name = 'Peter'
		AND last_name = 'Dinklage'),
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Game of Thrones'
		AND release_year = 2011),
	CURRENT_DATE
ON
	CONFLICT DO NOTHING;

INSERT
	INTO
	film_actor (actor_id,
	film_id,
	last_update)
SELECT
	(
	SELECT
		actor_id
	FROM
		actor
	WHERE
		first_name = 'Kit'
		AND last_name = 'Harington'),
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Game of Thrones'
		AND release_year = 2011),
	CURRENT_DATE
ON
	CONFLICT DO NOTHING;

INSERT
	INTO
	film_actor (actor_id,
	film_id,
	last_update)
SELECT
	(
	SELECT
		actor_id
	FROM
		actor
	WHERE
		first_name = 'Emilia'
		AND last_name = 'Clarke'),
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Game of Thrones'
		AND release_year = 2011),
	CURRENT_DATE
ON
	CONFLICT DO NOTHING;

INSERT
	INTO
	film_actor (actor_id,
	film_id,
	last_update)
SELECT
	(
	SELECT
		actor_id
	FROM
		actor
	WHERE
		first_name = 'Maisie'
		AND last_name = 'Williams'),
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Breaking Bad'
		AND release_year = 2008),
	CURRENT_DATE
ON
	CONFLICT DO NOTHING;

INSERT
	INTO
	film_actor (actor_id,
	film_id,
	last_update)
SELECT
	(
	SELECT
		actor_id
	FROM
		actor
	WHERE
		first_name = 'Richard'
		AND last_name = 'Madden'),
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Breaking Bad'
		AND release_year = 2008),
	CURRENT_DATE
ON
	CONFLICT DO NOTHING;

INSERT
	INTO
	film_actor (actor_id,
	film_id,
	last_update)
SELECT
	(
	SELECT
		actor_id
	FROM
		actor
	WHERE
		first_name = 'Aidan'
		AND last_name = 'Gillen'),
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Thor'
		AND release_year = 2011),
	CURRENT_DATE
ON
	CONFLICT DO NOTHING;

INSERT
	INTO
	inventory (film_id,
	store_id,
	last_update)
SELECT
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Game of Thrones'
		AND release_year = 2011),
	(
	SELECT
		MIN(store_id)
	FROM
		store),
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		inventory
	WHERE
		film_id = (
		SELECT
			film_id
		FROM
			film
		WHERE
			title = 'Game of Thrones'
			AND release_year = 2011)
		AND store_id = (
		SELECT
			MIN(store_id)
		FROM
			store)
);

INSERT
	INTO
	inventory (film_id,
	store_id,
	last_update)
SELECT
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Breaking Bad'
		AND release_year = 2008),
	(
	SELECT
		MIN(store_id)
	FROM
		store),
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		inventory
	WHERE
		film_id = (
		SELECT
			film_id
		FROM
			film
		WHERE
			title = 'Breaking Bad'
			AND release_year = 2008)
		AND store_id = (
		SELECT
			MIN(store_id)
		FROM
			store)
);

INSERT
	INTO
	inventory (film_id,
	store_id,
	last_update)
SELECT
	(
	SELECT
		film_id
	FROM
		film
	WHERE
		title = 'Thor'
		AND release_year = 2011),
	(
	SELECT
		MIN(store_id)
	FROM
		store),
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		inventory
	WHERE
		film_id = (
		SELECT
			film_id
		FROM
			film
		WHERE
			title = 'Thor'
			AND release_year = 2011)
		AND store_id = (
		SELECT
			MIN(store_id)
		FROM
			store)
);

SELECT
	i.inventory_id,
	f.title,
	i.store_id,
	i.last_update
FROM
	inventory i
JOIN film f ON
	i.film_id = f.film_id
WHERE
	f.title IN ('Game of Thrones', 'Breaking Bad', 'Thor')
	AND f.release_year IN (2011, 2008);

SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT r.rental_id) AS rental_count,
	COUNT(DISTINCT p.payment_id) AS payment_count
FROM
	customer c
JOIN rental r ON
	c.customer_id = r.customer_id
JOIN payment p ON
	c.customer_id = p.customer_id
GROUP BY
	c.customer_id,
	c.first_name,
	c.last_name
HAVING
	COUNT(DISTINCT r.rental_id) >= 43
	AND COUNT(DISTINCT p.payment_id) >= 43
ORDER BY
	rental_count DESC
LIMIT 1;

UPDATE
	customer
SET
	first_name = 'Aibek',
	last_name = 'Dzhaksybekov',
	email = 'aibek.dzhaksybekov@sakilacustomer.org',
	address_id = (
	SELECT
		MIN(address_id)
	FROM
		address),
	last_update = CURRENT_DATE
WHERE
	customer_id = (
	SELECT
		c.customer_id
	FROM
		customer c
	JOIN rental r ON
		c.customer_id = r.customer_id
	JOIN payment p ON
		c.customer_id = p.customer_id
	GROUP BY
		c.customer_id
	HAVING
		COUNT(DISTINCT r.rental_id) >= 43
			AND COUNT(DISTINCT p.payment_id) >= 43
		ORDER BY
			COUNT(DISTINCT r.rental_id) DESC
		LIMIT 1
);

SELECT
	customer_id,
	first_name,
	last_name,
	email,
	address_id,
	last_update
FROM
	customer
WHERE
	first_name = 'Aibek'
	AND last_name = 'Dzhaksybekov';

SELECT
	*
FROM
	payment
WHERE
	customer_id = (
	SELECT
		customer_id
	FROM
		customer
	WHERE
		first_name = 'Aibek'
		AND last_name = 'Dzhaksybekov'
);

DELETE
FROM
	payment
WHERE
	customer_id = (
	SELECT
		customer_id
	FROM
		customer
	WHERE
		first_name = 'Aibek'
		AND last_name = 'Dzhaksybekov'
);

SELECT
	*
FROM
	rental
WHERE
	customer_id = (
	SELECT
		customer_id
	FROM
		customer
	WHERE
		first_name = 'Aibek'
		AND last_name = 'Dzhaksybekov'
);

DELETE
FROM
	rental
WHERE
	customer_id = (
	SELECT
		customer_id
	FROM
		customer
	WHERE
		first_name = 'Aibek'
		AND last_name = 'Dzhaksybekov'
);

WITH rental_got AS (
INSERT
	INTO
		rental (rental_date,
		inventory_id,
		customer_id,
		return_date,
		staff_id,
		last_update)
		SELECT
			'2017-01-15 10:00:00'::TIMESTAMP,
			(
			SELECT
				i.inventory_id
			FROM
				inventory i
			JOIN film f ON
				i.film_id = f.film_id
			WHERE
				f.title = 'Game of Thrones'
				AND f.release_year = 2011
				AND i.store_id = (
				SELECT
					MIN(store_id)
				FROM
					store)
			LIMIT 1
        ),
			(
			SELECT
				customer_id
			FROM
				customer
			WHERE
				first_name = 'Aibek'
				AND last_name = 'Dzhaksybekov'),
			'2017-01-15 10:00:00'::TIMESTAMP + 7 * INTERVAL '1 day',
			(
			SELECT
				MIN(staff_id)
			FROM
				staff),
			CURRENT_DATE
		WHERE
			NOT EXISTS (
			SELECT
				1
			FROM
				rental
			WHERE
				customer_id = (
				SELECT
					customer_id
				FROM
					customer
				WHERE
					first_name = 'Aibek'
					AND last_name = 'Dzhaksybekov')
				AND inventory_id = (
				SELECT
					i.inventory_id
				FROM
					inventory i
				JOIN film f ON
					i.film_id = f.film_id
				WHERE
					f.title = 'Game of Thrones'
					AND f.release_year = 2011
					AND i.store_id = (
					SELECT
						MIN(store_id)
					FROM
						store)
				LIMIT 1
          )
    )
    RETURNING rental_id,
			customer_id
)
INSERT
	INTO
	payment (customer_id,
	staff_id,
	rental_id,
	amount,
	payment_date)
SELECT
	r.customer_id,
	(
	SELECT
		MIN(staff_id)
	FROM
		staff),
	r.rental_id,
	4.99,
	'2017-01-15 10:05:00'::TIMESTAMP
FROM
	rental_got r
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		payment p
	WHERE
		p.rental_id = r.rental_id
		AND p.customer_id = r.customer_id
)
RETURNING payment_id,
	customer_id,
	rental_id,
	amount,
	payment_date;

WITH rental_bb AS (
INSERT
	INTO
		rental (rental_date,
		inventory_id,
		customer_id,
		return_date,
		staff_id,
		last_update)
		SELECT
			'2017-02-10 12:00:00'::TIMESTAMP,
			(
			SELECT
				i.inventory_id
			FROM
				inventory i
			JOIN film f ON
				i.film_id = f.film_id
			WHERE
				f.title = 'Breaking Bad'
				AND f.release_year = 2008
				AND i.store_id = (
				SELECT
					MIN(store_id)
				FROM
					store)
			LIMIT 1
        ),
			(
			SELECT
				customer_id
			FROM
				customer
			WHERE
				first_name = 'Aibek'
				AND last_name = 'Dzhaksybekov'),
			'2017-02-10 12:00:00'::TIMESTAMP + 14 * INTERVAL '1 day',
			(
			SELECT
				MIN(staff_id)
			FROM
				staff),
			CURRENT_DATE
		WHERE
			NOT EXISTS (
			SELECT
				1
			FROM
				rental
			WHERE
				customer_id = (
				SELECT
					customer_id
				FROM
					customer
				WHERE
					first_name = 'Aibek'
					AND last_name = 'Dzhaksybekov')
				AND inventory_id = (
				SELECT
					i.inventory_id
				FROM
					inventory i
				JOIN film f ON
					i.film_id = f.film_id
				WHERE
					f.title = 'Breaking Bad'
					AND f.release_year = 2008
					AND i.store_id = (
					SELECT
						MIN(store_id)
					FROM
						store)
				LIMIT 1
          )
    )
    RETURNING rental_id,
			customer_id
)
INSERT
	INTO
	payment (customer_id,
	staff_id,
	rental_id,
	amount,
	payment_date)
SELECT
	r.customer_id,
	(
	SELECT
		MIN(staff_id)
	FROM
		staff),
	r.rental_id,
	9.99,
	'2017-02-10 12:05:00'::TIMESTAMP
FROM
	rental_bb r
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		payment p
	WHERE
		p.rental_id = r.rental_id
		AND p.customer_id = r.customer_id
)
RETURNING payment_id,
	customer_id,
	rental_id,
	amount,
	payment_date;

WITH rental_thor AS (
INSERT
	INTO
		rental (rental_date,
		inventory_id,
		customer_id,
		return_date,
		staff_id,
		last_update)
		SELECT
			'2017-03-20 15:00:00'::TIMESTAMP,
			(
			SELECT
				i.inventory_id
			FROM
				inventory i
			JOIN film f ON
				i.film_id = f.film_id
			WHERE
				f.title = 'Thor'
				AND f.release_year = 2011
				AND i.store_id = (
				SELECT
					MIN(store_id)
				FROM
					store)
			LIMIT 1
        ),
			(
			SELECT
				customer_id
			FROM
				customer
			WHERE
				first_name = 'Aibek'
				AND last_name = 'Dzhaksybekov'),
			'2017-03-20 15:00:00'::TIMESTAMP + 21 * INTERVAL '1 day',
			(
			SELECT
				MIN(staff_id)
			FROM
				staff),
			CURRENT_DATE
		WHERE
			NOT EXISTS (
			SELECT
				1
			FROM
				rental
			WHERE
				customer_id = (
				SELECT
					customer_id
				FROM
					customer
				WHERE
					first_name = 'Aibek'
					AND last_name = 'Dzhaksybekov')
				AND inventory_id = (
				SELECT
					i.inventory_id
				FROM
					inventory i
				JOIN film f ON
					i.film_id = f.film_id
				WHERE
					f.title = 'Thor'
					AND f.release_year = 2011
					AND i.store_id = (
					SELECT
						MIN(store_id)
					FROM
						store)
				LIMIT 1
          )
    )
    RETURNING rental_id,
			customer_id
)
INSERT
	INTO
	payment (customer_id,
	staff_id,
	rental_id,
	amount,
	payment_date)
SELECT
	r.customer_id,
	(
	SELECT
		MIN(staff_id)
	FROM
		staff),
	r.rental_id,
	19.99,
	'2017-03-20 15:05:00'::TIMESTAMP
FROM
	rental_thor r
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		payment p
	WHERE
		p.rental_id = r.rental_id
		AND p.customer_id = r.customer_id
)
RETURNING payment_id,
	customer_id,
	rental_id,
	amount,
	payment_date;

COMMIT;