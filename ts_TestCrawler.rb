﻿require './TestSuite.rb'
require './ref.rb'
require './Crawler.rb'
require './validation.rb'

class TestCrawler < TestSuite
	
	@@crawler = nil
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi = $globalState.dbi
		@ref_list_hash = @dbi.load_all_refs
		
		if @@crawler == nil then
			@logger.info("Creating crawler for test.")
			@@crawler = Crawler::new(@logger, @ref_list_hash, @config)
		end
		@crawler = @@crawler
		
		@logger.level = SimpleHtmlLogger::DEBUG
	end
	
	def teardown
		@logger.debug("Teardown")
		# @crawler.close_driver()
		@logger.level = SimpleHtmlLogger::INFO
	end
	
	
	##################
	#      Tests     #
	##################
	# def test_crawl
		
		# @logger.imp("Testing fetch meetings")
		# begin
			# job = Job::new
		
			# homepage_url = "file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm"
			# returned_meeting_list = @crawler.crawl(homepage_url, job)
			
			# expected_meeting_list_size = 5
			# assert_equal(expected_meeting_list_size, returned_meeting_list.size)
			
			## First meeting : 9 races
			# first_meeting = returned_meeting_list[1]
			# nb_races_in_first_meeting = 9
			
			## Second meeting : 8 races
			# second_meeting = returned_meeting_list[2]
			# nb_races_in_second_meeting = 8
			
			## Third meeting : 8 races
			# third_meeting = returned_meeting_list[3]
			# nb_races_in_third_meeting = 8
			
			## Fourth meeting : 5 races
			# fourth_meeting = returned_meeting_list[4]
			# nb_races_in_fourth_meeting = 5
			
			## Fifth meeting : 6 races
			# fifth_meeting = returned_meeting_list[5]
			# nb_races_in_fifth_meeting = 6
			
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_meetings
		
		# @logger.imp("Testing fetch meetings")
		# begin
			# job = Job::new
			# date = Date::new(2013,11,15)
			# @crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			# html_meeting_list = @crawler.driver.find_element(:xpath, "//div[@id='reunions-view']")
			
			# if html_meeting_list == nil then
				# flunk("html_meeting_list is nil.")
			# end
		
			# meeting_list = @crawler.fetch_meetings(html_meeting_list, date, job)
			
			## Checking the list has meetings in it and that those meetings
			##{ have races
			# assert_equal(5, meeting_list.size)
			# assert_equal(9, meeting_list[0].race_list.size)
			# assert_equal(8, meeting_list[1].race_list.size)
			# assert_equal(8, meeting_list[2].race_list.size)
			# assert_equal(4, meeting_list[3].race_list.size) # should be 5, according to the files 
															  ## but the main page only has 2 to 5
			# assert_equal(6, meeting_list[4].race_list.size)
			
			# @logger.ok("Tests for test_fetch_meetings OK.")
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	def test_fetch_meeting_shallow
		
		@logger.imp("Testing fetch meeting shallow")
		begin
			# Setting up 
			# -> Getting the page
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			# -> Getting the meeting list
			html_meeting_list = @crawler.driver.
					find_elements(:css, "div.reunion-line")
			# (Checking we did get a list and the right one)
			assert_equal(5, html_meeting_list.size)
			@logger.debug("There are indeed 5 meetings.")
			
			# -> Getting the meeting tag
			html_meeting_to_test = html_meeting_list[2]
			
			# (Checking it's the right one)
			reunion_id_attribute = html_meeting_to_test.attribute("data-reunionid")
			assert_equal("3", reunion_id_attribute)
			
			# Creating date and job
			job = Job::new
			date = Date::new(2013, 11, 15)
			
			# The function to test
			meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, date, job)
			
			verif_date = Date::new(2015, 06, 12)
			verif_number = "3"
			verif_racetrack = "HIPPODROME DE SAINT GALMIER"
			verif_urls_of_races_array = 
						["file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1.htm",
						 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C2.htm",
						 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C3.htm",
						 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C4.htm",
						 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C5.htm",
						 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C6.htm",
						 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C7.htm",
						 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C8.htm"]
			
			verif_track_condition = @ref_list_hash[:ref_track_condition_list]["Terrain bon"]
			verification_temp = 14
			verification_wind_dir = nil
			verification_wind_speed = 5
			verification_insolation = "P8c"
			verif_weather = Weather::new(
				insolation: verification_insolation, 
				temperature: verification_temp, 
				wind_direction: verification_wind_dir, 
				wind_speed: verification_wind_speed
			)
			
			verification_meeting = Meeting::new(
								date: verif_date, 
								job: job, 
								number: verif_number, 
								racetrack: verif_racetrack, 
								urls_of_races_array: verif_urls_of_races_array, 
								track_condition: verif_track_condition, 
								weather: verif_weather)
						
			validate_meeting(verification_meeting, meeting, "on 12/06/2012")
			
			# 2nd test: country
			html_meeting_to_test = html_meeting_list[3]
			meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, date, job)
			verif_country = "Af Sud"
			verif_racetrack = "HIPPODROME DE VAAL"
			
			assert_equal(verif_country, meeting.country)
			assert_equal(verif_racetrack, meeting.racetrack)
			
			@logger.ok("Tests for test_fetch_meeting_shallow OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_fetch_meeting
		
		@logger.imp("Testing fetch meeting")
		begin
			
			urls_of_races_array = 
				["file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1.htm",
				 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C2.htm",
				 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C3.htm",
				 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C4.htm",
				 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C5.htm",
				 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C6.htm",
				 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C7.htm",
				 "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C8.htm"]
			
			html_meeting_to_test = Meeting::new(urls_of_races_array: urls_of_races_array)
			
			assert_equal(0, html_meeting_to_test.race_list.size)
			
			# The function to test
			meeting = @crawler.fetch_meeting(html_meeting_to_test)
			
			assert_equal(8, meeting.race_list.size)
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_fetch_race
		@logger.imp("Testing fetch race")
		begin
			# Setting up 
			# -> Getting the page
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			
			# -> Getting the meeting list
			html_meeting_list = @crawler.driver.
					find_elements(:css, "div.reunion-line")
			# (Checking we did get a list and the right one)
			assert_equal(5, html_meeting_list.size)
			
			# -> Getting the meeting tag
			html_meeting = html_meeting_list[0]
			# (Checking it's the right one)
			reunion_id_attribute = html_meeting.attribute("data-reunionid")
			assert_equal("1", reunion_id_attribute)
			
			secondary_id = "numOfficiel-" + reunion_id_attribute
			secondary_div_tag = @crawler.driver
					.find_element(:id, secondary_id)
			
			# -> Getting the list of races
			link_to_races_tags = secondary_div_tag.find_elements(:css, "a.course")
			urls_of_races_array = []
			link_to_races_tags.each do |link_to_race_tag|
				urls_of_races_array.push(link_to_race_tag.attribute("href"))
			end
			# Checking we've got the right number
			assert_equal(9, urls_of_races_array.size)
			
			# Extracting the race to test
			url_to_race = urls_of_races_array[6]
			meeting = Meeting::new(job: Job::new, weather: Weather:: new)
			fetched_race = @crawler.fetch_race(url_to_race, meeting)
			# @logger.debug("test_fetch_race - fetched_race: " + fetched_race.to_s)
			validate_race_R1_C7(fetched_race, meeting)
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_fetch_weather
		
		@logger.imp("Testing fetch weather")
		begin
			# Setting up 
			# -> Getting the page
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			
			# -> Getting the meeting list
			html_meeting_list = @crawler.driver.
					find_elements(:css, "div.reunion-line")
			# (Checking we did get a list and the right one)
			assert_equal(5, html_meeting_list.size)
			
			# -> Getting the meeting tag
			html_meeting = html_meeting_list[1]
			
			# (Checking it's the right one)
			reunion_id_attribute = html_meeting.attribute("data-reunionid")
			assert_equal("2", reunion_id_attribute)
			
			div_tag_for_weather = html_meeting.
					find_element(:css, "div.picto-meteo")
			
			# the function to test
			weather = @crawler.fetch_weather(div_tag_for_weather)
			# @logger.debug("Weather : " + weather.to_s)
			
			verification_temp = 12
			verification_wind_dir = nil
			verification_wind_speed = 16
			verification_insolation = "P1"
			verification_weather = Weather::new(
				insolation: verification_insolation, 
				temperature: verification_temp, 
				wind_direction: verification_wind_dir, 
				wind_speed: verification_wind_speed
			)
			
			assert_equal(verification_weather, weather)
			@logger.ok("Tests for test_fetch_weather OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_join_runner_list_and_result_list
		@logger.imp("Testing join runner list and result list")
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
			runner_from_result_list = result_list[2]
			validate_result_R4_C5_N2(runner_from_result_list)
			
			runner_from_list_runners = list_runners[2]
			validate_runner_R4_C5_N2(runner_from_list_runners, race_to_test)
			
			# 10th Place (and  distance)
			runner_from_result_list = result_list[5]
			validate_result_R4_C5_N5(runner_from_result_list)
			
			runner_from_list_runners = list_runners[5]
			validate_runner_R4_C5_N5(runner_from_list_runners, race_to_test)
			
			# No Place (and no distance)
			runner_from_result_list = result_list[4]
			validate_result_R4_C5_N4(runner_from_result_list)
			
			runner_from_list_runners = list_runners[4]
			validate_runner_R4_C5_N4(runner_from_list_runners, race_to_test)
			
			# Non runner
			runner_from_result_list = result_list[17]
			validate_result_R4_C5_N17(runner_from_result_list)
			
			runner_from_list_runners = list_runners[17]
			validate_runner_R4_C5_N17(runner_from_list_runners, race_to_test)
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			runner_to_check = joint_list[2]
			validate_joint_R4_C5_N2(runner_to_check, race_to_test)
			
			# 10th place (with distance)
			runner_to_check = joint_list[5]
			validate_joint_R4_C5_N5(runner_to_check, race_to_test)
			
			# no place (and no distance)
			runner_to_check = joint_list[4]
			validate_joint_R4_C5_N4(runner_to_check, race_to_test)
			
			# non runner
			runner_to_check = joint_list[17]
			validate_joint_R4_C5_N17(runner_to_check, race_to_test)
			
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
			runner_from_result_list = result_list[5]
			validate_result_R1_C1_N5(runner_from_result_list)
			
			runner_from_list_runners = list_runners[5]
			validate_runner_R1_C1_N5(runner_from_list_runners, race_to_test)
			
			# Favorite
			runner_from_result_list = result_list[9]
			validate_result_R1_C1_N4(runner_from_result_list)
			
			runner_from_list_runners = list_runners[9]
			validate_runner_R1_C1_N4(runner_from_list_runners, race_to_test)
			
			# Disqualified
			runner_from_result_list = result_list[4]
			validate_result_R1_C1_N9(runner_from_result_list)
			
			runner_from_list_runners = list_runners[4]
			validate_runner_R1_C1_N9(runner_from_list_runners, race_to_test)
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			runner_to_check = joint_list[5]
			validate_joint_R1_C1_N5(runner_to_check, race_to_test)
			
			# Favorite
			runner_to_check = joint_list[9]
			validate_joint_R1_C1_N9(runner_to_check, race_to_test)
			
			# Disqualified
			runner_to_check = joint_list[4]
			validate_joint_R1_C1_N4(runner_to_check, race_to_test)
			
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
			
			runner_from_result_list = result_list[11]
			validate_result_R2_C7_N11(runner_from_result_list)
			
			runner_from_list_runners = list_runners[11]
			validate_runner_R2_C7_N11(runner_from_list_runners, race_to_test)
			
			# Favorite
			runner_from_result_list = result_list[1]
			validate_result_R2_C7_N1(runner_from_result_list)
			
			runner_from_list_runners = list_runners[1]
			validate_runner_R2_C7_N1(runner_from_list_runners, race_to_test)
			
			# Substitute
			runner_from_result_list = result_list[12]
			validate_result_R2_C7_N12(runner_from_result_list)
			
			runner_from_list_runners = list_runners[12]
			validate_runner_R2_C7_N12(runner_from_list_runners, race_to_test)
			
			# 12th place
			runner_from_result_list = result_list[4]
			validate_result_R2_C7_N4(runner_from_result_list)
			
			runner_from_list_runners = list_runners[4]
			validate_runner_R2_C7_N4(runner_from_list_runners, race_to_test)
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			runner_to_check = joint_list[11]
			validate_joint_R2_C7_N11(runner_to_check, race_to_test)
			
			# Favorite
			runner_to_check = joint_list[1]
			validate_joint_R2_C7_N1(runner_to_check, race_to_test)
			
			# Substitute
			runner_to_check = joint_list[12]
			validate_joint_R2_C7_N12(runner_to_check, race_to_test)
			
			# 12th place
			runner_to_check = joint_list[4]
			
			
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
			runner_from_result_list = result_list[3]
			validate_result_R1_C7_N3(runner_from_result_list)
			
			runner_from_list_runners = list_runners[3]
			validate_runner_R1_C7_N3(runner_from_list_runners, race_to_test)
			
			# Favorite
			runner_from_result_list = result_list[1]
			validate_result_R1_C7_N1(runner_from_result_list)
			
			runner_from_list_runners = list_runners[1]
			validate_runner_R1_C7_N1(runner_from_list_runners, race_to_test)
			
			# Disqualified
			runner_from_result_list = result_list[11]
			validate_result_R1_C7_N11(runner_from_result_list)
			
			runner_from_list_runners = list_runners[11]
			validate_runner_R1_C7_N11(runner_from_list_runners, race_to_test)
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			runner_to_check = joint_list[3]
			validate_joint_R1_C7_N3(runner_to_check, race_to_test)
			
			# Favorite
			runner_to_check = joint_list[1]
			validate_joint_R1_C7_N1(runner_to_check, race_to_test)
			
			# Disqualified		
			runner_to_check = joint_list[11]
			validate_joint_R1_C7_N11(runner_to_check, race_to_test)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_get_column_map()
		
		@logger.imp("Testing getting the right column map")
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
			
			@logger.ok("Tests for get_column_map OK.")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_fetch_runners
		
		@logger.imp("Testing fetch runners")
		begin
			# Setting up 
			# -> Getting the race
			url = "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5.htm"
			# @crawler.driver.get(url)
			
			# -> Getting the meeting list
			race_to_test = Race::new() # R4_C5
			# Checking the list is empty beforehand
			assert_equal(nil, race_to_test.runner_list)
			race_to_test.url = url
			
			# the function to test
			runner_list = @crawler.fetch_runners(race_to_test)
			
			# Checking we did get a list and the right one
			assert_equal(17, runner_list.size)
			
			# Checking individual Runners :
			
			# is_favorite
			runner_to_check = runner_list[2]
			validate_joint_R4_C5_N2(runner_to_check, race_to_test)
			
			
			# is between 1 and 10
			
			# is after 10
			
			# is non_runner
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_fetch_runners_shallow
		
		@logger.imp("Testing fetch runners shallow")
		begin
			# Setting up 
			# -> Getting the first race (with distance)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C3_runners.htm")
			
			race_to_test = Race::new() # R4_C3
			runner = nil
			
			# the function to test
			runner_hash = @crawler.fetch_runners_shallow(race_to_test)
			
			# Checking we did get a list and the right one
			assert("Runner list is nil", runner_hash != nil)
			assert_equal(8, runner_hash.size, "Wrong number of runners fetched")
			
			# Checking the fetched results
			
			# Without blinder
			runner_to_check = runner_hash[1]
			expected_runner = Runner::new(
								age: 7,
								blinder: @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"],
								draw: 8,
								earnings_career: 0.0,
								history: "1p2p(13)7p9p",		
								horse: Horse::new(	name: "Mythical Palace",  
													sex: @ref_list_hash[:ref_sex_list]["H"]),
								is_favorite: false,
								is_substitute: false,
								jockey: Jockey::new(name: "G Lerena"),
								load_handicap: 60.5,
								load_ride: 0.0,
								non_runner: false,
								number: 1,
								race: race_to_test,
								single_rating_before_race: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""],
								url: "")
			validate_runner_shallow(expected_runner, runner_to_check, "runner (with draw) without blinder")
			
			# Non runner
			runner_to_check = runner_hash[8]
			expected_runner = Runner::new(
								age: 0,
								blinder: @ref_list_hash[:ref_blinder_list][""],
								draw: 0,
								earnings_career: 0.0,
								history: "",
								horse: Horse::new(	name: "Phenomenal", 
													sex: @ref_list_hash[:ref_sex_list][""]),
								is_favorite: false,
								is_substitute: false,
								jockey: Jockey::new(name: ""),
								load_handicap: 0.0,
								load_ride: 0.0,
								non_runner: true,
								number: 8,			
								race: race_to_test,
								single_rating_before_race: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""],
								url: "")
			validate_runner_shallow(expected_runner, runner_to_check, "non runner (with draw)")
			
			# -> Getting the second race (with time)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runners.htm")
			
			race_to_test = Race::new() # R1_C7
			
			# the function to test
			runner_hash = @crawler.fetch_runners_shallow(race_to_test)
			
			# Checking we did get a list and the right one
			assert_equal(12, runner_hash.size, "Wrong number of runners fetched")
			
			# Checking the fetched results
			runner_to_check = runner_hash[9]
			expected_runner = Runner::new(
								age: 7,
								blinder: @ref_list_hash[:ref_blinder_list][""],
								draw: 0,
								history: "3aDa2a(13)",
								horse: Horse::new(	name: "Jaervso Ole", 
													sex: @ref_list_hash[:ref_sex_list]["M"]),
								is_favorite: false,
								is_substitute: false,
								jockey: Jockey::new(name: "F. Nivard"),
								load_handicap: 0.0,
								load_ride: 0.0,
								non_runner: false,
								number: 9,
								race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: 2100,
								earnings_career: 100566.00,
								shoes: @ref_list_hash[:ref_shoes_list][""])
			validate_runner_shallow(expected_runner, runner_to_check, "runner without shoes and with earnings")

			runner_to_check = runner_hash[3]
			expected_runner = Runner::new(
								age: 7,
								blinder: @ref_list_hash[:ref_blinder_list][""],
								draw: 0,
								history: "0a2a1a1a(1",
								horse: Horse::new(	name: "Doktor Jaros", 
													sex: @ref_list_hash[:ref_sex_list]["M"]),
								is_favorite: false,
								is_substitute: false,
								jockey: Jockey::new(name: "G. Gudmestad"),
								load_handicap: 0.0,
								load_ride: 0.0,
								non_runner: false,
								number: 3,
								race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: 2100,
								earnings_career: 87843.00,
								shoes: @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS"])
			validate_runner_shallow(expected_runner, runner_to_check, "runner with shoes (front) and earnings")

			runner_to_check = runner_hash[11]
			expected_runner = Runner::new(
								age: 10,
								blinder: @ref_list_hash[:ref_blinder_list][""],
								draw: 0,
								history: "4a0a6a5a(1",
								horse: Horse::new(name: "Metkutus", sex: @ref_list_hash[:ref_sex_list]["M"]),
								is_favorite: false,
								is_substitute: false,
								jockey: Jockey::new(name: "J.m. Paavola"),
								load_handicap: 0.0,
								load_ride: 0.0,
								non_runner: false,
								number: 11,
								race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: 2100,
								earnings_career: 86140.00,
								shoes: @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"])
			validate_runner_shallow(expected_runner, runner_to_check, "runner (with trainer) with front and back shoes off")

			
			# -> Getting the third race (without draw)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8_runners.htm")
			
			race_to_test = Race::new() # R2_C8
			
			# the function to test
			runner_hash = @crawler.fetch_runners_shallow(race_to_test)
			
			# Checking we did get a list and the right one
			assert_equal(11, runner_hash.size, "Wrong number of runners fetched")
			
			# Checking the fetched results
			runner_to_check = runner_hash[8]
			expected_runner = Runner::new(
								age: 5,
								blinder: @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"],
								draw: 0,
								history: "3a0h8h3s2s6s",
								horse: Horse::new(name: "Becqualink", sex: @ref_list_hash[:ref_sex_list]["H"]),
								is_favorite: false,
								is_substitute: false,
								jockey: Jockey::new(name: "F.corallo"),
								load_handicap: 66,
								load_ride: 64,
								non_runner: false,
								number: 8,
								race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: nil,
								earnings_career: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""])
			validate_runner_shallow(expected_runner, runner_to_check, "runner without draw")
			
			runner_to_check = runner_hash[9]
			expected_runner = Runner::new(
								age: 5,
								blinder: @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"],
								draw: 0,
								history: "",
								horse: Horse::new(name: "Velours D'allier", sex: @ref_list_hash[:ref_sex_list]["H"]),
								is_favorite: false,
								is_substitute: false,
								jockey: Jockey::new(name: "J.zerourou"),
								load_handicap: 66,
								load_ride: 64,
								non_runner: false,
								number: 9,
								race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: nil,
								earnings_career: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""])
			validate_runner_shallow(expected_runner, runner_to_check, "runner without draw or history but with load_ride")
			
			
			# Checking the fetched results
			runner_to_check = runner_hash[4]
			expected_runner = Runner::new(
								age: 5,
								blinder: @ref_list_hash[:ref_blinder_list]["OEILLERES_AUSTRALIENNES"],
								draw: 0,
								history: "4h(13)1h4p2s",
								horse: Horse::new(name: "Va Longtemps", sex: @ref_list_hash[:ref_sex_list]["F"]),
								is_favorite: false,
								is_substitute: false,
								jockey: Jockey::new(name: "J.plouganou"),
								load_handicap: 67,
								load_ride: 0.0,
								non_runner: false,
								number: 4,
								race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: nil,
								earnings_career: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""])
			validate_runner_shallow(expected_runner, runner_to_check, "runner without draw but with load_ride and history")
			
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_fetch_race_results
		
		@logger.imp("Testing fetch race results")
		begin
			# Setting up 
			# -> Getting the first race (with distance)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1.htm")
			
			race_to_test = Race::new() # R4_C1
			runner = nil
			
			# the function to test
			runner_hash = @crawler.fetch_race_results(race_to_test)
			
			# Checking we did get a list and the right one
			assert("Runner list is nil", runner_hash != nil)
			assert_equal(12, runner_hash.size)
			
			# Checking the fetched results
			# first place (distance == "")
			runner_to_check = runner_hash[2]
			expected_runner = Runner::new(
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_BRAVE_VISION.htm",
								commentary: "",
								distance: "",
								final_place: 1,
								number: 2,
								single_rating_after_race: 29.9,
								time: "",
								is_favorite: false,
								non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "runner (first place)")
			
			# After 10th place (final_place == nil)
			runner_to_check = runner_hash[10]
			expected_runner = Runner::new(
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_LONG_SHOT.htm",
								commentary: "",
								distance: "",
								final_place: 0,
								number: 10,
								single_rating_after_race: 23.9,
								time: "",
								is_favorite: false,
								non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "runner (After 10th place)")
			
			# Non-runner (non_runner == true, final_place == nil, single_rating_after_race == nil)
			runner_to_check = runner_hash[11]
			expected_runner = Runner::new(
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_OUT_MY_WAY.htm",
								commentary: "",
								distance: "",
								final_place: 0,
								number: 11,
								single_rating_after_race: 0.0,
								time: "",
								is_favorite: false,
								non_runner: true,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "Non-runner")
			
			# Normal
			runner_to_check = runner_hash[1]
			expected_runner = Runner::new(
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_AMERICAN_TIGER.htm",
								commentary: "",
								distance: "5 Longueurs 1/2",
								final_place: 3,
								number: 1,
								single_rating_after_race: 4.8,
								time: "",
								is_favorite: false,
								non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "normal runner")
			
			# Favorite (is_favorite == true)
			runner_to_check = runner_hash[6]
			expected_runner = Runner::new(
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1_runner_ISPHAN.htm",
								commentary: "",
								distance: "1/2 Longueur",
								final_place: 2,
								number: 6,
								single_rating_after_race: 4.7,
								time: "",
								is_favorite: true,
								non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "Favorite runner")
			@logger.ok("Tests for race with distance OK.")
			
			# -> Getting the second race (with time)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1.htm")
			
			race_to_test = Race::new() # R3_C1
			
			# the function to test
			runner_hash = @crawler.fetch_race_results(race_to_test)
			
			# Checking we did get a list and the right one
			assert_equal(14, runner_hash.size)
			
			# Checking the fetched results
			runner_to_check = runner_hash[11]
			expected_runner = Runner::new(
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1_runner_QUASAR_DE_KACY.htm",
								commentary: "Dans le dernier tiers du peloton, à la corde, a vite été sollicité et n'a jamais pu se rapprocher.",
								distance: "",
								final_place: 10,
								number: 11,
								single_rating_after_race: 100.9,
								time: "1'16\"90",
								is_favorite: false,
								non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "runner with commentary and time")
			
			runner_to_check = runner_hash[10]
			expected_runner = Runner::new(
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1_runner_ROC_BERRY.htm",
								commentary: "S'est vite enlevé.",
								distance: "",
								final_place: 0,
								number: 10,
								single_rating_after_race: 45.2,
								time: "0'00\"00",
								is_favorite: false,
								non_runner: false,
								disqualified: true)
			validate_runner_from_result_list(expected_runner, runner_to_check, "runner with commentary and 0 time")
			
			
			# checking that there is a favorite
			favorite_runner = nil
			runner_hash.each_value do |runner|
				if runner.is_favorite then
					favorite_runner = runner
					break
				end
			end
			assert("No favorite found in race!", favorite_runner != nil)
			
			@logger.ok("Tests for race with time OK.")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	# def test_fetch_runner
		
		# @logger.imp("Testing fetch runner")
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
			# races_run: 7,
			# victories: 0,
			# places: 6,
			# earnings_career: 3024.00,
			# earnings_current_year: 1049.00,
			# earnings_last_year: 1975.00,
			# earnings_victory: 0.00,
			# description: nil,
			# horse.breed: "PUR-SANG",
			# horse.coat: nil,
			# breeder: "",
			# trainer: "C MAYHEW",
			# number: 1,
			# owner: "MESSRS A LANG & R J MAYHEW",
			# horse.father.name: "antonius pius",
			# horse.mother.name: "cherry flower",
			# horse.mother.father.name: "goldkeeper",
			# "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4_runner_ANTONIA_MAJOR.htm", 				
														# runner_to_check.url, 						"Wrong url while checking runner without victories or breeder")
			# @logger.ok("Tests for runner (without victories or breeder) OK.")
			
			## runner without earnings, victories or places
			# runner_to_check = runner_shallow_hash[7]
			# races_run, 					"Wrong races_run while checking runner without earnings: 3,
			# victories, 					"Wrong victories while checking runner without earnings: 0,
			# places, 					"Wrong places while checking runner without earnings: 0,
			# earnings_career, 			"Wrong earnings_career while checking runner without earnings: 0.00,
			# earnings_current_year, 		"Wrong earnings_current_year while checking runner without earnings: 0.00,
			# earnings_last_year, 		"Wrong earnings_last_year while checking runner without earnings: 0.00,
			# earnings_victory, 			"Wrong earnings_victory while checking runner without earnings: 0.00,
			# description, 				"Wrong description while checking runner without earnings: nil,
			# horse.breed, 				"Wrong horse.breed while checking runner without earnings: "PUR-SANG",
			# horse.coat, 				"Wrong horse.coat while checking runner without earnings: nil,
			# breeder, 					"Wrong breeder while checking runner without earnings: "",
			# number, 					"Wrong number while checking runner without earnings: 7,
			# trainer, 					"Wrong trainer while checking runner without earnings: "S M FERREIRA",
			# owner, 						"Wrong owner while checking runner without earnings: "MR S M FERREIRA",
			# horse.father.name, 			"Wrong horse.father.name while checking runner without earnings: "casey tibbs",
			# horse.mother.name, 			"Wrong horse.mother.name while checking runner without earnings: "dahlia's legacy",
			# horse.mother.father.name, 	"Wrong horse.mother.father.name while checking runner without earnings: "dahar",
			# "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4_runner_DAHLIA%27S_DESTINY.htm", 				
											# runner_to_check.url, 						"Wrong url while checking runner without earnings, victories or places")
			# @logger.ok("Tests for runner (without earnings, victories or places) OK.")
			
			
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
			# races_run: 12,
			# victories: 2,
			# places: 6,
			# earnings_career: 68300.00,
			# earnings_current_year: 0.00,
			# earnings_last_year: 53900.00,
			# earnings_victory: 36480.00,
			# description: nil,
			# horse.breed: "PUR-SANG",
			# horse.coat: "GRIS FONCE",
			# breeder: "HARAS DE SAINT-VOIR",
			# trainer: "MACAIRE (S)",
			# number: 3,
			# owner: "HARAS DE SAINT-VOIR",
			# horse.father.name: "sacro saint",
			# horse.mother.name: "biblique",
			# horse.mother.father.name: "saint cyrien",
			# "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8_runner_VOTEZ_POUR_MOI.htm", 				
												# runner_to_check.url, 					"Wrong url while checking runner without without earnings_current_year")
			# @logger.ok("Tests for runner (without earnings_current_year) OK.")
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
end