require './TestSuite.rb'
require './ref.rb'
require './Crawler.rb'

class TestCrawler < TestSuite
		
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi = $globalState.dbi
		@ref_list_hash = @dbi.load_all_refs
		@crawler = Crawler::new(@logger, @ref_list_hash, @config)
		@logger.level = SimpleHtmlLogger::DEBUG
	end
	
	def teardown
		@logger.debug("Teardown")
		@crawler.close_driver()
		@logger.level = SimpleHtmlLogger::INFO
	end
	
	
	##################
	#      Tests     #
	##################
#	def test_crawl
#		
#		@logger.info("Testing fetch meetings")
#		begin
#			job = Job::new
#		
#			@crawler.crawl("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm", job)
#		rescue Exception => err
#			@logger.error(err.inspect)
#			@logger.error(err.backtrace)
#			flunk(err.inspect)
#		end
#	end
	
	# def test_fetch_meetings
		
		# @logger.info("Testing fetch meetings")
		# begin
			# job = Job::new
			# date = Date::new(2013,11,15)
			# @logger.debug("Logger outputs debug messages")
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			# html_meeting_list = @crawler.driver.find_element(:xpath, "//div[@id='reunions-view']")
		
			
			# if html_meeting_list == nil then
				# flunk("html_meeting_list is nil.")
			# end
		
			# meeting_list = @crawler.fetch_meetings(html_meeting_list, date, job)
			
			## Checking the list has meetings in it and that those meetings
			## have races
			# assert_equal(5, meeting_list.size)
			# assert_equal(9, meeting_list[0].race_list.size)
			# assert_equal(8, meeting_list[1].race_list.size)
			# assert_equal(8, meeting_list[2].race_list.size)
			# assert_equal(4, meeting_list[3].race_list.size) # should be 5, according to the files 
															 ##  but the main page only has 2 to 5
			# assert_equal(6, meeting_list[4].race_list.size)
			
			# @logger.info("Tests for test_fetch_meetings OK.")
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_meeting_shallow
		
		# @logger.info("Testing fetch meeting shallow")
		# begin
			## Setting up 
			## -> Getting the page
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			## -> Getting the meeting list
			# html_meeting_list = @crawler.driver.
					# find_elements(:css, "div.reunion-line")
			## (Checking we did get a list and the right one)
			# assert_equal(5, html_meeting_list.size)
			# @logger.debug("There are indeed 5 meetings.")
			
			## -> Getting the meeting tag
			# html_meeting_to_test = html_meeting_list[2]
			
			## (Checking it's the right one)
			# reunion_id_attribute = html_meeting_to_test.attribute("data-reunionid")
			# assert_equal("3", reunion_id_attribute)
			
			## Creating date and job
			# job = Job::new
			# date = Date::new(2013, 11, 15)
			
			## The function to test
			# meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, date, job)
			
			# verif_date = Date::new(2015, 06, 12)
			# verif_number = "3"
			# verif_racetrack = "HIPPODROME DE SAINT GALMIER"
			# verif_urls_of_races_array = 
						# ["file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1.htm",
						 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C2.htm",
						 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C3.htm",
						 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C4.htm",
						 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C5.htm",
						 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C6.htm",
						 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C7.htm",
						 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C8.htm"]
			# verif_track_condition = @ref_list_hash[:ref_track_condition_list]["Terrain bon"]
			
			# verification_temp = 14
			# verification_wind_dir = nil
			# verification_wind_speed = 5
			# verification_insolation = "P8c"
			# verif_weather = Weather::new(
				# insolation: verification_insolation, 
				# temperature: verification_temp, 
				# wind_direction: verification_wind_dir, 
				# wind_speed: verification_wind_speed
			# )
			
			# verification_meeting = Meeting::new(
								# date: verif_date, 
								# job: job, 
								# number: verif_number, 
								# racetrack: verif_racetrack, 
								# urls_of_races_array: verif_urls_of_races_array, 
								# track_condition: verif_track_condition, 
								# weather: verif_weather)
								
			# assert_equal(verification_meeting, meeting)
			
			## 2nd test: country
			# html_meeting_to_test = html_meeting_list[3]
			# meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, date, job)
			# verif_country = "Af Sud"
			# verif_racetrack = "HIPPODROME DE VAAL"
			
			# assert_equal(verif_country, meeting.country)
			# assert_equal(verif_racetrack, meeting.racetrack)
			
			# @logger.info("Tests for test_fetch_meeting_shallow OK.")
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_meeting
		
		# @logger.info("Testing fetch meeting")
		# begin
			
			# urls_of_races_array = 
				# ["file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1.htm",
				 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C2.htm",
				 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C3.htm",
				 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C4.htm",
				 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C5.htm",
				 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C6.htm",
				 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C7.htm",
				 # "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C8.htm"]
			
			# html_meeting_to_test = Meeting::new(urls_of_races_array: urls_of_races_array)
			
			# assert_equal(0, html_meeting_to_test.race_list.size)
			
			## The function to test
			# meeting = @crawler.fetch_meeting(html_meeting_to_test)
			
			# assert_equal(8, meeting.race_list.size)
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_race
		# @logger.info("Testing fetch race")
		# begin
			## Setting up 
			## -> Getting the page
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			
			## -> Getting the meeting list
			# html_meeting_list = @crawler.driver.
					# find_elements(:css, "div.reunion-line")
			## (Checking we did get a list and the right one)
			# assert_equal(5, html_meeting_list.size)
			
			## -> Getting the meeting tag
			# html_meeting = html_meeting_list[0]
			## (Checking it's the right one)
			# reunion_id_attribute = html_meeting.attribute("data-reunionid")
			# assert_equal("1", reunion_id_attribute)
			
			# secondary_id = "numOfficiel-" + reunion_id_attribute
			# secondary_div_tag = @crawler.driver
					# .find_element(:id, secondary_id)
			
			## -> Getting the list of races
			# link_to_races_tags = secondary_div_tag.find_elements(:css, "a.course")
			# urls_of_races_array = []
			# link_to_races_tags.each do |link_to_race_tag|
				# urls_of_races_array.push(link_to_race_tag.attribute("href"))
			# end
			## Checking we've got the right number
			# assert_equal(9, urls_of_races_array.size)
			
			## Extracting the race to test
			# url_to_race = urls_of_races_array[6]
			# meeting = Meeting::new()
			# fetched_race = @crawler.fetch_race(url_to_race, meeting)
			
			# verif_bets = 166715.00
			# verif_detailed_conditions = "PRIX DES TROTTEURS \"SANG-FROID\" Course 7 Course Internationale Départ à l'Autostart 20.000. - Attelé. - 2.100 mètres (G. P.) 9.000, 5.000, 2.800, 1.600, 1.000, 400, 200. Course spéciale sur invitation réservée à 12 trotteurs \"Sang-Froid\" sélectio nés par les Fédérations de Finlande, Norvège et Suède. 3 chevaux seront menés par des jockeys français désignés p r la SECF."
			# verif_distance = 2100
			# verif_general_conditions = "Internationale - Autostart  - Corde à gauche"
			# verif_meeting = meeting
			# verif_name = "PRIX DES TROTTEURS \"SANG-FROID\""
			# verif_number = 7
			# verif_race_type = @ref_list_hash[:ref_race_type_list]["Attelé"]
			# verif_result = "3 - 7 - 1 - 10 - 6 - 2 - 12"
			# verif_result_insertion_time = Time::new
			# verif_runner_list = []
			# verif_time =  Time::new("2014-02-20")
			# verif_url = "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7.htm"
			# verif_value =  20000
			
			# verif_race = Race::new(bets: verif_bets,
				# detailed_conditions: verif_detailed_conditions,
				# distance: verif_distance,  
				# general_conditions: verif_general_conditions,
				# meeting: verif_meeting, 
				# name: verif_name, 
				# number: verif_number, 
				# race_type: verif_race_type,
				# result: verif_result,
				# result_insertion_time: verif_result_insertion_time,
				# runner_list: verif_runner_list,
				# time: verif_time,
				# url: verif_url,  
				# value: verif_value
			# )
			
			# assert_equal(verif_race, fetched_race)
			# @logger.info("Tests for test_fetch_race OK.")
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_weather
		
		# @logger.info("Testing fetch weather")
		# begin
			## Setting up 
			## -> Getting the page
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			
			## -> Getting the meeting list
			# html_meeting_list = @crawler.driver.
					# find_elements(:css, "div.reunion-line")
			## (Checking we did get a list and the right one)
			# assert_equal(5, html_meeting_list.size)
			
			## -> Getting the meeting tag
			# html_meeting = html_meeting_list[1]
			
			## (Checking it's the right one)
			# reunion_id_attribute = html_meeting.attribute("data-reunionid")
			# assert_equal("2", reunion_id_attribute)
			
			# div_tag_for_weather = html_meeting.
					# find_element(:css, "div.picto-meteo")
			
			## the function to test
			# weather = @crawler.fetch_weather(div_tag_for_weather)
			## @logger.debug("Weather : " + weather.to_s)
			
			# verification_temp = 12
			# verification_wind_dir = nil
			# verification_wind_speed = 16
			# verification_insolation = "P1"
			# verification_weather = Weather::new(
				# insolation: verification_insolation, 
				# temperature: verification_temp, 
				# wind_direction: verification_wind_dir, 
				# wind_speed: verification_wind_speed
			# )
			
			# assert_equal(verification_weather, weather)
			# @logger.info("Tests for test_fetch_weather OK.")
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	def test_join_runner_list_and_result_list
		@logger.info("Testing join runner list and result list")
		begin
			# Setting up 
			# -> Getting the first race
			url = "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5.htm"
			@crawler.driver.get(url)
			
			
			# -> Getting the meeting list
			race_to_test = Race::new() # R4_C5
			# Checking the list is empty beforehand
			assert_equal(nil, race_to_test.runner_list)
			race_to_test.url = url
			
			# getting the runner_list 
			result_list = @crawler.fetch_race_results(race_to_test)
			
			# go to runners' page
			@crawler.go_to_runners_page()
			
			# getting the runner_list
			list_runners = @crawler.fetch_list_runners(race_to_test)
			
			# Checking the data beforehand
			# First place (no distance) & favorite
			blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "stronghold")
			grand_father = Horse::new(name: "doyoun")
			mother = Horse::new(name: "haifaa", father: grand_father)
			
			runner_from_result_list = result_list[2]
			assert_equal("", 	runner_from_result_list.commentary, 				"Wrong commentary while checking first place is_favorite")
			assert_equal("", 	runner_from_result_list.distance, 					"Wrong distance while checking first place is_favorite")
			assert_equal(false, runner_from_result_list.disqualified, 				"Wrong disqualified while checking first place is_favorite")
			assert_equal(1, 	runner_from_result_list.final_place, 				"Wrong final_place while checking first place is_favorite")
			assert_equal(true, 	runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking first place is_favorite")
			assert_equal(nil, 	runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking first place is_favorite")
			assert_equal(false, runner_from_result_list.non_runner, 				"Wrong non_runner while checking first place is_favorite")
			assert_equal(2, 	runner_from_result_list.number, 					"Wrong number while checking first place is_favorite")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm", 
								runner_from_result_list.url, 						"Wrong url while checking first place is_favorite")
			assert_equal(2.9, 	runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking first place is_favorite")
			assert_equal("", 	runner_from_result_list.time, 						"Wrong time while checking first place is_favorite")
			@logger.info("Tests (from: results) for runner 1st place is_fav OK.")
			
			runner_from_list_runners = list_runners[2]
			assert_equal(5, 			runner_from_list_runners.age, 					"Wrong age while checking runner first place is_favorite")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking runner first place is_favorite")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking first place")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking first place")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking first place")
			assert_equal(11, 			runner_from_list_runners.draw, 					"Wrong draw while checking runner first place is_favorite")
			assert_equal(54359.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking runner first place is_favorite")
			assert_equal(3527.00, 		runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking runner first place is_favorite")
			assert_equal(8944.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking runner first place is_favorite")
			assert_equal(7098.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking runner first place is_favorite")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking first place")
			assert_equal("2p2p3p6p", 	runner_from_list_runners.history, 				"Wrong history while checking runner first place is_favorite")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking first place")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking first place")
			assert_equal(60.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking runner first place is_favorite")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking runner first place is_favorite")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking first place")
			assert_equal(2, 			runner_from_list_runners.number, 				"Wrong number while checking first place")
			assert_equal(14, 			runner_from_list_runners.places, 				"Wrong places while checking runner 10th place (with distance)")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking runner first place is_favorite")
			assert_equal(23, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking runner 10th place (with distance)")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking runner first place is_favorite")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking runner first place is_favorite")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking first place")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking first place")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking first place")
			assert_equal(2, 			runner_from_list_runners.victories, 			"Wrong victories while checking runner 10th place (with distance)")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking runner first place is_favorite")
			assert_equal("P Strydom", 	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking runner first place is_favorite")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking runner first place is_favorite")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking runner first place is_favorite")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking runner first place is_favorite")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking runner first place is_favorite")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking runner first place is_favorite")
			assert_equal("Negev", 		runner_from_list_runners.horse.name, 			"Wrong horse.name while checking runner first place is_favorite")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking runner first place is_favorite")
			assert_equal("MESSRS C M COMAROFF & B K PARKER", 		
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking runner first place is_favorite")
			assert_equal("L W GOOSEN", 	runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking runner first place is_favorite")
			@logger.info("Tests (from: runner) for runner 1st place is_fav OK.")

			# 10th Place (and  distance)
			blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "eyeofthetiger")
			grand_father = Horse::new(name: "argosy")
			mother = Horse::new(name: "missdefied", father: grand_father)
			
			runner_from_result_list = result_list[5]
			assert_equal("", 				runner_from_result_list.commentary, 				"Wrong commentary while checking runner 10th place (with distance)")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking runner 10th place (with distance)")
			assert_equal("3/4 De Longueur", runner_from_result_list.distance, 					"Wrong distance while checking runner 10th place (with distance)")
			assert_equal(10, 				runner_from_result_list.final_place, 				"Wrong final_place while checking runner 10th place (with distance)")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking runner 10th place (with distance)")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking runner 10th place (with distance)")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking runner 10th place (with distance)")
			assert_equal(5, 				runner_from_result_list.number, 					"Wrong number while checking runner 10th place (with distance)")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_AIM_OF_THE_GAME.htm",
											runner_from_result_list.url, 						"Wrong url while checking runner 10th place (with distance)")
			assert_equal(9.6, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking runner 10th place (with distance)")
			assert_equal("", 				runner_from_result_list.time, 						"Wrong time while checking runner 10th place (with distance)")
			@logger.info("Tests (from: results) for runner 10th place with dist OK.")
			
			runner_from_list_runners = list_runners[5]
			assert_equal(6, 			runner_from_list_runners.age, 					"Wrong age while checking runner 10th place (with distance)")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking runner 10th place (with distance)")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking runner 10th place (with distance)")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking runner 10th place (with distance)")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking runner 10th place (with distance)")
			assert_equal(3, 			runner_from_list_runners.draw, 					"Wrong draw while checking runner 10th place (with distance)")
			assert_equal(24095.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking runner 10th place (with distance)")
			assert_equal(4408.00, 		runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking runner 10th place (with distance)")
			assert_equal(12601.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking runner 10th place (with distance)")
			assert_equal(15898.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking runner 10th place (with distance)")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking runner 10th place (with distance)")
			assert_equal("1p7p(13)9p8p",runner_from_list_runners.history, 				"Wrong history while checking runner 10th place (with distance)")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking runner 10th place (with distance)")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking runner 10th place (with distance)")
			assert_equal(58.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking runner 10th place (with distance)")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking runner 10th place (with distance)")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking runner 10th place (with distance)")
			assert_equal(5, 			runner_from_list_runners.number, 				"Wrong number while checking runner 10th place (with distance)")
			assert_equal(15, 			runner_from_list_runners.places, 				"Wrong places while checking runner 10th place (with distance)")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking runner 10th place (with distance)")
			assert_equal(43, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking runner 10th place (with distance)")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking runner 10th place (with distance)")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking runner 10th place (with distance)")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking runner 10th place (with distance)")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking runner 10th place (with distance)")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_AIM_OF_THE_GAME.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking first place")
			assert_equal(5, 			runner_from_list_runners.victories, 			"Wrong victories while checking runner 10th place (with distance)")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking runner 10th place (with distance)")
			assert_equal("S Brown", 	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking runner 10th place (with distance)")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking runner 10th place (with distance)")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking runner 10th place (with distance)")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking runner 10th place (with distance)")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking runner 10th place (with distance)")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking runner 10th place (with distance)")
			assert_equal("Aim Of The Game", 		
										runner_from_list_runners.horse.name, 			"Wrong horse.name while checking runner 10th place (with distance)")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking runner 10th place (with distance)")
			assert_equal("MR L J & MRS M J ERASMUS", 		
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking runner 10th place (with distance)")
			assert_equal("L J ERASMUS", runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking runner 10th place (with distance)")
			@logger.info("Tests (from: runner) for runner 10th place with dist OK.")
			
			# No Place (and no distance)
			blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "black minnaloushe")
			grand_father = Horse::new(name: "cordoba")
			mother = Horse::new(name: "light fandango", father: grand_father)
			
			runner_from_result_list = result_list[4]
			assert_equal("", 				runner_from_result_list.commentary, 				"Wrong commentary while checking runner no place (and no distance)")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking runner no place (and no distance)")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking runner no place (and no distance)")
			assert_equal(0, 				runner_from_result_list.final_place, 				"Wrong final_place while checking runner no place (and no distance)")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking runner no place (and no distance)")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking runner no place (and no distance)")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking runner no place (and no distance)")
			assert_equal(4, 				runner_from_result_list.number, 					"Wrong number while checking runner no place (and no distance)")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_CAT'S_GAME.htm",
											runner_from_result_list.url, 						"Wrong url while checking runner no place (and no distance)")
			assert_equal(13.9, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking runner no place (and no distance)")
			assert_equal("", 				runner_from_result_list.time, 						"Wrong time while checking runner no place (and no distance)")
			@logger.info("Tests (from: results) for runner no place and no dist OK.")
			
			runner_from_list_runners = list_runners[4]
			assert_equal(5, 			runner_from_list_runners.age, 					"Wrong age while checking runner no place (and no distance)")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking runner no place (and no distance)")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking runner no place (and no distance)")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking runner no place (and no distance)")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking runner no place (and no distance)")
			assert_equal(8, 			runner_from_list_runners.draw, 					"Wrong draw while checking runner no place (and no distance)")
			assert_equal(11334.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking runner no place (and no distance)")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking runner no place (and no distance)")
			assert_equal(5117.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking runner no place (and no distance)")
			assert_equal(6921.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking runner no place (and no distance)")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking runner no place (and no distance)")
			assert_equal("5p8p2p6p",	runner_from_list_runners.history, 				"Wrong history while checking runner no place (and no distance)")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking runner no place (and no distance)")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking runner no place (and no distance)")
			assert_equal(59.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking runner no place (and no distance)")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking runner no place (and no distance)")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking runner no place (and no distance)")
			assert_equal(4, 			runner_from_list_runners.number, 				"Wrong number while checking runner no place (and no distance)")
			assert_equal(5, 			runner_from_list_runners.places, 				"Wrong places while checking runner no place (and no distance)")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking runner no place (and no distance)")
			assert_equal(12, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking runner no place (and no distance)")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking runner no place (and no distance)")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking runner no place (and no distance)")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking runner no place (and no distance)")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking runner no place (and no distance)")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_CAT'S_GAME.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking first place")
			assert_equal(2, 			runner_from_list_runners.victories, 			"Wrong victories while checking runner no place (and no distance)")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking runner no place (and no distance)")
			assert_equal("M V'rensburg",runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking runner no place (and no distance)")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking runner no place (and no distance)")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking runner no place (and no distance)")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking runner no place (and no distance)")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking runner no place (and no distance)")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking runner no place (and no distance)")
			assert_equal("Cat's Game", 	runner_from_list_runners.horse.name, 			"Wrong horse.name while checking runner no place (and no distance)")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking runner no place (and no distance)")
			assert_equal("MRS L C A BOUWER", 		
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking runner no place (and no distance)")
			assert_equal("S M FERREIRA",runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking runner no place (and no distance)")
			@logger.info("Tests (from: runner) for runner no place no dist OK.")
			
			
			# Non runner
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list][""]
			
			father = Horse::new(name: "windrush")
			grand_father = Horse::new(name: "northern guest")
			mother = Horse::new(name: "arctic game", father: grand_father)
			
			runner_from_result_list = result_list[17]
			assert_equal("", 				runner_from_result_list.commentary, 				"Wrong commentary while checking non runner")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking non runner")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking non runner")
			assert_equal(0, 				runner_from_result_list.final_place, 				"Wrong final_place while checking non runner")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking non runner")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking non runner")
			assert_equal(true, 				runner_from_result_list.non_runner, 				"Wrong non_runner while checking non runner")
			assert_equal(17, 				runner_from_result_list.number, 					"Wrong number while checking non runner")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_LIZZY_GREY.htm",
											runner_from_result_list.url, 						"Wrong url while checking non runner")
			assert_equal(0.0, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking non runner")
			assert_equal("", 				runner_from_result_list.time, 						"Wrong time while checking non runner")
			@logger.info("Tests (from: results) for non runner OK.")
			
			runner_from_list_runners = list_runners[17]
			assert_equal(0, 			runner_from_list_runners.age, 					"Wrong age while checking non runner")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking non runner")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking non runner")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking non runner")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking non runner")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking non runner")
			assert_equal(7845.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking non runner")
			assert_equal(1190.00, 		runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking non runner")			
			assert_equal(1491.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking non runner")
			assert_equal(2753.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking non runner")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking non runner")
			assert_equal("",			runner_from_list_runners.history, 				"Wrong history while checking non runner")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking non runner")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 			"Wrong is_substitute while checking non runner")
			assert_equal(0.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking non runner")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking non runner")
			assert_equal(true, 			runner_from_list_runners.non_runner, 			"Wrong non_runner while checking non runner")
			assert_equal(17, 			runner_from_list_runners.number, 				"Wrong number while checking non runner")
			assert_equal(8, 			runner_from_list_runners.places, 				"Wrong places while checking non runner")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking non runner")
			assert_equal(16, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking non runner")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking non runner")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking non runner")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking non runner")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking non runner")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_LIZZY_GREY.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking first place")
			assert_equal(1, 			runner_from_list_runners.victories, 			"Wrong victories while checking non runner")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking non runner")
			assert_equal("",			runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking non runner")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking non runner")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking non runner")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking non runner")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking non runner")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking non runner")
			assert_equal("Lizzy Grey", 	runner_from_list_runners.horse.name, 			"Wrong horse.name while checking non runner")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking non runner")
			assert_equal("MR A D C A FERNANDES", 		
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking non runner")
			assert_equal("G H VAN ZYL",runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking non runner")
			@logger.info("Tests (from: runner) for non runner OK.")
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place (no distance) & favorite
			blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "stronghold")
			grand_father = Horse::new(name: "doyoun")
			mother = Horse::new(name: "haifaa", father: grand_father)
			
			runner_to_check = joint_list[2]
			assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner first place is_favorite")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner first place is_favorite")
			assert_equal("", 					runner_to_check.commentary, 			"Wrong commentary while checking runner first place is_favorite")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner first place is_favorite")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner first place is_favorite")
			assert_equal("", 					runner_to_check.distance, 				"Wrong distance while checking runner first place is_favorite")
			assert_equal(11, 					runner_to_check.draw, 					"Wrong draw while checking runner first place is_favorite")
			assert_equal(54359.00, 				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner first place is_favorite")
			assert_equal(3527.00, 				runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner first place is_favorite")
			assert_equal(8944.00, 				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner first place is_favorite")
			assert_equal(7098.00, 				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner first place is_favorite")
			assert_equal(1, 					runner_to_check.final_place, 			"Wrong final_place while checking runner first place is_favorite")
			assert_equal("2p2p3p6p", 			runner_to_check.history, 				"Wrong history while checking runner first place is_favorite")
			assert_equal(true, 					runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner first place is_favorite")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner first place is_favorite")
			assert_equal(60.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner first place is_favorite")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner first place is_favorite")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner first place is_favorite")
			assert_equal(2, 					runner_to_check.number, 				"Wrong number while checking runner first place is_favorite")
			assert_equal(14, 					runner_to_check.places, 				"Wrong places while checking runner first place is_favorite")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner first place is_favorite")
			assert_equal(23, 					runner_to_check.races_run, 				"Wrong races_run while checking runner first place is_favorite")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner first place is_favorite")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner first place is_favorite")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner first place is_favorite")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner first place is_favorite")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner first place is_favorite")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner first place is_favorite")
			assert_equal(2.9, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner first place is_favorite")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner first place is_favorite")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking runner first place is_favorite")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm", 		
												runner_to_check.url, 					"Wrong url while checking runner first place is_favorite")
			assert_equal(2, 					runner_to_check.victories, 				"Wrong victories while checking runner first place is_favorite")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner first place is_favorite")
			assert_equal("P Strydom", 			runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner first place is_favorite")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner first place is_favorite")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner first place is_favorite")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner first place is_favorite")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner first place is_favorite")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner first place is_favorite")
			assert_equal("Negev", 				runner_to_check.horse.name, 			"Wrong horse.name while checking runner first place is_favorite")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner first place is_favorite")
			assert_equal("MESSRS C M COMAROFF & B K PARKER", 		
												runner_to_check.owner.name, 			"Wrong owner.name while checking runner first place is_favorite")
			assert_equal("L W GOOSEN", 			runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner first place is_favorite")
			@logger.info("Tests (after joining) for runner 1st place is_fav OK.")
			
			# 10th place (with distance)
			blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "eyeofthetiger")
			grand_father = Horse::new(name: "argosy")
			mother = Horse::new(name: "missdefied", father: grand_father)
			
			runner_to_check = joint_list[5]
			assert_equal(6, 					runner_to_check.age, 					"Wrong age while checking runner 10th place (with distance)")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner 10th place (with distance)")
			assert_equal("", 					runner_to_check.commentary, 			"Wrong commentary while checking runner 10th place (with distance)")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner 10th place (with distance)")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner 10th place (with distance)")
			assert_equal("3/4 De Longueur", 	runner_to_check.distance, 				"Wrong distance while checking runner 10th place (with distance)")
			assert_equal(3, 					runner_to_check.draw, 					"Wrong draw while checking runner 10th place (with distance)")
			assert_equal(24095.00,  			runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner 10th place (with distance)")
			assert_equal(4408.00,				runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner 10th place (with distance)")
			assert_equal(12601.00,				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner 10th place (with distance)")
			assert_equal(15898.00,				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner 10th place (with distance)")
			assert_equal(10, 					runner_to_check.final_place, 			"Wrong final_place while checking runner 10th place (with distance)")
			assert_equal("1p7p(13)9p8p", 		runner_to_check.history, 				"Wrong history while checking runner 10th place (with distance)")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner 10th place (with distance)")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner 10th place (with distance)")
			assert_equal(58.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner 10th place (with distance)")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner 10th place (with distance)")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner 10th place (with distance)")
			assert_equal(5, 					runner_to_check.number, 				"Wrong number while checking runner 10th place (with distance)")
			assert_equal(15, 					runner_to_check.places, 				"Wrong places while checking runner 10th place (with distance)")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner 10th place (with distance)")
			assert_equal(43, 					runner_to_check.races_run, 				"Wrong races_run while checking runner 10th place (with distance)")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner 10th place (with distance)")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner 10th place (with distance)")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner 10th place (with distance)")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner 10th place (with distance)")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner 10th place (with distance)")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner 10th place (with distance)")
			assert_equal(9.6, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner 10th place (with distance)")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner 10th place (with distance)")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking runner 10th place (with distance)")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_AIM_OF_THE_GAME.htm", 		
												runner_to_check.url, 					"Wrong url while checking runner 10th place (with distance)")
			assert_equal(5, 					runner_to_check.victories, 				"Wrong victories while checking runner 10th place (with distance)")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner 10th place (with distance)")
			assert_equal("S Brown", 			runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner 10th place (with distance)")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner 10th place (with distance)")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner 10th place (with distance)")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner 10th place (with distance)")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner 10th place (with distance)")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner 10th place (with distance)")
			assert_equal("Aim Of The Game", 	runner_to_check.horse.name, 			"Wrong horse.name while checking runner 10th place (with distance)")
			assert_equal(sex, 					runner_to_check.horse.sex, 			"Wrong horse.sex while checking runner 10th place (with distance)")
			assert_equal("MR L J & MRS M J ERASMUS", 		
												runner_to_check.owner.name, 			"Wrong owner.name while checking runner 10th place (with distance)")
			assert_equal("L J ERASMUS", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner 10th place (with distance)")
			@logger.info("Tests (after joining) for runner 10th place with dist OK.")
			
			# no place (and no distance)
			blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "black minnaloushe")
			grand_father = Horse::new(name: "cordoba")
			mother = Horse::new(name: "light fandango", father: grand_father)
			
			runner_to_check = joint_list[4]
						
			assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner no place (and no distance)")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner no place (and no distance)")
			assert_equal("", 					runner_to_check.commentary, 			"Wrong commentary while checking runner no place (and no distance)")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner no place (and no distance)")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner no place (and no distance)")
			assert_equal("", 					runner_to_check.distance, 				"Wrong distance while checking runner no place (and no distance)")
			assert_equal(8, 					runner_to_check.draw, 					"Wrong draw while checking runner no place (and no distance)")
			assert_equal(11334.00,  			runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner no place (and no distance)")
			assert_equal(0.00,					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner no place (and no distance)")
			assert_equal(5117.00,				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner no place (and no distance)")
			assert_equal(6921.00,				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner no place (and no distance)")
			assert_equal(0, 					runner_to_check.final_place, 			"Wrong final_place while checking runner no place (and no distance)")
			assert_equal("5p8p2p6p", 			runner_to_check.history, 				"Wrong history while checking runner no place (and no distance)")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner no place (and no distance)")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner no place (and no distance)")
			assert_equal(59.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner no place (and no distance)")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner no place (and no distance)")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner no place (and no distance)")
			assert_equal(4, 					runner_to_check.number, 				"Wrong number while checking runner no place (and no distance)")
			assert_equal(5, 					runner_to_check.places, 				"Wrong places while checking runner no place (and no distance)")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner no place (and no distance)")
			assert_equal(12, 					runner_to_check.races_run, 				"Wrong races_run while checking runner no place (and no distance)")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner no place (and no distance)")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner no place (and no distance)")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner no place (and no distance)")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner no place (and no distance)")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner no place (and no distance)")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner no place (and no distance)")
			assert_equal(13.9, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner no place (and no distance)")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner no place (and no distance)")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking runner no place (and no distance)")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_CAT'S_GAME.htm", 		
												runner_to_check.url, 					"Wrong url while checking runner no place (and no distance)")
			assert_equal(2, 					runner_to_check.victories, 				"Wrong victories while checking runner no place (and no distance)")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner no place (and no distance)")
			assert_equal("M V'rensburg", 		runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner no place (and no distance)")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner no place (and no distance)")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner no place (and no distance)")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner no place (and no distance)")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner no place (and no distance)")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner no place (and no distance)")
			assert_equal("Cat's Game", 			runner_to_check.horse.name, 			"Wrong horse.name while checking runner no place (and no distance)")
			assert_equal(sex, 					runner_to_check.horse.sex, 			"Wrong horse.sex while checking runner no place (and no distance)")
			assert_equal("MRS L C A BOUWER", 	runner_to_check.owner.name, 			"Wrong owner.name while checking runner no place (and no distance)")
			assert_equal("S M FERREIRA", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner no place (and no distance)")
			@logger.info("Tests (after joining) for runner no place and no dist OK.")
			
			
			# non runner
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list][""]
			
			father = Horse::new(name: "windrush")
			grand_father = Horse::new(name: "northern guest")
			mother = Horse::new(name: "arctic game", father: grand_father)
			
			runner_to_check = joint_list[17]
						
			assert_equal(0, 					runner_to_check.age, 					"Wrong age while checking non runner")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking non runner")
			assert_equal("", 					runner_to_check.commentary, 			"Wrong commentary while checking non runner")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking non runner")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking non runner")
			assert_equal("", 					runner_to_check.distance, 				"Wrong distance while checking non runner")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking non runner")
			assert_equal(7845.00,  				runner_to_check.earnings_career, 		"Wrong earnings_career while checking non runner")
			assert_equal(1190.00,				runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking non runner")
			assert_equal(1491.00,				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking non runner")
			assert_equal(2753.00,				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking non runner")
			assert_equal(0, 					runner_to_check.final_place, 			"Wrong final_place while checking non runner")
			assert_equal("", 					runner_to_check.history, 				"Wrong history while checking non runner")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking non runner")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking non runner")
			assert_equal(0.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking non runner")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking non runner")
			assert_equal(true, 					runner_to_check.non_runner, 			"Wrong non_runner while checking non runner")
			assert_equal(17, 					runner_to_check.number, 				"Wrong number while checking non runner")
			assert_equal(8, 					runner_to_check.places, 				"Wrong places while checking non runner")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking non runner")
			assert_equal(16, 					runner_to_check.races_run, 				"Wrong races_run while checking non runner")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking non runner")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking non runner")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking non runner")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking non runner")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking non runner")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking non runner")
			assert_equal(0.0, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking non runner")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking non runner")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking non runner")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_LIZZY_GREY.htm", 		
												runner_to_check.url, 					"Wrong url while checking non runner")
			assert_equal(1, 					runner_to_check.victories, 				"Wrong victories while checking non runner")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking non runner")
			assert_equal("", 					runner_to_check.jockey.name, 			"Wrong jockey.name while checking non runner")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking non runner")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking non runner")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking non runner")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking non runner")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking non runner")
			assert_equal("Lizzy Grey", 			runner_to_check.horse.name, 			"Wrong horse.name while checking non runner")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking non runner")
			assert_equal("MR A D C A FERNANDES",runner_to_check.owner.name, 			"Wrong owner.name while checking non runner")
			assert_equal("G H VAN ZYL", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking non runner")
			@logger.info("Tests (after joining) for non runner OK.")
			
			# Getting the second page
			url = "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1.htm"
			@crawler.driver.get(url)
			
			# -> Getting the meeting list
			race_to_test = Race::new() # R1_C1
			# Checking the list is empty beforehand
			assert_equal(nil, race_to_test.runner_list)
			race_to_test.url = url
			
			# getting the runner_list 
			result_list = @crawler.fetch_race_results(race_to_test)
			
			# go to runners' page
			@crawler.go_to_runners_page()
			
			# getting the runner_list
			list_runners = @crawler.fetch_list_runners(race_to_test)
			
			# First
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_POSTERIEURS"]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "prodigious")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "pocket edition", father: grand_father)
			
			runner_from_result_list = result_list[5]
			assert_equal("Installé au commandement en bas de la descente, a repoussé jusqu'au bout la bonne attaque de Valroy (9).", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking first place")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking first place")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking first place")
			assert_equal(1, 				runner_from_result_list.final_place, 				"Wrong final_place while checking first place")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking first place")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking first place")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking first place")
			assert_equal(5, 				runner_from_result_list.number, 					"Wrong number while checking first place")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VIRGIOUS_DU_MAZA.htm",
											runner_from_result_list.url, 						"Wrong url while checking first place")
			assert_equal(8.4, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking first place")
			assert_equal("1'13\"80", 		runner_from_result_list.time, 						"Wrong time while checking first place")
			@logger.info("Tests (from: results) for first place OK.")
			
			runner_from_list_runners = list_runners[5]
			assert_equal(5, 			runner_from_list_runners.age, 					"Wrong age while checking first place")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking first place")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking first place")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking first place")
			assert_equal(2700, 			runner_from_list_runners.distance, 				"Wrong distance while checking first place")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking first place")
			assert_equal(85060.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking first place")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking first place")			
			assert_equal(69400.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking first place")
			assert_equal(67600.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking first place")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking first place")
			assert_equal("DmDa(13)1m",	runner_from_list_runners.history, 				"Wrong history while checking first place")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking first place")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking first place")
			assert_equal(67.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking first place")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking first place")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking first place")
			assert_equal(5, 			runner_from_list_runners.number, 				"Wrong number while checking first place")
			assert_equal(6, 			runner_from_list_runners.places, 				"Wrong places while checking first place")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking first place")
			assert_equal(16, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking first place")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking first place")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking first place")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking first place")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking first place")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VIRGIOUS_DU_MAZA.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking first place")
			assert_equal(5, 			runner_from_list_runners.victories, 			"Wrong victories while checking first place")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking first place")
			assert_equal("D. Bonne",	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking first place")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking first place")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking first place")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking first place")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking first place")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking first place")
			assert_equal("Virgious Du Maza", 	
										runner_from_list_runners.horse.name, 			"Wrong horse.name while checking first place")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking first place")
			assert_equal("Ecurie du MAZA", 		
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking first place")
			assert_equal("S. ERNAULT",	runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking first place")
			@logger.info("Tests (from: runner) for 1st place OK.")
			
			
			# Favorite
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["M"]
			
			father = Horse::new(name: "first de retz")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "leda d'occagnes", father: grand_father)
			
			runner_from_result_list = result_list[9]
			assert_equal("Vite en troisième position, a donné un bon coup de reins dans les 100 derniers mètres sans pouvoir remonter totalement Virgious du Maza (5).", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking is favorite")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking is favorite")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking is favorite")
			assert_equal(2, 				runner_from_result_list.final_place, 				"Wrong final_place while checking is favorite")
			assert_equal(true, 				runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking is favorite")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking is favorite")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking is favorite")
			assert_equal(9, 				runner_from_result_list.number, 					"Wrong number while checking is favorite")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALROY.htm",
											runner_from_result_list.url, 						"Wrong url while checking is favorite")
			assert_equal(2.5, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking is favorite")
			assert_equal("1'13\"80", 		runner_from_result_list.time, 						"Wrong time while checking is favorite")
			@logger.info("Tests (from: results) for is favorite OK.")
			
			runner_from_list_runners = list_runners[9]
			assert_equal(5, 			runner_from_list_runners.age, 					"Wrong age while checking is favorite")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking is favorite")
			assert_equal(2700, 			runner_from_list_runners.distance, 				"Wrong distance while checking is favorite")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking is favorite")
			assert_equal(105130.00, 	runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking is favorite")
			assert_equal(9520.00, 		runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking is favorite")			
			assert_equal(53550.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking is favorite")
			assert_equal(37500.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking is favorite")
			assert_equal("3m(13)2mDm",	runner_from_list_runners.history, 				"Wrong history while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking is favorite")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking is favorite")
			assert_equal(67.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking is favorite")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking is favorite")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking is favorite")
			assert_equal(9, 			runner_from_list_runners.number, 				"Wrong number while checking is favorite")
			assert_equal(11, 			runner_from_list_runners.places, 				"Wrong places while checking is favorite")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking is favorite")
			assert_equal(28, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking is favorite")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking is favorite")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking is favorite")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking is favorite")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALROY.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking is favorite")
			assert_equal(4, 			runner_from_list_runners.victories, 			"Wrong victories while checking is favorite")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking is favorite")
			assert_equal("A. Abrivard",	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking is favorite")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking is favorite")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking is favorite")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking is favorite")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking is favorite")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking is favorite")
			assert_equal("Valroy", 		runner_from_list_runners.horse.name, 			"Wrong horse.name while checking is favorite")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking is favorite")
			assert_equal("Ecurie des CHARMES", 		
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking is favorite")
			assert_equal("J.M. BAZIRE",	runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking is favorite")
			@logger.info("Tests (from: runner) for is_fav OK.")
			
			
			# Disqualified
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "nijinski blue")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "nectarine turgot", father: grand_father)
			
			runner_from_result_list = result_list[4]
			assert_equal("Vite en tête, puis relayé par Virgious du Maza (5) en bas de la descente, venait visiblement dominer son rival lorsqu'il s'est montré fautif à mi-ligne droite.", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking disqualified")
			assert_equal(true, 				runner_from_result_list.disqualified, 				"Wrong disqualified while checking disqualified")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking disqualified")
			assert_equal(0, 				runner_from_result_list.final_place, 				"Wrong final_place while checking disqualified")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking disqualified")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking disqualified")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking disqualified")
			assert_equal(4, 				runner_from_result_list.number, 					"Wrong number while checking disqualified")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALDEZ_TURGOT.htm",
											runner_from_result_list.url, 						"Wrong url while checking disqualified")
			assert_equal(4.2, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking disqualified")
			assert_equal("0'00\"00", 		runner_from_result_list.time, 						"Wrong time while checking disqualified")
			@logger.info("Tests (from: results) for disqualified OK.")
			
			runner_from_list_runners = list_runners[4]
			assert_equal(5, 			runner_from_list_runners.age, 					"Wrong age while checking disqualified")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking disqualified")
			assert_equal(2700, 			runner_from_list_runners.distance, 				"Wrong distance while checking disqualified")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking disqualified")
			assert_equal(84980.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking disqualified")
			assert_equal(27900.00, 		runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking disqualified")			
			assert_equal(54060.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking disqualified")
			assert_equal(72900.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking disqualified")
			assert_equal("1m3m(13)1m",	runner_from_list_runners.history, 				"Wrong history while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking disqualified")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking disqualified")
			assert_equal(67.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking disqualified")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking disqualified")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking disqualified")
			assert_equal(4, 			runner_from_list_runners.number, 				"Wrong number while checking disqualified")
			assert_equal(8, 			runner_from_list_runners.places, 				"Wrong places while checking disqualified")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking disqualified")
			assert_equal(23, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking disqualified")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking disqualified")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking disqualified")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking disqualified")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALDEZ_TURGOT.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking disqualified")
			assert_equal(6, 			runner_from_list_runners.victories, 			"Wrong victories while checking disqualified")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking disqualified")
			assert_equal("M. Abrivard",	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking disqualified")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking disqualified")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking disqualified")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking disqualified")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking disqualified")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking disqualified")
			assert_equal("Valdez Turgot", 	
										runner_from_list_runners.horse.name, 			"Wrong horse.name while checking disqualified")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking disqualified")
			assert_equal("P. COIGNARD", runner_from_list_runners.owner.name, 			"Wrong owner.name while checking disqualified")
			assert_equal("P. COIGNARD",	runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking disqualified")
			@logger.info("Tests (from: runner) for disqualified OK.")
			
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_POSTERIEURS"]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "prodigious")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "pocket edition", father: grand_father)
			
			runner_to_check = joint_list[5]
			assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner first place")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner first place")
			assert_equal("Installé au commandement en bas de la descente, a repoussé jusqu'au bout la bonne attaque de Valroy (9).", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner first place")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner first place")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner first place")
			assert_equal(2700, 					runner_to_check.distance, 				"Wrong distance while checking runner first place")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner first place")
			assert_equal(85060.00,				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner first place")
			assert_equal(0.00, 					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner first place")
			assert_equal(69400.00,				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner first place")
			assert_equal(67600.00,				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner first place")
			assert_equal(1, 					runner_to_check.final_place, 			"Wrong final_place while checking runner first place")
			assert_equal("DmDa(13)1m", 			runner_to_check.history, 				"Wrong history while checking runner first place")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner first place")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner first place")
			assert_equal(67.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner first place")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner first place")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner first place")
			assert_equal(5, 					runner_to_check.number, 				"Wrong number while checking runner first place")
			assert_equal(6, 					runner_to_check.places, 				"Wrong places while checking runner first place")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner first place")
			assert_equal(16, 					runner_to_check.races_run, 				"Wrong races_run while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner first place")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner first place")
			assert_equal(8.4, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner first place")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner first place")
			assert_equal("1'13\"80", 			runner_to_check.time, 					"Wrong time while checking runner first place")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VIRGIOUS_DU_MAZA.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner first place")
			assert_equal(5, 					runner_to_check.victories, 				"Wrong victories while checking runner first place")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner first place")
			assert_equal("D. Bonne", 			runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner first place")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner first place")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner first place")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner first place")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner first place")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner first place")
			assert_equal("Virgious Du Maza", 	runner_to_check.horse.name, 			"Wrong horse.name while checking runner first place")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner first place")
			assert_equal("Ecurie du MAZA", 		runner_to_check.owner.name, 			"Wrong owner.name while checking runner first place")
			assert_equal("S. ERNAULT", 			runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner first place")
			@logger.info("Tests (after joining) for runner 1st place OK.")
			
			
			# Favorite
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["M"]
			
			father = Horse::new(name: "first de retz")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "leda d'occagnes", father: grand_father)
			
			runner_to_check = joint_list[9]
			assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner is favorite")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner is favorite")
			assert_equal("Vite en troisième position, a donné un bon coup de reins dans les 100 derniers mètres sans pouvoir remonter totalement Virgious du Maza (5).", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner is favorite")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner is favorite")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner is favorite")
			assert_equal(2700, 					runner_to_check.distance, 				"Wrong distance while checking runner is favorite")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner is favorite")
			assert_equal(105130.00,				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner is favorite")
			assert_equal(9520.00, 				runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner is favorite")
			assert_equal(53550.00, 				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner is favorite")
			assert_equal(37500.00, 				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner is favorite")
			assert_equal(2, 					runner_to_check.final_place, 			"Wrong final_place while checking runner is favorite")
			assert_equal("3m(13)2mDm", 			runner_to_check.history, 				"Wrong history while checking runner is favorite")
			assert_equal(true,	 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner is favorite")
			assert_equal(false,	 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner is favorite")
			assert_equal(67.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner is favorite")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner is favorite")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner is favorite")
			assert_equal(9, 					runner_to_check.number, 				"Wrong number while checking runner is favorite")
			assert_equal(11, 					runner_to_check.places, 				"Wrong places while checking runner is favorite")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner is favorite")
			assert_equal(28, 					runner_to_check.races_run, 				"Wrong races_run while checking runner is favorite")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner is favorite")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner is favorite")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner is favorite")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner is favorite")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner is favorite")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner is favorite")
			assert_equal(2.5, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner is favorite")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner is favorite")
			assert_equal("1'13\"80", 			runner_to_check.time, 					"Wrong time while checking runner is favorite")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALROY.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner is favorite")
			assert_equal(4, 					runner_to_check.victories, 				"Wrong victories while checking runner is favorite")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner is favorite")
			assert_equal("A. Abrivard", 		runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner is favorite")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner is favorite")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner is favorite")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner is favorite")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner is favorite")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner is favorite")
			assert_equal("Valroy", 				runner_to_check.horse.name, 			"Wrong horse.name while checking runner is favorite")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner is favorite")
			assert_equal("Ecurie des CHARMES", 	runner_to_check.owner.name, 			"Wrong owner.name while checking runner is favorite")
			assert_equal("J.M. BAZIRE", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner is favorite")
			@logger.info("Tests (after joining) for runner is_fav OK.")
			
			# Disqualified
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "nijinski blue")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "nectarine turgot", father: grand_father)
			
			runner_to_check = joint_list[4]
			assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner disqualified")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner disqualified")
			assert_equal("Vite en tête, puis relayé par Virgious du Maza (5) en bas de la descente, venait visiblement dominer son rival lorsqu'il s'est montré fautif à mi-ligne droite.", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner disqualified")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner disqualified")
			assert_equal(true, 					runner_to_check.disqualified, 			"Wrong disqualified while checking runner disqualified")
			assert_equal(2700, 					runner_to_check.distance, 				"Wrong distance while checking runner disqualified")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner disqualified")
			assert_equal(84980.00,				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner disqualified")
			assert_equal(27900.00,				runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner disqualified")
			assert_equal(54060.00,				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner disqualified")
			assert_equal(72900.00,				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner disqualified")
			assert_equal(0, 					runner_to_check.final_place, 			"Wrong final_place while checking runner disqualified")
			assert_equal("1m3m(13)1m", 			runner_to_check.history, 				"Wrong history while checking runner disqualified")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner disqualified")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner disqualified")
			assert_equal(67.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner disqualified")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner disqualified")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner disqualified")
			assert_equal(4, 					runner_to_check.number, 				"Wrong number while checking runner disqualified")
			assert_equal(8, 					runner_to_check.places, 				"Wrong places while checking runner disqualified")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner disqualified")
			assert_equal(23, 					runner_to_check.races_run, 				"Wrong races_run while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner disqualified")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner disqualified")
			assert_equal(4.2, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner disqualified")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner disqualified")
			assert_equal("0'00\"00", 			runner_to_check.time, 					"Wrong time while checking runner disqualified")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALDEZ_TURGOT.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner disqualified")
			assert_equal(6, 					runner_to_check.victories, 				"Wrong victories while checking runner disqualified")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner disqualified")
			assert_equal("M. Abrivard", 		runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner disqualified")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner disqualified")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner disqualified")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner disqualified")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner disqualified")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner disqualified")
			assert_equal("Valdez Turgot", 		runner_to_check.horse.name, 			"Wrong horse.name while checking runner disqualified")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner disqualified")
			assert_equal("P. COIGNARD", 		runner_to_check.owner.name, 			"Wrong owner.name while checking runner disqualified")
			assert_equal("P. COIGNARD", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner disqualified")
			@logger.info("Tests (after joining) for runner disqualified OK.")
			
			# Third page : R2_C7 (no draw)
			
			url = "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7.htm"
			@crawler.driver.get(url)
			
			# -> Getting the meeting list
			race_to_test = Race::new() # R2_C7
			# Checking the list is empty beforehand
			assert_equal(nil, race_to_test.runner_list)
			race_to_test.url = url
			
			# getting the runner_list 
			result_list = @crawler.fetch_race_results(race_to_test)
			
			# go to runners' page
			@crawler.go_to_runners_page()
			
			# getting the runner_list
			list_runners = @crawler.fetch_list_runners(race_to_test)
			
			# First
			blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "assessor")
			grand_father = Horse::new(name: "garde royale")
			mother = Horse::new(name: "notting hill", father: grand_father)
			
			runner_from_result_list = result_list[11]
			assert_equal("Après avoir patienté en quatrième ou cinquième position, s'est rapprochée entre les deux dernières haies, puis a bien accéléré sur le plat, créant la décision aux abords du poteau.", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking first place")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking first place")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking first place")
			assert_equal(1, 				runner_from_result_list.final_place, 				"Wrong final_place while checking first place")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking first place")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking first place")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking first place")
			assert_equal(11, 				runner_from_result_list.number, 					"Wrong number while checking first place")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_VIVA_VOCE_SIVOLA.htm",
											runner_from_result_list.url, 						"Wrong url while checking first place")
			assert_equal(93.6, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking first place")
			assert_equal("", 				runner_from_result_list.time, 						"Wrong time while checking first place")
			@logger.info("Tests (from: results) for first place OK.")
			
			runner_from_list_runners = list_runners[11]
			assert_equal(5, 			runner_from_list_runners.age, 					"Wrong age while checking first place")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking first place")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking first place")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking first place")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking first place")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking first place")
			assert_equal(9970.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking first place")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking first place")			
			assert_equal(3825.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking first place")
			assert_equal(0.00, 			runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking first place")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking first place")
			assert_equal("3aThAh5s5s3h",runner_from_list_runners.history, 				"Wrong history while checking first place")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking first place")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking first place")
			assert_equal(64.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking first place")
			assert_equal(61.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking first place")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking first place")
			assert_equal(11, 			runner_from_list_runners.number, 				"Wrong number while checking first place")
			assert_equal(6, 			runner_from_list_runners.places, 				"Wrong places while checking first place")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking first place")
			assert_equal(19, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking first place")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking first place")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking first place")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking first place")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking first place")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_VIVA_VOCE_SIVOLA.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking first place")
			assert_equal(0, 			runner_from_list_runners.victories, 			"Wrong victories while checking first place")
			assert_equal("MR GILLES TRAPENARD", 			
										runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking first place")
			assert_equal("C.abou",		runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking first place")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking first place")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking first place")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking first place")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking first place")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking first place")
			assert_equal("Viva Voce Sivola", 	
										runner_from_list_runners.horse.name, 			"Wrong horse.name while checking first place")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking first place")
			assert_equal("MME F.GIMMI PELLEGRINO", 		
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking first place")
			assert_equal("MME F.GIMMI PELLEGRINO",	
										runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking first place")
			@logger.info("Tests (from: runner) for 1st place OK.")
			
			# Favorite
			blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "martaline")
			grand_father = Horse::new(name: "sanglamore")
			mother = Horse::new(name: "la haie blanche", father: grand_father)
			
			runner_from_result_list = result_list[1]
			assert_equal("Vite en tête, n'a été dominé que dans les derniers mètres.", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking favorite")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking favorite")
			assert_equal("1 Tête", 			runner_from_result_list.distance, 					"Wrong distance while checking favorite")
			assert_equal(3, 				runner_from_result_list.final_place, 				"Wrong final_place while checking favorite")
			assert_equal(true, 				runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking favorite")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking favorite")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking favorite")
			assert_equal(1, 				runner_from_result_list.number, 					"Wrong number while checking favorite")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_FRANZ_QUERCUS.htm",
											runner_from_result_list.url, 						"Wrong url while checking favorite")
			assert_equal(2.6, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking favorite")
			assert_equal("", 				runner_from_result_list.time, 						"Wrong time while checking favorite")
			@logger.info("Tests (from: results) for favorite OK.")
			
			runner_from_list_runners = list_runners[1]
			assert_equal(7, 			runner_from_list_runners.age, 					"Wrong age while checking favorite")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking favorite")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking favorite")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking favorite")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking favorite")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking favorite")
			assert_equal(60330.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking favorite")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking favorite")			
			assert_equal(0.00, 			runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking favorite")
			assert_equal(48960.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking favorite")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking favorite")
			assert_equal("1s1h3h(11)1s",runner_from_list_runners.history, 				"Wrong history while checking favorite")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking favorite")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking favorite")
			assert_equal(72.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking favorite")
			assert_equal(68.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking favorite")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking favorite")
			assert_equal(1, 			runner_from_list_runners.number, 				"Wrong number while checking favorite")
			assert_equal(3, 			runner_from_list_runners.places, 				"Wrong places while checking favorite")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking favorite")
			assert_equal(9, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking favorite")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking favorite")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking favorite")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking favorite")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking favorite")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_FRANZ_QUERCUS.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking favorite")
			assert_equal(5, 			runner_from_list_runners.victories, 			"Wrong victories while checking favorite")
			assert_equal("MR DANIEL CHASSAGNEUX", 			
										runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking favorite")
			assert_equal("J.rougier",	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking favorite")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking favorite")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking favorite")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking favorite")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking favorite")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking favorite")
			assert_equal("Franz Quercus", 	
										runner_from_list_runners.horse.name, 			"Wrong horse.name while checking favorite")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking favorite")
			assert_equal("JD.COTTON", 	runner_from_list_runners.owner.name, 			"Wrong owner.name while checking favorite")
			assert_equal("MACAIRE (S)",	runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking favorite")
			@logger.info("Tests (from: runner) for favorite OK.")
			
			# Substitute
			blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_AUSTRALIENNES"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "bonbon rose")
			grand_father = Horse::new(name: "saint preuil")
			mother = Horse::new(name: "sainte kash", father: grand_father)
			
			runner_from_result_list = result_list[12]
			assert_equal("Venue de l'arrière-garde, a progressé entre les deux dernières haies et a conclu correctement.", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking substitute")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking substitute")
			assert_equal("1 Longueur 1/2", 	runner_from_result_list.distance, 					"Wrong distance while checking substitute")
			assert_equal(6, 				runner_from_result_list.final_place, 				"Wrong final_place while checking substitute")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking substitute")
			assert_equal(nil, 			runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking substitute")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking substitute")
			assert_equal(12, 				runner_from_result_list.number, 					"Wrong number while checking substitute")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_TWEETY_KASH.htm",
											runner_from_result_list.url, 						"Wrong url while checking substitute")
			assert_equal(22.3, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking substitute")
			assert_equal("", 				runner_from_result_list.time, 						"Wrong time while checking substitute")
			@logger.info("Tests (from: results) for substitute OK.")
			
			runner_from_list_runners = list_runners[12]
			assert_equal(5, 			runner_from_list_runners.age, 					"Wrong age while checking substitute")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking substitute")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking substitute")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking substitute")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking substitute")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking substitute")
			assert_equal(17775.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking substitute")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking substitute")			
			assert_equal(17775.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking substitute")
			assert_equal(10560.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking substitute")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking substitute")
			assert_equal("AhAsTs6h(13)",runner_from_list_runners.history, 				"Wrong history while checking substitute")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking substitute")
			assert_equal(true, 			runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking substitute")
			assert_equal(64.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking substitute")
			assert_equal(65.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking substitute")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking substitute")
			assert_equal(12, 			runner_from_list_runners.number, 				"Wrong number while checking substitute")
			assert_equal(4, 			runner_from_list_runners.places, 				"Wrong places while checking substitute")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking substitute")
			assert_equal(13, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking substitute")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking substitute")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking substitute")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking substitute")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking substitute")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_TWEETY_KASH.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking substitute")
			assert_equal(2, 			runner_from_list_runners.victories, 			"Wrong victories while checking substitute")
			assert_equal("MR ARNAUD CHAILLE-CHAILLE", 			
										runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking substitute")
			assert_equal("B.lestrade",	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking substitute")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking substitute")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking substitute")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking substitute")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking substitute")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking substitute")
			assert_equal("Tweety Kash", 	
										runner_from_list_runners.horse.name, 			"Wrong horse.name while checking substitute")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking substitute")
			assert_equal("S.HOFFMEISTER",
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking substitute")
			assert_equal("M.SEROR",		runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking substitute")
			@logger.info("Tests (from: runner) for substitute OK.")
			
			# 12th place
			blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["ALEZAN"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "medicean")
			grand_father = Horse::new(name: "trempolino")
			mother = Horse::new(name: "vivacity", father: grand_father)
			
			runner_from_result_list = result_list[4]
			assert_equal("Rapproché à la sortie du tournant final, faisant alors illusion pour la troisième ou quatrième place, a marqué le pas sur le plat.", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking 12th place")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking 12th place")
			assert_equal("4 Longueurs", 	runner_from_result_list.distance, 					"Wrong distance while checking 12th place")
			assert_equal(12, 				runner_from_result_list.final_place, 				"Wrong final_place while checking 12th place")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking 12th place")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking 12th place")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking 12th place")
			assert_equal(4, 				runner_from_result_list.number, 					"Wrong number while checking 12th place")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm",
											runner_from_result_list.url, 						"Wrong url while checking 12th place")
			assert_equal(17.6, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking 12th place")
			assert_equal("", 				runner_from_result_list.time, 						"Wrong time while checking 12th place")
			@logger.info("Tests (from: results) for 12th place OK.")
			
			runner_from_list_runners = list_runners[4]
			assert_equal(7, 			runner_from_list_runners.age, 					"Wrong age while checking 12th place")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking 12th place")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking 12th place")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking 12th place")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking 12th place")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking 12th place")
			assert_equal(21175.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking 12th place")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking 12th place")			
			assert_equal(21175.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking 12th place")
			assert_equal(14400.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking 12th place")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking 12th place")
			assert_equal("9hAh1h4h5h5h",runner_from_list_runners.history, 				"Wrong history while checking 12th place")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking 12th place")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking 12th place")
			assert_equal(68.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking 12th place")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking 12th place")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking 12th place")
			assert_equal(4, 			runner_from_list_runners.number, 				"Wrong number while checking 12th place")
			assert_equal(4, 			runner_from_list_runners.places, 				"Wrong places while checking 12th place")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking 12th place")
			assert_equal(13, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking 12th place")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking 12th place")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking 12th place")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking 12th place")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking 12th place")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking 12th place")
			assert_equal(2, 			runner_from_list_runners.victories, 			"Wrong victories while checking 12th place")
			assert_equal("STILVI COMPANIA FINANCIERA S.A.", 			
										runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking 12th place")
			assert_equal("A.lecordier",	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking 12th place")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking 12th place")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking 12th place")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking 12th place")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking 12th place")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking 12th place")
			assert_equal("Grypas", 		runner_from_list_runners.horse.name, 			"Wrong horse.name while checking 12th place")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking 12th place")
			assert_equal("A.CANAVERO", 	runner_from_list_runners.owner.name, 			"Wrong owner.name while checking 12th place")
			assert_equal("C.SCANDELLA",	runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking 12th place")
			@logger.info("Tests (from: runner) for 12th place OK.")
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "assessor")
			grand_father = Horse::new(name: "garde royale")
			mother = Horse::new(name: "notting hill", father: grand_father)
			
			runner_to_check = joint_list[11]
			assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner first place")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner first place")
			assert_equal("Après avoir patienté en quatrième ou cinquième position, s'est rapprochée entre les deux dernières haies, puis a bien accéléré sur le plat, créant la décision aux abords du poteau.", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner first place")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner first place")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner first place")
			assert_equal("", 					runner_to_check.distance, 				"Wrong distance while checking runner first place")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner first place")
			assert_equal(9970.00, 				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner first place")
			assert_equal(0.00, 					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner first place")
			assert_equal(3825.00, 				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner first place")
			assert_equal(0.00, 					runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner first place")
			assert_equal(1, 					runner_to_check.final_place, 			"Wrong final_place while checking runner first place")
			assert_equal("3aThAh5s5s3h", 		runner_to_check.history, 				"Wrong history while checking runner first place")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner first place")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner first place")
			assert_equal(64.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner first place")
			assert_equal(61.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner first place")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner first place")
			assert_equal(11, 					runner_to_check.number, 				"Wrong number while checking runner first place")
			assert_equal(6, 					runner_to_check.places, 				"Wrong places while checking runner first place")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner first place")
			assert_equal(19, 					runner_to_check.races_run, 				"Wrong races_run while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner first place")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner first place")
			assert_equal(93.6, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner first place")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner first place")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking runner first place")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_VIVA_VOCE_SIVOLA.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner first place")
			assert_equal(0, 					runner_to_check.victories, 				"Wrong victories while checking runner first place")
			assert_equal("MR GILLES TRAPENARD", runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner first place")
			assert_equal("C.abou", 				runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner first place")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner first place")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner first place")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner first place")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner first place")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner first place")
			assert_equal("Viva Voce Sivola", 	runner_to_check.horse.name, 			"Wrong horse.name while checking runner first place")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner first place")
			assert_equal("MME F.GIMMI PELLEGRINO", 		
												runner_to_check.owner.name, 			"Wrong owner.name while checking runner first place")
			assert_equal("MME F.GIMMI PELLEGRINO", 			
												runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner first place")
			@logger.info("Tests (after joining) for runner 1st place OK.")
			
			# Favorite
			blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "martaline")
			grand_father = Horse::new(name: "sanglamore")
			mother = Horse::new(name: "la haie blanche", father: grand_father)
			
			runner_to_check = joint_list[1]
			assert_equal(7, 					runner_to_check.age, 					"Wrong age while checking runner favorite")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner favorite")
			assert_equal("Vite en tête, n'a été dominé que dans les derniers mètres.", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner favorite")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner favorite")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner favorite")
			assert_equal("1 Tête", 				runner_to_check.distance, 				"Wrong distance while checking runner favorite")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner favorite")
			assert_equal(60330.00,				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner favorite")
			assert_equal(0.00, 					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner favorite")
			assert_equal(0.00, 					runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner favorite")
			assert_equal(48960.00,				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner favorite")
			assert_equal(3, 					runner_to_check.final_place, 			"Wrong final_place while checking runner favorite")
			assert_equal("1s1h3h(11)1s", 		runner_to_check.history, 				"Wrong history while checking runner favorite")
			assert_equal(true, 					runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner favorite")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner favorite")
			assert_equal(72.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner favorite")
			assert_equal(68.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner favorite")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner favorite")
			assert_equal(1, 					runner_to_check.number, 				"Wrong number while checking runner favorite")
			assert_equal(3, 					runner_to_check.places, 				"Wrong places while checking runner favorite")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner favorite")
			assert_equal(9, 					runner_to_check.races_run, 				"Wrong races_run while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner favorite")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner favorite")
			assert_equal(2.6, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner favorite")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner favorite")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking runner favorite")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_FRANZ_QUERCUS.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner favorite")
			assert_equal(5, 					runner_to_check.victories, 				"Wrong victories while checking runner favorite")
			assert_equal("MR DANIEL CHASSAGNEUX", 					
												runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner favorite")
			assert_equal("J.rougier", 			runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner favorite")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner favorite")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner favorite")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner favorite")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner favorite")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner favorite")
			assert_equal("Franz Quercus", 		runner_to_check.horse.name, 			"Wrong horse.name while checking runner favorite")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner favorite")
			assert_equal("JD.COTTON", 			runner_to_check.owner.name, 			"Wrong owner.name while checking runner favorite")
			assert_equal("MACAIRE (S)", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner favorite")
			@logger.info("Tests (after joining) for runner favorite OK.")
			
			# Substitute
			blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_AUSTRALIENNES"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["BAI"]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "bonbon rose")
			grand_father = Horse::new(name: "saint preuil")
			mother = Horse::new(name: "sainte kash", father: grand_father)
			
			runner_to_check = joint_list[12]
			assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner favorite")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner favorite")
			assert_equal("Venue de l'arrière-garde, a progressé entre les deux dernières haies et a conclu correctement.", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner favorite")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner favorite")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner favorite")
			assert_equal("1 Longueur 1/2", 		runner_to_check.distance, 				"Wrong distance while checking runner favorite")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner favorite")
			assert_equal(17775.00,				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner favorite")
			assert_equal(0.00, 					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner favorite")
			assert_equal(17775.00,				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner favorite")
			assert_equal(10560.00,				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner favorite")
			assert_equal(6, 					runner_to_check.final_place, 			"Wrong final_place while checking runner favorite")
			assert_equal("AhAsTs6h(13)", 		runner_to_check.history, 				"Wrong history while checking runner favorite")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner favorite")
			assert_equal(true, 					runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner favorite")
			assert_equal(64.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner favorite")
			assert_equal(65.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner favorite")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner favorite")
			assert_equal(12, 					runner_to_check.number, 				"Wrong number while checking runner favorite")
			assert_equal(4, 					runner_to_check.places, 				"Wrong places while checking runner favorite")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner favorite")
			assert_equal(13, 					runner_to_check.races_run, 				"Wrong races_run while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner favorite")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner favorite")
			assert_equal(22.3, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner favorite")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner favorite")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking runner favorite")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_TWEETY_KASH.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner favorite")
			assert_equal(2, 					runner_to_check.victories, 				"Wrong victories while checking runner favorite")
			assert_equal("MR ARNAUD CHAILLE-CHAILLE", 					
												runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner favorite")
			assert_equal("B.lestrade", 			runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner favorite")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner favorite")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner favorite")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner favorite")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner favorite")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner favorite")
			assert_equal("Tweety Kash", 		runner_to_check.horse.name, 			"Wrong horse.name while checking runner favorite")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner favorite")
			assert_equal("S.HOFFMEISTER", 		runner_to_check.owner.name, 			"Wrong owner.name while checking runner favorite")
			assert_equal("M.SEROR", 			runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner favorite")
			@logger.info("Tests (after joining) for runner favorite OK.")
			
			# 12th place
			blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["ALEZAN"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "medicean")
			grand_father = Horse::new(name: "trempolino")
			mother = Horse::new(name: "vivacity", father: grand_father)
			
			runner_to_check = joint_list[4]
			assert_equal(7, 					runner_to_check.age, 					"Wrong age while checking runner 12th place")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner 12th place")
			assert_equal("Rapproché à la sortie du tournant final, faisant alors illusion pour la troisième ou quatrième place, a marqué le pas sur le plat.", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner 12th place")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner 12th place")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner 12th place")
			assert_equal("4 Longueurs", 		runner_to_check.distance, 				"Wrong distance while checking runner 12th place")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner 12th place")
			assert_equal(21175.00,				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner 12th place")
			assert_equal(0.00, 					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner 12th place")
			assert_equal(21175.00,				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner 12th place")
			assert_equal(14400.00,				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner 12th place")
			assert_equal(12, 					runner_to_check.final_place, 			"Wrong final_place while checking runner 12th place")
			assert_equal("9hAh1h4h5h5h", 		runner_to_check.history, 				"Wrong history while checking runner 12th place")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner 12th place")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner 12th place")
			assert_equal(68.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner 12th place")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner 12th place")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner 12th place")
			assert_equal(4, 					runner_to_check.number, 				"Wrong number while checking runner 12th place")
			assert_equal(4, 					runner_to_check.places, 				"Wrong places while checking runner 12th place")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner 12th place")
			assert_equal(13, 					runner_to_check.races_run, 				"Wrong races_run while checking runner 12th place")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner 12th place")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner 12th place")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner 12th place")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner 12th place")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner 12th place")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner 12th place")
			assert_equal(17.6, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner 12th place")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner 12th place")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking runner 12th place")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner 12th place")
			assert_equal(2, 					runner_to_check.victories, 				"Wrong victories while checking runner 12th place")
			assert_equal("STILVI COMPANIA FINANCIERA S.A.", 					
												runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner 12th place")
			assert_equal("A.lecordier", 		runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner 12th place")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner 12th place")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner 12th place")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner 12th place")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner 12th place")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner 12th place")
			assert_equal("Grypas", 				runner_to_check.horse.name, 			"Wrong horse.name while checking runner 12th place")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner 12th place")
			assert_equal("A.CANAVERO", 			runner_to_check.owner.name, 			"Wrong owner.name while checking runner 12th place")
			assert_equal("C.SCANDELLA", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner 12th place")
			@logger.info("Tests (after joining) for runner 12th place OK.")
			
			# Fourth page : R1_C7 (attelé, with driver rather than jockey)
			url = "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7.htm"
			@crawler.driver.get(url)
			
			# -> Getting the meeting list
			race_to_test = Race::new() # R1_C7
			# Checking the list is empty beforehand
			assert_equal(nil, race_to_test.runner_list)
			race_to_test.url = url
			
			# getting the runner_list 
			result_list = @crawler.fetch_race_results(race_to_test)
			
			# go to runners' page
			@crawler.go_to_runners_page()
			
			# getting the runner_list
			list_runners = @crawler.fetch_list_runners(race_to_test)
			
			
			# First place
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS"]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
			coat = @ref_list_hash[:ref_coat_list]["NOIR"]
			sex = @ref_list_hash[:ref_sex_list]["M"]
			
			father = Horse::new(name: "mortvedt jerkeld")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "faks perla", father: grand_father)
			
			runner_from_result_list = result_list[3]
			assert_equal("Patient sur une troisième ligne, a débordé Närby Kalabalik (8) sur le fil.", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking first place")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking first place")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking first place")
			assert_equal(1, 				runner_from_result_list.final_place, 				"Wrong final_place while checking first place")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking first place")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking first place")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking first place")
			assert_equal(3, 				runner_from_result_list.number, 					"Wrong number while checking first place")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_DOKTOR_JAROS.htm",
											runner_from_result_list.url, 						"Wrong url while checking first place")
			assert_equal(11.6, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking first place")
			assert_equal("1'24\"70", 		runner_from_result_list.time, 						"Wrong time while checking first place")
			@logger.info("Tests (from: results) for first place OK.")
			
			runner_from_list_runners = list_runners[3]
			assert_equal(7, 			runner_from_list_runners.age, 					"Wrong age while checking first place")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking first place")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking first place")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking first place")
			assert_equal(2100, 			runner_from_list_runners.distance, 				"Wrong distance while checking first place")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking first place")
			assert_equal(87843.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking first place")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking first place")			
			assert_equal(0.00, 			runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking first place")
			assert_equal(0.00, 			runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking first place")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking first place")
			assert_equal("0a2a1a1a(1",	runner_from_list_runners.history, 				"Wrong history while checking first place")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking first place")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking first place")
			assert_equal(0.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking first place")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking first place")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking first place")
			assert_equal(3, 			runner_from_list_runners.number, 				"Wrong number while checking first place")
			assert_equal(0, 			runner_from_list_runners.places, 				"Wrong places while checking first place")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking first place")
			assert_equal(0, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking first place")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking first place")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking first place")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking first place")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking first place")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking first place")
			assert_equal(0, 			runner_from_list_runners.victories, 			"Wrong victories while checking first place")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking first place")
			assert_equal("G. Gudmestad",runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking first place")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking first place")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking first place")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking first place")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking first place")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking first place")
			assert_equal("Doktor Jaros",runner_from_list_runners.horse.name, 			"Wrong horse.name while checking first place")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking first place")
			assert_equal("Ecurie JAROS (NOR)", 	
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking first place")
			assert_equal("G. GUDMESTAD",runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking first place")
			@logger.info("Tests (from: runner) for first place OK.")
			
			
			# Favorite
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
			coat = @ref_list_hash[:ref_coat_list]["BAI FONCE"]
			sex = @ref_list_hash[:ref_sex_list]["M"]
			
			father = Horse::new(name: "jarvsofaks")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "norheim elle", father: grand_father)
			
			runner_from_result_list = result_list[1]
			assert_equal("Longtemps en dehors de l'animateur Juni Kongen (7), a conservé la quatrième place en léger retrait.", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking is favorite")
			assert_equal(false, 			runner_from_result_list.disqualified, 				"Wrong disqualified while checking is favorite")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking is favorite")
			assert_equal(3, 				runner_from_result_list.final_place, 				"Wrong final_place while checking is favorite")
			assert_equal(true, 				runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking is favorite")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking is favorite")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking is favorite")
			assert_equal(1, 				runner_from_result_list.number, 					"Wrong number while checking is favorite")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_NORHEIM_JAERV.htm",
											runner_from_result_list.url, 						"Wrong url while checking is favorite")
			assert_equal(3.5, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking is favorite")
			assert_equal("1'25\"30", 		runner_from_result_list.time, 						"Wrong time while checking is favorite")
			@logger.info("Tests (from: results) for is favorite OK.")
			
			runner_from_list_runners = list_runners[1]
			assert_equal(6, 			runner_from_list_runners.age, 					"Wrong age while checking is favorite")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking is favorite")
			assert_equal(2100, 			runner_from_list_runners.distance, 				"Wrong distance while checking is favorite")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking is favorite")
			assert_equal(120946.00, 	runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking is favorite")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking is favorite")			
			assert_equal(0.00, 			runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking is favorite")
			assert_equal(0.00, 			runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking is favorite")
			assert_equal("6a1a(13)3a",	runner_from_list_runners.history, 				"Wrong history while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking is favorite")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking is favorite")
			assert_equal(0.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking is favorite")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking is favorite")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking is favorite")
			assert_equal(1, 			runner_from_list_runners.number, 				"Wrong number while checking is favorite")
			assert_equal(0, 			runner_from_list_runners.places, 				"Wrong places while checking is favorite")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking is favorite")
			assert_equal(0, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking is favorite")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking is favorite")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking is favorite")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking is favorite")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking is favorite")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_NORHEIM_JAERV.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking is favorite")
			assert_equal(0, 			runner_from_list_runners.victories, 			"Wrong victories while checking is favorite")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking is favorite")
			assert_equal("T.e. Solberg",runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking is favorite")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking is favorite")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking is favorite")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking is favorite")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking is favorite")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking is favorite")
			assert_equal("Norheim Jaerv",
										runner_from_list_runners.horse.name, 			"Wrong horse.name while checking is favorite")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking is favorite")
			assert_equal("Georg William SVERDRUP (NOR)", 	
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking is favorite")
			assert_equal("Georg William SVERDRUP",	
										runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking is favorite")
			@logger.info("Tests (from: runner) for is favorite OK.")
			
			# Disqualified
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
			coat = @ref_list_hash[:ref_coat_list]["ALEZAN BRULE"]
			sex = @ref_list_hash[:ref_sex_list]["M"]
			
			father = Horse::new(name: "liptus")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "mikun metka", father: grand_father)
			
			runner_from_result_list = result_list[11]
			assert_equal("S'est montré fautif peu après le départ.", 				
											runner_from_result_list.commentary, 				"Wrong commentary while checking disqualified")
			assert_equal(true, 				runner_from_result_list.disqualified, 				"Wrong disqualified while checking disqualified")
			assert_equal("", 				runner_from_result_list.distance, 					"Wrong distance while checking disqualified")
			assert_equal(0, 				runner_from_result_list.final_place, 				"Wrong final_place while checking disqualified")
			assert_equal(false, 			runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking disqualified")
			assert_equal(nil, 				runner_from_result_list.is_substitute, 				"Wrong is_substitute while checking disqualified")
			assert_equal(false, 			runner_from_result_list.non_runner, 				"Wrong non_runner while checking disqualified")
			assert_equal(11, 				runner_from_result_list.number, 					"Wrong number while checking disqualified")
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_METKUTUS.htm",
											runner_from_result_list.url, 						"Wrong url while checking disqualified")
			assert_equal(32.6, 				runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking disqualified")
			assert_equal("0'00\"00", 		runner_from_result_list.time, 						"Wrong time while checking disqualified")
			@logger.info("Tests (from: results) for disqualified OK.")
			
			runner_from_list_runners = list_runners[11]
			assert_equal(10, 			runner_from_list_runners.age, 					"Wrong age while checking disqualified")
			assert_equal(blinder, 		runner_from_list_runners.blinder, 				"Wrong blinder while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking disqualified")
			assert_equal(2100, 			runner_from_list_runners.distance, 				"Wrong distance while checking disqualified")
			assert_equal(0, 			runner_from_list_runners.draw, 					"Wrong draw while checking disqualified")
			assert_equal(86140.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking disqualified")
			assert_equal(0.00, 			runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking disqualified")			
			assert_equal(200.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking disqualified")
			assert_equal(0.00, 			runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking disqualified")
			assert_equal("4a0a6a5a(1",	runner_from_list_runners.history, 				"Wrong history while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking disqualified")
			assert_equal(false, 		runner_from_list_runners.is_substitute, 		"Wrong is_substitute while checking disqualified")
			assert_equal(0.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking disqualified")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking disqualified")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking disqualified")
			assert_equal(11, 			runner_from_list_runners.number, 				"Wrong number while checking disqualified")
			assert_equal(1, 			runner_from_list_runners.places, 				"Wrong places while checking disqualified")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking disqualified")
			assert_equal(2, 			runner_from_list_runners.races_run, 			"Wrong races_run while checking disqualified")
			assert_equal(shoes, 		runner_from_list_runners.shoes, 				"Wrong shoes while checking disqualified")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking disqualified")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking disqualified")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking disqualified")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_METKUTUS.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking disqualified")
			assert_equal(0, 			runner_from_list_runners.victories, 			"Wrong victories while checking disqualified")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking disqualified")
			assert_equal("J.m. Paavola",runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking disqualified")
			assert_equal(breed, 		runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking disqualified")
			assert_equal(coat, 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking disqualified")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking disqualified")
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking disqualified")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking disqualified")
			assert_equal("Metkutus", 	runner_from_list_runners.horse.name, 			"Wrong horse.name while checking disqualified")
			assert_equal(sex, 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking disqualified")
			assert_equal("J.M. PAAVOLA (FIN)", 	
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking disqualified")
			assert_equal("J.M. PAAVOLA",runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking disqualified")
			@logger.info("Tests (from: runner) for disqualified OK.")
			
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS"]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
			coat = @ref_list_hash[:ref_coat_list]["NOIR"]
			sex = @ref_list_hash[:ref_sex_list]["M"]
			
			father = Horse::new(name: "mortvedt jerkeld")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "faks perla", father: grand_father)
			
			runner_to_check = joint_list[3]
			assert_equal(7, 					runner_to_check.age, 					"Wrong age while checking runner first place")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner first place")
			assert_equal("Patient sur une troisième ligne, a débordé Närby Kalabalik (8) sur le fil.", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner first place")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner first place")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner first place")
			assert_equal(2100, 					runner_to_check.distance, 				"Wrong distance while checking runner first place")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner first place")
			assert_equal(87843.00, 				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner first place")
			assert_equal(0.00, 					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner first place")
			assert_equal(0.00, 					runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner first place")
			assert_equal(0.00, 					runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner first place")
			assert_equal(1, 					runner_to_check.final_place, 			"Wrong final_place while checking runner first place")
			assert_equal("0a2a1a1a(1", 			runner_to_check.history, 				"Wrong history while checking runner first place")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner first place")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner first place")
			assert_equal(0.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner first place")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner first place")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner first place")
			assert_equal(3, 					runner_to_check.number, 				"Wrong number while checking runner first place")
			assert_equal(0, 					runner_to_check.places, 				"Wrong places while checking runner first place")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner first place")
			assert_equal(0, 					runner_to_check.races_run, 				"Wrong races_run while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner first place")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner first place")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner first place")
			assert_equal(11.6, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner first place")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner first place")
			assert_equal("1'24\"70", 					runner_to_check.time, 					"Wrong time while checking runner first place")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_DOKTOR_JAROS.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner first place")
			assert_equal(0, 					runner_to_check.victories, 				"Wrong victories while checking runner first place")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner first place")
			assert_equal("G. Gudmestad", 		runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner first place")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner first place")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner first place")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner first place")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner first place")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner first place")
			assert_equal("Doktor Jaros", 		runner_to_check.horse.name, 			"Wrong horse.name while checking runner first place")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner first place")
			assert_equal("Ecurie JAROS (NOR)", 	runner_to_check.owner.name, 			"Wrong owner.name while checking runner first place")
			assert_equal("G. GUDMESTAD", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner first place")
			@logger.info("Tests (after joining) for runner 1st place OK.")
			
			# Favorite
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list][""]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
			coat = @ref_list_hash[:ref_coat_list]["BAI FONCE"]
			sex = @ref_list_hash[:ref_sex_list]["M"]
			
			father = Horse::new(name: "jarvsofaks")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "norheim elle", father: grand_father)
			
			runner_to_check = joint_list[1]
			assert_equal(6, 					runner_to_check.age, 					"Wrong age while checking runner favorite")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner favorite")
			assert_equal("Longtemps en dehors de l'animateur Juni Kongen (7), a conservé la quatrième place en léger retrait.", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner favorite")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner favorite")
			assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner favorite")
			assert_equal(2100, 					runner_to_check.distance, 				"Wrong distance while checking runner favorite")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner favorite")
			assert_equal(120946.00, 			runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner favorite")
			assert_equal(0.00, 					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner favorite")
			assert_equal(0.00, 					runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner favorite")
			assert_equal(0.00, 					runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner favorite")
			assert_equal(3, 					runner_to_check.final_place, 			"Wrong final_place while checking runner favorite")
			assert_equal("6a1a(13)3a", 			runner_to_check.history, 				"Wrong history while checking runner favorite")
			assert_equal(true, 					runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner favorite")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner favorite")
			assert_equal(0.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner favorite")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner favorite")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner favorite")
			assert_equal(1, 					runner_to_check.number, 				"Wrong number while checking runner favorite")
			assert_equal(0, 					runner_to_check.places, 				"Wrong places while checking runner favorite")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner favorite")
			assert_equal(0, 					runner_to_check.races_run, 				"Wrong races_run while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner favorite")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner favorite")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner favorite")
			assert_equal(3.5, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner favorite")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner favorite")
			assert_equal("1'25\"30", 			runner_to_check.time, 					"Wrong time while checking runner favorite")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_NORHEIM_JAERV.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner favorite")
			assert_equal(0, 					runner_to_check.victories, 				"Wrong victories while checking runner favorite")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner favorite")
			assert_equal("T.e. Solberg", 		runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner favorite")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner favorite")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner favorite")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner favorite")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner favorite")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner favorite")
			assert_equal("Norheim Jaerv", 		runner_to_check.horse.name, 			"Wrong horse.name while checking runner favorite")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner favorite")
			assert_equal("Georg William SVERDRUP (NOR)", 		
												runner_to_check.owner.name, 			"Wrong owner.name while checking runner favorite")
			assert_equal("Georg William SVERDRUP", 			
												runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner favorite")
			@logger.info("Tests (after joining) for runner is_fav OK.")
			
			# Disqualified
			blinder = @ref_list_hash[:ref_blinder_list][""]
			shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"]
			breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
			coat = @ref_list_hash[:ref_coat_list]["ALEZAN BRULE"]
			sex = @ref_list_hash[:ref_sex_list]["M"]
			
			father = Horse::new(name: "liptus")
			grand_father = Horse::new(name: "-")
			mother = Horse::new(name: "mikun metka", father: grand_father)
			
			runner_to_check = joint_list[11]
			assert_equal(10, 					runner_to_check.age, 					"Wrong age while checking runner disqualified")
			assert_equal(blinder, 				runner_to_check.blinder, 				"Wrong blinder while checking runner disqualified")
			assert_equal("S'est montré fautif peu après le départ.", 					
												runner_to_check.commentary, 			"Wrong commentary while checking runner disqualified")		
			assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner disqualified")
			assert_equal(true, 					runner_to_check.disqualified, 			"Wrong disqualified while checking runner disqualified")
			assert_equal(2100, 					runner_to_check.distance, 				"Wrong distance while checking runner disqualified")
			assert_equal(0, 					runner_to_check.draw, 					"Wrong draw while checking runner disqualified")
			assert_equal(86140.00, 				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner disqualified")
			assert_equal(0.00, 					runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner disqualified")
			assert_equal(200.00, 				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner disqualified")
			assert_equal(0.00, 					runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner disqualified")
			assert_equal(0, 					runner_to_check.final_place, 			"Wrong final_place while checking runner disqualified")
			assert_equal("4a0a6a5a(1", 			runner_to_check.history, 				"Wrong history while checking runner disqualified")
			assert_equal(false, 				runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner disqualified")
			assert_equal(false, 				runner_to_check.is_substitute, 			"Wrong is_substitute while checking runner disqualified")
			assert_equal(0.0, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner disqualified")
			assert_equal(0.0, 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner disqualified")
			assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner disqualified")
			assert_equal(11, 					runner_to_check.number, 				"Wrong number while checking runner disqualified")
			assert_equal(1, 					runner_to_check.places, 				"Wrong places while checking runner disqualified")
			assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner disqualified")
			assert_equal(2, 					runner_to_check.races_run, 				"Wrong races_run while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner disqualified")
			assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner disqualified")
			assert_equal(shoes, 				runner_to_check.shoes, 					"Wrong shoes while checking runner disqualified")
			assert_equal(32.6, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner disqualified")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner disqualified")
			assert_equal("0'00\"00", 			runner_to_check.time, 					"Wrong time while checking runner disqualified")
			# FIXME If real website does have a URL per runner
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_METKUTUS.htm", 	
												runner_to_check.url, 					"Wrong url while checking runner disqualified")
			assert_equal(0, 					runner_to_check.victories, 				"Wrong victories while checking runner disqualified")
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner disqualified")
			assert_equal("J.m. Paavola", 		runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner disqualified")
			assert_equal(breed, 				runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner disqualified")
			assert_equal(coat, 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner disqualified")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner disqualified")
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner disqualified")
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner disqualified")
			assert_equal("Metkutus", 			runner_to_check.horse.name, 			"Wrong horse.name while checking runner disqualified")
			assert_equal(sex, 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner disqualified")
			assert_equal("J.M. PAAVOLA (FIN)", 	runner_to_check.owner.name, 			"Wrong owner.name while checking runner disqualified")
			assert_equal("J.M. PAAVOLA", 		runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner disqualified")
			@logger.info("Tests (after joining) for runner disqualified OK.")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_get_column_map()
		
		@logger.info("Testing getting the right column map")
		begin
			# Setting up 
			# -> Getting the first race
			url_race_dict = Hash::new
			url_race_dict["R1_C1".to_s] = Crawler::COLUMN_MAP_TYPE_1
			url_race_dict["R1_C2".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R1_C3".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R1_C4".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R1_C5".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R1_C6".to_s] = Crawler::COLUMN_MAP_TYPE_1
			url_race_dict["R1_C7".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R1_C8".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R1_C9".to_s] = Crawler::COLUMN_MAP_TYPE_1
			url_race_dict["R3_C1".to_s] = Crawler::COLUMN_MAP_TYPE_1
			url_race_dict["R3_C2".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R3_C3".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R3_C4".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R3_C5".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R3_C6".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R3_C7".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R3_C8".to_s] = Crawler::COLUMN_MAP_TYPE_4
			url_race_dict["R2_C1".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R2_C2".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R2_C3".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R2_C4".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R2_C5".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R2_C6".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R4_C2".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R4_C3".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R4_C4".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R4_C5".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R5_C1".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R5_C2".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R5_C3".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R5_C4".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R5_C5".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R5_C6".to_s] = Crawler::COLUMN_MAP_TYPE_2
			url_race_dict["R2_C7".to_s] = Crawler::COLUMN_MAP_TYPE_3
			url_race_dict["R2_C8".to_s] = Crawler::COLUMN_MAP_TYPE_3
			
			url_race_dict.each do |race_ID, expected_column_map|
				
				url = "file:///D:/Dev/workspace/RPP/Test-HTML/" +
						race_ID + "_runners.htm"
				
				@crawler.driver.get(url)
				actual_column_map = @crawler.get_column_map()
				
				assert_equal(expected_column_map, actual_column_map,
							"Wrong column map while testing " + 
							"get_column_map for race: " + race_ID)
			end
			
			@logger.info("Tests for get_column_map OK.")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	# def test_fetch_runners
		
		# @logger.info("Testing fetch runners")
		# begin
			## Setting up 
			## -> Getting the race
			# url = "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5.htm"
			## @crawler.driver.get(url)
			
			## -> Getting the meeting list
			# race_to_test = Race::new() # R4_C5
			## Checking the list is empty beforehand
			# assert_equal(nil, race_to_test.runner_list)
			# race_to_test.url = url
			
			## the function to test
			# runner_list = @crawler.fetch_runners(race_to_test)
			
			## Checking we did get a list and the right one
			# assert_equal(17, runner_list.size)
			
			## Checking individual Runners :
			
			## is_favorite
			# runner_to_check = runner_list[2]
			# assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner first place is_favorite")
			# assert_equal("OEILLERES_CLASSIQUE", runner_to_check.blinder, 				"Wrong blinder while checking runner first place is_favorite")
			# assert_equal("", 					runner_to_check.commentary, 			"Wrong commentary while checking runner first place is_favorite")		
			# assert_equal("", 					runner_to_check.description, 			"Wrong description while checking runner first place is_favorite")
			# assert_equal(false, 				runner_to_check.disqualified, 			"Wrong disqualified while checking runner first place is_favorite")
			# assert_equal("", 					runner_to_check.distance, 				"Wrong distance while checking runner first place is_favorite")
			# assert_equal(11, 					runner_to_check.draw, 					"Wrong draw while checking runner first place is_favorite")
			# assert_equal(54359.00, 				runner_to_check.earnings_career, 		"Wrong earnings_career while checking runner first place is_favorite")
			# assert_equal(3527.00, 				runner_to_check.earnings_current_year,	"Wrong earnings_current_year while checking runner first place is_favorite")
			# assert_equal(8944.00, 				runner_to_check.earnings_last_year, 	"Wrong earnings_last_year while checking runner first place is_favorite")
			# assert_equal(7098.00, 				runner_to_check.earnings_victory, 		"Wrong earnings_victory while checking runner first place is_favorite")
			# assert_equal(1, 					runner_to_check.final_place, 			"Wrong final_place while checking runner first place is_favorite")
			# assert_equal("2p2p3p6p", 			runner_to_check.history, 				"Wrong history while checking runner first place is_favorite")
			# assert_equal(true, 					runner_to_check.is_favorite, 			"Wrong is_favorite while checking runner first place is_favorite")
			# assert_equal(60, 					runner_to_check.load_handicap, 			"Wrong load_handicap while checking runner first place is_favorite")
			# assert_equal("", 					runner_to_check.load_ride, 				"Wrong load_ride while checking runner first place is_favorite")
			# assert_equal(false, 				runner_to_check.non_runner, 			"Wrong non_runner while checking runner first place is_favorite")
			# assert_equal(2, 					runner_to_check.number, 				"Wrong number while checking runner first place is_favorite")
			# assert_equal("Mythical Palace", 	runner_to_check.places, 				"Wrong places while checking runner first place is_favorite")
			# assert_equal(race_to_test, 			runner_to_check.race, 					"Wrong race while checking runner first place is_favorite")
			# assert_equal(23, 					runner_to_check.races_run, 				"Wrong races_run while checking runner first place is_favorite")
			# assert_equal(nil, 					runner_to_check.score_horse, 			"Wrong score_horse while checking runner first place is_favorite")
			# assert_equal(nil, 					runner_to_check.score_jockey, 			"Wrong score_jockey while checking runner first place is_favorite")
			# assert_equal(nil, 					runner_to_check.score_owner, 			"Wrong score_owner while checking runner first place is_favorite")
			# assert_equal(nil, 					runner_to_check.score_trainer, 			"Wrong score_trainer while checking runner first place is_favorite")
			# assert_equal(nil, 					runner_to_check.score_breeder, 			"Wrong score_breeder while checking runner first place is_favorite")
			# assert_equal(nil, 					runner_to_check.shoes, 					"Wrong shoes while checking runner first place is_favorite")
			# assert_equal(2.9, 					runner_to_check.single_rating, 			"Wrong single_rating while checking runner first place is_favorite")
			# assert_equal(nil, 					runner_to_check.time, 					"Wrong time while checking runner first place is_favorite")
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm", 		
												# runner_to_check.url, 					"Wrong url while checking runner first place is_favorite")
			# assert_equal(2, 					runner_to_check.victories, 				"Wrong victories while checking runner first place is_favorite")
			
			# assert_equal("-", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner first place is_favorite")
			# assert_equal("P Strydom", 			runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner first place is_favorite")
			# assert_equal("PUR-SANG", 			runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner first place is_favorite")
			# assert_equal("", 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner first place is_favorite")
			# assert_equal("stronghold", 			runner_to_check.horse.father, 			"Wrong horse.father while checking runner first place is_favorite")
			# assert_equal("haifaa", 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner first place is_favorite")
			# assert_equal("doyoun", 				runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner first place is_favorite")
			# assert_equal("NEGEV", 				runner_to_check.horse.name, 			"Wrong horse.name while checking runner first place is_favorite")
			# assert_equal("F", 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner first place is_favorite")
			# assert_equal("MESSRS C M COMAROFF & B K PARKER", 		
												# runner_to_check.owner.name, 			"Wrong owner.name while checking runner first place is_favorite")
			# assert_equal("L W GOOSEN", 			runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner first place is_favorite")
			
			# @logger.info("Tests for runner 1st place is_fav OK.")
			
			## is between 1 and 10
			
			## is after 10
			
			## is non_runner
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_runners_shallow
		
		# @logger.info("Testing fetch runners shallow")
		# begin
			## Setting up 
			## -> Getting the first race (with distance)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C3_runners.htm")
			
			# race_to_test = Race::new() # R4_C3
			# runner = nil
			
			## the function to test
			# runner_hash = @crawler.fetch_runners_shallow(race_to_test)
			
			## Checking we did get a list and the right one
			# assert("Runner list is nil", runner_hash != nil)
			# assert_equal(8, runner_hash.size, "Wrong number of runners fetched")
			
			## Checking the fetched results
			
			## Without blinder
			# runner_to_check = runner_hash[1]
			# assert_equal(7, 				runner_to_check.age, 			"Wrong age while checking runner without blinder")
			# assert_equal("SANS_OEILLERES", 	runner_to_check.blinder, 		"Wrong blinder while checking runner without blinder")
			# assert_equal(8, 				runner_to_check.draw, 			"Wrong draw while checking runner without blinder")
			# assert_equal("1p2p(13)7p9p", 	runner_to_check.history, 		"Wrong history while checking runner without blinder")			
			# assert_equal("Mythical Palace", runner_to_check.horse.name, 	"Wrong horse.name while checking runner without blinder")
			# assert_equal("H", 				runner_to_check.horse.sex, 		"Wrong sex while checking runner without blinder")
			# assert_equal(false, 			runner_to_check.is_favorite, 	"Wrong is_favorite while checking runner without blinder")
			# assert_equal("G Lerena", 		runner_to_check.jockey.name, 	"Wrong jockey.name while checking runner without blinder")
			# assert_equal(60.5, 				runner_to_check.load_handicap, 	"Wrong load_handicap while checking runner without blinder")
			# assert_equal(0, 				runner_to_check.load_ride, 		"Wrong load_ride while checking runner without blinder")
			# assert_equal(false, 			runner_to_check.non_runner, 	"Wrong non_runner while checking runner without blinder")
			# assert_equal(1, 				runner_to_check.number, 		"Wrong number while checking runner without blinder")
			# assert_equal(race_to_test, 		runner_to_check.race, 			"Wrong race while checking runner without blinder")
			# assert_equal(0.0, 				runner_to_check.single_rating, 	"Wrong single_rating while checking runner without blinder")
			# assert_equal("S G Tarry", 		runner_to_check.trainer.name, 	"Wrong trainer.name while checking runner without blinder")
			# assert_equal("", 				runner_to_check.url, 			"Wrong url while checking runner without blinder")
			# @logger.info("Tests for runner (with draw) without blinder OK.")
			
			## Non runner
			# runner_to_check = runner_hash[8]
			# assert_equal(nil, 			runner_to_check.age, 			"Wrong age while checking non runner")
			# assert_equal(nil, 			runner_to_check.blinder, 		"Wrong blinder while checking non runner")
			# assert_equal(nil, 			runner_to_check.draw, 			"Wrong draw while checking non runner")
			# assert_equal(nil, 			runner_to_check.history, 		"Wrong history while checking non runner")
			# assert_equal("Phenomenal", 	runner_to_check.horse.name, 	"Wrong horse.name while checking non runner")
			# assert_equal(nil, 			runner_to_check.horse.sex, 		"Wrong sex while checking runner non with blinder")
			# assert_equal(false, 		runner_to_check.is_favorite, 	"Wrong is_favorite while checking non runner without blinder")
			# assert_equal(nil, 			runner_to_check.jockey, 		"Wrong jockey while checking non runner")
			# assert_equal(nil, 			runner_to_check.load_handicap, 	"Wrong load_handicap while checking non runner")
			# assert_equal(nil, 			runner_to_check.load_ride, 		"Wrong load_ride while checking non runner")
			# assert_equal(true, 			runner_to_check.non_runner, 	"Wrong is_favorite while checking non runner without blinder")
			# assert_equal(8, 			runner_to_check.number, 		"Wrong number while checking non runner")			
			# assert_equal(race_to_test, 	runner_to_check.race, 			"Wrong race while checking non runner")
			# assert_equal(nil, 			runner_to_check.single_rating, 	"Wrong single_rating while checking non runner")
			# assert_equal(nil, 			runner_to_check.trainer, 		"Wrong trainer while checking non runner")
			# assert_equal("", 			runner_to_check.url, 			"Wrong url while checking non runner")
			# @logger.info("Tests for non runner (with draw) OK.")
			
			## -> Getting the second race (with time)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runners.htm")
			
			# race_to_test = Race::new() # R1_C7
			
			## the function to test
			# runner_hash = @crawler.fetch_runners_shallow(race_to_test)
			
			## Checking we did get a list and the right one
			# assert_equal(12, runner_hash.size, "Wrong number of runners fetched")
			
			## Checking the fetched results
			# runner_to_check = runner_hash[9]
			# assert_equal(7, 				runner_to_check.age, 				"Wrong age while checking runner without shoes and with earnings")
			# assert_equal(nil, 				runner_to_check.blinder, 			"Wrong blinder while checking runner without shoes and with earnings")
			# assert_equal(nil, 				runner_to_check.draw, 				"Wrong draw while checking runner without shoes and with earnings")
			# assert_equal("3aDa2a(13)", 		runner_to_check.history, 			"Wrong history while checking runner without shoes and with earnings")
			# assert_equal("Jaervso Ole", 	runner_to_check.horse.name, 		"Wrong horse.name while checking runner without shoes and with earnings")
			# assert_equal("M", 				runner_to_check.horse.sex, 			"Wrong horse.sex while checking runner without shoes and with earnings")
			# assert_equal(false, 			runner_to_check.is_favorite, 		"Wrong is_favorite while checking runner without shoes and with earnings")
			# assert_equal("F. Nivard", 		runner_to_check.jockey.name, 		"Wrong jockey.name while checking runner without shoes and with earnings")
			# assert_equal(nil, 				runner_to_check.load_handicap, 		"Wrong load_handicap while checking runner without shoes and with earnings")
			# assert_equal(nil, 				runner_to_check.load_ride, 			"Wrong load_ride while checking runner without shoes and with earnings")
			# assert_equal(false, 			runner_to_check.non_runner, 		"Wrong is_favorite while checking runner without shoes and with earnings")
			# assert_equal(9, 				runner_to_check.number, 			"Wrong number while checking runner without shoes and with earnings")
			# assert_equal(race_to_test, 		runner_to_check.race, 				"Wrong race while checking runner without shoes and with earnings")
			# assert_equal(0.0, 				runner_to_check.single_rating, 		"Wrong single_rating while checking runner without shoes and with earnings")
			# assert_equal("", 				runner_to_check.url, 				"Wrong url while checking runner without shoes and with earnings")
			# assert_equal("O. Tjomsland", 	runner_to_check.trainer.name, 		"Wrong trainer.name while checking runner without shoes and with earnings")
			# assert_equal(2100, 				runner_to_check.distance, 			"Wrong distance while checking runner without shoes and with earnings")
			# assert_equal(100566.00, 		runner_to_check.earnings_career, 	"Wrong earnings_career while checking runner without shoes and with earnings")
			# assert_equal("", 				runner_to_check.shoes, 				"Wrong shoes while checking runner without shoes and with earnings")
			# @logger.info("Tests for runner without shoes and with earnings OK.")

			# runner_to_check = runner_hash[3]
			# assert_equal(7, 					runner_to_check.age, 				"Wrong age while checking runner with shoes (front) and earnings")
			# assert_equal(nil, 					runner_to_check.blinder, 			"Wrong blinder while checking runner with shoes front) and earnings")
			# assert_equal(nil, 					runner_to_check.draw, 				"Wrong draw while checking runner with shoes (front) and earnings")
			# assert_equal("0a2a1a1a(1", 			runner_to_check.history, 			"Wrong history while checking runner with shoes (front) and earnings")
			# assert_equal("Doktor Jaros", 		runner_to_check.horse.name, 		"Wrong horse.name while checking runner with shoes (front) and earnings")
			# assert_equal("M", 					runner_to_check.horse.sex, 			"Wrong horse.sex while checking runner with shoes (front) and earnings")
			# assert_equal(false, 				runner_to_check.is_favorite, 		"Wrong is_favorite while checking runner with shoes (front) and earnings")
			# assert_equal("G. Gudmestad", 		runner_to_check.jockey.name, 		"Wrong jockey.name while checking runner with shoes (front) and earnings")
			# assert_equal(nil, 					runner_to_check.load_handicap, 		"Wrong load_handicap while checking runner with shoes (front) and earnings")
			# assert_equal(nil, 					runner_to_check.load_ride, 			"Wrong load_ride while checking runner with shoes (front) and earnings")
			# assert_equal(false, 				runner_to_check.non_runner, 		"Wrong is_favorite while checking runner with shoes (front) and earnings")
			# assert_equal(3, 					runner_to_check.number, 			"Wrong number while checking runner with shoes (front) and earnings")
			# assert_equal(race_to_test, 			runner_to_check.race, 				"Wrong race while checking runner with shoes (front) and earnings")
			# assert_equal(0.0, 					runner_to_check.single_rating, 		"Wrong single_rating while checking runner with shoes (front) and earnings")
			# assert_equal("", 					runner_to_check.url, 				"Wrong url while checking runner with shoes (front) and earnings")
			# assert_equal("G. Gudmestad", 		runner_to_check.trainer.name, 		"Wrong trainer.name while checking runner with shoes (front) and earnings")
			# assert_equal(2100, 					runner_to_check.distance, 			"Wrong distance while checking runner with shoes (front) and earnings")
			# assert_equal(87843.00, 				runner_to_check.earnings_career, 	"Wrong earnings_career while checking runner with shoes (front) and earnings")
			# assert_equal("DEFERRE_ANTERIEURS", 	runner_to_check.shoes, 				"Wrong shoes while checking runner with shoes (front) and earnings")
			# @logger.info("Tests for runner with shoes (front) and earnings OK.")

			# runner_to_check = runner_hash[11]
			# assert_equal(10, 								runner_to_check.age, 				"Wrong age while checking runner with shoes (front & back) off and earnings")
			# assert_equal(nil, 								runner_to_check.blinder, 			"Wrong blinder while checking runner with shoes (front & back) off and earnings")
			# assert_equal(nil, 								runner_to_check.draw, 				"Wrong draw while checking runner with shoes (front & back) off and earnings")
			# assert_equal("4a0a6a5a(1", 						runner_to_check.history, 			"Wrong history while checking runner with shoes (front & back) off and earnings")
			# assert_equal("Metkutus", 						runner_to_check.horse.name, 		"Wrong horse.name while checking runner with shoes (front & back) off and earnings")
			# assert_equal("M", 								runner_to_check.horse.sex, 			"Wrong horse.sex while checking runner with shoes (front & back) off and earnings")
			# assert_equal(false, 							runner_to_check.is_favorite, 		"Wrong is_favorite while checking runner with shoes (front & back) off and earnings")
			# assert_equal("J.m. Paavola", 					runner_to_check.jockey.name, 		"Wrong jockey.name while checking runner with shoes (front & back) off and earnings")
			# assert_equal(nil, 								runner_to_check.load_handicap, 		"Wrong load_handicap while checking runner with shoes (front & back) off and earnings")
			# assert_equal(nil, 								runner_to_check.load_ride, 			"Wrong load_ride while checking runner with shoes (front & back) off and earnings")
			# assert_equal(false, 							runner_to_check.non_runner, 		"Wrong is_favorite while checking runner with shoes (front & back) off and earnings")
			# assert_equal(11, 								runner_to_check.number, 			"Wrong number while checking runner with shoes (front & back) off and earnings")
			# assert_equal(race_to_test, 						runner_to_check.race, 				"Wrong race while checking runner with shoes (front & back) off and earnings")
			# assert_equal(0.0, 								runner_to_check.single_rating, 		"Wrong single_rating while checking runner with shoes (front & back) off and earnings")
			# assert_equal("", 								runner_to_check.url, 				"Wrong url while checking runner with shoes (front & back) off and earnings")
			# assert_equal("J.m. Paavola", 					runner_to_check.trainer.name, 		"Wrong trainer.name while checking runner with shoes (front & back) off and earnings")
			# assert_equal(2100, 								runner_to_check.distance, 			"Wrong distance while checking runner with shoes (front & back) off and earnings")
			# assert_equal(86140.00, 							runner_to_check.earnings_career, 	"Wrong earnings_career while checking runner with shoes (front & back) off and earnings")
			# assert_equal("DEFERRE_ANTERIEURS_POSTERIEURS",	runner_to_check.shoes, 				"Wrong shoes while checking runner with shoes (front & back) off and earnings")
			# @logger.info("Tests for runner (with trainer) with front and back shoes off OK.")

			
			## -> Getting the third race (without draw)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8_runners.htm")
			
			# race_to_test = Race::new() # R2_C8
			
			## the function to test
			# runner_hash = @crawler.fetch_runners_shallow(race_to_test)
			
			## Checking we did get a list and the right one
			# assert_equal(11, runner_hash.size, "Wrong number of runners fetched")
			
			## Checking the fetched results
			# runner_to_check = runner_hash[8]
			# assert_equal(5, 					runner_to_check.age, 				"Wrong age while checking runner without draw")
			# assert_equal("OEILLERES_CLASSIQUE",	runner_to_check.blinder, 			"Wrong blinder while checking runner without draw")
			# assert_equal(nil, 					runner_to_check.draw, 				"Wrong draw while checking runner without draw")
			# assert_equal("3a0h8h3s2s6s", 		runner_to_check.history, 			"Wrong history while checking runner without draw")
			# assert_equal("Becqualink", 			runner_to_check.horse.name, 		"Wrong horse.name while checking runner without draw")
			# assert_equal("H", 					runner_to_check.horse.sex, 			"Wrong horse.sex while checking runner without draw")
			# assert_equal(false, 				runner_to_check.is_favorite, 		"Wrong is_favorite while checking runner without draw")
			# assert_equal("F.corallo", 			runner_to_check.jockey.name, 		"Wrong jockey.name while checking runner without draw")
			# assert_equal(66, 					runner_to_check.load_handicap, 		"Wrong load_handicap while checking runner without draw")
			# assert_equal(64, 					runner_to_check.load_ride, 			"Wrong load_ride while checking runner without draw")
			# assert_equal(false, 				runner_to_check.non_runner, 		"Wrong is_favorite while checking runner without draw")
			# assert_equal(8, 					runner_to_check.number, 			"Wrong number while checking runner without draw")
			# assert_equal(race_to_test, 			runner_to_check.race, 				"Wrong race while checking runner without draw")
			# assert_equal(0.0, 					runner_to_check.single_rating, 		"Wrong single_rating while checking runner without draw")
			# assert_equal("", 					runner_to_check.url, 				"Wrong url while checking runner without draw")
			# assert_equal("C.scandella", 		runner_to_check.trainer.name, 		"Wrong trainer.name while checking runner without draw")
			# assert_equal(nil, 					runner_to_check.distance, 			"Wrong distance while checking runner without draw")
			# assert_equal(nil, 					runner_to_check.earnings_career, 	"Wrong earnings_career while checking runner without draw")
			# assert_equal(nil, 					runner_to_check.shoes, 				"Wrong shoes while checking runner without draw")
			# @logger.info("Tests for runner without draw OK.")
			
			# runner_to_check = runner_hash[9]
			# assert_equal(5, 					runner_to_check.age, 				"Wrong age while checking runner without draw or history but with load_ride")
			# assert_equal("SANS_OEILLERES", 		runner_to_check.blinder, 			"Wrong blinder while checking runner without draw or history but with load_ride")
			# assert_equal(nil, 					runner_to_check.draw, 				"Wrong draw while checking runner without draw or history but with load_ride")
			# assert_equal("", 					runner_to_check.history, 			"Wrong history while checking runner without draw or history but with load_ride")
			# assert_equal("Velours D'allier",	runner_to_check.horse.name, 		"Wrong horse.name while checking runner without draw or history but with load_ride")
			# assert_equal("H", 					runner_to_check.horse.sex, 			"Wrong horse.sex while checking runner without draw or history but with load_ride")
			# assert_equal(false, 				runner_to_check.is_favorite, 		"Wrong is_favorite while checking runner without draw or history but with load_ride")
			# assert_equal("J.zerourou", 			runner_to_check.jockey.name, 		"Wrong jockey.name while checking runner without draw or history but with load_ride")
			# assert_equal(66, 					runner_to_check.load_handicap, 		"Wrong load_handicap while checking runner without draw or history but with load_ride")
			# assert_equal(64, 					runner_to_check.load_ride, 			"Wrong load_ride while checking runner without draw or history but with load_ride")
			# assert_equal(false, 				runner_to_check.non_runner, 		"Wrong is_favorite while checking runner without draw or history but with load_ride")
			# assert_equal(9, 					runner_to_check.number, 			"Wrong number while checking runner without draw or history but with load_ride")
			# assert_equal(race_to_test, 			runner_to_check.race, 				"Wrong race while checking runner without draw or history but with load_ride")
			# assert_equal(0.0, 					runner_to_check.single_rating, 		"Wrong single_rating while checking runner without draw or history but with load_ride")
			# assert_equal("", 					runner_to_check.url, 				"Wrong url while checking runner without draw or history but with load_ride")
			# assert_equal("E.clayeux", 			runner_to_check.trainer.name, 		"Wrong trainer.name while checking runner without draw or history but with load_ride")
			# assert_equal(nil, 					runner_to_check.distance, 			"Wrong distance while checking runner without draw or history but with load_ride")
			# assert_equal(nil, 					runner_to_check.earnings_career, 	"Wrong earnings_career while checking runner without draw or history but with load_ride")
			# assert_equal(nil, 					runner_to_check.shoes, 				"Wrong shoes while checking runner without draw or history but with load_ride")
			# @logger.info("Tests for runner without draw or history but with load_ride OK.")
			
			
			## Checking the fetched results
			# runner_to_check = runner_hash[4]
			# assert_equal(5, 						runner_to_check.age, 				"Wrong age while checking runner without draw but with load_ride and history")
			# assert_equal("OEILLERES_AUSTRALIENNES",	runner_to_check.blinder, 			"Wrong blinder while checking runner without draw but with load_ride and history")
			# assert_equal(nil, 						runner_to_check.draw, 				"Wrong draw while checking runner without draw but with load_ride and history")
			# assert_equal("4h(13)1h4p2s", 			runner_to_check.history, 			"Wrong history while checking runner without draw but with load_ride and history")
			# assert_equal("Va Longtemps", 			runner_to_check.horse.name, 		"Wrong horse.name while checking runner without draw but with load_ride and history")
			# assert_equal("F", 						runner_to_check.horse.sex, 			"Wrong horse.sex while checking runner without draw but with load_ride and history")
			# assert_equal(false, 					runner_to_check.is_favorite, 		"Wrong is_favorite while checking runner without draw but with load_ride and history")
			# assert_equal("J.plouganou", 			runner_to_check.jockey.name, 		"Wrong jockey.name while checking runner without draw but with load_ride and history")
			# assert_equal(67, 						runner_to_check.load_handicap, 		"Wrong load_handicap while checking runner without draw but with load_ride and history")
			# assert_equal(0, 						runner_to_check.load_ride, 			"Wrong load_ride while checking runner without draw but with load_ride and history")
			# assert_equal(false, 					runner_to_check.non_runner, 		"Wrong is_favorite while checking runner without draw but with load_ride and history")
			# assert_equal(4, 						runner_to_check.number, 			"Wrong number while checking runner without draw but with load_ride and history")
			# assert_equal(race_to_test, 				runner_to_check.race, 				"Wrong race while checking runner without draw but with load_ride and history")
			# assert_equal(0.0, 						runner_to_check.single_rating, 		"Wrong single_rating while checking runner without draw but with load_ride and history")
			# assert_equal("", 						runner_to_check.url, 				"Wrong url while checking runner without draw but with load_ride and history")
			# assert_equal("E.clayeux", 				runner_to_check.trainer.name, 		"Wrong trainer.name while checking runner without draw but with load_ride and history")
			# assert_equal(nil, 						runner_to_check.distance, 			"Wrong distance while checking runner without draw but with load_ride and history")
			# assert_equal(nil, 						runner_to_check.earnings_career, 	"Wrong earnings_career while checking runner without draw but with load_ride and history")
			# assert_equal(nil, 						runner_to_check.shoes, 				"Wrong shoes while checking runner without draw but with load_ride and history")
			# @logger.info("Tests for runner without draw but with load_ride and history OK.")
			
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_race_results
		
		# @logger.info("Testing fetch race results")
		# begin
			## Setting up 
			## -> Getting the first race (with distance)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1.htm")
			
			# race_to_test = Race::new() # R4_C1
			# runner = nil
			
			## the function to test
			# runner_hash = @crawler.fetch_race_results(race_to_test)
			
			## Checking we did get a list and the right one
			# assert("Runner list is nil", runner_hash != nil)
			# assert_equal(12, runner_hash.size)
			
			## Checking the fetched results
			## first place (distance == "")
			# runner_to_check = runner_hash[2]
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_BRAVE_VISION.htm", 
								# 	runner_to_check.url, 			"Wrong url while checking first place")
			# assert_equal("", 	runner_to_check.commentary, 	"Wrong commentary while checking first place")
			# assert_equal("", 	runner_to_check.distance, 		"Wrong distance while checking first place")
			# assert_equal(1, 	runner_to_check.final_place, 	"Wrong final_place while checking first place")
			# assert_equal(2, 	runner_to_check.number, 		"Wrong number while checking first place")
			# assert_equal(29.9, 	runner_to_check.single_rating, 	"Wrong single_rating while checking first place")
			# assert_equal("", 	runner_to_check.time, 			"Wrong time while checking first place")
			# assert_equal(false, runner_to_check.is_favorite, 	"Wrong is_favorite while checking first place")
			# assert_equal(false, runner_to_check.non_runner, 	"Wrong non_runner while checking first place")
			# assert_equal(false, runner_to_check.disqualified, 	"Wrong disqualified while checking first place")
			# @logger.info("Tests for runner (first place) OK.")
			
			## After 10th place (final_place == nil)
			# runner_to_check = runner_hash[10]
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_LONG_SHOT.htm", 
								# 	runner_to_check.url, 			"Wrong url while checking runner arrived after 10th place")
			# assert_equal("", 		runner_to_check.commentary, 	"Wrong commentary while checking runner arrived after 10th place")
			# assert_equal("", 		runner_to_check.distance, 		"Wrong distance while checking runner arrived after 10th place")
			# assert_equal(nil, 		runner_to_check.final_place, 	"Wrong final_place while checking runner arrived after 10th place")
			# assert_equal(10, 		runner_to_check.number, 		"Wrong number while checking runner arrived after 10th place")
			# assert_equal(23.9, 		runner_to_check.single_rating, 	"Wrong single_rating while checking runner arrived after 10th place")
			# assert_equal("", 		runner_to_check.time, 			"Wrong time while checking runner arrived after 10th place")
			# assert_equal(false, 	runner_to_check.is_favorite, 	"Wrong is_favorite while checking runner arrived after 10th place")
			# assert_equal(false, 	runner_to_check.non_runner, 	"Wrong non_runner while checking runner arrived after 10th place")
			# assert_equal(false, 	runner_to_check.disqualified, 	"Wrong disqualified while checking runner arrived after 10th place")
			# @logger.info("Tests for runner (After 10th place) OK.")
			
			## Non-runner (non_runner == true, final_place == nil, single_rating == nil)
			# runner_to_check = runner_hash[11]
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_OUT_MY_WAY.htm", 
								# runner_to_check.url, 			"Wrong url while checking non-runner")
			# assert_equal("", 	runner_to_check.commentary, 	"Wrong commentary while checking non-runner")
			# assert_equal("", 	runner_to_check.distance, 		"Wrong disqualified while checking non-runner")
			# assert_equal(nil, 	runner_to_check.final_place, 	"Wrong disqualified while checking non-runner")
			# assert_equal(11, 	runner_to_check.number, 		"Wrong disqualified while checking non-runner")
			# assert_equal(nil, 	runner_to_check.single_rating, 	"Wrong disqualified while checking non-runner")
			# assert_equal("", 	runner_to_check.time, 			"Wrong disqualified while checking non-runner")
			# assert_equal(false, runner_to_check.is_favorite, 	"Wrong disqualified while checking non-runner")
			# assert_equal(true, 	runner_to_check.non_runner, 	"Wrong disqualified while checking non-runner")
			# assert_equal(false, runner_to_check.disqualified, 	"Wrong disqualified while checking non-runner")
			# @logger.info("Tests for Non-runner OK.")
			
			## Normal
			# runner_to_check = runner_hash[1]
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_AMERICAN_TIGER.htm", 
												# runner_to_check.url, 			"Wrong disqualified while checking first place")
			# assert_equal("", 					runner_to_check.commentary, 	"Wrong disqualified while checking normal runner")
			# assert_equal("5 Longueurs 1/2", 	runner_to_check.distance, 		"Wrong disqualified while checking normal runner")
			# assert_equal(3, 					runner_to_check.final_place, 	"Wrong disqualified while checking normal runner")
			# assert_equal(1, 					runner_to_check.number, 		"Wrong disqualified while checking normal runner")
			# assert_equal(4.8, 					runner_to_check.single_rating, 	"Wrong disqualified while checking normal runner")
			# assert_equal("", 					runner_to_check.time, 			"Wrong disqualified while checking normal runner")
			# assert_equal(false, 				runner_to_check.is_favorite, 	"Wrong disqualified while checking normal runner")
			# assert_equal(false, 				runner_to_check.non_runner, 	"Wrong disqualified while checking normal runner")
			# assert_equal(false, 				runner_to_check.disqualified, 	"Wrong disqualified while checking normal runner")
			# @logger.info("Tests for normal runner OK.")
			
			## Favorite (is_favorite == true)
			# runner_to_check = runner_hash[6]
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_ISPHAN.htm", 
											# runner_to_check.url, 			"Wrong disqualified while checking first place")
			# assert_equal("", 				runner_to_check.commentary, 	"Wrong disqualified while checking favorite")
			# assert_equal("1/2 Longueur", 	runner_to_check.distance, 		"Wrong disqualified while checking favorite")
			# assert_equal(2, 				runner_to_check.final_place, 	"Wrong disqualified while checking favorite")
			# assert_equal(6, 				runner_to_check.number, 		"Wrong disqualified while checking favorite")
			# assert_equal(4.7, 				runner_to_check.single_rating, 	"Wrong disqualified while checking favorite")
			# assert_equal("", 				runner_to_check.time, 			"Wrong disqualified while checking favorite")
			# assert_equal(true, 				runner_to_check.is_favorite, 	"Wrong disqualified while checking favorite")
			# assert_equal(false, 			runner_to_check.non_runner, 	"Wrong disqualified while checking favorite")
			# assert_equal(false, 			runner_to_check.disqualified, 	"Wrong disqualified while checking favorite")
			# @logger.info("Tests for Favorite runner OK.")
			# @logger.info("Tests for race with distance OK.")
			
			## -> Getting the second race (with time)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1.htm")
			
			# race_to_test = Race::new() # R3_C1
			
			## the function to test
			# runner_hash = @crawler.fetch_race_results(race_to_test)
			
			## Checking we did get a list and the right one
			# assert_equal(14, runner_hash.size)
			
			## Checking the fetched results
			# runner_to_check = runner_hash[11]
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1_runner_QUASAR_DE_KACY.htm", 
										# runner_to_check.url, 			"Wrong url while checking with commentary and time")
			# assert_equal("Dans le dernier tiers du peloton, à la corde, a vite été sollicité et n'a jamais pu se rapprocher.", 
										# runner_to_check.commentary, 	"Wrong commentary while checking with commentary and time")
			# assert_equal("", 			runner_to_check.distance, 		"Wrong distance while checking with commentary and time")
			# assert_equal(10, 			runner_to_check.final_place, 	"Wrong final_place while checking with commentary and time")
			# assert_equal(11, 			runner_to_check.number, 		"Wrong number while checking with commentary and time")
			# assert_equal(100.9, 		runner_to_check.single_rating, 	"Wrong single_rating while checking with commentary and time")
			# assert_equal("1'16\"90", 	runner_to_check.time, 			"Wrong time while checking with commentary and time")
			# assert_equal(false, 		runner_to_check.is_favorite, 	"Wrong is_favorite while checking with commentary and time")
			# assert_equal(false, 		runner_to_check.non_runner, 	"Wrong non_runner while checking with commentary and time")
			# assert_equal(false, 		runner_to_check.disqualified, 	"Wrong disqualified while checking with commentary and time")
			# @logger.info("Tests for runner with commentary and time OK.")
			
			# runner_to_check = runner_hash[10]
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1_runner_ROC_BERRY.htm", 
										# runner_to_check.url, 			"Wrong url while checking with commentary and 0 time")
			# assert_equal("S'est vite enlevé.", 	
										# runner_to_check.commentary, 	"Wrong commentary while checking with commentary and 0 time")
			# assert_equal("", 			runner_to_check.distance, 		"Wrong distance while checking with commentary and 0 time")
			# assert_equal(nil, 			runner_to_check.final_place, 	"Wrong final_place while checking with commentary and 0 time")
			# assert_equal(10, 			runner_to_check.number, 		"Wrong number while checking with commentary and 0 time")
			# assert_equal(45.2, 			runner_to_check.single_rating, 	"Wrong single_rating while checking with commentary and 0 time")
			# assert_equal("0'00\"00", 	runner_to_check.time, 			"Wrong time while checking with commentary and 0 time")
			# assert_equal(false, 		runner_to_check.is_favorite, 	"Wrong is_favorite while checking with commentary and 0 time")
			# assert_equal(false, 		runner_to_check.non_runner, 	"Wrong non_runner while checking with commentary and 0 time")
			# assert_equal(true, 			runner_to_check.disqualified, 	"Wrong disqualified while checking with commentary and 0 time")
			# @logger.info("Tests for runner with commentary and 0 time OK.")
			
			
			## checking that there is a favorite
			# favorite_runner = nil
			# runner_hash.each_value do |runner|
				# if runner.is_favorite then
					# favorite_runner = runner
					# break
				# end
			# end
			# assert("No favorite found in race!", favorite_runner != nil)
			
			# @logger.info("Tests for race with time OK.")
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_runner
		
		# @logger.info("Testing fetch runner")
		# begin
			## Setting up 
			## -> Getting the first race (with distance)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4.htm")
			
			# race_to_test = Race::new() # R4_C4
			# runner = nil
			
			## fetching the hash of runners (to get the URLs)
			# runner_results_hash = @crawler.fetch_race_results(race_to_test)
			
			## Checking we did get a list and the right one
			# assert("Runner list is nil", runner_results_hash != nil)
			# assert_equal(17, runner_results_hash.size, "Wrong number of runners fetched")
			
			## fetching the runners' shallow data (as if we're in the fetch_runners function)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4_runners.htm")
			# runner_shallow_hash = @crawler.fetch_runners_shallow(race_to_test)
			
			# assert_equal(17, runner_shallow_hash.size, "Wrong number of runners shallow fetched")
			
			## putting each runner's URL
			# runner_shallow_hash.each do |key, shallow_runner|
				## @logger.debug("number = " + key.to_s + ", shallow_runner: " + shallow_runner.to_s)
				## @logger.debug("current_number: " + current_number.to_s)
				# result_runner = runner_results_hash[key]
				## @logger.debug("url before: " + shallow_runner.url)
				## @logger.debug("result_runner url: " + result_runner.url)
				# shallow_runner.url = result_runner.url
				
				## @logger.debug("url after: " + shallow_runner.url)
			# end
			
			## the function to test
			# runner_shallow_hash.each do |key, shallow_runner|
				# shallow_runner = @crawler.fetch_runner(shallow_runner)
			# end
			
			
			## runner without victories or breeder
			# runner_to_check = runner_shallow_hash[1]
			# assert_equal(7, 							runner_to_check.races_run, 					"Wrong races_run while checking runner without victories or breeder")
			# assert_equal(0, 							runner_to_check.victories, 					"Wrong victories while checking runner without victories or breeder")
			# assert_equal(6, 							runner_to_check.places, 					"Wrong places while checking runner without victories or breeder")
			# assert_equal(3024.00, 						runner_to_check.earnings_career, 			"Wrong earnings_career while checking runner without victories or breeder")			
			# assert_equal(1049.00, 						runner_to_check.earnings_current_year, 		"Wrong earnings_current_year while checking runner without victories or breeder")
			# assert_equal(1975.00, 						runner_to_check.earnings_last_year, 		"Wrong earnings_last_year while checking runner without victories or breeder")
			# assert_equal(0.00, 							runner_to_check.earnings_victory, 			"Wrong earnings_victory while checking runner without victories or breeder")
			# assert_equal(nil, 							runner_to_check.description, 				"Wrong description while checking runner without victories or breeder")
			# assert_equal("PUR-SANG", 					runner_to_check.horse.breed, 				"Wrong horse.breed while checking runner without victories or breeder")
			# assert_equal(nil, 							runner_to_check.horse.coat, 				"Wrong horse.coat while checking runner without victories or breeder")
			# assert_equal("", 							runner_to_check.breeder, 					"Wrong breeder while checking runner without victories or breeder")
			# assert_equal("C MAYHEW", 					runner_to_check.trainer, 					"Wrong trainer while checking runner without victories or breeder")
			# assert_equal(1, 							runner_to_check.number, 					"Wrong number while checking runner without victories or breeder")
			# assert_equal("MESSRS A LANG & R J MAYHEW",	runner_to_check.owner, 						"Wrong owner while checking runner without victories or breeder")
			# assert_equal("antonius pius", 				runner_to_check.horse.father.name, 			"Wrong horse.father.name while checking runner without victories or breeder")
			# assert_equal("cherry flower", 				runner_to_check.horse.mother.name, 			"Wrong horse.mother.name while checking runner without victories or breeder")
			# assert_equal("goldkeeper", 					runner_to_check.horse.mother.father.name, 	"Wrong horse.mother.father.name while checking runner without victories or breeder")
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4_runner_ANTONIA_MAJOR.htm", 				
														# runner_to_check.url, 						"Wrong url while checking runner without victories or breeder")
			# @logger.info("Tests for runner (without victories or breeder) OK.")
			
			## runner without earnings, victories or places
			# runner_to_check = runner_shallow_hash[7]
			# assert_equal(3, 				runner_to_check.races_run, 					"Wrong races_run while checking runner without earnings, victories or places")
			# assert_equal(0, 				runner_to_check.victories, 					"Wrong victories while checking runner without earnings, victories or places")
			# assert_equal(0, 				runner_to_check.places, 					"Wrong places while checking runner without earnings, victories or places")
			# assert_equal(0.00, 				runner_to_check.earnings_career, 			"Wrong earnings_career while checking runner without earnings, victories or places")			
			# assert_equal(0.00, 				runner_to_check.earnings_current_year, 		"Wrong earnings_current_year while checking runner without earnings, victories or places")
			# assert_equal(0.00, 				runner_to_check.earnings_last_year, 		"Wrong earnings_last_year while checking runner without earnings, victories or places")
			# assert_equal(0.00, 				runner_to_check.earnings_victory, 			"Wrong earnings_victory while checking runner without earnings, victories or places")
			# assert_equal(nil, 				runner_to_check.description, 				"Wrong description while checking runner without earnings, victories or places")
			# assert_equal("PUR-SANG", 		runner_to_check.horse.breed, 				"Wrong horse.breed while checking runner without earnings, victories or places")
			# assert_equal(nil, 				runner_to_check.horse.coat, 				"Wrong horse.coat while checking runner without earnings, victories or places")
			# assert_equal("", 				runner_to_check.breeder, 					"Wrong breeder while checking runner without earnings, victories or places")
			# assert_equal(7, 				runner_to_check.number, 					"Wrong number while checking runner without earnings, victories or places")
			# assert_equal("S M FERREIRA", 	runner_to_check.trainer, 					"Wrong trainer while checking runner without earnings, victories or places")
			# assert_equal("MR S M FERREIRA",	runner_to_check.owner, 						"Wrong owner while checking runner without earnings, victories or places")
			# assert_equal("casey tibbs", 	runner_to_check.horse.father.name, 			"Wrong horse.father.name while checking runner without earnings, victories or places")
			# assert_equal("dahlia's legacy", runner_to_check.horse.mother.name, 			"Wrong horse.mother.name while checking runner without earnings, victories or places")
			# assert_equal("dahar", 			runner_to_check.horse.mother.father.name, 	"Wrong horse.mother.father.name while checking runner without earnings, victories or places")
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4_runner_DAHLIA%27S_DESTINY.htm", 				
											# runner_to_check.url, 						"Wrong url while checking runner without earnings, victories or places")
			# @logger.info("Tests for runner (without earnings, victories or places) OK.")
			
			
			## -> Getting the second race (with time)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8.htm")
			
			# race_to_test = Race::new() # R2_C8
			# runner = nil
			
			## fetching the hash of runners (to get the URLs)
			# runner_results_hash = @crawler.fetch_race_results(race_to_test)
			
			## Checking we did get a list and the right one
			# assert("Runner list is nil", runner_results_hash != nil)
			# assert_equal(11, runner_results_hash.size, "Wrong number of runners fetched")
			
			## fetching the runners' shallow data (as if we're in the fetch_runners function)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8_runners.htm")
			# runner_shallow_hash = @crawler.fetch_runners_shallow(race_to_test)
			
			## putting each runner's URL
			# runner_shallow_hash.each do |key, shallow_runner|
				# result_runner = runner_results_hash[shallow_runner.number]
				# shallow_runner.url = result_runner.url
			# end
			
			## the function to test
			# runner_shallow_hash.each do |key, shallow_runner|
				# shallow_runner = @crawler.fetch_runner(shallow_runner)
			# end
			
			## runner without earnings_current_year
			# runner_to_check = runner_shallow_hash[3]
			# assert_equal(12, 					runner_to_check.races_run, 					"Wrong races_run while checking runner without without earnings_current_year")
			# assert_equal(2, 					runner_to_check.victories, 					"Wrong victories while checking runner without without earnings_current_year")
			# assert_equal(6, 					runner_to_check.places, 					"Wrong places while checking runner without without earnings_current_year")
			# assert_equal(68300.00, 				runner_to_check.earnings_career, 			"Wrong earnings_career while checking runner without without earnings_current_year")			
			# assert_equal(0.00, 					runner_to_check.earnings_current_year, 		"Wrong earnings_current_year while checking runner without without earnings_current_year")
			# assert_equal(53900.00, 				runner_to_check.earnings_last_year, 		"Wrong earnings_last_year while checking runner without without earnings_current_year")
			# assert_equal(36480.00, 				runner_to_check.earnings_victory, 			"Wrong earnings_victory while checking runner without without earnings_current_year")
			# assert_equal(nil, 					runner_to_check.description, 				"Wrong description while checking runner without without earnings_current_year")
			# assert_equal("PUR-SANG", 			runner_to_check.horse.breed, 				"Wrong horse.breed while checking runner without without earnings_current_year")
			# assert_equal("GRIS FONCE", 			runner_to_check.horse.coat, 				"Wrong horse.coat while checking runner without without earnings_current_year")
			# assert_equal("HARAS DE SAINT-VOIR",	runner_to_check.breeder, 					"Wrong breeder while checking runner without without earnings_current_year")
			# assert_equal("MACAIRE (S)", 		runner_to_check.trainer, 					"Wrong breeder while checking runner without without earnings_current_year")
			# assert_equal(3, 					runner_to_check.number, 					"Wrong number while checking runner without earnings_current_year")
			# assert_equal("HARAS DE SAINT-VOIR",	runner_to_check.owner, 						"Wrong breeder while checking runner without without earnings_current_year")
			# assert_equal("sacro saint", 		runner_to_check.horse.father.name, 			"Wrong horse.father.name while checking runner without without earnings_current_year")
			# assert_equal("biblique", 			runner_to_check.horse.mother.name, 			"Wrong horse.mother.name while checking runner without without earnings_current_year")
			# assert_equal("saint cyrien", 		runner_to_check.horse.mother.father.name, 	"Wrong horse.mother.father.name while checking runner without without earnings_current_year")
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8_runner_VOTEZ_POUR_MOI.htm", 				
												# runner_to_check.url, 					"Wrong url while checking runner without without earnings_current_year")
			# @logger.info("Tests for runner (without earnings_current_year) OK.")
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
end