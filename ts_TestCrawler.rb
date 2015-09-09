﻿require './TestSuite.rb'
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
			
			# @logger.info("All tests for test_fetch_meetings OK.")
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
			
			# @logger.info("All tests for test_fetch_meeting_shallow OK.")
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
			# @logger.info("All tests for test_fetch_race OK.")
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
			# @logger.info("All tests for test_fetch_weather OK.")
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
			runner_from_result_list = result_list[2]
			assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm", 
								runner_from_result_list.url, 						"Wrong url while checking first place is_favorite")
			assert_equal("", 	runner_from_result_list.commentary, 				"Wrong commentary while checking first place is_favorite")
			assert_equal("", 	runner_from_result_list.distance, 					"Wrong distance while checking first place is_favorite")
			assert_equal(1, 	runner_from_result_list.final_place, 				"Wrong final_place while checking first place is_favorite")
			assert_equal(2, 	runner_from_result_list.number, 					"Wrong number while checking first place is_favorite")
			assert_equal(2.9, 	runner_from_result_list.single_rating_after_race, 	"Wrong single_rating_after_race while checking first place is_favorite")
			assert_equal("", 	runner_from_result_list.time, 						"Wrong time while checking first place is_favorite")
			assert_equal(true, 	runner_from_result_list.is_favorite, 				"Wrong is_favorite while checking first place is_favorite")
			assert_equal(false, runner_from_result_list.non_runner, 				"Wrong non_runner while checking first place is_favorite")
			assert_equal(false, runner_from_result_list.disqualified, 				"Wrong disqualified while checking first place is_favorite")
			assert_equal("", 	runner_from_result_list.time, 						"Wrong time while checking first place is_favorite")
			@logger.info("All tests for runner first place is_favorite OK.")
			
			runner_from_list_runners = list_runners[2]
			assert_equal(5, 			runner_from_list_runners.age, 					"Wrong age while checking runner without shoes and with earnings")
			assert_equal("OEILLERES_CLASSIQUE", 			
										runner_from_list_runners.blinder, 				"Wrong blinder while checking runner without shoes and with earnings")
			assert_equal(nil, 			runner_from_list_runners.commentary, 			"Wrong commentary while checking first place")
			assert_equal(nil, 			runner_from_list_runners.disqualified, 			"Wrong disqualified while checking first place")
			assert_equal(nil, 			runner_from_list_runners.distance, 				"Wrong distance while checking first place")
			assert_equal(11, 			runner_from_list_runners.draw, 					"Wrong draw while checking runner without shoes and with earnings")
			assert_equal(3527.00, 		runner_from_list_runners.earnings_current_year,	"Wrong earnings_current_year while checking runner first place is_favorite")
			assert_equal(54359.00, 		runner_from_list_runners.earnings_career, 		"Wrong earnings_career while checking runner first place is_favorite")
			assert_equal(8944.00, 		runner_from_list_runners.earnings_last_year, 	"Wrong earnings_last_year while checking runner first place is_favorite")
			assert_equal(7098.00, 		runner_from_list_runners.earnings_victory, 		"Wrong earnings_victory while checking runner first place is_favorite")
			assert_equal(nil, 			runner_from_list_runners.final_place, 			"Wrong final_place while checking first place")
			assert_equal("2p2p3p6p", 	runner_from_list_runners.history, 				"Wrong history while checking runner without shoes and with earnings")
			assert_equal(nil, 			runner_from_list_runners.is_favorite, 			"Wrong is_favorite while checking first place")
			assert_equal(60.0, 			runner_from_list_runners.load_handicap, 		"Wrong load_handicap while checking runner without shoes and with earnings")
			assert_equal(0.0, 			runner_from_list_runners.load_ride, 			"Wrong load_ride while checking runner without shoes and with earnings")
			assert_equal(false, 		runner_from_list_runners.non_runner, 			"Wrong non_runner while checking first place")
			assert_equal(2, 			runner_from_list_runners.number, 				"Wrong number while checking first place")
			assert_equal(race_to_test, 	runner_from_list_runners.race, 					"Wrong race while checking runner without shoes and with earnings")
			assert_equal(nil, 			runner_from_list_runners.shoes, 				"Wrong shoes while checking runner without shoes and with earnings")
			assert_equal(0.0, 			runner_from_list_runners.single_rating_before_race,
																						"Wrong single_rating_before_race while checking runner without shoes and with earnings")
			assert_equal(nil, 			runner_from_list_runners.time, 					"Wrong time while checking first place")
			assert_equal("", 			runner_from_list_runners.url, 					"Wrong url while checking first place")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm", 
			# 							runner_from_list_runners.url, 					"Wrong url while checking first place")
			assert_equal("", 			runner_from_list_runners.breeder.name, 			"Wrong breeder.name while checking runner first place is_favorite")
			assert_equal("P Strydom", 	runner_from_list_runners.jockey.name, 			"Wrong jockey.name while checking runner first place is_favorite")
			assert_equal("PUR-SANG", 	runner_from_list_runners.horse.breed, 			"Wrong horse.breed while checking runner first place is_favorite")
			assert_equal("", 			runner_from_list_runners.horse.coat, 			"Wrong horse.coat while checking runner first place is_favorite")
			father = Horse::new(name: "stronghold")
			assert_equal(father, 		runner_from_list_runners.horse.father, 			"Wrong horse.father while checking runner first place is_favorite")
			grand_father = Horse::new(name: "doyoun")
			mother = Horse::new(name: "haifaa", father: grand_father)
			assert_equal(mother, 		runner_from_list_runners.horse.mother, 			"Wrong horse.mother while checking runner first place is_favorite")
			assert_equal(grand_father, 	runner_from_list_runners.horse.mother.father, 	"Wrong horse.mother.father while checking runner first place is_favorite")
			assert_equal("Negev", 		runner_from_list_runners.horse.name, 			"Wrong horse.name while checking runner first place is_favorite")
			assert_equal("F", 			runner_from_list_runners.horse.sex, 			"Wrong horse.sex while checking runner first place is_favorite")
			assert_equal("MESSRS C M COMAROFF & B K PARKER", 		
										runner_from_list_runners.owner.name, 			"Wrong owner.name while checking runner first place is_favorite")
			assert_equal("L W GOOSEN", 	runner_from_list_runners.trainer.name, 			"Wrong trainer.name while checking runner first place is_favorite")
			@logger.info("All tests for runner (first place) OK.")
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# is_favorite
			runner_to_check = joint_list[2]
			assert_equal(5, 					runner_to_check.age, 					"Wrong age while checking runner first place is_favorite")
			assert_equal("OEILLERES_CLASSIQUE", runner_to_check.blinder, 				"Wrong blinder while checking runner first place is_favorite")
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
			assert_equal(nil, 					runner_to_check.shoes, 					"Wrong shoes while checking runner first place is_favorite")
			assert_equal(2.9, 					runner_to_check.single_rating_after_race, 			
																						"Wrong single_rating while checking runner first place is_favorite")
			assert_equal(0.0, 					runner_to_check.single_rating_before_race, 			
																						"Wrong single_rating while checking runner first place is_favorite")
			assert_equal("", 					runner_to_check.time, 					"Wrong time while checking runner first place is_favorite")
			# FIXME If real website does have a URL per runner
			# assert_equal("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm", 		
												# runner_to_check.url, 					"Wrong url while checking runner first place is_favorite")
			assert_equal(2, 					runner_to_check.victories, 				"Wrong victories while checking runner first place is_favorite")
			
			assert_equal("", 					runner_to_check.breeder.name, 			"Wrong breeder.name while checking runner first place is_favorite")
			assert_equal("P Strydom", 			runner_to_check.jockey.name, 			"Wrong jockey.name while checking runner first place is_favorite")
			assert_equal("PUR-SANG", 			runner_to_check.horse.breed, 			"Wrong horse.breed while checking runner first place is_favorite")
			assert_equal("", 					runner_to_check.horse.coat, 			"Wrong horse.coat while checking runner first place is_favorite")
			father = Horse::new(name: "stronghold")
			assert_equal(father, 				runner_to_check.horse.father, 			"Wrong horse.father while checking runner first place is_favorite")
			grand_father = Horse::new(name: "doyoun")
			mother = Horse::new(name: "haifaa", father: grand_father)
			assert_equal(mother, 				runner_to_check.horse.mother, 			"Wrong horse.mother while checking runner first place is_favorite")
			
			assert_equal(grand_father, 			runner_to_check.horse.mother.father, 	"Wrong horse.mother.father while checking runner first place is_favorite")
			assert_equal("Negev", 				runner_to_check.horse.name, 			"Wrong horse.name while checking runner first place is_favorite")
			assert_equal("F", 					runner_to_check.horse.sex, 				"Wrong horse.sex while checking runner first place is_favorite")
			assert_equal("MESSRS C M COMAROFF & B K PARKER", 		
												runner_to_check.owner.name, 			"Wrong owner.name while checking runner first place is_favorite")
			assert_equal("L W GOOSEN", 			runner_to_check.trainer.name, 			"Wrong trainer.name while checking runner first place is_favorite")
			
			@logger.info("All tests for runner first place is_favorite OK.")
			
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
			
			# @logger.info("All tests for runner first place is_favorite OK.")
			
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
			# @logger.info("All tests for runner (with draw) without blinder OK.")
			
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
			# @logger.info("All tests for non runner (with draw) OK.")
			
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
			# @logger.info("All tests for runner without shoes and with earnings OK.")

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
			# @logger.info("All tests for runner with shoes (front) and earnings OK.")

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
			# @logger.info("All tests for runner (with trainer) with front and back shoes off OK.")

			
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
			# @logger.info("All tests for runner without draw OK.")
			
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
			# @logger.info("All tests for runner without draw or history but with load_ride OK.")
			
			
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
			# @logger.info("All tests for runner without draw but with load_ride and history OK.")
			
			
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
			# @logger.info("All tests for runner (first place) OK.")
			
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
			# @logger.info("All tests for runner (After 10th place) OK.")
			
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
			# @logger.info("All tests for Non-runner OK.")
			
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
			# @logger.info("All tests for normal runner OK.")
			
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
			# @logger.info("All tests for Favorite runner OK.")
			# @logger.info("All tests for race with distance OK.")
			
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
			# @logger.info("All tests for runner with commentary and time OK.")
			
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
			# @logger.info("All tests for runner with commentary and 0 time OK.")
			
			
			## checking that there is a favorite
			# favorite_runner = nil
			# runner_hash.each_value do |runner|
				# if runner.is_favorite then
					# favorite_runner = runner
					# break
				# end
			# end
			# assert("No favorite found in race!", favorite_runner != nil)
			
			# @logger.info("All tests for race with time OK.")
			
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
			# @logger.info("All tests for runner (without victories or breeder) OK.")
			
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
			# @logger.info("All tests for runner (without earnings, victories or places) OK.")
			
			
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
			# @logger.info("All tests for runner (without earnings_current_year) OK.")
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
end