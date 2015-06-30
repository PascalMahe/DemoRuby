require 'date'
require './TestSuite.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class TestDatabaseInterfaceInsert < TestSuite
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi = $globalState.dbi
		if(@ref_list_hash == nil) then 
			@ref_list_hash = @dbi.load_all_refs
		end
		
		@logger.level = SimpleHtmlLogger::ERROR
	end
	
	##################
	#      Tests     #
	##################
	def test_insert_breeder
		
		@logger.info("Testing insertion of Breeder")
		begin
			# Counting Breeders in DB before insert
			
			old_breeder_num = @dbi.select_count_from_table(@config[:gen][:table_names][:breeder])
			
			breeder = Breeder::new
			breeder.name = "LYNN LODGE STUD"
			
			breeder.id = @dbi.insert_breeder(breeder)
			
			# Counting Breeders in DB after insert
			new_breeder_num = @dbi.select_count_from_table(@config[:gen][:table_names][:breeder])
			
			inserted_breeder = @dbi.load_breeder_by_id(breeder.id)
			assert_equal(breeder.name, inserted_breeder.name)
			assert_equal(old_breeder_num + 1, new_breeder_num)
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_forecast_with_matchrate
		@logger.info("Testing insertion of Forecast")
		begin
			# Counting number of Forecasts before test
			old_forecast_num = @dbi.select_count_from_table(@config[:gen][:table_names][:forecast])
			
			forecast = Forecast::new
			forecast.race = @dbi.load_race_by_id(-1)
			forecast.origin = @dbi.load_origin_by_id(-1)
			forecast.expected_result = "1 - 2 - 7 - 3 - 4"
			forecast.result_match_rate = 1045
			forecast.normalised_result_match_rate = 0.15
			
			forecast.id = @dbi.insert_forecast_with_matchrate(forecast)
			
			# Checking insert by value
			inserted_forecast = @dbi.load_forecast_by_id(forecast.id)
			assert_equal(forecast.race, inserted_forecast.race)
			assert_equal(forecast.origin, inserted_forecast.origin)
			assert_equal(forecast.expected_result, inserted_forecast.expected_result)
			assert_equal(forecast.result_match_rate, inserted_forecast.result_match_rate)
			assert_equal(forecast.normalised_result_match_rate, inserted_forecast.normalised_result_match_rate)
			
			# Counting number of RefDirection after test
			new_forecast_num = @dbi.select_count_from_table(@config[:gen][:table_names][:forecast])
			assert_equal(old_forecast_num + 1, new_forecast_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_forecast_without_matchrate
		@logger.info("Testing insertion of Forecast")
		begin
			# Counting number of Forecasts before test
			old_forecast_num = @dbi.select_count_from_table(@config[:gen][:table_names][:forecast])
			
			forecast = Forecast::new
			forecast.race = @dbi.load_race_by_id(-1)
			forecast.origin = @dbi.load_origin_by_id(-1)
			forecast.expected_result = "1 - 2 - 7 - 3 - 4"

			forecast.id = @dbi.insert_forecast_without_matchrate(forecast)
			
			# Checking insert by value
			inserted_forecast = @dbi.load_forecast_by_id(forecast.id)
			assert_equal(forecast.race, inserted_forecast.race)
			assert_equal(forecast.origin, inserted_forecast.origin)
			assert_equal(forecast.expected_result, inserted_forecast.expected_result)
			assert_equal(nil, inserted_forecast.result_match_rate)
			assert_equal(nil, inserted_forecast.normalised_result_match_rate)
			
			# Counting number of RefDirection after test
			new_forecast_num = @dbi.select_count_from_table(@config[:gen][:table_names][:forecast])
			assert_equal(old_forecast_num + 1, new_forecast_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_horse
		@logger.info("Testing insertion of Horse")
		begin
			# Counting number of Horses before test
			old_horse_num = @dbi.select_count_from_table(@config[:gen][:table_names][:horse])
			
			horse = Horse::new
			horse.sex = @ref_list_hash[:ref_sex_list]["M"]
			horse.breed = @ref_list_hash[:ref_breed_list]["Pur-sang"]
			horse.coat = @ref_list_hash[:ref_coat_list]["gris"]
			horse.name = "SILVER TREASURE"
			horse.id = @dbi.insert_horse(horse)
			
			# Checking insert by value
			inserted_horse = @dbi.load_horse_by_id(horse.id)
			assert_equal(horse.sex, inserted_horse.sex)
			assert_equal(horse.breed, inserted_horse.breed)
			assert_equal(horse.coat, inserted_horse.coat)
			assert_equal(horse.name, inserted_horse.name)
			
			# Counting number of RefDirection after test
			new_horse_num = @dbi.select_count_from_table(@config[:gen][:table_names][:horse])
			assert_equal(old_horse_num + 1, new_horse_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_job
		@logger.level = SimpleHtmlLogger::DEBUG
		@logger.info("Testing insertion of Job")
		begin
			# Counting number of Jobs before test
			old_job_num = @dbi.select_count_from_table(@config[:gen][:table_names][:job])
			
			job = Job::new
			job.start_time = DateTime.now
			job.loading_end_time = DateTime.now
			job.crawling_end_time = DateTime.now
			job.computing_end_time = DateTime.now

			@dbi.insert_job(job)
			
			# Checking insert by value
			selected_job = @dbi.load_job_by_id(job.id)
			
			# DEBUGGING
			strFirstMessage = ""
			@logger.debug("Created job's start time : " + job.start_time.to_s + ", it's a : " + job.start_time.class.name)
			# job.start_time.class.name = Time
			# => Fixed by assigning it to DateTime.now rather than Time.now 
			# (NB: DateTime is not loaded by default, needs : require 'Date')
			@logger.debug("Fetched job's start time : " + selected_job.start_time.to_s + ", it's a : " + selected_job.start_time.class.name)
			# selected_job.start_time.class.name = DateTime
			
			assert_equal(
				job.start_time.strftime(@config[:gen][:default_date_time_format]), 
				selected_job.start_time.strftime(@config[:gen][:default_date_time_format]))
			assert_equal(
				job.loading_end_time.strftime(@config[:gen][:default_date_time_format]), 
				selected_job.loading_end_time.strftime(@config[:gen][:default_date_time_format]))
			assert_equal(
				job.crawling_end_time.strftime(@config[:gen][:default_date_time_format]), 
				selected_job.crawling_end_time.strftime(@config[:gen][:default_date_time_format]))
			assert_equal(
				job.computing_end_time.strftime(@config[:gen][:default_date_time_format]), 
				selected_job.computing_end_time.strftime(@config[:gen][:default_date_time_format]))
			
			# Counting number of RefDirection after test
			new_job_num = @dbi.select_count_from_table(@config[:gen][:table_names][:job])
			assert_equal(old_job_num + 1, new_job_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_jockey
		@logger.info("Testing insertion of Jockey")
		begin
			# Counting number of Jockeys before test
			old_jockey_num = @dbi.select_count_from_table(@config[:gen][:table_names][:jockey])
			
			jockey = Jockey::new
			jockey.jacket = "/turf/casaques/31102013/petites-casaques-course/1/4.png*-60px"
			jockey.name = "c.soumillon"
			jockey.id = @dbi.insert_jockey(jockey)
			
			# Checking insert by value
			inserted_jockey = @dbi.load_jockey_by_id(jockey.id)
			assert_equal(jockey.name, inserted_jockey.name)
			assert_equal(jockey.jacket, inserted_jockey.jacket)
			
			# Counting number of RefDirection after test
			new_jockey_num = @dbi.select_count_from_table(@config[:gen][:table_names][:jockey])
			assert_equal(old_jockey_num + 1, new_jockey_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end

	def test_insert_meeting
		@logger.info("Testing insertion of Meeting")
		
		begin
			# Counting number of Meetings before test
			old_meeting_num = @dbi.select_count_from_table(@config[:gen][:table_names][:meeting])
			
			job = @dbi.load_job_by_id(-1)
			track_condition = @ref_list_hash[:ref_track_condition_list]["Terrain bon"]
			country = "BEL"
			date = Time.now
			racetrack = "Auteuil"
			number = 11
			urls_of_races_array = []
			
			meeting = Meeting::new(country: country, 
						date: date, 
						job: job, 
						number: number, 
						racetrack: racetrack, 
						urls_of_races_array: urls_of_races_array, 
						track_condition: track_condition)

			@dbi.insert_meeting(meeting)

			# Checking insert by value
			selected_meeting = @dbi.load_meeting_by_id(meeting.id)
			assert_equal(meeting.country, selected_meeting.country)
			assert_equal(meeting.job, selected_meeting.job)
			assert_equal(meeting.track_condition, selected_meeting.track_condition)
			assert_equal(
				meeting.date.strftime(@config[:gen][:default_date_format]), 
				selected_meeting.date.strftime(@config[:gen][:default_date_format])
			)
			assert_equal(meeting.racetrack, selected_meeting.racetrack)
			assert_equal(meeting.number, selected_meeting.number)
			assert_equal(meeting.urls_of_races_array, [])
			
			# Counting number of RefDirection after test
			new_meeting_num = @dbi.select_count_from_table(@config[:gen][:table_names][:meeting])
			assert_equal(old_meeting_num + 1, new_meeting_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_origin
		@logger.info("Testing insertion of Origin")
		begin
			# Counting number of Origins before test
			old_origin_num = @dbi.select_count_from_table(@config[:gen][:table_names][:origin])
			
			origin = Origin::new
			origin.name = "Single Rating"
			origin.column_order = "single_rating"
			origin.url = "http://www.pmu.fr/turf/index.html#/turf/30102013/reunion-1-PARIS_VINCENNES/pronostics.html"

			origin.id = @dbi.insert_origin(origin)
			
			# Checking insert by value
			insert_origin = @dbi.load_origin_by_id(origin.id)
			assert_equal(origin.name, insert_origin.name)
			assert_equal(origin.column_order, insert_origin.column_order)
			assert_equal(origin.url, insert_origin.url)
			
			# Counting number of RefDirection after test
			new_origin_num = @dbi.select_count_from_table(@config[:gen][:table_names][:origin])
			assert_equal(old_origin_num + 1, new_origin_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_owner
		@logger.info("Testing insertion of Owner")
		begin
			# Counting number of Owners before test
			old_owner_num = @dbi.select_count_from_table(@config[:gen][:table_names][:owner])
			
			owner = Owner::new
			owner.name = "MLLE A.WEAVER"

			owner.id = @dbi.insert_owner(owner)
			
			# Checking insert by value
			insert_owner = @dbi.load_owner_by_id(owner.id)
			assert_equal(owner.name, insert_owner.name)
			
			# Counting number of RefDirection after test
			new_owner_num = @dbi.select_count_from_table(@config[:gen][:table_names][:owner])
			assert_equal(old_owner_num + 1, new_owner_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_race_with_result
		@logger.info("Testing insertion of Race")
		
		begin
			# Counting number of Races before test
			old_race_num = @dbi.select_count_from_table(@config[:gen][:table_names][:race])
			
			bets = 143010
			
			detailed_conditions = "PRIX SECF Course 02 Départ à l'Autostart 7.200 - Attelé. - 2850 mètres. 3.000, 1.500, 720, 480, 300. et 1.200 au fonds d'élevage. Pour 5 à 6 ans n'ayant pas gagné 28.000."
			distance = 2850
			meeting = @dbi.load_meeting_by_id(-1)
			name = "ALL TO COME MAIDEN JUVENILE PLATE"
			number = 2
			race_type = @ref_list_hash[:ref_race_type_list]["Haies course à conditions"]
			result = "1 - 2 - 3 - 4 - 5"
			result_insertion_time = DateTime.now
			time = "11h45"
			url = "http://www.pmu.fr/turf/15102013/reunion-4-MONS__28GHLIN_29/index.html#/turf/15102013/reunion-4-MONS__28GHLIN_29/course-2-SECF.html"
			value = 7200
			
			race = Race::new(
					bets: bets,
					detailed_conditions: detailed_conditions, 
					distance: distance, 
					meeting: meeting, 
					name: name, 
					number: number, 
					race_type: race_type, 
					result: result,
					result_insertion_time: result_insertion_time,
					time: time, 
					url: url, 
					value: value
			)
			
			@dbi.insert_race_with_result(race)

			# Checking insert by value
			selected_race = @dbi.load_race_by_id(race.id)

			assert_equal(race.bets, 				selected_race.bets)
			assert_equal(race.detailed_conditions, 	selected_race.detailed_conditions)
			assert_equal(race.distance, 			selected_race.distance)
			assert_equal(race.meeting, 				selected_race.meeting)
			assert_equal(race.name, 				selected_race.name)
			assert_equal(race.number, 				selected_race.number)
			assert_equal(race.race_type, 			selected_race.race_type)
			assert_equal(race.result, 				selected_race.result)

			assert_equal(
				race.result_insertion_time.strftime(@config[:gen][:default_date_time_format]), 
				selected_race.result_insertion_time.strftime(@config[:gen][:default_date_time_format])
			)
			assert_equal(race.time, 	selected_race.time)
			assert_equal(race.url,		selected_race.url)
			assert_equal(race.value, 	selected_race.value)
			
			# Counting number of RefDirection after test
			new_race_num = @dbi.select_count_from_table(@config[:gen][:table_names][:race])
			assert_equal(old_race_num + 1, new_race_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_race_without_result
		@logger.info("Testing insertion of Race")
		
		begin
			# Counting number of Races before test
			old_race_num = @dbi.select_count_from_table(@config[:gen][:table_names][:race])
			
			bets = 143010
			detailed_conditions = "PRIX SECF Course 02 Départ à l'Autostart 7.200 - Attelé. - 2850 mètres. 3.000, 1.500, 720, 480, 300. et 1.200 au fonds d'élevage. Pour 5 à 6 ans n'ayant pas gagné 28.000."
			distance = 2850
			meeting = @dbi.load_meeting_by_id(-1)
			name = "ALL TO COME MAIDEN JUVENILE PLATE"
			number = 2
			race_type = @ref_list_hash[:ref_race_type_list]["Haies course à conditions"]
			time = "11h45"
			url = "http://www.pmu.fr/turf/15102013/reunion-4-MONS__28GHLIN_29/index.html#/turf/15102013/reunion-4-MONS__28GHLIN_29/course-2-SECF.html"
			value = 7200
			
			race = Race::new(
					bets: bets,
					detailed_conditions: detailed_conditions, 
					distance: distance, 
					meeting: meeting, 
					name: name, 
					number: number, 
					race_type: race_type, 
					time: time, 
					url: url, 
					value: value)
			
			@dbi.insert_race_without_result(race)

			# Checking insert by value
			selected_race = @dbi.load_race_by_id(race.id)
			
			assert_equal(race.bets, 				selected_race.bets)
			assert_equal(race.detailed_conditions, 	selected_race.detailed_conditions)
			assert_equal(race.distance, 			selected_race.distance)
			assert_equal(race.meeting, 				selected_race.meeting)
			assert_equal(race.name, 				selected_race.name)
			assert_equal(race.number, 				selected_race.number)
			assert_equal(race.race_type, 			selected_race.race_type)
			assert_equal(nil, 						selected_race.result)
			assert_equal(nil, 						selected_race.result_insertion_time)
			assert_equal(race.time, 				selected_race.time)
			assert_equal(race.url, 					selected_race.url)
			assert_equal(race.value, 				selected_race.value)
			
			# Counting number of RefDirection after test
			new_race_num = @dbi.select_count_from_table(@config[:gen][:table_names][:race])
			assert_equal(old_race_num + 1, new_race_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.level = SimpleHtmlLogger::INFO
	end
	
	def test_insert_ref_objects
		@logger.info("Testing insertion of RefObjects")
		begin
			##### REF DIRECTION #####
			# Counting number of RefDirection before test
			old_ref_direction_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_direction])
			
			@dbi.insert_ref_direction(RefDirection::new("", "test1"))
			
			# Counting number of RefDirection after test
			new_ref_direction_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_direction])
			assert_equal(old_ref_direction_num + 1, new_ref_direction_num)
			
			
			##### REF TRACK CONDITION #####
			# Counting number of RefTrackCondition before test
			old_ref_track_condition_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_track_condition])
			
			@dbi.insert_ref_track_condition(RefTrackCondition::new("", "test1"))

			# Counting number of RefTrackCondition after test
			new_ref_track_condition_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_track_condition])
			assert_equal(old_ref_track_condition_num + 1, new_ref_track_condition_num)
			
			##### REF RACE TYPE #####
			# Counting number of RefRaceType before test
			old_ref_race_type_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_race_type])
			
			@dbi.insert_ref_race_type(RefRaceType::new("", "test1"))
			
			# Counting number of RefRaceType after test
			new_ref_race_type_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_race_type])
			assert_equal(old_ref_race_type_num + 1, new_ref_race_type_num)
			
			
			##### REF COLUMN #####
			# Counting number of RefColumn before test
			old_ref_column_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_column])
			
			@dbi.insert_ref_column(RefColumn::new("", "test1"))
			
			# Counting number of RefColumn after test
			new_ref_column_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_column])
			assert_equal(old_ref_column_num + 1, new_ref_column_num)
			
			##### REF SEX #####
			# Counting number of RefSex before test
			old_ref_sex_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_sex])
			
			@dbi.insert_ref_sex(RefSex::new("", "test1"))
			
			# Counting number of RefSex after test
			new_ref_sex_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_sex])
			assert_equal(old_ref_sex_num + 1, new_ref_sex_num)
			
			
			##### REF BREED #####
			# Counting number of RefBreed before test
			old_ref_breed_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_breed])
			
			@dbi.insert_ref_breed(RefBreed::new("", "test1"))
			
			# Counting number of RefBreed after test
			new_ref_breed_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_breed])
			assert_equal(old_ref_breed_num + 1, new_ref_breed_num)
			
			
			##### REF COAT #####
			# Counting number of RefCoat before test
			old_ref_coat_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_coat])
						
			@dbi.insert_ref_coat(RefCoat::new("", "test1"))
			
			# Counting number of RefCoat after test
			new_ref_coat_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_coat])
			assert_equal(old_ref_coat_num + 1, new_ref_coat_num)
			
			
			##### REF BLINDER #####
			# Counting number of RefBlinder before test
			old_ref_blinder_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_blinder])
						
			@dbi.insert_ref_blinder(RefBlinder::new("", "test1"))
			
			# Counting number of RefBlinder after test
			new_ref_blinder_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_blinder])
			assert_equal(old_ref_blinder_num + 1, new_ref_blinder_num)
			
			
			##### REF SHOES #####
			# Counting number of RefShoes before test
			old_ref_shoes_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_shoes])
						
			@dbi.insert_ref_shoes(RefShoes::new("", "test1"))
			
			# Counting number of RefShoes after test
			new_ref_shoes_num = @dbi.select_count_from_table(@config[:gen][:table_names][:ref_shoes])
			assert_equal(old_ref_shoes_num + 1, new_ref_shoes_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_runner_with_final_place
		@logger.info("Testing insertion of Runner")
		begin
			# Counting number of runners before test
			old_runner_num = @dbi.select_count_from_table(@config[:gen][:table_names][:runner])
			
			runner = Runner::new(
				breeder: @dbi.load_breeder_by_id(-1),
				blinder: @ref_list_hash[:ref_blinder_list]["http://ressources0.pmu.fr/turf/cb3590072752/img/design/oeillere.gif"],
				earnings_career: 355958,
				earnings_current_year: 55600,
				earnings_last_year: 231858,
				earnings_victory: 340358,
				description: "Décevant dans la course de référence, il serait dangereux de l'écarter totalement. Une place est à sa portée. Par Gianni Caggiula, Equidia.",
				distance: 7200,
				draw: 5,
				final_place: 1,
				history: "2p 5p 2p 0p 1p 2p 6p 0p 3p 7p ",
				horse: @dbi.load_horse_by_id(-1),
				jockey: @dbi.load_jockey_by_id(-1),
				load: 58.5,
				non_runner: 0,
				number: 1,
				places: 2,
				owner: @dbi.load_owner_by_id(-1),
				race: @dbi.load_race_by_id(-1),
				races_run: 10,
				shoes: @ref_list_hash[:ref_shoes_list]["http://ressources0.pmu.fr/turf/cb603952032/img/pictos_courses/defer/Da.gif"],
				single_rating: 9.7,
				trainer: @dbi.load_trainer_by_id(-1),
				url: "/turf/01112013/reunion-1-SAINT_CLOUD/course-8-DU_CHAROLAIS/partant-6-ROSEAL_DES_BOIS/index.html",
				victories: 6,
			)
			@dbi.insert_runner_with_final_place(runner)

			# Checking by value
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
			assert_equal(runner.final_place, selected_runner.final_place)
			
			# Counting the number of weights after insertion
			new_runner_num = @dbi.select_count_from_table(@config[:gen][:table_names][:runner])
			assert_equal(old_runner_num + 1, new_runner_num)
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end

	def test_insert_runner_without_final_place
		@logger.info("Testing insertion of Runner")
		begin
			# Counting number of runners before test
			old_runner_num = @dbi.select_count_from_table(@config[:gen][:table_names][:runner])
			
			runner = Runner::new(
				breeder: @dbi.load_breeder_by_id(-1),
				blinder: @ref_list_hash[:ref_blinder_list]["http://ressources0.pmu.fr/turf/cb3590072752/img/design/oeillere.gif"],
				earnings_career: 355958,
				earnings_current_year: 55600,
				earnings_last_year: 231858,
				earnings_victory: 340358,
				description: "Décevant dans la course de référence, il serait dangereux de l'écarter totalement. Une place est à sa portée. Par Gianni Caggiula, Equidia.",
				distance: 7200,
				draw: 5,
				history: "2p 5p 2p 0p 1p 2p 6p 0p 3p 7p ",
				horse: @dbi.load_horse_by_id(-1),
				jockey: @dbi.load_jockey_by_id(-1),
				load: 58.5,
				non_runner: 0,
				number: 1,
				places: 2,
				owner: @dbi.load_owner_by_id(-1),
				race: @dbi.load_race_by_id(-1),
				races_run: 10,
				shoes: @ref_list_hash[:ref_shoes_list]["http://ressources0.pmu.fr/turf/cb603952032/img/pictos_courses/defer/Da.gif"],
				single_rating: 9.7,
				trainer: @dbi.load_trainer_by_id(-1),
				url: "/turf/01112013/reunion-1-SAINT_CLOUD/course-8-DU_CHAROLAIS/partant-6-ROSEAL_DES_BOIS/index.html",
				victories: 6,
			)
			@dbi.insert_runner_without_final_place(runner)

			# Checking by value
			selected_runner = @dbi.load_runner_by_id(runner.id)
			
			assert_equal(runner.blinder, 				selected_runner.blinder)
			assert_equal(runner.breeder, 				selected_runner.breeder)
			assert_equal(runner.description, 			selected_runner.description)
			assert_equal(runner.distance, 				selected_runner.distance)
			assert_equal(runner.draw, 					selected_runner.draw)
			assert_equal(runner.earnings_career, 		selected_runner.earnings_career)
			assert_equal(runner.earnings_current_year, 	selected_runner.earnings_current_year)
			assert_equal(runner.earnings_last_year, 	selected_runner.earnings_last_year)
			assert_equal(runner.earnings_victory, 		selected_runner.earnings_victory)
			assert_equal(runner.history, 				selected_runner.history)
			assert_equal(runner.horse, 					selected_runner.horse)
			assert_equal(runner.jockey, 				selected_runner.jockey)
			assert_equal(runner.load, 					selected_runner.load)
			assert_equal(runner.non_runner, 			selected_runner.non_runner)
			assert_equal(runner.number, 				selected_runner.number)
			assert_equal(runner.owner, 					selected_runner.owner)
			assert_equal(runner.places, 				selected_runner.places)
			assert_equal(runner.race, 					selected_runner.race)
			assert_equal(runner.races_run, 				selected_runner.races_run)
			assert_equal(runner.shoes, 					selected_runner.shoes)
			assert_equal(runner.single_rating, 			selected_runner.single_rating)
			assert_equal(runner.trainer, 				selected_runner.trainer)
			assert_equal(runner.url, 					selected_runner.url)
			assert_equal(runner.victories, 				selected_runner.victories)
			
			# Counting the number of weights after insertion
			new_runner_num = @dbi.select_count_from_table(@config[:gen][:table_names][:runner])
			assert_equal(old_runner_num + 1, new_runner_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_trainer
		@logger.info("Testing insertion of Trainer")
		begin
			# Counting number of weathers before test
			old_trainer_num = @dbi.select_count_from_table(@config[:gen][:table_names][:trainer])
			
			trainer = Trainer::new
			trainer.name = "R.CHOTARD"

			@dbi.insert_trainer(trainer)
			
			# Checking insertion by value
			selected_trainer = @dbi.load_trainer_by_id(trainer.id)
			assert_equal(trainer.name, selected_trainer.name)
			
			# Counting the number of weights after insertion
			new_trainer_num = @dbi.select_count_from_table(@config[:gen][:table_names][:trainer])
			assert_equal(old_trainer_num + 1, new_trainer_num)
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
		end
	end
	
	def test_insert_weather
		@logger.info("Testing insertion of Weather")
		begin
			# Counting number of weathers before test
			old_weather_num = @dbi.select_count_from_table(@config[:gen][:table_names][:weather])
			
			weather = Weather::new(
				insolation: "P6.png",
				temperature: 19,
				wind_direction: @ref_list_hash[:ref_direction_list]["S"],
				wind_speed: 11
				)

			@dbi.insert_weather(weather)

			# Checking insertion by value
			selected_weather = @dbi.load_weather_by_id(weather.id)

			assert_equal(weather.wind_direction, selected_weather.wind_direction)
			assert_equal(weather.temperature, selected_weather.temperature)
			assert_equal(weather.wind_speed, selected_weather.wind_speed)
			assert_equal(weather.insolation, selected_weather.insolation)
			
			# Counting the number of weights after insertion
			new_weather_num = @dbi.select_count_from_table(@config[:gen][:table_names][:weather])
			assert_equal(old_weather_num + 1, new_weather_num)
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_insert_weight
		@logger.info("Testing insertion of Weight")
		begin
			# Counting number of weights before test
			old_weight_num = @dbi.select_count_from_table(@config[:gen][:table_names][:weight])
			
			# Insertion test
			weight = Weight::new
			weight.forecast = @dbi.load_forecast_by_id(-1)
			weight.name = "flLfD"
			weight.value = 11

			@dbi.insert_weight(weight)

			# Checking insertion by value
			inserted_weight = @dbi.load_weight_by_id(weight.id)
						
			assert_equal(weight.forecast, inserted_weight.forecast)
			assert_equal(weight.name, inserted_weight.name)
			assert_equal(weight.value, inserted_weight.value)
			
			# Counting the number of weights after insertion
			new_weight_num = @dbi.select_count_from_table(@config[:gen][:table_names][:weight])
			assert_equal(old_weight_num + 1, new_weight_num)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
end