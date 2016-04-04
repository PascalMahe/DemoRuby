require 'date'
require './TestSuite.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
require './validation-core.rb'

class TestDatabaseInterfaceInsert < TestSuite
	
	def setup
		testSetup()
	end
	
	##################
	#      Tests     #
	##################
	def test_insert_breeder
		
		@logger.imp("Testing insertion of Breeder")
		begin
			# Counting Breeders in DB before insert
			
			old_breeder_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:breeder])
			
			breeder = Breeder::new
			breeder.name = "LYNN LODGE STUD"
			
			breeder.id = @dbi_insert.insert_breeder(breeder)
			
			# Counting Breeders in DB after insert
			new_breeder_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:breeder])
			
			inserted_breeder = @dbi_select_tech.load_breeder_by_id(breeder.id)
			assert_equal(breeder.name, inserted_breeder.name)
			assert_equal(old_breeder_num + 1, new_breeder_num)
			
			@logger.ok("Tests for insertion of Breeder OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_forecast_with_matchrate
		@logger.imp("Testing insertion of Forecast")
		begin
			# Counting number of Forecasts before test
			old_forecast_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:forecast])
			
			forecast = Forecast::new
			forecast.race = @dbi_select_tech.load_race_by_id(-1)
			forecast.origin = @dbi_select_tech.load_origin_by_id(-1)
			forecast.expected_result = "1 - 2 - 7 - 3 - 4"
			forecast.result_match_rate = 1045
			forecast.normalised_result_match_rate = 0.15
			
			forecast.id = @dbi_insert.insert_forecast_with_matchrate(forecast)
			
			# Checking insert by value
			inserted_forecast = @dbi_select_tech.load_forecast_by_id(forecast.id)
			assert_equal(forecast.race, inserted_forecast.race)
			assert_equal(forecast.origin, inserted_forecast.origin)
			assert_equal(forecast.expected_result, inserted_forecast.expected_result)
			assert_equal(forecast.result_match_rate, inserted_forecast.result_match_rate)
			assert_equal(forecast.normalised_result_match_rate, inserted_forecast.normalised_result_match_rate)
			
			# Counting number of RefDirection after test
			new_forecast_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:forecast])
			assert_equal(old_forecast_num + 1, new_forecast_num)
			
			@logger.ok("Tests for insertion of Forecast OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_forecast_without_matchrate
		@logger.imp("Testing insertion of Forecast (without matchrate)")
		begin
			# Counting number of Forecasts before test
			old_forecast_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:forecast])
			
			forecast = Forecast::new
			forecast.race = @dbi_select_tech.load_race_by_id(-1)
			forecast.origin = @dbi_select_tech.load_origin_by_id(-1)
			forecast.expected_result = "1 - 2 - 7 - 3 - 4"

			forecast.id = @dbi_insert.insert_forecast_without_matchrate(forecast)
			
			# Checking insert by value
			inserted_forecast = @dbi_select_tech.load_forecast_by_id(forecast.id)
			assert_equal(forecast.race, inserted_forecast.race)
			assert_equal(forecast.origin, inserted_forecast.origin)
			assert_equal(forecast.expected_result, inserted_forecast.expected_result)
			assert_equal(nil, inserted_forecast.result_match_rate)
			assert_equal(nil, inserted_forecast.normalised_result_match_rate)
			
			# Counting number of RefDirection after test
			new_forecast_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:forecast])
			assert_equal(old_forecast_num + 1, new_forecast_num)

			@logger.ok("Tests for insertion of Forecast (without matchrate) OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_horse
		@logger.imp("Testing insertion of Horse")
		begin
			# Counting number of Horses before test
			old_horse_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:horse])
			
			horse = Horse::new(
				breed: @ref_list_hash[:ref_breed_list]["Pur-sang"],
				coat: @ref_list_hash[:ref_coat_list]["gris"],
				father: Horse::new(id: -2),
				mother: Horse::new(id: -3),
				name: "SILVER TREASURE",
				sex: @ref_list_hash[:ref_sex_list]["M"]
			)
			
			@logger.debug("test_insert_horse - horse.father.id : " + horse.father.id.to_s)
			@logger.debug("test_insert_horse - horse.mother.id : " + horse.mother.id.to_s)
			
			horse.id = @dbi_insert.insert_horse(horse)
			
			# Checking insert by value
			inserted_horse = @dbi_select_tech.load_horse_by_id(horse.id)
			assert_equal(horse.breed, inserted_horse.breed)
			assert_equal(horse.coat, inserted_horse.coat)
			assert_equal(horse.name, inserted_horse.name)
			assert_equal(horse.sex, inserted_horse.sex)
			
			# father
			expected_father = Horse::new(
				breed: @ref_list_hash[:ref_breed_list]["Test Breed"],
				coat: @ref_list_hash[:ref_coat_list]["Test Coat"],
				id: -2,
				father: nil,
				mother: nil,
				name: "Test Father name",
				sex: @ref_list_hash[:ref_sex_list]["Test Sex"]
			)
			assert_equal(expected_father, inserted_horse.father)
			
			# mother
			expected_mother = Horse::new(
				breed: @ref_list_hash[:ref_breed_list]["Test Breed"],
				coat: @ref_list_hash[:ref_coat_list]["Test Coat"],
				id: -3,
				father: nil,
				mother: nil,
				name: "Test Mother name",
				sex: @ref_list_hash[:ref_sex_list]["Test Sex"]
			)
			assert_equal(expected_mother, inserted_horse.mother)
			
			# Counting number of Horses after test
			new_horse_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:horse])
			assert_equal(old_horse_num + 1, new_horse_num)
			
			@logger.ok("Tests for insertion of Horse OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_job
		@logger.imp("Testing insertion of Job")
		begin
			# Counting number of Jobs before test
			old_job_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:job])
			
			job = Job::new
			job.start_time = DateTime.now
			job.loading_end_time = DateTime.now
			job.crawling_end_time = DateTime.now
			job.computing_end_time = DateTime.now

			@dbi_insert.insert_job(job)
			
			# Checking insert by value
			selected_job = @dbi_select_tech.load_job_by_id(job.id)
			
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
			
			# Counting number of Job after test
			new_job_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:job])
			assert_equal(old_job_num + 1, new_job_num)
			
			@logger.ok("Tests for insertion of Job OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_jockey
		@logger.imp("Testing insertion of Jockey")
		begin
			# Counting number of Jockeys before test
			old_jockey_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:jockey])
			
			jockey = Jockey::new
			jockey.jacket = "/turf/casaques/31102013/petites-casaques-course/1/4.png*-60px"
			jockey.name = "c.soumillon"
			jockey.id = @dbi_insert.insert_jockey(jockey)
			
			# Checking insert by value
			inserted_jockey = @dbi_select_tech.load_jockey_by_id(jockey.id)
			assert_equal(jockey.name, inserted_jockey.name)
			assert_equal(jockey.jacket, inserted_jockey.jacket)
			
			# Counting number of RefDirection after test
			new_jockey_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:jockey])
			assert_equal(old_jockey_num + 1, new_jockey_num)
			
			@logger.ok("Tests for insertion of Jockey OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end

	def test_insert_meeting
		@logger.imp("Testing insertion of Meeting")
		
		begin
			# Counting number of Meetings before test
			old_meeting_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:meeting])
			
			country = "BEL"
			date = Time.now
			job = @dbi_select_tech.load_job_by_id(-1)
			number = 11
			racetrack = "Auteuil"
			track_condition = @ref_list_hash[:ref_track_condition_list]["Terrain bon"]
			urls_of_races_array = []
			weather = Weather::new(id: -1)
			
			meeting = Meeting::new(country: country, 
									date: date, 
									job: job, 
									number: number, 
									racetrack: racetrack, 
									urls_of_races_array: urls_of_races_array, 
									track_condition: track_condition,
									weather: weather)

			@dbi_insert.insert_meeting(meeting)

			# Checking insert by value
			selected_meeting = @dbi_select_tech.load_meeting_by_id(meeting.id)
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
			
			# weather
			expected_weather = Weather::new(id: -1,
											insolation: "Test Weather 1 insolation",
											temperature: -1,
											wind_direction: @ref_list_hash[:ref_direction_list]["Test Direction"],
											wind_speed: -1)
			
			assert_equal(expected_weather, selected_meeting.weather)
			
			# Counting number of Meetings after test
			new_meeting_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:meeting])
			assert_equal(old_meeting_num + 1, new_meeting_num)
			
			@logger.ok("Tests for insertion of Meeting OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_origin
		@logger.imp("Testing insertion of Origin")
		begin
			# Counting number of Origins before test
			old_origin_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:origin])
			
			origin = Origin::new
			origin.name = "Single Rating"
			origin.column_order = "single_rating"
			origin.url = "http://www.pmu.fr/turf/index.html#/turf/30102013/reunion-1-PARIS_VINCENNES/pronostics.html"

			origin.id = @dbi_insert.insert_origin(origin)
			
			# Checking insert by value
			insert_origin = @dbi_select_tech.load_origin_by_id(origin.id)
			assert_equal(origin.name, insert_origin.name)
			assert_equal(origin.column_order, insert_origin.column_order)
			assert_equal(origin.url, insert_origin.url)
			
			# Counting number of Origin after test
			new_origin_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:origin])
			assert_equal(old_origin_num + 1, new_origin_num)
			
			@logger.ok("Tests for insertion of Origin OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_owner
		@logger.imp("Testing insertion of Owner")
		begin
			# Counting number of Owners before test
			old_owner_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:owner])
			
			owner = Owner::new
			owner.name = "MLLE A.WEAVER"

			owner.id = @dbi_insert.insert_owner(owner)
			
			# Checking insert by value
			insert_owner = @dbi_select_tech.load_owner_by_id(owner.id)
			assert_equal(owner.name, insert_owner.name)
			
			# Counting number of Owner after test
			new_owner_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:owner])
			assert_equal(old_owner_num + 1, new_owner_num)
			
			@logger.ok("Tests for insertion of Owner OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_race_with_result
		@logger.imp("Testing insertion of Race")
		begin
			# Counting number of Races before test
			old_race_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:race])
			
			bets = 143010
			detailed_conditions = "PRIX SECF Course 02 Départ à l'Autostart 7.200 - Attelé. - 2850 mètres. 3.000, 1.500, 720, 480, 300. et 1.200 au fonds d'élevage. Pour 5 à 6 ans n'ayant pas gagné 28.000."
			distance = 2850
			general_conditions = "Internationale - Autostart Corde à gauche"
			# meeting = @dbi_select_tech.load_meeting_by_id(-1)
			id_meeting = -1
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
					general_conditions: general_conditions,
					# meeting: meeting, 
					name: name, 
					number: number, 
					race_type: race_type, 
					result: result,
					result_insertion_time: result_insertion_time,
					time: time, 
					url: url, 
					value: value
			)
			
			@dbi_insert.insert_race_with_result(race, id_meeting)

			# Checking insert by value
			selected_race = @dbi_select_tech.load_race_by_id(race.id)

			assert_equal(race.bets, 				selected_race.bets)
			assert_equal(race.detailed_conditions, 	selected_race.detailed_conditions)
			assert_equal(race.distance, 			selected_race.distance)
			assert_equal(race.general_conditions, 	selected_race.general_conditions)
			# assert_equal(race.meeting, 				selected_race.meeting)
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
			
			# Counting number of Race after test
			new_race_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:race])
			assert_equal(old_race_num + 1, new_race_num)
			
			@logger.ok("Tests for insertion of Race OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_race_without_result
		@logger.imp("Testing insertion of Race (without result)")
		
		begin
			@logger.level = SimpleHtmlLogger::DEBUG
			# Counting number of Races before test
			old_race_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:race])
			
			bets = 143010
			detailed_conditions = "PRIX SECF Course 02 Départ à l'Autostart 7.200 - Attelé. - 2850 mètres. 3.000, 1.500, 720, 480, 300. et 1.200 au fonds d'élevage. Pour 5 à 6 ans n'ayant pas gagné 28.000."
			distance = 2850
			general_conditions = "Internationale - Autostart Corde à gauche"
			# meeting = @dbi_select_tech.load_meeting_by_id(-1)
			id_meeting = -1
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
					general_conditions: general_conditions, 
					# meeting: meeting, 
					name: name, 
					number: number, 
					race_type: race_type, 
					time: time, 
					url: url, 
					value: value)
			
			@dbi_insert.insert_race_without_result(race, id_meeting)

			# Checking insert by value
			selected_race = @dbi_select_tech.load_race_by_id(race.id)
			
			validate_race(race, selected_race, "insertion of race")
			
			# Counting number of Races after test
			new_race_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:race])
			assert_equal(old_race_num + 1, new_race_num)
			
			@logger.ok("Tests for insertion of Race (without result) OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_ref_objects
		@logger.imp("Testing insertion of RefObjects")
		begin
			##### REF DIRECTION #####
			# Counting number of RefDirection before test
			old_ref_direction_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_direction])
			
			@dbi_insert.insert_ref_direction(RefDirection::new("", "test1"))
			
			# Counting number of RefDirection after test
			new_ref_direction_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_direction])
			assert_equal(old_ref_direction_num + 1, new_ref_direction_num)
			
			
			##### REF TRACK CONDITION #####
			# Counting number of RefTrackCondition before test
			old_ref_track_condition_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_track_condition])
			
			@dbi_insert.insert_ref_track_condition(RefTrackCondition::new("", "test1"))

			# Counting number of RefTrackCondition after test
			new_ref_track_condition_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_track_condition])
			assert_equal(old_ref_track_condition_num + 1, new_ref_track_condition_num)
			
			##### REF RACE TYPE #####
			# Counting number of RefRaceType before test
			old_ref_race_type_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_race_type])
			
			@dbi_insert.insert_ref_race_type(RefRaceType::new("", "test1"))
			
			# Counting number of RefRaceType after test
			new_ref_race_type_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_race_type])
			assert_equal(old_ref_race_type_num + 1, new_ref_race_type_num)
			
			
			##### REF COLUMN #####
			# Counting number of RefColumn before test
			old_ref_column_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_column])
			
			@dbi_insert.insert_ref_column(RefColumn::new("", "test1"))
			
			# Counting number of RefColumn after test
			new_ref_column_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_column])
			assert_equal(old_ref_column_num + 1, new_ref_column_num)
			
			##### REF SEX #####
			# Counting number of RefSex before test
			old_ref_sex_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_sex])
			
			@dbi_insert.insert_ref_sex(RefSex::new("", "test1"))
			
			# Counting number of RefSex after test
			new_ref_sex_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_sex])
			assert_equal(old_ref_sex_num + 1, new_ref_sex_num)
			
			
			##### REF BREED #####
			# Counting number of RefBreed before test
			old_ref_breed_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_breed])
			
			@dbi_insert.insert_ref_breed(RefBreed::new("", "test1"))
			
			# Counting number of RefBreed after test
			new_ref_breed_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_breed])
			assert_equal(old_ref_breed_num + 1, new_ref_breed_num)
			
			
			##### REF COAT #####
			# Counting number of RefCoat before test
			old_ref_coat_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_coat])
						
			@dbi_insert.insert_ref_coat(RefCoat::new("", "test1"))
			
			# Counting number of RefCoat after test
			new_ref_coat_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_coat])
			assert_equal(old_ref_coat_num + 1, new_ref_coat_num)
			
			
			##### REF BLINDER #####
			# Counting number of RefBlinder before test
			old_ref_blinder_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_blinder])
						
			@dbi_insert.insert_ref_blinder(RefBlinder::new("", "test1"))
			
			# Counting number of RefBlinder after test
			new_ref_blinder_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_blinder])
			assert_equal(old_ref_blinder_num + 1, new_ref_blinder_num)
			
			
			##### REF SHOES #####
			# Counting number of RefShoes before test
			old_ref_shoes_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_shoes])
						
			@dbi_insert.insert_ref_shoes(RefShoes::new("", "test1"))
			
			# Counting number of RefShoes after test
			new_ref_shoes_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:ref_shoes])
			assert_equal(old_ref_shoes_num + 1, new_ref_shoes_num)
			
			@logger.ok("Tests for insertion of RefObject OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_runner_after_race
		@logger.imp("Testing insertion of Runner (after race)")
		begin
			# Counting number of runners before test
			old_runner_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:runner])
			
			id_race = -1
			runner = Runner::new(
				blinder: @ref_list_hash[:ref_blinder_list]["http://ressources0.pmu.fr/turf/cb3590072752/img/design/oeillere.gif"],
				breeder: @dbi_select_tech.load_breeder_by_id(-1),
				horse: @dbi_select_tech.load_horse_by_id(-1),
				jockey: @dbi_select_tech.load_jockey_by_id(-1),
				owner: @dbi_select_tech.load_owner_by_id(-1),
				# race: @dbi_select_tech.load_race_by_id(-1),
				shoes: @ref_list_hash[:ref_shoes_list]["http://ressources0.pmu.fr/turf/cb603952032/img/pictos_courses/defer/Da.gif"],
				trainer: @dbi_select_tech.load_trainer_by_id(-1),
				age: 5,
				commentary: "Patient sur une troisième ligne, a débordé Närby Kalabalik (8) sur le fil.",
				description: "Décevant dans la course de référence, il serait dangereux de l'écarter totalement. Une place est à sa portée. Par Gianni Caggiula, Equidia.",
				distance: 7200,
				disqualified: false,
				draw: 5,
				earnings_career: 355958,
				earnings_current_year: 55600,
				earnings_last_year: 231858,
				earnings_victory: 340358,
				final_place: 1,
				history: "2p 5p 2p 0p 1p 2p 6p 0p 3p 7p ",
				is_favorite: true,
				is_non_runner: false,
				is_substitute: true,
				load_handicap: 58.5,
				load_ride: 12.4,
				number: 1,
				places: 2,
				races_run: 10,
				single_rating_after_race: 9.7,
				single_rating_before_race: 5.2,
				url: "/turf/01112013/reunion-1-SAINT_CLOUD/course-8-DU_CHAROLAIS/partant-6-ROSEAL_DES_BOIS/index.html",
				victories: 6
			)
			@dbi_insert.insert_runner_after_race(runner, id_race)

			# Checking by value
			selected_runner = @dbi_select_tech.load_runner_by_id(runner.id)

			assert_equal(runner.blinder, 					selected_runner.blinder)
			assert_equal(runner.breeder, 					selected_runner.breeder)
			assert_equal(runner.horse, 						selected_runner.horse)
			assert_equal(runner.jockey, 					selected_runner.jockey)
			assert_equal(runner.owner, 						selected_runner.owner)
			# assert_equal(runner.race, 						selected_runner.race)
			assert_equal(runner.shoes, 						selected_runner.shoes)
			assert_equal(runner.trainer, 					selected_runner.trainer)
			
			assert_equal(runner.age, 						selected_runner.age)
			assert_equal(runner.commentary, 				selected_runner.commentary)
			assert_equal(runner.description, 				selected_runner.description)
			assert_equal(runner.disqualified, 				selected_runner.disqualified)
			assert_equal(runner.distance,					selected_runner.distance)
			assert_equal(runner.draw, 						selected_runner.draw)
			assert_equal(runner.earnings_career, 			selected_runner.earnings_career)
			assert_equal(runner.earnings_current_year, 		selected_runner.earnings_current_year)
			assert_equal(runner.earnings_last_year, 		selected_runner.earnings_last_year)
			assert_equal(runner.earnings_victory, 			selected_runner.earnings_victory)
			assert_equal(runner.final_place, 				selected_runner.final_place)
			assert_equal(runner.history, 					selected_runner.history)
			assert_equal(runner.is_favorite, 				selected_runner.is_favorite)
			assert_equal(runner.is_non_runner, 				selected_runner.is_non_runner)
			assert_equal(runner.is_substitute, 				selected_runner.is_substitute)
			assert_equal(runner.load_handicap, 				selected_runner.load_handicap)
			assert_equal(runner.load_ride, 					selected_runner.load_ride)
			assert_equal(runner.number, 					selected_runner.number)
			assert_equal(runner.places,   					selected_runner.places)
			assert_equal(runner.races_run, 					selected_runner.races_run)
			assert_equal(runner.single_rating_after_race, 	selected_runner.single_rating_after_race)
			assert_equal(runner.single_rating_before_race, 	selected_runner.single_rating_before_race)
			assert_equal(runner.time, 						selected_runner.time)
			assert_equal(runner.url, 						selected_runner.url)
			assert_equal(runner.victories, 					selected_runner.victories)
			
			# Counting the number of weights after insertion
			new_runner_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:runner])
			assert_equal(old_runner_num + 1, new_runner_num)
			
			@logger.ok("Tests for insertion of Runner (after race) OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end

	def test_insert_runner_before_race
		# no final_place, disqualified or single_rating_after_race
		
		@logger.imp("Testing insertion of Runner")
		begin
			# Counting number of runners before test
			old_runner_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:runner])
			id_race = -1
			
			runner = Runner::new(
				blinder: @ref_list_hash[:ref_blinder_list]["http://ressources0.pmu.fr/turf/cb3590072752/img/design/oeillere.gif"],
				breeder: @dbi_select_tech.load_breeder_by_id(-1),
				horse: @dbi_select_tech.load_horse_by_id(-1),
				jockey: @dbi_select_tech.load_jockey_by_id(-1),
				owner: @dbi_select_tech.load_owner_by_id(-1),
				# race: @dbi_select_tech.load_race_by_id(-1),
				shoes: @ref_list_hash[:ref_shoes_list]["http://ressources0.pmu.fr/turf/cb603952032/img/pictos_courses/defer/Da.gif"],
				trainer: @dbi_select_tech.load_trainer_by_id(-1),
				age: 5,
				commentary: "Patient sur une troisième ligne, a débordé Närby Kalabalik (8) sur le fil.",
				description: "Décevant dans la course de référence, il serait dangereux de l'écarter totalement. Une place est à sa portée. Par Gianni Caggiula, Equidia.",
				distance: 7200,
				draw: 5,
				earnings_career: 355958,
				earnings_current_year: 55600,
				earnings_last_year: 231858,
				earnings_victory: 340358,
				history: "2p 5p 2p 0p 1p 2p 6p 0p 3p 7p ",
				is_favorite: true,
				is_non_runner: false,
				is_substitute: true,
				load_handicap: 58.5,
				load_ride: 12.4,
				number: 1,
				places: 2,
				races_run: 10,
				single_rating_before_race: 5.2,
				url: "/turf/01112013/reunion-1-SAINT_CLOUD/course-8-DU_CHAROLAIS/partant-6-ROSEAL_DES_BOIS/index.html",
				victories: 6
			)
			@dbi_insert.insert_runner_before_race(runner, id_race)

			# Checking by value
			selected_runner = @dbi_select_tech.load_runner_by_id(runner.id)
			
			assert_equal(runner.blinder, 					selected_runner.blinder)
			assert_equal(runner.breeder, 					selected_runner.breeder)
			assert_equal(runner.horse, 						selected_runner.horse)
			assert_equal(runner.jockey, 					selected_runner.jockey)
			assert_equal(runner.owner, 						selected_runner.owner)
			# assert_equal(runner.race, 						selected_runner.race)
			assert_equal(runner.shoes, 						selected_runner.shoes)
			assert_equal(runner.trainer, 					selected_runner.trainer)
			
			assert_equal(runner.age, 						selected_runner.age)
			assert_equal(runner.commentary, 				selected_runner.commentary)
			assert_equal(runner.description, 				selected_runner.description)
			assert_equal(runner.distance,					selected_runner.distance)
			assert_equal(runner.draw, 						selected_runner.draw)
			assert_equal(runner.earnings_career, 			selected_runner.earnings_career)
			assert_equal(runner.earnings_current_year, 		selected_runner.earnings_current_year)
			assert_equal(runner.earnings_last_year, 		selected_runner.earnings_last_year)
			assert_equal(runner.earnings_victory, 			selected_runner.earnings_victory)
			assert_equal(runner.history, 					selected_runner.history)
			assert_equal(runner.is_favorite, 				selected_runner.is_favorite)
			assert_equal(runner.is_non_runner, 				selected_runner.is_non_runner)
			assert_equal(runner.is_substitute, 				selected_runner.is_substitute)
			assert_equal(runner.load_handicap, 				selected_runner.load_handicap)
			assert_equal(runner.load_ride, 					selected_runner.load_ride)
			assert_equal(runner.number, 					selected_runner.number)
			assert_equal(runner.places,   					selected_runner.places)
			assert_equal(runner.races_run, 					selected_runner.races_run)
			assert_equal(runner.single_rating_before_race, 	selected_runner.single_rating_before_race)
			assert_equal(runner.time, 						selected_runner.time)
			assert_equal(runner.url, 						selected_runner.url)
			assert_equal(runner.victories, 					selected_runner.victories)
			
			# Counting the number of Runner after insertion
			new_runner_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:runner])
			assert_equal(old_runner_num + 1, new_runner_num)
			
			@logger.ok("Tests for insertion of Runner (before race) OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_trainer
		@logger.imp("Testing insertion of Trainer")
		begin
			# Counting number of Trainer before test
			old_trainer_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:trainer])
			
			trainer = Trainer::new
			trainer.name = "R.CHOTARD"

			@dbi_insert.insert_trainer(trainer)
			
			# Checking insertion by value
			selected_trainer = @dbi_select_tech.load_trainer_by_id(trainer.id)
			assert_equal(trainer.name, selected_trainer.name)
			
			# Counting the number of Trainer after insertion
			new_trainer_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:trainer])
			assert_equal(old_trainer_num + 1, new_trainer_num)
			
			@logger.ok("Tests for insertion of Trainer OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
		end
	end
	
	def test_insert_weather
		@logger.imp("Testing insertion of Weather")
		begin
			# Counting number of weathers before test
			old_weather_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:weather])
			
			weather = Weather::new(
				insolation: "P6.png",
				temperature: 19,
				wind_direction: @ref_list_hash[:ref_direction_list]["S"],
				wind_speed: 11
			)

			@dbi_insert.insert_weather(weather)

			# Checking insertion by value
			selected_weather = @dbi_select_tech.load_weather_by_id(weather.id)

			assert_equal(weather.wind_direction, selected_weather.wind_direction)
			assert_equal(weather.insolation, selected_weather.insolation)
			assert_equal(weather.temperature, selected_weather.temperature)
			assert_equal(weather.wind_speed, selected_weather.wind_speed)
			
			# Counting the number of Weather after insertion
			new_weather_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:weather])
			assert_equal(old_weather_num + 1, new_weather_num)
			
			@logger.ok("Tests for insertion of Weather OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_insert_weight
		@logger.imp("Testing insertion of Weight")
		begin
			# Counting number of weights before test
			old_weight_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:weight])
			
			# Insertion test
			weight = Weight::new
			weight.forecast = @dbi_select_tech.load_forecast_by_id(-1)
			weight.name = "flLfD"
			weight.value = 11

			@dbi_insert.insert_weight(weight)

			# Checking insertion by value
			inserted_weight = @dbi_select_tech.load_weight_by_id(weight.id)
						
			assert_equal(weight.forecast, inserted_weight.forecast)
			assert_equal(weight.name, inserted_weight.name)
			assert_equal(weight.value, inserted_weight.value)
			
			# Counting the number of weights after insertion
			new_weight_num = @dbi_select_tech.select_count_from_table(@config[:gen][:table_names][:weight])
			assert_equal(old_weight_num + 1, new_weight_num)
			
			@logger.ok("Tests for insertion of Weight OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
end