require './TestSuite.rb'
require './validation.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class TestDatabaseInterfaceSelect < TestSuite
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi_select = $globalState.dbi_select_by_tech_id
		if(@ref_list_hash == nil) then 
			@ref_list_hash = @dbi_select.load_all_refs
		end
	end
	
	def teardown
		
	end
	
	##################
	#      Tests     #
	##################
	def test_select_breeder
		@logger.imp("Testing selection of Breeder")
		begin
			test_id = -1
			selected_breeder = @dbi_select.load_breeder_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 				selected_breeder.id)
			assert_equal("Test Breeder 1 Name", selected_breeder.name)
			
			@logger.ok("Tests selection of Breeder OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	def test_select_forecast
		@logger.imp("Testing selection of Forecast")
		begin
			test_id = -1
			selected_forecast = @dbi_select.load_forecast_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 							selected_forecast.id)
			assert_equal("Test Forecast 1 Expected result", selected_forecast.expected_result)
			assert_equal(-1.1, 								selected_forecast.result_match_rate)
			assert_equal(-1.1, 								selected_forecast.normalised_result_match_rate)
			
			job = Job::new(id: -1,
							start_time: DateTime.new(2015, 01, 27, 17, 35, 0.250, '+00'),
							loading_end_time: DateTime.new(2015, 01, 27, 18, 36, 1.500, '+00'),
							crawling_end_time: DateTime.new(2015, 01, 27, 19, 37, 2.750, '+00'),
							computing_end_time: DateTime.new(2015, 01, 27, 20, 38, 3.999, '+00'))
			
			weather = Weather::new(id: -1,
									insolation: "Test Weather 1 insolation",
									temperature: -1,
									wind_direction: @ref_list_hash[:ref_direction_list]["Test Direction"],
									wind_speed: -1)
			
			meeting = Meeting::new(country: "Test Meeting 1 country",
									date: Date.new(2015, 01, 01),
									id: -1,
									job: job,
									number: -1,
									racetrack: "Test Meeting 1 racetrack",
									track_condition: @ref_list_hash[:ref_track_condition_list]["Test Track Condition"],
									weather: weather)
			
			expected_race = Race::new(bets: -1,
							detailed_conditions: "Test Race 1 detailed conditions",
							distance: -1,
							id: -1,
							meeting: meeting,
							name: "Test Race 1 name",
							number: -1,
							general_conditions: "Test Race 1 general conditions",
							race_type: @ref_list_hash[:ref_race_type_list]["Test Race Type"],
							result: "Test Race 1 result",
							# result_insertion_time: "01/01/2015 00:00",
							result_insertion_time: DateTime.new(2015, 01, 01, 00, 00, 00, '+00'),
							time: "Test Race 1 time",
							url: "Test Race 1 URL",
							value: -1)
							
			validate_race(expected_race, selected_forecast.race, "selection of race")
			
			@logger.ok("Tests selection of Forecast OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_horse
		@logger.imp("Testing selection of Horse")
		begin
			test_id = -1
			selected_horse = @dbi_select.load_horse_by_id(test_id)
			
			father = Horse::new(id: -2, 
								breed: @ref_list_hash[:ref_breed_list]["Test Breed"],
								coat: @ref_list_hash[:ref_coat_list]["Test Coat"],
								father: nil,
								mother: nil,
								name: "Test Father name",
								sex: @ref_list_hash[:ref_sex_list]["Test Sex"])
								
			mother = Horse::new(id: -3, 
								breed: @ref_list_hash[:ref_breed_list]["Test Breed"],
								coat: @ref_list_hash[:ref_coat_list]["Test Coat"],
								father: nil,
								mother: nil,
								name: "Test Mother name",
								sex: @ref_list_hash[:ref_sex_list]["Test Sex"])
			
			expected_horse = Horse::new(	id: -1, 
								breed: @ref_list_hash[:ref_breed_list]["Test Breed"],
								coat: @ref_list_hash[:ref_coat_list]["Test Coat"],
								father: father,
								mother: mother,
								name: "Test Horse 1 name",
								sex: @ref_list_hash[:ref_sex_list]["Test Sex"])
								
			validate_horse(expected_horse, selected_horse, "selection of horse")
			@logger.ok("Tests selection of Horse OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_job
		@logger.imp("Testing selection of Job")
		begin
			test_id = -1
			selected_job = @dbi_select.load_job_by_id(test_id)
			
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
			
			@logger.ok("Tests selection of Job OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	
	def test_select_jockey
		@logger.imp("Testing selection of Jockey")
		begin
			test_id = -1
			selected_jockey = @dbi_select.load_jockey_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 					selected_jockey.id)
			assert_equal("Test Jockey 1 name", 		selected_jockey.name)
			assert_equal("Test Jockey 1 jacket", 	selected_jockey.jacket)
			
			@logger.ok("Tests selection of Jockey OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end

	def test_select_meeting
		@logger.imp("Testing selection of Meeting")
		begin
			test_id = -1
			selected_meeting = @dbi_select.load_meeting_by_id(test_id)
			
			job = Job::new(id: -1,
							start_time: DateTime.new(2015, 01, 27, 17, 35, 0.250, '+00'),
							loading_end_time: DateTime.new(2015, 01, 27, 18, 36, 1.500, '+00'),
							crawling_end_time: DateTime.new(2015, 01, 27, 19, 37, 2.750, '+00'),
							computing_end_time: DateTime.new(2015, 01, 27, 20, 38, 3.999, '+00'))
			
			weather = Weather::new(id: -1,
									insolation: "Test Weather 1 insolation",
									temperature: -1,
									wind_direction: @ref_list_hash[:ref_direction_list]["Test Direction"],
									wind_speed: -1)
			
			meeting = Meeting::new(country: "Test Meeting 1 country",
									date: Date.new(2015, 01, 01),
									id: -1,
									job: job,
									number: -1,
									racetrack: "Test Meeting 1 racetrack",
									track_condition: @ref_list_hash[:ref_track_condition_list]["Test Track Condition"],
									weather: weather)
									
			validate_meeting(meeting, selected_meeting, "selection of Meeting")
			
			@logger.ok("Tests selection of Meeting OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_origin
		@logger.imp("Testing selection of Origin")
		begin
			test_id = -1
			selected_origin = @dbi_select.load_origin_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 						selected_origin.id)
			assert_equal("Test Origin 1 name", 			selected_origin.name)
			assert_equal("Test Origin 1 column order", 	selected_origin.column_order)
			assert_equal("Test Origin 1 URL", 			selected_origin.url)
			
			@logger.ok("Tests selection of Origin OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_owner
		@logger.imp("Testing selection of Owner")
		begin
			test_id = -1
			selected_owner = @dbi_select.load_owner_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 				selected_owner.id)
			assert_equal("Test Owner 1 name", 	selected_owner.name)
			
			@logger.ok("Tests selection of Owner OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_race
		@logger.imp("Testing selection of Race")
		begin
			test_id = -1
			selected_race = @dbi_select.load_race_by_id(test_id)
			
			# Checking value
			job = Job::new(id: -1,
							start_time: DateTime.new(2015, 01, 27, 17, 35, 0.250, '+00'),
							loading_end_time: DateTime.new(2015, 01, 27, 18, 36, 1.500, '+00'),
							crawling_end_time: DateTime.new(2015, 01, 27, 19, 37, 2.750, '+00'),
							computing_end_time: DateTime.new(2015, 01, 27, 20, 38, 3.999, '+00'))
			
			weather = Weather::new(id: -1,
									insolation: "Test Weather 1 insolation",
									temperature: -1,
									wind_direction: @ref_list_hash[:ref_direction_list]["Test Direction"],
									wind_speed: -1)
			
			meeting = Meeting::new(country: "Test Meeting 1 country",
									date: Date.new(2015, 01, 01),
									id: -1,
									job: job,
									number: -1,
									racetrack: "Test Meeting 1 racetrack",
									track_condition: @ref_list_hash[:ref_track_condition_list]["Test Track Condition"],
									weather: weather)
			
			expected_race = Race::new(bets: -1,
							detailed_conditions: "Test Race 1 detailed conditions",
							distance: -1,
							id: -1,
							meeting: meeting,
							name: "Test Race 1 name",
							number: -1,
							general_conditions: "Test Race 1 general conditions",
							race_type: @ref_list_hash[:ref_race_type_list]["Test Race Type"],
							result: "Test Race 1 result",
							# result_insertion_time: "01/01/2015 00:00",
							result_insertion_time: DateTime.new(2015, 01, 01, 00, 00, 00, '+00'),
							time: "Test Race 1 time",
							url: "Test Race 1 URL",
							value: -1)
							
			validate_race(expected_race, selected_race, "selection of race")
			
			@logger.ok("Tests selection of Race OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_ref_objects
		@logger.imp("Testing selection of RefObjects")
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
			
			@logger.ok("Tests selection of RefObjects OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_runner
		@logger.imp("Testing selection of Runner")
		begin
			test_id = -1
			selected_runner = @dbi_select.load_runner_by_id(test_id)
			
			breeder = Breeder::new(id: -1, name: "Test Breeder 1 Name")
			
			father = Horse::new(id: -2, 
								breed: @ref_list_hash[:ref_breed_list]["Test Breed"],
								coat: @ref_list_hash[:ref_coat_list]["Test Coat"],
								father: nil,
								mother: nil,
								name: "Test Father name",
								sex: @ref_list_hash[:ref_sex_list]["Test Sex"])
								
			mother = Horse::new(id: -3, 
								breed: @ref_list_hash[:ref_breed_list]["Test Breed"],
								coat: @ref_list_hash[:ref_coat_list]["Test Coat"],
								father: nil,
								mother: nil,
								name: "Test Mother name",
								sex: @ref_list_hash[:ref_sex_list]["Test Sex"])
			
			horse = Horse::new(	id: -1, 
								breed: @ref_list_hash[:ref_breed_list]["Test Breed"],
								coat: @ref_list_hash[:ref_coat_list]["Test Coat"],
								father: father,
								mother: mother,
								name: "Test Horse 1 name",
								sex: @ref_list_hash[:ref_sex_list]["Test Sex"])
								
			job = Job::new(id: -1,
							start_time: DateTime.new(2015, 01, 27, 17, 35, 0.250, '+00'),
							loading_end_time: DateTime.new(2015, 01, 27, 18, 36, 1.500, '+00'),
							crawling_end_time: DateTime.new(2015, 01, 27, 19, 37, 2.750, '+00'),
							computing_end_time: DateTime.new(2015, 01, 27, 20, 38, 3.999, '+00'))
								
			jockey = Jockey::new(id: -1, name: "Test Jockey 1 name", jacket: "Test Jockey 1 jacket")
			
			weather = Weather::new(id: -1,
									insolation: "Test Weather 1 insolation",
									temperature: -1,
									wind_direction: @ref_list_hash[:ref_direction_list]["Test Direction"],
									wind_speed: -1)
			
			meeting = Meeting::new(country: "Test Meeting 1 country",
									date: Date.new(2015, 01, 01),
									id: -1,
									job: job,
									number: -1,
									racetrack: "Test Meeting 1 racetrack",
									track_condition: @ref_list_hash[:ref_track_condition_list]["Test Track Condition"],
									weather: weather)
									
			owner = Owner::new(id: -1, name: "Test Owner 1 name")
			
			race = Race::new(bets: -1,
							detailed_conditions: "Test Race 1 detailed conditions",
							distance: -1,
							id: -1,
							meeting: meeting,
							name: "Test Race 1 name",
							number: -1,
							general_conditions: "Test Race 1 general conditions",
							race_type: @ref_list_hash[:ref_race_type_list]["Test Race Type"],
							result: "Test Race 1 result",
							# result_insertion_time: "01/01/2015 00:00",
							result_insertion_time: DateTime.new(2015, 01, 01, 00, 00, 00, '+00'),
							time: "Test Race 1 time",
							url: "Test Race 1 URL",
							value: -1)
							
			trainer = Trainer::new(id: -1, name: "Test Trainer 1 name")
			
			expected_runner = Runner::new(
				blinder: @ref_list_hash[:ref_blinder_list]["Test Blinder"],
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				race: race,
				shoes: @ref_list_hash[:ref_shoes_list]["Test Shoes"],
				trainer: trainer,
				age: -1,
				commentary: "Test Runner 1 commentary",
				description: "Test Runner 1 description",
				distance: -1,
				disqualified: false,
				draw: -1,
				earnings_career: -1,
				earnings_current_year: -1,
				earnings_last_year: -1,
				earnings_victory: -1,
				final_place: -1,
				history: "Test Runner 1 history",
				id: test_id,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: false,
				load_handicap: -1.1,
				load_ride: -1.1,
				number: -1,
				places: -1,
				races_run: -1,
				single_rating_after_race: -1.1,
				single_rating_before_race: -1.1,
				time: "Test Runner 1 time",
				url: "Test Runner 1 url",
				victories: -1
			)
			# Checking value
			validate_joint_runner(expected_runner, selected_runner, "selection of runner")
			
			@logger.ok("Tests selection of Runner OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_trainer
		@logger.imp("Testing selection of Trainer")
		begin
			test_id = -1
			selected_trainer = @dbi_select.load_trainer_by_id(test_id)
			
			# Checking value
			assert_equal(test_id, 				selected_trainer.id)
			assert_equal("Test Trainer 1 name", selected_trainer.name)
			
			@logger.ok("Tests selection of Trainer OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_weather
		@logger.imp("Testing selection of Weather")
		begin
			test_id = -1
			selected_weather = @dbi_select.load_weather_by_id(test_id)
			
			# Checking value
			assert_equal(-1,							selected_weather.id)
			assert_equal(-1, 							selected_weather.temperature)
			assert_equal(-1,						 	selected_weather.wind_speed)
			assert_equal("Test Weather 1 insolation", 	selected_weather.insolation)
			
			# Nested value : wind_direction
			assert_equal(-1, 				selected_weather.wind_direction.id)
			assert_equal("Test Direction", 	selected_weather.wind_direction.text)
			
			@logger.ok("Tests selection of Weather OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_select_weight
		@logger.imp("Testing selection of Weight")
		begin
			test_id = -1
			selected_weight = @dbi_select.load_weight_by_id(test_id)
			
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
			assert_equal("Test Race 1 general conditions", selected_weight.forecast.race.general_conditions)
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
			
			@logger.ok("Tests selection of Weight OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
end