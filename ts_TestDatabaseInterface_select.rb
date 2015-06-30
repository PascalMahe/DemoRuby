require './TestSuite.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class TestDatabaseInterfaceSelect < TestSuite
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi = $globalState.dbi
		if(@ref_list_hash == nil) then 
			@ref_list_hash = @dbi.load_all_refs
		end
	end
	
	##################
	#      Tests     #
	##################
	def test_select_breeder
		@logger.info("Testing selection of Breeder")
		begin
			test_id = -1
			selected_breeder = @dbi.load_breeder_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 				selected_breeder.id)
			assert_equal("Test Breeder 1 Name", selected_breeder.name)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_select_forecast
		@logger.info("Testing selection of Forecast")
		begin
			test_id = -1
			selected_forecast = @dbi.load_forecast_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 								selected_forecast.id)
			assert_equal("Test Forecast 1 Expected result", 	selected_forecast.expected_result)
			assert_equal(-1.1, 									selected_forecast.result_match_rate)
			assert_equal(-1.1, 									selected_forecast.normalised_result_match_rate)
			
			# Nested value : race
			assert_equal(-1, 						selected_forecast.race.id)
			assert_equal("Test Race 1 time", 		selected_forecast.race.time)
			assert_equal(-1, 						selected_forecast.race.number)
			assert_equal("Test Race 1 name", 		selected_forecast.race.name)
			assert_equal("Test Race 1 result", 		selected_forecast.race.result)
			default_time = Date.new(2015, 01, 01)
			
			assert_equal(
				default_time,
				selected_forecast.race.result_insertion_time
			)
			assert_equal(-1, selected_forecast.race.distance)
			assert_equal("Test Race 1 detailed conditions", selected_forecast.race.detailed_conditions)
			assert_equal(-1, selected_forecast.race.bets)
			assert_equal(-1, selected_forecast.race.value)
			assert_equal("Test Race 1 URL", selected_forecast.race.url)
						
			# Nested value (2nd level) : race_type
			assert_equal(-1,				selected_forecast.race.race_type.id)
			assert_equal("Test Race Type", 	selected_forecast.race.race_type.text)
			
			# Nested value (2nd level) : meeting
			assert_equal(-1, selected_forecast.race.meeting.id)
			assert_equal(
				default_time,
				selected_forecast.race.meeting.date
			)
			assert_equal("Test Meeting 1 country", 		selected_forecast.race.meeting.country)
			assert_equal("Test Meeting 1 racetrack", 	selected_forecast.race.meeting.racetrack)
			assert_equal(-1, selected_forecast.race.meeting.number)
			assert_equal(nil, selected_forecast.race.meeting.urls_of_races_array)
			
			# Nested value (3rd level) : track_condition
			assert_equal(-1, selected_forecast.race.meeting.track_condition.id)
			assert_equal("Test Track Condition", selected_forecast.race.meeting.track_condition.text)
			
			# Nested value (3rd level) : job
			assert_equal(-1, selected_forecast.race.meeting.job.id)

			expected_start_time = 			DateTime.new(2015, 01, 27, 17, 35, 0.250)
			assert_equal(
				expected_start_time, 
				selected_forecast.race.meeting.job.start_time
			)
			
			expected_loading_end_time = 	DateTime.new(2015, 01, 27, 18, 36, 1.500)
			assert_equal(
				expected_loading_end_time,
				selected_forecast.race.meeting.job.loading_end_time
			)
			
			expected_crawling_end_time = 	DateTime.new(2015, 01, 27, 19, 37, 2.750)
			assert_equal(
				expected_crawling_end_time, 
				selected_forecast.race.meeting.job.crawling_end_time
			)
			
			expected_computing_end_time = 	DateTime.new(2015, 01, 27, 20, 38, 3.999)
			assert_equal(
				expected_computing_end_time, 
				selected_forecast.race.meeting.job.computing_end_time
			)
			
			# Nested value (3rd level) : weather
			assert_equal(-1,							selected_forecast.race.meeting.weather.id)
			assert_equal(-1, 							selected_forecast.race.meeting.weather.temperature)
			assert_equal(-1,						 	selected_forecast.race.meeting.weather.wind_speed)
			assert_equal("Test Weather 1 insolation", 	selected_forecast.race.meeting.weather.insolation)
			
			# Nested value (4th level) : wind_direction
			assert_equal(-1, 				selected_forecast.race.meeting.weather.wind_direction.id)
			assert_equal("Test Direction", 	selected_forecast.race.meeting.weather.wind_direction.text)
			
						
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_horse
		@logger.info("Testing selection of Horse")
		begin
			test_id = -1
			selected_horse = @dbi.load_horse_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 				selected_horse.id)
			assert_equal("Test Horse 1 name", 	selected_horse.name)
	
			# Nested value : sex
			assert_equal(-1,			selected_horse.sex.id)
			assert_equal("Test Sex", 	selected_horse.sex.text)
			
			# Nested value : breed
			assert_equal(-1,			selected_horse.breed.id)
			assert_equal("Test Breed", 	selected_horse.breed.text)
			
			# Nested value : coat
			assert_equal(-1,			selected_horse.coat.id)
			assert_equal("Test Coat", 	selected_horse.coat.text)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_job
		@logger.info("Testing selection of Job")
		begin
			test_id = -1
			selected_job = @dbi.load_job_by_id(test_id)
			
			# Checking value
			assert_equal(-1, selected_job.id)

			expected_start_time = 			DateTime.new(2015, 01, 27, 17, 35, 0.250)
			assert_equal(
				expected_start_time, 
				selected_job.start_time
			)
			
			expected_loading_end_time = 	DateTime.new(2015, 01, 27, 18, 36, 1.500)
			assert_equal(
				expected_loading_end_time, 
				selected_job.loading_end_time
			)
			
			expected_crawling_end_time = 	DateTime.new(2015, 01, 27, 19, 37, 2.750)
			assert_equal(
				expected_crawling_end_time, 
				selected_job.crawling_end_time
			)
			
			expected_computing_end_time = 	DateTime.new(2015, 01, 27, 20, 38, 3.999)
			assert_equal(
				expected_computing_end_time, 
				selected_job.computing_end_time
			)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	
	def test_select_jockey
		@logger.info("Testing selection of Jockey")
		begin
			test_id = -1
			selected_jockey = @dbi.load_jockey_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 					selected_jockey.id)
			assert_equal("Test Jockey 1 name", 		selected_jockey.name)
			assert_equal("Test Jockey 1 jacket", 	selected_jockey.jacket)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end

	def test_select_meeting
		@logger.info("Testing selection of Meeting")
		begin
			test_id = -1
			selected_meeting = @dbi.load_meeting_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 						selected_meeting.id)
			assert_equal("Test Meeting 1 country", 		selected_meeting.country)
			assert_equal(Date.new(2015, 01, 01),		selected_meeting.date)
			assert_equal("Test Meeting 1 racetrack", 	selected_meeting.racetrack)
			assert_equal(-1, 							selected_meeting.number)
			assert_equal(nil, 							selected_meeting.urls_of_races_array)
			
			# Nested value : track_condition
			assert_equal(-1,							selected_meeting.track_condition.id)
			assert_equal("Test Track Condition", 		selected_meeting.track_condition.text)
			
			# Nested value : job
			assert_equal(-1, selected_meeting.job.id)

			expected_start_time = 			DateTime.new(2015, 01, 27, 17, 35, 0.250)
			assert_equal(
				expected_start_time, 
				selected_meeting.job.start_time
			)
			
			expected_loading_end_time = 	DateTime.new(2015, 01, 27, 18, 36, 1.500)
			assert_equal(
				expected_loading_end_time, 
				selected_meeting.job.loading_end_time
			)
			
			expected_crawling_end_time = 	DateTime.new(2015, 01, 27, 19, 37, 2.750)
			assert_equal(
				expected_crawling_end_time, 
				selected_meeting.job.crawling_end_time
			)
			
			expected_computing_end_time = 	DateTime.new(2015, 01, 27, 20, 38, 3.999)
			assert_equal(
				expected_computing_end_time, 
				selected_meeting.job.computing_end_time
			)
			
			# Nested value : weather
			assert_equal(-1,							selected_meeting.weather.id)
			assert_equal(-1, 							selected_meeting.weather.temperature)
			assert_equal(-1,						 	selected_meeting.weather.wind_speed)
			assert_equal("Test Weather 1 insolation", 	selected_meeting.weather.insolation)
			
			# Nested value (2nd level) : wind_direction
			assert_equal(-1, 				selected_meeting.weather.wind_direction.id)
			assert_equal("Test Direction", 	selected_meeting.weather.wind_direction.text)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_origin
		@logger.info("Testing selection of Origin")
		begin
			test_id = -1
			selected_origin = @dbi.load_origin_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 						selected_origin.id)
			assert_equal("Test Origin 1 name", 			selected_origin.name)
			assert_equal("Test Origin 1 column order", 	selected_origin.column_order)
			assert_equal("Test Origin 1 URL", 			selected_origin.url)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_owner
		@logger.info("Testing selection of Owner")
		begin
			test_id = -1
			selected_owner = @dbi.load_owner_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 				selected_owner.id)
			assert_equal("Test Owner 1 name", 	selected_owner.name)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_race
		@logger.info("Testing selection of Race")
		begin
			test_id = -1
			selected_race = @dbi.load_race_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 							selected_race.id)
			assert_equal("Test Race 1 time", 				selected_race.time)
			assert_equal(-1, 								selected_race.number)
			assert_equal("Test Race 1 name", 				selected_race.name)
			assert_equal("Test Race 1 result", 				selected_race.result)
			assert_equal(-1, 								selected_race.distance)
			assert_equal("Test Race 1 detailed conditions", selected_race.detailed_conditions)
			assert_equal(-1, 								selected_race.bets)
			assert_equal("Test Race 1 URL", 				selected_race.url)
			assert_equal(-1, 								selected_race.value)
			
			expected_result_insertion_time = 	DateTime.new(2015, 01, 01, 00, 00)
			assert_equal(
				expected_result_insertion_time, 
				selected_race.result_insertion_time
			)
			
			# Nested value : meeting
			assert_equal(test_id, 						selected_race.meeting.id)
			assert_equal("Test Meeting 1 country", 		selected_race.meeting.country)
			assert_equal(Date.new(2015, 01, 01), 		selected_race.meeting.date)
			assert_equal("Test Meeting 1 racetrack", 	selected_race.meeting.racetrack)
			assert_equal(-1, 							selected_race.meeting.number)
			assert_equal(nil, 							selected_race.meeting.urls_of_races_array)
			
			# Nested value : track_condition
			assert_equal(-1,						selected_race.meeting.track_condition.id)
			assert_equal("Test Track Condition", 	selected_race.meeting.track_condition.text)
			
			# Nested value (2nd level) : job
			assert_equal(-1, selected_race.meeting.job.id)

			expected_start_time = 			DateTime.new(2015, 01, 27, 17, 35, 0.250)
			assert_equal(
				expected_start_time, 
				selected_race.meeting.job.start_time
			)
			
			expected_loading_end_time = 	DateTime.new(2015, 01, 27, 18, 36, 1.500)
			assert_equal(
				expected_loading_end_time, 
				selected_race.meeting.job.loading_end_time
			)
			
			expected_crawling_end_time = 	DateTime.new(2015, 01, 27, 19, 37, 2.750)
			assert_equal(
				expected_crawling_end_time, 
				selected_race.meeting.job.crawling_end_time
			)
			
			expected_computing_end_time = 	DateTime.new(2015, 01, 27, 20, 38, 3.999)
			assert_equal(
				expected_computing_end_time, 
				selected_race.meeting.job.computing_end_time
			)
			
			# Nested value (2nd level) : weather
			assert_equal(-1,							selected_race.meeting.weather.id)
			assert_equal(-1, 							selected_race.meeting.weather.temperature)
			assert_equal(-1,						 	selected_race.meeting.weather.wind_speed)
			assert_equal("Test Weather 1 insolation", 	selected_race.meeting.weather.insolation)
			
			# Nested value (3nd level) : wind_direction
			assert_equal(-1, 				selected_race.meeting.weather.wind_direction.id)
			assert_equal("Test Direction", 	selected_race.meeting.weather.wind_direction.text)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_ref_objects
		@logger.info("Testing selection of RefObjects")
		begin
			@logger.info("Blinder")
			test_id = -1
			selected_blinder = @ref_list_hash[:ref_blinder_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 			selected_blinder.id)
			assert_equal("Test Blinder", 	selected_blinder.text)
			
			@logger.info("Breed")
			test_id = -1
			selected_breed = @ref_list_hash[:ref_breed_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 		selected_breed.id)
			assert_equal("Test Breed", 	selected_breed.text)
			
			@logger.info("Coat")
			test_id = -1
			selected_coat = @ref_list_hash[:ref_coat_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 		selected_coat.id)
			assert_equal("Test Coat", 	selected_coat.text)
			
			@logger.info("Column")
			test_id = -1
			selected_column = @ref_list_hash[:ref_column_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 			selected_column.id)
			assert_equal("Test Column", 	selected_column.text)
			
			@logger.info("Direction")
			test_id = -1
			selected_direction = @ref_list_hash[:ref_direction_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 			selected_direction.id)
			assert_equal("Test Direction", 	selected_direction.text)
			
			@logger.info("Race Type")
			test_id = -1
			selected_race_type = @ref_list_hash[:ref_race_type_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 			selected_race_type.id)
			assert_equal("Test Race Type", 	selected_race_type.text)
			
			@logger.info("Sex")
			test_id = -1
			selected_sex = @ref_list_hash[:ref_sex_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 		selected_sex.id)
			assert_equal("Test Sex", 	selected_sex.text)
			
			@logger.info("Shoes")
			test_id = -1
			selected_shoes = @ref_list_hash[:ref_shoes_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 		selected_shoes.id)
			assert_equal("Test Shoes", 	selected_shoes.text)
			
			@logger.info("Track Condition")
			test_id = -1
			selected_track_condition = @ref_list_hash[:ref_track_condition_list].get(test_id)
			
			# Checking value
			assert_equal(test_id, 					selected_track_condition.id)
			assert_equal("Test Track Condition", 	selected_track_condition.text)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_runner
		@logger.info("Testing selection of Runner")
		begin
			test_id = -1
			selected_runner = @dbi.load_runner_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 						selected_runner.id)
			assert_equal(-1, 							selected_runner.number)
			assert_equal(-1, 							selected_runner.draw)
			assert_equal(-1.1, 							selected_runner.single_rating)
			assert_equal(-1, 							selected_runner.non_runner)
			assert_equal(-1, 							selected_runner.races_run)
			assert_equal(-1, 							selected_runner.victories)
			assert_equal(-1, 							selected_runner.places)
			assert_equal(-1, 							selected_runner.earnings_career)
			assert_equal(-1, 							selected_runner.earnings_current_year)
			assert_equal(-1, 							selected_runner.earnings_last_year)
			assert_equal(-1, 							selected_runner.earnings_victory)
			assert_equal("Test Runner 1 description", 	selected_runner.description)
			assert_equal(-1, 							selected_runner.distance)
			assert_equal(-1.1, 							selected_runner.load)
			assert_equal("Test Runner 1 history", 		selected_runner.history)
			assert_equal("Test Runner 1 url", 			selected_runner.url)
			
			# Nested value : race
			assert_equal(test_id, 							selected_runner.race.id)
			assert_equal("Test Race 1 time", 				selected_runner.race.time)
			assert_equal(-1, 								selected_runner.race.number)
			assert_equal("Test Race 1 name", 				selected_runner.race.name)
			assert_equal("Test Race 1 result", 				selected_runner.race.result)
			assert_equal(-1, 								selected_runner.race.distance)
			assert_equal("Test Race 1 detailed conditions", selected_runner.race.detailed_conditions)
			assert_equal(-1, 								selected_runner.race.bets)
			assert_equal("Test Race 1 URL", 				selected_runner.race.url)
			assert_equal(-1, 								selected_runner.race.value)
			
			expected_result_insertion_time = 	DateTime.new(2015, 01, 01, 00, 00)
			assert_equal(
				expected_result_insertion_time, 
				selected_runner.race.result_insertion_time
			)
			
			# Nested value (2nd level) : meeting
			assert_equal(test_id, 						selected_runner.race.meeting.id)
			assert_equal("Test Meeting 1 country", 		selected_runner.race.meeting.country)
			assert_equal(Date.new(2015, 01, 01), 		selected_runner.race.meeting.date)
			assert_equal("Test Meeting 1 racetrack", 	selected_runner.race.meeting.racetrack)
			assert_equal(-1, 							selected_runner.race.meeting.number)
			assert_equal(nil, 							selected_runner.race.meeting.urls_of_races_array)
			
			# Nested value (2nd level) : track_condition
			assert_equal(-1,						selected_runner.race.meeting.track_condition.id)
			assert_equal("Test Track Condition", 	selected_runner.race.meeting.track_condition.text)
			
			# Nested value (3rd level) : job
			assert_equal(-1, selected_runner.race.meeting.job.id)

			expected_start_time = 			DateTime.new(2015, 01, 27, 17, 35, 0.250)
			assert_equal(
				expected_start_time, 
				selected_runner.race.meeting.job.start_time
			)
			
			expected_loading_end_time = 	DateTime.new(2015, 01, 27, 18, 36, 1.500)
			assert_equal(
				expected_loading_end_time, 
				selected_runner.race.meeting.job.loading_end_time
			)
			
			expected_crawling_end_time = 	DateTime.new(2015, 01, 27, 19, 37, 2.750)
			assert_equal(
				expected_crawling_end_time, 
				selected_runner.race.meeting.job.crawling_end_time
			)
			
			expected_computing_end_time = 	DateTime.new(2015, 01, 27, 20, 38, 3.999)
			assert_equal(
				expected_computing_end_time, 
				selected_runner.race.meeting.job.computing_end_time
			)
			
			# Nested value (3rd level) : weather
			assert_equal(-1,							selected_runner.race.meeting.weather.id)
			assert_equal(-1, 							selected_runner.race.meeting.weather.temperature)
			assert_equal(-1,						 	selected_runner.race.meeting.weather.wind_speed)
			assert_equal("Test Weather 1 insolation", 	selected_runner.race.meeting.weather.insolation)
			
			# Nested value (4th level) : wind_direction
			assert_equal(-1, 				selected_runner.race.meeting.weather.wind_direction.id)
			assert_equal("Test Direction", 	selected_runner.race.meeting.weather.wind_direction.text)
			
			# Nested value : horse
			assert_equal(test_id, 				selected_runner.horse.id)
			assert_equal("Test Horse 1 name", 	selected_runner.horse.name)
	
			# Nested value (2nd level) : sex
			assert_equal(-1,			selected_runner.horse.sex.id)
			assert_equal("Test Sex", 	selected_runner.horse.sex.text)
			
			# Nested value (2nd level) : breed
			assert_equal(-1,			selected_runner.horse.breed.id)
			assert_equal("Test Breed", 	selected_runner.horse.breed.text)
			
			# Nested value (2nd level) : coat
			assert_equal(-1,			selected_runner.horse.coat.id)
			assert_equal("Test Coat", 	selected_runner.horse.coat.text)
			
			# Nested value (2nd level) : jockey
			assert_equal(test_id, 					selected_runner.jockey.id)
			assert_equal("Test Jockey 1 name", 		selected_runner.jockey.name)
			assert_equal("Test Jockey 1 jacket", 	selected_runner.jockey.jacket)
			
			# Nested value : trainer
			assert_equal(test_id, 				selected_runner.trainer.id)
			assert_equal("Test Trainer 1 name", selected_runner.trainer.name)
			
			# Nested value : owner
			assert_equal(test_id, 				selected_runner.owner.id)
			assert_equal("Test Owner 1 name", 	selected_runner.owner.name)
			
			# Nested value : breeder
			assert_equal(test_id, 				selected_runner.breeder.id)
			assert_equal("Test Breeder 1 Name", selected_runner.breeder.name)
			
			# Nested value : blinder
			assert_equal(test_id, 			selected_runner.blinder.id)
			assert_equal("Test Blinder", 	selected_runner.blinder.text)
			
			# Nested value : shoes
			assert_equal(test_id, 		selected_runner.shoes.id)
			assert_equal("Test Shoes", 	selected_runner.shoes.text)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_trainer
		@logger.info("Testing selection of Trainer")
		begin
			test_id = -1
			selected_trainer = @dbi.load_trainer_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 				selected_trainer.id)
			assert_equal("Test Trainer 1 name", selected_trainer.name)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_weather
		@logger.info("Testing selection of Weather")
		begin
			test_id = -1
			selected_weather = @dbi.load_weather_by_id(test_id)
			
			# Checking value
			assert_equal(-1,							selected_weather.id)
			assert_equal(-1, 							selected_weather.temperature)
			assert_equal(-1,						 	selected_weather.wind_speed)
			assert_equal("Test Weather 1 insolation", 	selected_weather.insolation)
			
			# Nested value : wind_direction
			assert_equal(-1, 				selected_weather.wind_direction.id)
			assert_equal("Test Direction", 	selected_weather.wind_direction.text)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_weight
		@logger.info("Testing selection of Weight")
		begin
			test_id = -1
			selected_weight = @dbi.load_weight_by_id(test_id)
			
			# Checking value
			assert_equal(-1,					selected_weight.id)
			assert_equal("Test Weight 1 name",	selected_weight.name)
			assert_equal(-1.1,					selected_weight.value)
			
			# Nested value : forecast
			assert_equal(test_id, 								selected_weight.forecast.id)
			assert_equal("Test Forecast 1 Expected result", 	selected_weight.forecast.expected_result)
			assert_equal(-1.1, 									selected_weight.forecast.result_match_rate)
			assert_equal(-1.1, 									selected_weight.forecast.normalised_result_match_rate)
			
			# Nested value (2nd level) : race
			assert_equal(-1, 						selected_weight.forecast.race.id)
			assert_equal("Test Race 1 time", 		selected_weight.forecast.race.time)
			assert_equal(-1, 						selected_weight.forecast.race.number)
			assert_equal("Test Race 1 name", 		selected_weight.forecast.race.name)
			assert_equal("Test Race 1 result", 		selected_weight.forecast.race.result)
			default_time = Date.new(2015, 01, 01)
			str_default_time = default_time.strftime(@config[:gen][:default_date_format])
			assert_equal(
				str_default_time,
				selected_weight.forecast.race.result_insertion_time.strftime(@config[:gen][:default_date_format])
			)
			assert_equal(-1, selected_weight.forecast.race.distance)
			assert_equal("Test Race 1 detailed conditions", selected_weight.forecast.race.detailed_conditions)
			assert_equal(-1, selected_weight.forecast.race.bets)
			assert_equal(-1, selected_weight.forecast.race.value)
			assert_equal("Test Race 1 URL", selected_weight.forecast.race.url)
						
			# Nested value (3rd level) : race_type
			assert_equal(-1,				selected_weight.forecast.race.race_type.id)
			assert_equal("Test Race Type", 	selected_weight.forecast.race.race_type.text)
			
			# Nested value (3rd level) : meeting
			assert_equal(-1, selected_weight.forecast.race.meeting.id)
			assert_equal(
				str_default_time,
				selected_weight.forecast.race.meeting.date.strftime(@config[:gen][:default_date_format])
			)
			assert_equal("Test Meeting 1 country", 		selected_weight.forecast.race.meeting.country)
			assert_equal("Test Meeting 1 racetrack", 	selected_weight.forecast.race.meeting.racetrack)
			assert_equal(-1, selected_weight.forecast.race.meeting.number)
			assert_equal(nil, selected_weight.forecast.race.meeting.urls_of_races_array)
			
			# Nested value (4th level) : track_condition
			assert_equal(-1, 						selected_weight.forecast.race.meeting.track_condition.id)
			assert_equal("Test Track Condition", 	selected_weight.forecast.race.meeting.track_condition.text)
			
			# Nested value (4th level) : job
			assert_equal(-1, selected_weight.forecast.race.meeting.job.id)

			expected_start_time = 			DateTime.new(2015, 01, 27, 17, 35, 0.250)
			assert_equal(
				expected_start_time, 
				selected_weight.forecast.race.meeting.job.start_time
			)
			
			expected_loading_end_time = 	DateTime.new(2015, 01, 27, 18, 36, 1.500)
			assert_equal(
				expected_loading_end_time, 
				selected_weight.forecast.race.meeting.job.loading_end_time
			)
			
			expected_crawling_end_time = 	DateTime.new(2015, 01, 27, 19, 37, 2.750)
			assert_equal(
				expected_crawling_end_time, 
				selected_weight.forecast.race.meeting.job.crawling_end_time
			)
			
			expected_computing_end_time = 	DateTime.new(2015, 01, 27, 20, 38, 3.999)
			assert_equal(
				expected_computing_end_time, 
				selected_weight.forecast.race.meeting.job.computing_end_time
			)
			
			# Nested value (4th level) : weather
			assert_equal(-1,							selected_weight.forecast.race.meeting.weather.id)
			assert_equal(-1, 							selected_weight.forecast.race.meeting.weather.temperature)
			assert_equal(-1,						 	selected_weight.forecast.race.meeting.weather.wind_speed)
			assert_equal("Test Weather 1 insolation", 	selected_weight.forecast.race.meeting.weather.insolation)
			
			# Nested value (5th level) : wind_direction
			assert_equal(-1, 				selected_weight.forecast.race.meeting.weather.wind_direction.id)
			assert_equal("Test Direction", 	selected_weight.forecast.race.meeting.weather.wind_direction.text)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
end