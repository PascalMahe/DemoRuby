require 'test/unit'
require './common.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
 
class TestDatabaseInterface < Test::Unit::TestCase

	def setup
    	if @config == nil then
			@config = load_config()
			@dbi = DatabaseInterface::new(@config, true)
			@logger = @config[:logger]
			@ref_list_hash = @dbi.load_all_refs
			@logger.imp("TEST SUITE : TestDatabaseInterface")
		end
    end
	
	def test_insert_breeder
		@logger.info("Testing insertion of Breeder")
		breeder = Breeder::new
		breeder.name = "LYNN LODGE STUD"
		
		breeder.id = @dbi.insert_breeder(breeder)
		
		inserted_breeder = @dbi.load_breeder_by_id(breeder.id)
		assert_equal(breeder.name, inserted_breeder.name)
	end
	
	def test_insert_forecast
		@logger.info("Testing insertion of Forecast")
		forecast = Forecast::new
		forecast.race = @dbi.load_race_by_id(1)
		forecast.origin = @dbi.load_origin_by_id(1)
		forecast.expected_result = "1 - 2 - 7 - 3 - 4"
		forecast.result_match_rate = 1045
		forecast.normalised_result_match_rate = 0.15
		
		forecast.id = @dbi.insert_forecast(forecast)
		
		inserted_forecast = @dbi.load_forecast_by_id(forecast.id)
		assert_equal(forecast.race, inserted_forecast.race)
		assert_equal(forecast.origin, inserted_forecast.origin)
		assert_equal(forecast.expected_result, inserted_forecast.expected_result)
		assert_equal(forecast.result_match_rate, inserted_forecast.result_match_rate)
		assert_equal(forecast.normalised_result_match_rate, inserted_forecast.normalised_result_match_rate)
	end
	
	def test_insert_horse
		@logger.info("Testing insertion of Horse")
		horse = Horse::new
		horse.sex = @ref_list_hash[:ref_sex_list]["M", @logger]
		horse.breed = @ref_list_hash[:ref_breed_list]["Pur-sang", @logger]
		horse.coat = @ref_list_hash[:ref_coat_list]["gris", @logger]
		horse.name = "SILVER TREASURE"
		horse.id = @dbi.insert_horse(horse)
		
		inserted_horse = @dbi.load_horse_by_id(horse.id)
		assert_equal(horse.sex, inserted_horse.sex)
		assert_equal(horse.breed, inserted_horse.breed)
		assert_equal(horse.coat, inserted_horse.coat)
		assert_equal(horse.name, inserted_horse.name)
	end
	
	def test_insert_job
		@logger.info("Testing insertion of Job")
		job = Job::new
		job.start_time = Time.now.strftime(@config[:gen][:default_date_time_format])
		job.loading_end_time = Time.now.strftime(@config[:gen][:default_date_time_format])
		job.crawling_end_time = Time.now.strftime(@config[:gen][:default_date_time_format])
		job.computing_end_time = Time.now.strftime(@config[:gen][:default_date_time_format])

		@dbi.insert_job(job)

		selected_job = @dbi.load_job_by_id(job.id)

		assert_equal(job.start_time, selected_job.start_time)
		assert_equal(job.loading_end_time, selected_job.loading_end_time)
		assert_equal(job.crawling_end_time, selected_job.crawling_end_time)
		assert_equal(job.computing_end_time, selected_job.computing_end_time)
	end
	
	def test_insert_jockey
		@logger.info("Testing insertion of Jockey")
		jockey = Jockey::new
		jockey.jacket = "/turf/casaques/31102013/petites-casaques-course/1/4.png*-60px"
		jockey.name = "c.soumillon"
		jockey.id = @dbi.insert_jockey(jockey)
		
		inserted_jockey = @dbi.load_jockey_by_id(jockey.id)
		assert_equal(jockey.name, inserted_jockey.name)
		assert_equal(jockey.jacket, inserted_jockey.jacket)
	end

	def test_insert_meeting
		@logger.info("Testing insertion of RMeeting")
		meeting = Meeting::new
		meeting.job = @dbi.load_job_by_id(1)
		meeting.track_condition = @ref_list_hash[:ref_track_condition_list]["Terrain bon", @logger]
		meeting.date = Time.now
		meeting.racetrack = "Auteuil"
		meeting.number = 11
		meeting.url = "http://www.test.com"

		@dbi.insert_meeting(meeting)

		selected_meeting = @dbi.load_meeting_by_id(meeting.id)

		assert_equal(meeting.job, selected_meeting.job)
		assert_equal(meeting.track_condition, selected_meeting.track_condition)
		assert_equal(
			meeting.date.strftime(@config[:gen][:default_date_format]), 
			selected_meeting.date.strftime(@config[:gen][:default_date_format])
		)
		assert_equal(meeting.racetrack, selected_meeting.racetrack)
		assert_equal(meeting.number, selected_meeting.number)
		assert_equal(meeting.url, selected_meeting.url)
	end
	
	def test_insert_origin
		@logger.info("Testing insertion of Origin")
		origin = Origin::new
		origin.name = "Single Rating"
		origin.column_order = "single_rating"
		origin.url = "http://www.pmu.fr/turf/index.html#/turf/30102013/reunion-1-PARIS_VINCENNES/pronostics.html"
		
		origin.id = @dbi.insert_origin(origin)
		
		insert_origin = @dbi.load_origin_by_id(origin.id)
		assert_equal(origin.name, insert_origin.name)
		assert_equal(origin.column_order, insert_origin.column_order)
		assert_equal(origin.url, insert_origin.url)
	end
	
	def test_insert_owner
		@logger.info("Testing insertion of Owner")
		owner = Owner::new
		owner.name = "MLLE A.WEAVER"

		owner.id = @dbi.insert_owner(owner)
		
		insert_owner = @dbi.load_owner_by_id(owner.id)
		assert_equal(owner.name, insert_owner.name)
	end
	
	def test_insert_race
		@logger.info("Testing insertion of Race")
		race = Race::new
		race.meeting = @dbi.load_meeting_by_id(1)
		race.race_type = @ref_list_hash[:ref_race_type_list]["Haies course à conditions", @logger]
		race.time = Time.now.strftime(@config[:gen][:default_time_format])
		race.number = 2
		race.country = "BEL"
		race.distance = 2850
		race.detailed_conditions = "PRIX SECF Course 02 Départ à l'Autostart 7.200 - Attelé. - 2850 mètres. 3.000, 1.500, 720, 480, 300. et 1.200 au fonds d'élevage. Pour 5 à 6 ans n'ayant pas gagné 28.000."
		race.bets = 143010
		race.url = "http://www.pmu.fr/turf/15102013/reunion-4-MONS__28GHLIN_29/index.html#/turf/15102013/reunion-4-MONS__28GHLIN_29/course-2-SECF.html"
		race.value = 7200

		@dbi.insert_race_without_result(race)

		selected_race = @dbi.load_race_by_id(race.id)

		assert_equal(race.meeting, selected_race.meeting)
		assert_equal(race.race_type, selected_race.race_type)
		assert_equal(race.time, selected_race.time)
		assert_equal(race.number, selected_race.number)
		assert_equal(race.country, selected_race.country)
		assert_equal(race.distance, selected_race.distance)
		assert_equal(race.detailed_conditions, selected_race.detailed_conditions)
		assert_equal(race.bets, selected_race.bets)
		assert_equal(race.value, selected_race.value)
		assert_equal(race.url, selected_race.url)		
	end
	
	def test_insert_ref_objects
		@logger.info("Testing insertion of RefObjects")
		@dbi.insert_ref_direction(RefDirection::new("", "test1"))
		@dbi.insert_ref_track_condition(RefTrackCondition::new("", "test1"))
		@dbi.insert_ref_race_type(RefRaceType::new("", "test1"))
		@dbi.insert_ref_column(RefColumn::new("", "test1"))
		@dbi.insert_ref_sex(RefSex::new("", "test1"))
		@dbi.insert_ref_breed(RefBreed::new("", "test1"))
		@dbi.insert_ref_coat(RefCoat::new("", "test1"))
		@dbi.insert_ref_blinder(RefBlinder::new("", "test1"))
		@dbi.insert_ref_shoes(RefShoes::new("", "test1"))
	end
	
	def test_insert_runner
		@logger.info("Testing insertion of Runner")
		runner = Runner::new
		runner.race = @dbi.load_race_by_id(1)
		runner.horse = @dbi.load_horse_by_id(1)
		runner.jockey = @dbi.load_jockey_by_id(1)
		runner.trainer = @dbi.load_trainer_by_id(1)
		runner.owner = @dbi.load_owner_by_id(1)
		runner.breeder = @dbi.load_breeder_by_id(1)
		runner.blinder = @ref_list_hash[:ref_blinder_list]["http://ressources0.pmu.fr/turf/cb3590072752/img/design/oeillere.gif", @logger]
		runner.shoes = @ref_list_hash[:ref_shoes_list]["http://ressources0.pmu.fr/turf/cb603952032/img/pictos_courses/defer/Da.gif", @logger]
		runner.number = 1
		runner.draw = 5
		runner.single_rating = 9.7
		runner.non_runner = 0
		runner.races_run = 10
		runner.victories = 6
		runner.places = 2
		runner.earnings_career = 355958
		runner.earnings_current_year = 55600
		runner.earnings_last_year = 231858
		runner.earnings_victory = 340358
		runner.description = "Décevant dans la course de référence, il serait dangereux de l'écarter totalement. Une place est à sa portée. Par Gianni Caggiula, Equidia."
		runner.distance = 7200
		runner.load = 58.5
		runner.history = "2p 5p 2p 0p 1p 2p 6p 0p 3p 7p "
		runner.url = "/turf/01112013/reunion-1-SAINT_CLOUD/course-8-DU_CHAROLAIS/partant-6-ROSEAL_DES_BOIS/index.html"
		
		@dbi.insert_runner(runner)

		selected_runner = @dbi.load_runner_by_id(runner.id)

		assert_equal(runner.race, selected_runner.race)
		assert_equal(runner.horse, selected_runner.horse)
		assert_equal(runner.jockey, selected_runner.jockey)
		assert_equal(runner.trainer, selected_runner.trainer)
		assert_equal(runner.owner, selected_runner.owner)
		assert_equal(runner.breeder, selected_runner.breeder)
		assert_equal(runner.blinder, selected_runner.blinder)
		assert_equal(runner.shoes, selected_runner.shoes)
		assert_equal(runner.number, selected_runner.number)
		assert_equal(runner.draw, selected_runner.draw)
		assert_equal(runner.single_rating, selected_runner.single_rating)
		assert_equal(runner.non_runner, selected_runner.non_runner)
		assert_equal(runner.races_run, selected_runner.races_run)
		assert_equal(runner.victories, selected_runner.victories)
		assert_equal(runner.places, selected_runner.places)
		assert_equal(runner.earnings_career, selected_runner.earnings_career)
		assert_equal(runner.earnings_current_year, selected_runner.earnings_current_year)
		assert_equal(runner.earnings_last_year, selected_runner.earnings_last_year)
		assert_equal(runner.earnings_victory, selected_runner.earnings_victory)
		assert_equal(runner.description, selected_runner.description)
		assert_equal(runner.distance, selected_runner.distance)
		assert_equal(runner.load, selected_runner.load)
		assert_equal(runner.history, selected_runner.history)
		assert_equal(runner.url, selected_runner.url)
	end
	
	def test_insert_trainer
		@logger.info("Testing insertion of Trainer")
		trainer = Trainer::new
		trainer.name = "R.CHOTARD"

		@dbi.insert_trainer(trainer)

		selected_trainer = @dbi.load_trainer_by_id(trainer.id)

		assert_equal(trainer.name, selected_trainer.name)
	end
	
	def test_insert_weather
		@logger.info("Testing insertion of Weather")
		weather = Weather::new
		weather.wind_direction = @ref_list_hash[:ref_direction_list]["S"]
		weather.temperature = 19
		weather.wind_speed = 11
		weather.insolation = "P6.png"

		@dbi.insert_weather(weather)

		selected_weather = @dbi.load_weather_by_id(weather.id)

		assert_equal(weather.wind_direction, selected_weather.wind_direction)
		assert_equal(weather.temperature, selected_weather.temperature)
		assert_equal(weather.wind_speed, selected_weather.wind_speed)
		assert_equal(weather.insolation, selected_weather.insolation)
	end
	
	def test_insert_weight
		@logger.info("Testing insertion of Weight")
		weight = Weight::new
		weight.forecast = @dbi.load_forecast_by_id(1)
		weight.name = "flLfD"
		weight.value = 11

		@dbi.insert_weight(weight)

		selected_weight = @dbi.load_weight_by_id(weight.id)

		assert_equal(weight.forecast, selected_weight.forecast)
		assert_equal(weight.name, selected_weight.name)
		assert_equal(weight.value, selected_weight.value)
	end

end