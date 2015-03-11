require './ts_TestSuite.rb'
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
			assert_equal(1, 2) # "graceful" failure
		end
	end
	
	def test_select_forecast
		@logger.info("Testing selection of Forecast")
		begin
			test_id = -1
			selected_forecast = @dbi.load_forecast_by_id(test_id)
			
			@logger.debug(selected_forecast)
			
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
			assert_equal("Test Race 1 country", 	selected_forecast.race.country)
			assert_equal("Test Race 1 result", 		selected_forecast.race.result)
			assert_equal(
				"01/01/2015 00:00".strftime(@config[:gen][:default_date_format],
				selected_forecast.race.result_insertion_time.strftime(@config[:gen][:default_date_format]))
			)
			assert_equal(-1, selected_forecast.race.distance)
			assert_equal("Test Race 1 detailed conditions", selected_forecast.race.detailed_conditions)
			assert_equal(-1, selected_forecast.race.bets)
			assert_equal(-1, selected_forecast.race.value)
			assert_equal("Test Race 1 URL", selected_forecast.race.url)
			
			# Nested value (2nd level) : meeting
			assert_equal(-1, selected_forecast.race.meeting.id)
			assert_equal(
				"01/01/2015".strftime(@config[:gen][:default_date_format]),
				selected_forecast.race.meeting.date.strftime(@config[:gen][:default_date_format])
			)
			assert_equal("Test Meeting 1 racetrack", selected_forecast.race.meeting.racetrack)
			assert_equal(-1, selected_forecast.race.meeting.number)
			assert_equal("Test Meeting 1 URL", selected_forecast.race.meeting.url)
			
			# Nested value (3rd level) : track_condition
			assert_equal(-1, selected_forecast.race.meeting.track_condition.id)
			assert_equal("Test Track Condition", selected_forecast.race.meeting.track_condition.text)
			
			# Nested value (3rd level) : job
			assert_equal(-1, selected_forecast.race.meeting.job.id)
			assert_equal(
				Date::new("27/01/2015 17:35:00.250").strftime(@config[:gen][:default_date_time_format]), 
				selected_forecast.race.meeting.date.strftime(@config[:gen][:default_date_time_format])
			)
			assert_equal(
				Date::new("27/01/2015 18:36:01.500").strftime(@config[:gen][:default_date_time_format]), 
				selected_forecast.race.meeting.date.strftime(@config[:gen][:default_date_time_format])
			)
			assert_equal(
				Date::new("27/01/2015 19:37:02.750").strftime(@config[:gen][:default_date_time_format]), 
				selected_forecast.race.meeting.date.strftime(@config[:gen][:default_date_time_format])
			)
			assert_equal(
				Date::new("27/01/2015 20:38:03.999").strftime(@config[:gen][:default_date_time_format]), 
				selected_forecast.race.meeting.date.strftime(@config[:gen][:default_date_time_format])
			)
			
			# Nested value (3rd level) : weather
			# NOT FETCHED ! Keeping it (commented) for use in test_select_weather
			# Delete these lines if test_select_weather has been written
			#assert_equal(-1, 							selected_forecast.race.meeting.weather.id)
			#assert_equal(-1, 							selected_forecast.race.meeting.weather.temperature)
			#assert_equal(-, 							selected_forecast.race.meeting.weather.wind_speed)
			#assert_equal("Test Weather 1 insolation", 	selected_forecast.race.meeting.weather.insolation)
			
			# Nested value (4th level) : wind_direction
			#assert_equal(-1, 					selected_forecast.race.meeting.weather.wind_direction.id)
			#assert_equal("Test Direction", 	selected_forecast.race.meeting.weather.wind_direction.text)
			
			# Nested value (2nd level) : race_type
			assert_equal(-1,				selected_forecast.race.race_type.id)
			assert_equal("Test Race Type", 	selected_forecast.race.race_type.test)
						
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			assert_equal(1, 2) # "graceful" failure
		end
	end
	
end