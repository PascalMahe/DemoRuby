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
	
    def teardown
    	# puts 'runs after each test'
    end	


	def test_insert_ref_objects
		@logger.info("Testing loading of RefObjects")
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
	
	def test_insert_job
		@logger.info("Testing Job")
		job = Job::new
		job.start_time = start_time.strftime(config[:gen][:default_date_time_format])
		job.loading_end_time = Time.now.strftime(config[:gen][:default_date_time_format])
		job.crawling_end_time = Time.now.strftime(config[:gen][:default_date_time_format])
		job.computing_end_time = Time.now.strftime(config[:gen][:default_date_time_format])

		@dbi.insert_job(job)

		selected_job = @dbi.load_job_by_id(job.id)
		@logger.debug(selected_job.to_s)
		
		assert_equal(job.start_time, selected_job.start_time)
		assert_equal(job.loading_end_time, selected_job.loading_end_time)
		assert_equal(job.crawling_end_time, selected_job.crawling_end_time)
		assert_equal(job.computing_end_time, selected_job.computing_end_time)
	end
	
	def test_insert_weather
		@logger.info("Testing Weather")
		weather = Weather::new
		weather.wind_direction = @ref_list_hash[:ref_direction_list]["S"]
		weather.temperature = 19
		weather.wind_speed = 11
		weather.insolation = "P6.png"

		@dbi.insert_weather(weather)

		selected_weather = @dbi.load_weather_by_id(weather.id)
		@logger.debug(selected_weather.to_s)
		
		assert_equal(weather.wind_direction, selected_weather.wind_direction)
		assert_equal(weather.temperature, selected_weather.temperature)
		assert_equal(weather.wind_speed, selected_weather.wind_speed)
		assert_equal(weather.insolation, selected_weather.insolation)
	end
	
	def test_insert_meeting
		@logger.info("Testing Meeting")
		meeting = Meeting::new
		meeting.job = @dbi.load_job_by_id(1)
		meeting.track_condition = @ref_list_hash[:ref_trackcondition_list]["Terrain bon", logger]
		meeting.date = Time.now.strftime(config[:gen][:default_date_format])
		meeting.racetrack = "Auteuil"
		meeting.number = 11
		meeting.url = "http://www.test.com"

		@dbi.insert_meeting(meeting)

		selected_meeting = @dbi.load_meeting_by_id(meeting.id)
		@logger.debug(selected_meeting.to_s)
		
		assert_same(meeting.job, selected_meeting.job)
		assert_equal(meeting.wind_direction, selected_meeting.wind_direction)
		assert_equal(meeting.track_condition, selected_meeting.track_condition)
		assert_equal(meeting.date, selected_meeting.date)
		assert_equal(meeting.racetrack, selected_meeting.racetrack)
		assert_equal(meeting.number, selected_meeting.number)
		assert_equal(meeting.url, selected_meeting.url)
	end
	
	def test_insert_race
		@logger.info("Testing Race")
		race = Race::new
		race.meeting = @dbi.load_meeting_by_id(1)
		race.race_type = @ref_list_hash[:ref_race_type_list]["Haies course à conditions", logger]
		race.time = Time.now.strftime(config[:gen][:default_time_format])
		race.number = 2
		race.country = "BEL"
		race.distance = 2850
		race.detailed_conditions = "PRIX SECF Course 02 Départ à l'Autostart 7.200 - Attelé. - 2850 mètres. 3.000, 1.500, 720, 480, 300. et 1.200 au fonds d'élevage. Pour 5 à 6 ans n'ayant pas gagné 28.000."
		race.bets = 143010
		race.url = "http://www.pmu.fr/turf/15102013/reunion-4-MONS__28GHLIN_29/index.html#/turf/15102013/reunion-4-MONS__28GHLIN_29/course-2-SECF.html"
		race.value = 7200

		@dbi.insert_race_without_result(race)

		selected_race = @dbi.load_race_by_id(race.id)
		@logger.debug(selected_race.to_s)
		
		assert_same(race.meeting, selected_race.meeting)
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
end