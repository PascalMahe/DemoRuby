-- REFERENCE TABLES
CREATE TABLE IF NOT EXISTS RefDirection(
	id INTEGER PRIMARY KEY,
	text TEXT
);

CREATE TABLE IF NOT EXISTS RefTrackCondition(
	id INTEGER PRIMARY KEY,
	text TEXT
);

CREATE TABLE IF NOT EXISTS RefRaceType(
	id INTEGER PRIMARY KEY,
	text TEXT
);

CREATE TABLE IF NOT EXISTS RefColumn(
	id INTEGER PRIMARY KEY,
	text TEXT
);

CREATE TABLE IF NOT EXISTS RefSex(
	id INTEGER PRIMARY KEY,
	text TEXT
);

CREATE TABLE IF NOT EXISTS RefBreed(
	id INTEGER PRIMARY KEY,
	text TEXT
);

CREATE TABLE IF NOT EXISTS RefCoat(
	id INTEGER PRIMARY KEY,
	text TEXT
);

CREATE TABLE IF NOT EXISTS RefBinder(
	id INTEGER PRIMARY KEY,
	text TEXT
);

CREATE TABLE IF NOT EXISTS RefShoes(
	id INTEGER PRIMARY KEY,
	text TEXT
);

-- BUSINESS TABLES 
CREATE TABLE IF NOT EXISTS Weather(
	id_weather INTEGER PRIMARY KEY,
	id_wind_direction INTEGER, -- FK to RefDirection
	temperature INTEGER, -- in °C
	wind_speed INTEGER,
	insolation TEXT,
	FOREIGN KEY(id_wind_direction) REFERENCES RefDirection(id)
);

CREATE TABLE IF NOT EXISTS Meeting(
	id_meeting INTEGER PRIMARY KEY,
	id_track_condition INTEGER, -- FK to RefTrackCondition
	date DATE,
	racetrack TEXT,
	number INTEGER, 
	url TEXT,
	FOREIGN KEY(id_track_condition) REFERENCES RefTrackCondition(id)
);

CREATE TABLE IF NOT EXISTS Race(
	id_race INTEGER PRIMARY KEY
	id_meeting INTEGER, -- FK to Meeting
	id_racetype INTEGER, -- FK to RefRaceType
	time TEXT,
	number INTEGER,
	country TEXT,
	result TEXT,
	distance INTEGER, -- en meters
	detailed_conditions TEXT,
	bets INTEGER, -- in €
	name TEXT,
	url TEXT,
	value INTEGER, -- in €
	FOREIGN KEY(id_racetype) REFERENCES RefRaceType(id),
	FOREIGN KEY(id_meeting) REFERENCES Meeting(id_meeting)
);

CREATE TABLE IF NOT EXISTS Forecast(
	id_forecast INTEGER PRIMARY KEY,
	id_race INTEGER, -- FK to Race
	id_origin INTEGER, -- FK to Origin
	expected_result TEXT,
	result_match_rate REAL, -- ratio
	normalised_result_match_rate REAL, -- percent
	origin_score REAL
	FOREIGN KEY(id_race) REFERENCES Race(id_race),
	FOREIGN KEY(id_origin) REFERENCES Origin(id_origin)
);

CREATE TABLE IF NOT EXISTS Origin(
	id_origin INTEGER PRIMARY KEY,
	name TEXT,
	order TEXT,
	url TEXT
);

CREATE TABLE IF NOT EXISTS Jockey(
	id_jockey INTEGER PRIMARY KEY,
	name TEXT,
	jacket TEXT
);

CREATE TABLE IF NOT EXISTS Trainer(
	id_trainer INTEGER PRIMARY KEY,
	name TEXT
);

CREATE TABLE IF NOT EXISTS Owner(
	id_owner INTEGER PRIMARY KEY,
	name TEXT
);

CREATE TABLE IF NOT EXISTS Breeder(
	id_breeder INTEGER PRIMARY KEY,
	name TEXT
);

CREATE TABLE IF NOT EXISTS Horse(
	id_horse INTEGER PRIMARY KEY,
	id_sex INTEGER, -- FK to RefSex
	id_breed INTEGER, -- FK to RefBreed
	id_coat INTEGER, -- FK to RefCoat
	name TEXT,
	FOREIGN KEY(id_sex) REFERENCES RefSex(id),
	FOREIGN KEY(id_breed) REFERENCES RefBreed(id),
	FOREIGN KEY(id_coat) REFERENCES RefCoat(id)
);

CREATE TABLE IF NOT EXISTS Horse(
	id_runner INTEGER PRIMARY KEY,
	id_race INTEGER, -- FK to Race
	id_horse INTEGER, -- FK to Horse
	id_jockey INTEGER, -- FK to Jockey
	id_trainer INTEGER, -- FK to Trainer
	id_owner INTEGER, -- FK to Owner
	id_breeder INTEGER, -- FK to Breeder
	id_blinder INTEGER, -- FK to RefBlinder
	id_shoes INTEGER, -- FK to RefShoes
	number INTEGER,
	draw INTEGER,
	single_rating REAL,
	final_place INTEGER,
	non_runner INTEGER, -- boolean
	races_run INTEGER,
	victories INTEGER,
	places INTEGER,
	earnings_career INTEGER, -- in €
	earnings_current_year INTEGER, -- in €
	earnings_last_year INTEGER, -- in €
	earnings_victory INTEGER, -- in €
	description TEXT,
	distance INTEGER,
	load REAL,
	history TEXT,
	url TEXT,
	score_horse REAL,
	score_jockey REAL,
	score_owner REAL,
	score_trainer REAL,
	score_breeder REAL,
	FOREIGN KEY(id_race) REFERENCES Race(id),
	FOREIGN KEY(id_horse) REFERENCES Horse(id),
	FOREIGN KEY(id_jockey) REFERENCES Jockey(id),
	FOREIGN KEY(id_trainer) REFERENCES Trainer(id),
	FOREIGN KEY(id_owner) REFERENCES Owner(id),
	FOREIGN KEY(id_breeder) REFERENCES Breeder(id),
	FOREIGN KEY(id_blinder) REFERENCES RefBlinder(id),
	FOREIGN KEY(id_shoes) REFERENCES RefShoes(id)
);