require './TestSuite.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
require './validation.rb'

class TestDatabaseInterfaceDelete < TestSuite
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi_select = $globalState.dbi_select_by_tech_id
		@dbi_update = $globalState.dbi_update
		if(@ref_list_hash == nil) then 
			@ref_list_hash = @dbi_select.load_all_refs
		end
		
		@logger.level = SimpleHtmlLogger::INFO
	end
	
	##################
	#      Tests     #
	##################
	def test_update_forecast_with_match_rate
		
		@logger.imp("Testing update of Forecast with match rate")
		begin
			test_id = -10 # forecast without match rate
			selected_forecast = @dbi_select.load_forecast_by_id(test_id)
			
			# check that there is no match rate
			assert_equal("Test Forecast 10 update Expected result", selected_forecast.expected_result)
			assert_equal(nil, 										selected_forecast.result_match_rate)
			assert_equal(nil, 										selected_forecast.normalised_result_match_rate)
			
			# put match rate in
			selected_forecast.result_match_rate = -10.2
			selected_forecast.normalised_result_match_rate = -10.2
			
			# call update method
			@dbi_update.update_forecast_with_match_rate(selected_forecast)
			
			# reload and check
			updated_forecast = @dbi_select.load_forecast_by_id(test_id)
			
			assert_equal(selected_forecast.expected_result, 				updated_forecast.expected_result)
			assert_equal(selected_forecast.result_match_rate, 				updated_forecast.result_match_rate)
			assert_equal(selected_forecast.normalised_result_match_rate, 	updated_forecast.normalised_result_match_rate)
			
			@logger.ok("Tests for updating Forecast OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_update_race_with_result
		
		@logger.imp("Testing update of Race with results")
		begin
			test_id = -10 # race without results
			selected_race = @dbi_select.load_race_by_id(test_id)
			
			# check that there is no match rate
			# Checking value
			expected_race = Race::new(
				id: test_id,
				bets: -10,
				detailed_conditions: "Test Race 10 update detailed conditions",
				distance: -10,
				meeting: @dbi_select.load_meeting_by_id(-1),
				name: "Test Race 10 update name",
				number: -10,
				time: "Test Race 10 update time",
				url: "Test Race 10 update URL",
				value: -10,
				race_type: @ref_list_hash[:ref_race_type_list]["Test Race Type"],
				result: nil,
				result_insertion_time: nil
			)
			validate_race(expected_race, selected_race, "update of Race (with results), select before update")
			
			# put results in
			selected_race.result = "1 - 2 - 3 - 4 - 5"
			selected_race.result_insertion_time = DateTime.now
			
			# call update method
			@dbi_update.update_race_with_result(selected_race)
			
			# reload and check
			updated_race = @dbi_select.load_race_by_id(test_id)
			
			validate_race(selected_race, updated_race, "update of Race (with results), updated race")
			
			@logger.ok("Tests for updating Race OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_update_runner_with_final_place
		
		@logger.imp("Testing update of Runner with final place")
		
		begin
			test_id = -10 # runner without final place
			selected_runner = @dbi_select.load_runner_by_id(test_id)
			
			# check that there is no final_place
			# Checking value
			# objects get a Q&D test, I don't really care about the value, I 
			# just want to be sure that it's been loaded
			assert_equal(-1, 							selected_runner.blinder.id) 
			assert_equal(-1, 							selected_runner.breeder.id)
			assert_equal("Test Runner 10 description",	selected_runner.description)
			assert_equal(-10, 							selected_runner.distance)
			assert_equal(-10, 							selected_runner.draw)
			assert_equal(-10, 							selected_runner.earnings_career)
			assert_equal(-10, 							selected_runner.earnings_current_year)
			assert_equal(-10, 							selected_runner.earnings_last_year)
			assert_equal(-10, 							selected_runner.earnings_victory)
			assert_equal("Test Runner 10 history",		selected_runner.history)
			assert_equal(-1, 							selected_runner.horse.id)
			assert_equal(-1, 							selected_runner.jockey.id)
			assert_equal(-10.1, 						selected_runner.load_handicap)
			assert_equal(-10.1, 						selected_runner.load_ride)
			assert_equal(false, 						selected_runner.is_favorite)
			assert_equal(false, 						selected_runner.is_non_runner)
			assert_equal(false, 						selected_runner.is_substitute)
			assert_equal(-10, 							selected_runner.number)
			assert_equal(-1, 							selected_runner.owner.id)
			assert_equal(-10, 							selected_runner.places)
			assert_equal(-1, 							selected_runner.race.id)
			assert_equal(-10, 							selected_runner.races_run)
			assert_equal(-1, 							selected_runner.shoes.id)
			assert_equal(-10.1, 						selected_runner.single_rating_before_race)
			assert_equal(-1, 							selected_runner.trainer.id)
			assert_equal("Test Runner 10 url",			selected_runner.url)
			assert_equal(-10, 							selected_runner.victories)
			
			assert_equal(nil, 							selected_runner.disqualified)
			assert_equal(nil, 							selected_runner.final_place)
			assert_equal(nil, 							selected_runner.single_rating_after_race)
			
			# put results in
			selected_runner.disqualified = true
			selected_runner.final_place = 4
			selected_runner.single_rating_after_race = 20.4
			
			# call update method
			@dbi_update.update_runner_after_race(selected_runner) 
			
			# reload and check
			updated_runner = @dbi_select.load_runner_by_id(test_id)
			
			assert_equal(selected_runner.blinder.id, 				updated_runner.blinder.id) 
			assert_equal(selected_runner.breeder.id,				updated_runner.breeder.id)
			assert_equal(selected_runner.description,				updated_runner.description)
			assert_equal(selected_runner.distance,					updated_runner.distance)
			assert_equal(selected_runner.draw,						updated_runner.draw)
			assert_equal(selected_runner.earnings_career,			updated_runner.earnings_career)
			assert_equal(selected_runner.earnings_current_year,		updated_runner.earnings_current_year)
			assert_equal(selected_runner.earnings_last_year,		updated_runner.earnings_last_year)
			assert_equal(selected_runner.earnings_victory,			updated_runner.earnings_victory)
			assert_equal(selected_runner.history,					updated_runner.history)
			assert_equal(selected_runner.horse.id,					updated_runner.horse.id)
			assert_equal(selected_runner.jockey.id,					updated_runner.jockey.id)
			assert_equal(selected_runner.load_handicap,				updated_runner.load_handicap)
			assert_equal(selected_runner.load_ride,					updated_runner.load_ride)
			assert_equal(selected_runner.is_favorite,				updated_runner.is_favorite)
			assert_equal(selected_runner.is_non_runner,				updated_runner.is_non_runner)
			assert_equal(selected_runner.is_substitute,				updated_runner.is_substitute)
			assert_equal(selected_runner.number,					updated_runner.number)
			assert_equal(selected_runner.owner.id,					updated_runner.owner.id)
			assert_equal(selected_runner.places,					updated_runner.places)
			assert_equal(selected_runner.race.id,					updated_runner.race.id)
			assert_equal(selected_runner.races_run,					updated_runner.races_run)
			assert_equal(selected_runner.shoes.id,					updated_runner.shoes.id)
			assert_equal(selected_runner.single_rating_before_race,	updated_runner.single_rating_before_race)
			assert_equal(selected_runner.trainer.id,				updated_runner.trainer.id)
			assert_equal(selected_runner.url,						updated_runner.url)
			assert_equal(selected_runner.victories,					updated_runner.victories)
			             
			assert_equal(selected_runner.disqualified,				updated_runner.disqualified)
			assert_equal(selected_runner.final_place,				updated_runner.final_place)
			assert_equal(selected_runner.single_rating_after_race,	updated_runner.single_rating_after_race)
			
			@logger.ok("Tests for updating Runner OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end	
end