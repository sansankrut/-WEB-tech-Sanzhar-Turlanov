# Final Project — Cinema Database

## What is this

This is a database for a cinema. It stores information about films, halls, sessions, customers, tickets, payments, staff and reviews. The idea is to model how a real cinema works — you schedule a session, customers buy tickets, staff gets assigned, and after watching the film customers can leave a review.

## Database and schema

Database name: cinema_db
Schema name: cinema

## How to run

Open pgAdmin, go to Query Tool, open the file 02_final.sql and press F5. Or if you use psql:

    psql -U postgres -f 02_final.sql

You can run it multiple times, it will not give errors the second time.

## Tables

There are 10 tables total:

- genres — list of film genres like Action, Comedy etc
- halls — the screening rooms, each has a name and capacity
- customers — people who buy tickets
- staff — cinema employees like cashiers, managers, ushers
- films — the actual movies
- sessions — a specific showing of a film in a hall at a certain time
- tickets — when a customer books a seat for a session
- staff_sessions — which staff members work which session
- payments — payment info for each ticket
- reviews — customers rating and reviewing films they watched

## Many to many relationships

tickets connects customers and sessions
staff_sessions connects staff and sessions
reviews connects customers and films

## Some design decisions

I used ON DELETE RESTRICT on most foreign keys because I don't want to accidentally delete a film or customer if there are still records attached to them.

For staff_sessions I used CASCADE because if a session gets deleted, the staff assignments for it don't make sense anymore so they should go too.

I used NUMERIC(12,2) for all money columns instead of float because float has rounding problems with money.

The tax column in payments is GENERATED — it always calculates 12% of the amount automatically so nobody has to enter it manually.

New customers get status "regular" by default and it changes to "premium" automatically if they buy enough tickets.
