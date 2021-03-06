CREATE TABLE IF NOT EXISTS RefBlinder(
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
CREATE TABLE IF NOT EXISTS RefColumn(
	id INTEGER PRIMARY KEY,
	text TEXT
);
CREATE TABLE IF NOT EXISTS RefDirection(
	id INTEGER PRIMARY KEY,
	text TEXT
);
CREATE TABLE IF NOT EXISTS RefRaceType(
	id INTEGER PRIMARY KEY,
	text TEXT
);
CREATE TABLE IF NOT EXISTS RefRope(
	id INTEGER PRIMARY KEY,
	text TEXT
);
CREATE TABLE IF NOT EXISTS RefSex(
	id INTEGER PRIMARY KEY,
	text TEXT
);
CREATE TABLE IF NOT EXISTS RefSexRule(
	id INTEGER PRIMARY KEY,
	text TEXT
);
CREATE TABLE IF NOT EXISTS RefShoes(
	id INTEGER PRIMARY KEY,
	text TEXT
);
CREATE TABLE IF NOT EXISTS RefTrackCondition(
	id INTEGER PRIMARY KEY,
	text TEXT
);
CREATE TABLE IF NOT EXISTS Breeder(
	id_breeder INTEGER PRIMARY KEY,
	name TEXT
);
CREATE TABLE IF NOT EXISTS Forecast(
	id_forecast INTEGER PRIMARY KEY,
	id_race INTEGER, /* FK to Race */
	id_origin INTEGER, /* FK to Origin */
	expected_result TEXT,
	result_match_rate REAL, /* ratio */
	normalised_result_match_rate REAL, /* percent */
	FOREIGN KEY(id_race) REFERENCES Race(id_race),
	FOREIGN KEY(id_origin) REFERENCES Origin(id_origin)
);
CREATE TABLE IF NOT EXISTS Horse(
	id_horse INTEGER PRIMARY KEY,
	id_breed INTEGER, /* FK to RefBreed */
	id_coat INTEGER, /* FK to RefCoat */
	id_father INTEGER, /* FK to Horse */
	id_mother INTEGER, /* FK to Horse */
	id_sex INTEGER, /* FK to RefSex */
	name TEXT,
	FOREIGN KEY(id_breed) REFERENCES RefBreed(id),
	FOREIGN KEY(id_coat) REFERENCES RefCoat(id),
	FOREIGN KEY(id_father) REFERENCES Horse(id_horse),
	FOREIGN KEY(id_mother) REFERENCES Horse(id_horse),
	FOREIGN KEY(id_sex) REFERENCES RefSex(id)
);
CREATE TABLE IF NOT EXISTS Job(
	id_job INTEGER PRIMARY KEY,
	start_time DATETIME,
	loading_end_time DATETIME,
	crawling_end_time DATETIME,
	computing_end_time DATETIME
);
CREATE TABLE IF NOT EXISTS Jockey(
	id_jockey INTEGER PRIMARY KEY,
	name TEXT,
	jacket TEXT
);
CREATE TABLE IF NOT EXISTS Meeting(
	id_meeting INTEGER PRIMARY KEY,
	id_track_condition INTEGER, /* FK to RefTrackCondition */
	id_job INTEGER, /* FK to Job */
	id_weather INTEGER, /* FK to Weather */
	country TEXT,
	date DATE,
	racetrack TEXT,
	number INTEGER,
	url TEXT,
	FOREIGN KEY(id_track_condition) REFERENCES RefTrackCondition(id)
	FOREIGN KEY(id_job) REFERENCES Job(id_job)
	FOREIGN KEY(id_weather) REFERENCES Weather(id_weather)
);
CREATE TABLE IF NOT EXISTS Origin(
	id_origin INTEGER PRIMARY KEY,
	name TEXT,
	column_order TEXT,
	url TEXT
);
CREATE TABLE IF NOT EXISTS Owner(
	id_owner INTEGER PRIMARY KEY,
	name TEXT
);
CREATE TABLE IF NOT EXISTS Race(
	id_race INTEGER PRIMARY KEY,
	id_meeting INTEGER, /* FK to Meeting */
	id_race_type INTEGER, /* FK to RefRaceType */
	id_rope INTEGER, /* FK to RefRope */
	id_sex_rule INTEGER, /* FK to RefSexRule */
	bets INTEGER, /* in euros */
	detailed_conditions TEXT,
	distance INTEGER, /* in meters */
	general_conditions TEXT,
	number INTEGER,
	name TEXT,
	result TEXT,
	result_insertion_time DATETIME,
	time TEXT,
	url TEXT,
	value INTEGER, /* in euros */
	FOREIGN KEY(id_race_type) REFERENCES RefRaceType(id),
	FOREIGN KEY(id_rope) REFERENCES RefRope(id),
	FOREIGN KEY(id_sex_rule) REFERENCES RefSexRule(id),
	FOREIGN KEY(id_meeting) REFERENCES Meeting(id_meeting)
);
CREATE TABLE IF NOT EXISTS Runner(
	id_runner INTEGER PRIMARY KEY,
	id_blinder INTEGER, /* FK to RefBlinder */
	id_breeder INTEGER, /* FK to Breeder */
	id_horse INTEGER, /* FK to Horse */
	id_jockey INTEGER, /* FK to Jockey */
	id_owner INTEGER, /* FK to Owner */
	id_race INTEGER, /* FK to Race */
	id_shoes INTEGER, /* FK to RefShoes */
	id_trainer INTEGER, /* FK to Trainer */
	age INTEGER,
	commentary TEXT,
	description TEXT,
	disqualified INTEGER, /* boolean */
	distance INTEGER,
	draw INTEGER,
	earnings_career INTEGER, /* in euros */
	earnings_current_year INTEGER, /* in euros */
	earnings_last_year INTEGER, /* in euros */
	earnings_victory INTEGER, /* in euros */
	final_place INTEGER,
	history TEXT,
	is_favorite INTEGER, /* boolean */
	is_non_runner INTEGER, /* boolean */
	is_pregnant INTEGER, /* boolean */
	is_substitute INTEGER, /* boolean */
	load_handicap REAL,
	load_ride REAL,
	number INTEGER,
	places INTEGER,
	races_run INTEGER,
	single_rating_after_race REAL,
	single_rating_before_race REAL,
	time TEXT,
	url TEXT,
	victories INTEGER,
	FOREIGN KEY(id_blinder) REFERENCES RefBlinder(id),
	FOREIGN KEY(id_breeder) REFERENCES Breeder(id),
	FOREIGN KEY(id_horse) REFERENCES Horse(id),
	FOREIGN KEY(id_jockey) REFERENCES Jockey(id),
	FOREIGN KEY(id_owner) REFERENCES Owner(id),
	FOREIGN KEY(id_race) REFERENCES Race(id),
	FOREIGN KEY(id_shoes) REFERENCES RefShoes(id),
	FOREIGN KEY(id_trainer) REFERENCES Trainer(id)
);
CREATE TABLE IF NOT EXISTS Trainer(
	id_trainer INTEGER PRIMARY KEY,
	name TEXT
);
CREATE TABLE IF NOT EXISTS Weather(
	id_weather INTEGER PRIMARY KEY,
	id_wind_direction INTEGER, /* FK to RefDirection */
	temperature INTEGER, /* in degrees C */
	wind_speed INTEGER,
	insolation TEXT,
	FOREIGN KEY(id_wind_direction) REFERENCES RefDirection(id)
);
CREATE TABLE IF NOT EXISTS Weight(
	id_weight INTEGER PRIMARY KEY,
	id_forecast INTEGER, /* FK to Forecast */
	name TEXT,
	value REAL,
	FOREIGN KEY(id_forecast) REFERENCES Forecast(id_forecast)
);
