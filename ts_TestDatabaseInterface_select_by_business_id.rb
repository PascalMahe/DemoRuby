require './TestSuite.rb'
require './validation-core.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class TestDatabaseInterfaceSelect < TestSuite
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi_select_tech = $globalState.dbi_select_by_tech_id
		@dbi_select = $globalState.dbi_select_by_business_id
		@dbi_insert = $globalState.dbi_insert
		if(@ref_list_hash == nil) then 
			@ref_list_hash = @dbi_select_tech.load_all_refs
		end
		@logger.level = SimpleHtmlLogger::INFO
	end
	
	def teardown
		
	end
	
	##################
	#      Tests     #
	##################
	def test_load_breeder_id
		@logger.imp("Testing selection of Breeder ID")
		begin
			test_name = "Test Breeder 2 Name"
			breeder = Breeder::new(name: test_name)
			selected_id = @dbi_select.load_breeder_id(breeder)
			
			# Checking value
			assert_equal(selected_id, -2, "Wrong tech ID retrieved " +
									"while testing selection of Breeder ID")
			
			@logger.ok("Tests selection of Breeder ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_horse_id
		@logger.imp("Testing selection of Horse ID")
		begin
			father = Horse::new(id: -5)
			mother = Horse::new(id: -6)
			test_name = "Test Horse 2 name"
			horse = Horse::new(	father: father, 
								mother: mother, 
								name: test_name)
			selected_id = @dbi_select.load_horse_id(horse)
			
			# Checking value
			assert_equal(selected_id, -4, "Wrong tech ID retrieved " +
								 "while testing selection of Horse ID")
			
			@logger.ok("Tests selection of Horse ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_job_id
		@logger.imp("Testing selection of Job ID")
		begin
			# Value in sql.test.yml
			test_start_time = 
				DateTime.new(2016, 02, 18, 07, 55, 20.050, '+00')
			
			@logger.debug("test_load_job_id - test_start_time = " + 
				test_start_time.
					strftime(@config[:gen][:database_date_time_format]))
			
			job = Job::new(start_time: test_start_time)
			
			@logger.debug("test_load_job_id - job = " + job.to_s)
			selected_id = @dbi_select.load_job_id(job)
			
			# Checking value
			assert_equal(selected_id, -2, "Wrong tech ID retrieved " +
								 "while testing selection of Job ID")
			
			# Value created on the fly
			test_start_time = DateTime.now
			
			inserted_job = Job::new(start_time: test_start_time)
			
			@logger.debug("test_load_job_id - test_start_time = " + 
				test_start_time.
					strftime(@config[:gen][:database_date_time_format]))
			@dbi_insert.insert_job(inserted_job)
			
			@logger.debug("test_load_job_id - inserted_job = " + 
				inserted_job.to_s)
			
			loaded_job = Job::new(start_time: test_start_time)
			selected_id = @dbi_select.load_job_id(job)
			
			# Checking value
			validate_job(inserted_job, loaded_job, 
				"testing selection of Job ID (by value created on the fly)")
			
			@logger.ok("Tests selection of Job ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_jockey_id
		@logger.imp("Testing selection of Jockey ID")
		begin
			test_name = "Test Jockey 2 name"
			jockey = Jockey::new(name: test_name)
			selected_id = @dbi_select.load_jockey_id(jockey)
			
			# Checking value
			assert_equal(selected_id, -2, "Wrong tech ID retrieved " +
								 "while testing selection of Jockey ID")
			
			@logger.ok("Tests selection of Jockey ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_meeting_id
		@logger.imp("Testing selection of Meeting ID")
		begin
			test_date = Date::new(2016, 02, 17)
			test_racetrack = "Test Meeting 2 racetrack"
			meeting = Meeting::new(date: test_date, racetrack: test_racetrack)
			selected_id = @dbi_select.load_meeting_id(meeting)
			
			# Checking value
			assert_equal(selected_id, -2, "Wrong tech ID retrieved " +
								 "while testing selection of Meeting ID")
			
			@logger.ok("Tests selection of Meeting ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_owner_id
		@logger.imp("Testing selection of Owner ID")
		begin
			test_name = "Test Owner 2 name"
			owner = Owner::new(name: test_name)
			selected_id = @dbi_select.load_owner_id(owner)
			
			# Checking value
			assert_equal(selected_id, -2, "Wrong tech ID retrieved " +
								 "while testing selection of Owner ID")
			
			@logger.ok("Tests selection of Owner ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_race_id
		@logger.imp("Testing selection of Race ID")
		begin
			meeting_id = -2
			meeting = Meeting::new(id: meeting_id)
			number = -3
			race = Race::new(meeting: meeting, number: number)
			selected_id = @dbi_select.load_race_id(race)
			
			# Checking value
			assert_equal(selected_id, -3, "Wrong tech ID retrieved " +
								 "while testing selection of Race ID")
			
			@logger.ok("Tests selection of Race ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_runner_id
		@logger.imp("Testing selection of Runner ID")
		begin
			race_id = -3
			race = Race::new(id: race_id)
			number = -3
			runner = Runner::new(number: number, race: race)
			selected_id = @dbi_select.load_runner_id(runner)
			
			# Checking value
			assert_equal(selected_id, -3, "Wrong tech ID retrieved " +
								 "while testing selection of Runner ID")
			
			@logger.ok("Tests selection of Runner ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_trainer_id
		@logger.imp("Testing selection of Trainer ID")
		begin
			test_name = "Test Trainer 2 name"
			trainer = Trainer::new(name: test_name)
			selected_id = @dbi_select.load_trainer_id(trainer)
			
			# Checking value
			assert_equal(selected_id, -2, "Wrong tech ID retrieved " +
								 "while testing selection of Trainer ID")
			
			@logger.ok("Tests selection of Trainer ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_load_weather_id
		@logger.imp("Testing selection of Weather ID")
		begin
			test_insolation = "Test Weather 2 insolation"
			test_temperature = -2
			test_wind_direction = @ref_list_hash[:ref_direction_list]["Test Direction"]
			test_wind_speed = -2
			weather = Weather::new(insolation: test_insolation,
									temperature: test_temperature,
									wind_direction: test_wind_direction,
									wind_speed: test_wind_speed
			)
			selected_id = @dbi_select.load_weather_id(weather)
			
			# Checking value
			assert_equal(selected_id, -2, "Wrong tech ID retrieved " +
								 "while testing selection of Weather ID")
			
			@logger.ok("Tests selection of Weather ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
end