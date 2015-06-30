-- DROP
-- reference tables
DROP TABLE IF EXISTS RefBlinder;
DROP TABLE IF EXISTS RefBreed;
DROP TABLE IF EXISTS RefCoat;
DROP TABLE IF EXISTS RefColumn;
DROP TABLE IF EXISTS RefDirection;
DROP TABLE IF EXISTS RefRaceType;
DROP TABLE IF EXISTS RefShoes;
DROP TABLE IF EXISTS RefSex;
DROP TABLE IF EXISTS RefTrackCondition;
 
-- business tables 
DROP TABLE IF EXISTS Breeder;
DROP TABLE IF EXISTS Forecast;
DROP TABLE IF EXISTS Horse;
DROP TABLE IF EXISTS Job;
DROP TABLE IF EXISTS Jockey;
DROP TABLE IF EXISTS Meeting;
DROP TABLE IF EXISTS Origin;
DROP TABLE IF EXISTS Owner;
DROP TABLE IF EXISTS Race;
DROP TABLE IF EXISTS Runner;
DROP TABLE IF EXISTS Trainer;
DROP TABLE IF EXISTS Weather;
DROP TABLE IF EXISTS Weight;
 
-- CLEAN
-- reference tables
DELETE FROM RefBlinder;
DELETE FROM RefBreed;
DELETE FROM RefCoat;
DELETE FROM RefColumn;
DELETE FROM RefDirection;
DELETE FROM RefRaceType;
DELETE FROM RefShoes;
DELETE FROM RefSex;
DELETE FROM RefTrackCondition;
 
-- business tables 
DELETE FROM Breeder;
DELETE FROM Forecast;
DELETE FROM Horse;
DELETE FROM Job;
DELETE FROM Jockey;
DELETE FROM Meeting;
DELETE FROM Origin;
DELETE FROM Owner;
DELETE FROM Race;
DELETE FROM Runner;
DELETE FROM Trainer;
DELETE FROM Weather;
DELETE FROM Weight;