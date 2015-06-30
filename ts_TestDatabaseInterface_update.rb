require './TestSuite.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class TestDatabaseInterfaceDelete < TestSuite
	
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
	def test_update_forecast_with_match_rate
		
		@logger.info("Testing update of Forecast with match rate")
		begin
			test_id = -10 # forecast without match rate
			selected_forecast = @dbi.load_forecast_by_id(test_id)
			
			# check that there is no match rate
			assert_equal("Test Forecast 10 update Expected result", selected_forecast.expected_result)
			assert_equal(nil, 										selected_forecast.result_match_rate)
			assert_equal(nil, 										selected_forecast.normalised_result_match_rate)
			
			# put match rate in
			selected_forecast.result_match_rate = -10.2
			selected_forecast.normalised_result_match_rate = -10.2
			
			# call update method
			@dbi.update_forecast_with_match_rate(selected_forecast)
			
			# reload and check
			updated_forecast = @dbi.load_forecast_by_id(test_id)
			
			assert_equal(selected_forecast.expected_result, 				updated_forecast.expected_result)
			assert_equal(selected_forecast.result_match_rate, 				updated_forecast.result_match_rate)
			assert_equal(selected_forecast.normalised_result_match_rate, 	updated_forecast.normalised_result_match_rate)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_update_race_with_result
		
		@logger.info("Testing update of Race with results")
		begin
			test_id = -10 # race without results
			selected_race = @dbi.load_race_by_id(test_id)
			
			# check that there is no match rate
			# Checking value
			assert_equal(test_id, 									selected_race.id)
			assert_equal("Test Race 10 update time", 				selected_race.time)
			assert_equal(-10, 										selected_race.number)
			assert_equal("Test Race 10 update name", 				selected_race.name)
			assert_equal(-10, 										selected_race.distance)
			assert_equal("Test Race 10 update detailed conditions", selected_race.detailed_conditions)
			assert_equal(-10, 										selected_race.bets)
			assert_equal("Test Race 10 update URL", 				selected_race.url)
			assert_equal(-10, 										selected_race.value)
			
			assert_equal(nil, 										selected_race.result)
			assert_equal(nil, 										selected_race.result_insertion_time)
			
			# put results in
			selected_race.result = "1 - 2 - 3 - 4 - 5"
			selected_race.result_insertion_time = Time.now
			
			# call update method
			@dbi.update_race_with_result(selected_race)
			
			# reload and check
			updated_race = @dbi.load_race_by_id(test_id)
			
			assert_equal(test_id, 								updated_race.id)
			assert_equal(selected_race.time, 					updated_race.time)
			assert_equal(selected_race.number, 					updated_race.number)
			assert_equal(selected_race.name, 					updated_race.name)
			
			assert_equal(selected_race.distance, 				updated_race.distance)
			assert_equal(selected_race.detailed_conditions, 	updated_race.detailed_conditions)
			assert_equal(selected_race.bets, 					updated_race.bets)
			assert_equal(selected_race.url, 					updated_race.url)
			assert_equal(selected_race.value, 					updated_race.value)
			
			assert_equal(selected_race.result, 					updated_race.result)
			assert_equal(
				selected_race.result_insertion_time.strftime(@config[:gen][:default_date_time_format]), 	
				updated_race.result_insertion_time.strftime(@config[:gen][:default_date_time_format]))
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_update_runner_with_final_place
		
		@logger.info("Testing update of Runner with final place")
		
		begin
			test_id = -10 # runner without final place
			selected_runner = @dbi.load_runner_by_id(test_id)
			
			# check that there is no final_place
			# Checking value

			# objects get a Q&D test, I don't really care about the value, I 
			# just want to be sure that it's been loaded
			assert_equal(-1, 									selected_runner.blinder.id) 
			assert_equal(-1, 									selected_runner.breeder.id)
			assert_equal("Test Runner 10 update description",	selected_runner.description)
			assert_equal(-10, 									selected_runner.distance)
			assert_equal(-10, 									selected_runner.draw)
			assert_equal(-10, 									selected_runner.earnings_career)
			assert_equal(-10, 									selected_runner.earnings_current_year)
			assert_equal(-10, 									selected_runner.earnings_last_year)
			assert_equal(-10, 									selected_runner.earnings_victory)
			assert_equal("Test Runner 10 update history",		selected_runner.history)
			assert_equal(-1, 									selected_runner.horse.id)
			assert_equal(-1, 									selected_runner.jockey.id)
			assert_equal(-10.1, 								selected_runner.load)
			assert_equal(-10, 									selected_runner.non_runner)
			assert_equal(-10, 									selected_runner.number)
			assert_equal(-1, 									selected_runner.owner.id)
			assert_equal(-10, 									selected_runner.places)
			assert_equal(-1, 									selected_runner.race.id)
			assert_equal(-10, 									selected_runner.races_run)
			assert_equal(-1, 									selected_runner.shoes.id)
			assert_equal(-10.1, 								selected_runner.single_rating)
			assert_equal(-1, 									selected_runner.trainer.id)
			assert_equal("Test Runner 10 update url",			selected_runner.url)
			assert_equal(-10, 									selected_runner.victories)
			
			assert_equal(nil, 									selected_runner.final_place)
			
			# put results in
			selected_runner.final_place = 4
						
			# call update method
			@dbi.update_runner_with_final_place(selected_runner)
			
			# reload and check
			updated_runner = @dbi.load_runner_by_id(test_id)
			
			assert_equal(selected_runner.blinder.id, 			updated_runner.blinder.id) 
			assert_equal(selected_runner.breeder.id,			updated_runner.breeder.id)
			assert_equal(selected_runner.description,			updated_runner.description)
			assert_equal(selected_runner.distance,				updated_runner.distance)
			assert_equal(selected_runner.draw,					updated_runner.draw)
			assert_equal(selected_runner.earnings_career,		updated_runner.earnings_career)
			assert_equal(selected_runner.earnings_current_year,	updated_runner.earnings_current_year)
			assert_equal(selected_runner.earnings_last_year,	updated_runner.earnings_last_year)
			assert_equal(selected_runner.earnings_victory,		updated_runner.earnings_victory)
			assert_equal(selected_runner.history,				updated_runner.history)
			assert_equal(selected_runner.horse.id,				updated_runner.horse.id)
			assert_equal(selected_runner.jockey.id,				updated_runner.jockey.id)
			assert_equal(selected_runner.load,					updated_runner.load)
			assert_equal(selected_runner.non_runner,			updated_runner.non_runner)
			assert_equal(selected_runner.number,				updated_runner.number)
			assert_equal(selected_runner.owner.id,				updated_runner.owner.id)
			assert_equal(selected_runner.places,				updated_runner.places)
			assert_equal(selected_runner.race.id,				updated_runner.race.id)
			assert_equal(selected_runner.races_run,				updated_runner.races_run)
			assert_equal(selected_runner.shoes.id,				updated_runner.shoes.id)
			assert_equal(selected_runner.single_rating,			updated_runner.single_rating)
			assert_equal(selected_runner.trainer.id,			updated_runner.trainer.id)
			assert_equal(selected_runner.url,					updated_runner.url)
			assert_equal(selected_runner.victories,				updated_runner.victories)
			             
			assert_equal(selected_runner.final_place,			updated_runner.final_place)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end	
end