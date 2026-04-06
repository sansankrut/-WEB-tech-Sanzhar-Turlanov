
CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INT NOT NULL CHECK (age >= 0),
    country VARCHAR(50) NOT NULL,
    registered_date DATE NOT NULL DEFAULT CURRENT_DATE CHECK (registered_date >= '2026-01-01')
);


CREATE TABLE tournaments (
    tournament_id SERIAL PRIMARY KEY,
    title VARCHAR(100) UNIQUE NOT NULL,
    game_name VARCHAR(100) NOT NULL,
    prize_pool NUMERIC(10,2) NOT NULL CHECK (prize_pool >= 0),
    start_date DATE NOT NULL CHECK (start_date >= '2026-01-01'),
    end_date DATE NOT NULL CHECK (end_date >= '2026-01-01')
);

CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) UNIQUE NOT NULL,
    captain_id INT NOT NULL REFERENCES players(player_id),
    created_date DATE NOT NULL DEFAULT CURRENT_DATE CHECK (created_date >= '2026-01-01'),
    ranking INT NOT NULL DEFAULT 0 CHECK (ranking >= 0)
);


CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    tournament_id INT NOT NULL REFERENCES tournaments(tournament_id),
    team1_id INT NOT NULL REFERENCES teams(team_id),
    team2_id INT NOT NULL REFERENCES teams(team_id),
    match_date DATE NOT NULL CHECK (match_date >= '2026-01-01'),
    score VARCHAR(20),
    winner_team_id INT REFERENCES teams(team_id)
);
