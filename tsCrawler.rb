require './TestSuite.rb'
require './ref.rb'
require './Crawler.rb'
require './validation-meeting.rb'
require './validation-race.rb'
require './validation-runner-joint.rb'
require './validation-runner-list.rb'
require './validation-runner-result.rb'

class TestCrawler < TestSuite
	
	@@crawler = nil
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi_select = $globalState.dbi_select_by_tech_id
		@ref_list_hash = @dbi_select.load_all_refs
				
		if @@crawler == nil then
			@logger.info("Creating crawler for test.")
			@@crawler = Crawler::new(@logger, @ref_list_hash, @config)
		end
		@crawler = @@crawler
		
		@logger.level = SimpleHtmlLogger::INFO
		
		@test_start_time = Time.now()
	end
	
	def teardown
		test_end_time = Time.now()
		
		test_duration_in_s = test_end_time - @test_start_time
		
		# @logger.debug("teardown - test_start_time : " + @test_start_time.to_s)
		# @logger.debug("teardown - test_end_time : " + test_end_time.to_s)
		# @logger.debug("teardown - test_duration_in_s : " + test_duration_in_s.to_s)
		@logger.ok("(Test took " + 
			format_time_diff(test_duration_in_s) + 
			".)")
	
		@logger.debug("Teardown")
		# @crawler.close_driver()
		@logger.level = SimpleHtmlLogger::INFO
	end
	
	
	##################
	#      Tests     #
	##################
	# def testcrawl
		
		# @logger.imp("Testing fetch meetings")
		# test_start_time = Time.now()
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
			# log_flunking_test(err)
		# end
		# @logger.ok("Tests for crawl OK.")
		# test_end_time = Time.now()
		# test_duration_in_days = test_end_time - test_start_time
		# test_duration_in_s = test_duration_in_days * 24 * 60 * 60
		# @logger.ok("(Test took " + 
			# test_duration_in_s.to_f.to_s + 
			# "s.)")
	# end
	
	def not_test_fetch_meetings
		
		@logger.imp("Testing fetch meetings")
		begin
			job = Job::new
			date = Date::new(2013,11,15)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			html_meeting_list = @crawler.driver.find_element(:xpath, "//div[@id='reunions-view']")
			
			if html_meeting_list == nil then
				flunk("html_meeting_list is nil.")
			end
		
			meeting_list = @crawler.fetch_meetings(html_meeting_list, job)
			
			# Checking the list has meetings in it and that those meetings
			# have races
			assert_equal(5, meeting_list.size)
			assert_equal(9, meeting_list[0].race_list.size)
			assert_equal(8, meeting_list[1].race_list.size)
			assert_equal(8, meeting_list[2].race_list.size)
			assert_equal(4, meeting_list[3].race_list.size) # should be 5, according to the files 
															# but the main page only has 2 to 5
			assert_equal(6, meeting_list[4].race_list.size)
			
			# Checking the meetings
			# R1
			r1 = meeting_list[0]
			validate_R1(r1, job, date)
			
			r1_c7 = r1.race_list[6]
			validate_race_R1_C7(r1_c7)
			
			# R2
			r2 = meeting_list[1]
			validate_R2(r2, job, date)
			
			r2_c7 = r2.race_list[6]
			validate_race_R2_C7(r2_c7)
			
			# R3
			r3 = meeting_list[2]
			validate_R3(r3, job, date)
			
			r3_c1 = r3.race_list[0]
			validate_race_R3_C1(r3_c1)
			
			# R4
			r4 = meeting_list[3]
			validate_R4(r4, job, date)
			
			r4_c3 = r4.race_list[2]
			validate_race_R4_C3(r4_c3)
			
			# R5
			r5 = meeting_list[0]
			validate_R5(r5, job, date)
			
			r5_c5 = r5.race_list[4]
			validate_race_R5_C5(r5_c5)
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_meetings OK.")
	end
	
	def test_fetch_meeting_shallow
		
		@logger.imp("Testing fetch meeting shallow")
		test_start_time = Time.now()
		begin
			# Setting up 
			
			# Creating job
			job = Job::new
			
			# -> Getting the page
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			# -> Getting the meeting list
			html_meeting_list = @crawler.driver.
					find_elements(:css, "div.reunion-line")
			# (Checking we did get a list and the right one)
			assert_equal(5, html_meeting_list.size)
			@logger.debug("There are indeed 5 meetings.")

			# R1
			# -> Getting the meeting tag
			html_meeting_to_test = html_meeting_list[0]
			
			# (Checking it's the right one)
			reunion_id_attribute = html_meeting_to_test.attribute("data-reunionid")
			assert_equal("1", reunion_id_attribute)
			
			# Function to test
			meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, job)
			validate_R1(meeting, job)
			
			# R2
			html_meeting_to_test = html_meeting_list[1]
			meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, job)
			validate_R2(meeting, job)
			
			# R3
			html_meeting_to_test = html_meeting_list[2]
			meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, job)
			validate_R3(meeting, job)
			
			# R4 (country)
			html_meeting_to_test = html_meeting_list[3]
			meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, job)
			validate_R4(meeting, job)
			
			# R5 (country)
			html_meeting_to_test = html_meeting_list[4]
			meeting = @crawler.fetch_meeting_shallow(html_meeting_to_test, job)
			validate_R5(meeting, job)
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_meeting_shallow OK.")
	end
	
	def test_fetch_meeting
		
		@logger.imp("Testing fetch meeting")
		test_start_time = Time.now()
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
			
			assert_equal(nil, html_meeting_to_test.race_list)
			
			# The function to test
			meeting = @crawler.fetch_meeting(html_meeting_to_test)
			
			assert_equal(8, meeting.race_list.size)
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_meeting OK.")
	end
	
	def test_fetch_race
		@logger.imp("Testing fetch race")
		test_start_time = Time.now()
		begin
			@logger.level = SimpleHtmlLogger::DEBUG
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
			validate_race_R1_C7(fetched_race)
			
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_race OK.")
	end
	
	def test_fetch_weather
		
		@logger.imp("Testing fetch weather")
		test_start_time = Time.now()
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
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_weather OK.")
	end
	
	def test_join_runner_list_and_result_list
		@logger.imp("Testing join runner list and result list")
		test_start_time = Time.now()
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
			result_list = @crawler.fetch_race_results()
			
			# go to runners' page
			@crawler.go_to_runners_page()
			
			# getting the runner_list
			list_runners = @crawler.fetch_list_runners()
			
			# Checking the data beforehand
			# First place (no distance) & favorite
			runner_from_result_list = result_list[2]
			validate_result_R4_C5_N2(runner_from_result_list)
			
			runner_from_list_runners = list_runners[2]
			# validate_runner_R4_C5_N2(runner_from_list_runners, race_to_test)
			validate_runner_R4_C5_N2(runner_from_list_runners)
			
			# 10th Place (and  distance)
			runner_from_result_list = result_list[5]
			validate_result_R4_C5_N5(runner_from_result_list)
			
			runner_from_list_runners = list_runners[5]
			# validate_runner_R4_C5_N5(runner_from_list_runners, race_to_test)
			validate_runner_R4_C5_N5(runner_from_list_runners)
			
			# No Place (and no distance)
			runner_from_result_list = result_list[4]
			validate_result_R4_C5_N4(runner_from_result_list)
			
			runner_from_list_runners = list_runners[4]
			# validate_runner_R4_C5_N4(runner_from_list_runners, race_to_test)
			validate_runner_R4_C5_N4(runner_from_list_runners)
			
			# Non runner
			runner_from_result_list = result_list[17]
			validate_result_R4_C5_N17(runner_from_result_list)
			
			runner_from_list_runners = list_runners[17]
			# validate_runner_R4_C5_N17(runner_from_list_runners, race_to_test)
			validate_runner_R4_C5_N17(runner_from_list_runners)
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			runner_to_check = joint_list[2]
			# validate_joint_R4_C5_N2(runner_to_check, race_to_test)
			validate_joint_R4_C5_N2(runner_to_check)
			
			# 10th place (with distance)
			runner_to_check = joint_list[5]
			# validate_joint_R4_C5_N5(runner_to_check, race_to_test)
			validate_joint_R4_C5_N5(runner_to_check)
			
			# no place (and no distance)
			runner_to_check = joint_list[4]
			# validate_joint_R4_C5_N4(runner_to_check, race_to_test)
			validate_joint_R4_C5_N4(runner_to_check)
			
			# non runner
			runner_to_check = joint_list[17]
			# validate_joint_R4_C5_N17(runner_to_check, race_to_test)
			validate_joint_R4_C5_N17(runner_to_check)
			
			# Getting the second page
			url = "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1.htm"
			@crawler.driver.get(url)
			
			# -> Getting the meeting list
			race_to_test = Race::new() # R1_C1
			# Checking the list is empty beforehand
			assert_equal(nil, race_to_test.runner_list)
			race_to_test.url = url
			
			# getting the runner_list 
			result_list = @crawler.fetch_race_results()
			
			# go to runners' page
			@crawler.go_to_runners_page()
			
			# getting the runner_list
			list_runners = @crawler.fetch_list_runners()
			
			# First
			runner_from_result_list = result_list[5]
			validate_result_R1_C1_N5(runner_from_result_list)
			
			runner_from_list_runners = list_runners[5]
			# validate_runner_R1_C1_N5(runner_from_list_runners, race_to_test)
			validate_runner_R1_C1_N5(runner_from_list_runners)
			
			# Favorite
			runner_from_result_list = result_list[9]
			validate_result_R1_C1_N4(runner_from_result_list)
			
			runner_from_list_runners = list_runners[9]
			# validate_runner_R1_C1_N4(runner_from_list_runners, race_to_test)
			validate_runner_R1_C1_N4(runner_from_list_runners)
			
			# Disqualified
			runner_from_result_list = result_list[4]
			validate_result_R1_C1_N9(runner_from_result_list)
			
			runner_from_list_runners = list_runners[4]
			# validate_runner_R1_C1_N9(runner_from_list_runners, race_to_test)
			validate_runner_R1_C1_N9(runner_from_list_runners)
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			runner_to_check = joint_list[5]
			# validate_joint_R1_C1_N5(runner_to_check, race_to_test)
			validate_joint_R1_C1_N5(runner_to_check)
			
			# Favorite
			runner_to_check = joint_list[9]
			# validate_joint_R1_C1_N9(runner_to_check, race_to_test)
			validate_joint_R1_C1_N9(runner_to_check)
			
			# Disqualified
			runner_to_check = joint_list[4]
			# validate_joint_R1_C1_N4(runner_to_check, race_to_test)
			validate_joint_R1_C1_N4(runner_to_check)
			
			# Third page : R2_C7 (no draw)
			
			url = "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7.htm"
			@crawler.driver.get(url)
			
			# -> Getting the meeting list
			race_to_test = Race::new() # R2_C7
			# Checking the list is empty beforehand
			assert_equal(nil, race_to_test.runner_list)
			race_to_test.url = url
			
			# getting the runner_list 
			result_list = @crawler.fetch_race_results()
			
			# go to runners' page
			@crawler.go_to_runners_page()
			
			# getting the runner_list
			list_runners = @crawler.fetch_list_runners()
			
			# First
			
			runner_from_result_list = result_list[11]
			validate_result_R2_C7_N11(runner_from_result_list)
			
			runner_from_list_runners = list_runners[11]
			# validate_runner_R2_C7_N11(runner_from_list_runners, race_to_test)
			validate_runner_R2_C7_N11(runner_from_list_runners)
			
			# Favorite
			runner_from_result_list = result_list[1]
			validate_result_R2_C7_N1(runner_from_result_list)
			
			runner_from_list_runners = list_runners[1]
			# validate_runner_R2_C7_N1(runner_from_list_runners, race_to_test)
			validate_runner_R2_C7_N1(runner_from_list_runners)
			
			# Substitute
			runner_from_result_list = result_list[12]
			validate_result_R2_C7_N12(runner_from_result_list)
			
			runner_from_list_runners = list_runners[12]
			# validate_runner_R2_C7_N12(runner_from_list_runners, race_to_test)
			validate_runner_R2_C7_N12(runner_from_list_runners)
			
			# 12th place
			runner_from_result_list = result_list[4]
			validate_result_R2_C7_N4(runner_from_result_list)
			
			runner_from_list_runners = list_runners[4]
			# validate_runner_R2_C7_N4(runner_from_list_runners, race_to_test)
			validate_runner_R2_C7_N4(runner_from_list_runners)
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			runner_to_check = joint_list[11]
			# validate_joint_R2_C7_N11(runner_to_check, race_to_test)
			validate_joint_R2_C7_N11(runner_to_check)
			
			# Favorite
			runner_to_check = joint_list[1]
			# validate_joint_R2_C7_N1(runner_to_check, race_to_test)
			validate_joint_R2_C7_N1(runner_to_check)
			
			# Substitute
			runner_to_check = joint_list[12]
			# validate_joint_R2_C7_N12(runner_to_check, race_to_test)
			validate_joint_R2_C7_N12(runner_to_check)
			
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
			result_list = @crawler.fetch_race_results()
			
			# go to runners' page
			@crawler.go_to_runners_page()
			
			# getting the runner_list
			list_runners = @crawler.fetch_list_runners()
			
			@logger.level = SimpleHtmlLogger::DEBUG
			@logger.debug("test_join_runner_list_and_result_list - " + 
				"result_list.size = " + result_list.size)
			# First place
			runner_from_result_list = result_list[3]
			validate_result_R1_C7_N3(runner_from_result_list)
			
			runner_from_list_runners = list_runners[3]
			# validate_runner_R1_C7_N3(runner_from_list_runners, race_to_test)
			validate_runner_R1_C7_N3(runner_from_list_runners)
			
			# Favorite
			runner_from_result_list = result_list[1]
			validate_result_R1_C7_N1(runner_from_result_list)
			
			runner_from_list_runners = list_runners[1]
			# validate_runner_R1_C7_N1(runner_from_list_runners, race_to_test)
			validate_runner_R1_C7_N1(runner_from_list_runners)
			
			# Disqualified
			runner_from_result_list = result_list[11]
			validate_result_R1_C7_N11(runner_from_result_list)
			
			runner_from_list_runners = list_runners[11]
			# validate_runner_R1_C7_N11(runner_from_list_runners, race_to_test)
			validate_runner_R1_C7_N11(runner_from_list_runners)
			
			# Joining the lists
			joint_list = @crawler.join_runner_list_and_result_list(list_runners, result_list)
			
			# Checking the data aftwerward
			
			# First place
			runner_to_check = joint_list[3]
			# validate_joint_R1_C7_N3(runner_to_check, race_to_test)
			validate_joint_R1_C7_N3(runner_to_check)
			
			# Favorite
			runner_to_check = joint_list[1]
			# validate_joint_R1_C7_N1(runner_to_check, race_to_test)
			validate_joint_R1_C7_N1(runner_to_check)
			
			# Disqualified		
			runner_to_check = joint_list[11]
			# validate_joint_R1_C7_N11(runner_to_check, race_to_test)
			validate_joint_R1_C7_N11(runner_to_check)
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for join_runner_list_and_result_list OK.")
	end
	
	def test_get_column_map()
		
		@logger.imp("Testing getting the right column map")
		test_start_time = Time.now()
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
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for get_column_map OK.")
	end
	
	def test_fetch_runners
		
		@logger.imp("Testing fetch runners")
		test_start_time = Time.now()
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
			# validate_joint_R4_C5_N2(runner_to_check, race_to_test)
			validate_joint_R4_C5_N2(runner_to_check)
			
			
			# is between 1 and 10
			
			# is after 10
			
			# is is_non_runner
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_runners OK.")
	end
	
	def test_fetch_runners_shallow
		
		@logger.imp("Testing fetch runners shallow")
		test_start_time = Time.now()
		begin
			# Setting up 
			# -> Getting the first race (with distance)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C3_runners.htm")
			
			# race_to_test = Race::new() # R4_C3
			runner = nil
			
			# the function to test
			runner_hash = @crawler.fetch_runners_shallow()
			
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
								is_non_runner: false,
								is_substitute: false,
								jockey: Jockey::new(name: "G Lerena"),
								load_handicap: 60.5,
								load_ride: 0.0,
								number: 1,
								# race: race_to_test,
								single_rating_before_race: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""],
								url: "")
			validate_runner_shallow(expected_runner, runner_to_check, "(with draw) without blinder")
			
			# Non runner
			runner_to_check = runner_hash[8]
			expected_runner = Runner::new(
								age: 0,
								blinder: @ref_list_hash[:ref_blinder_list][""],
								draw: 0,
								earnings_career: 0.0,
								history: "",
								horse: Horse::new(name: "Phenomenal"),
								is_favorite: false,
								is_non_runner: true,
								is_substitute: false,
								jockey: Jockey::new(name: ""),
								load_handicap: 0.0,
								load_ride: 0.0,
								number: 8,			
								# race: race_to_test,
								single_rating_before_race: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""],
								url: "")
			validate_runner_shallow(expected_runner, runner_to_check, "non runner (with draw)")
			
			# -> Getting the second race (with time)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runners.htm")
			
			# race_to_test = Race::new() # R1_C7
			
			# the function to test
			runner_hash = @crawler.fetch_runners_shallow()
			
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
								is_non_runner: false,
								is_substitute: false,
								jockey: Jockey::new(name: "F. Nivard"),
								load_handicap: 0.0,
								load_ride: 0.0,
								number: 9,
								# race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: 2100,
								earnings_career: 100566.00,
								shoes: @ref_list_hash[:ref_shoes_list][""])
			validate_runner_shallow(expected_runner, runner_to_check, "without shoes and with earnings")

			runner_to_check = runner_hash[3]
			expected_runner = Runner::new(
								age: 7,
								blinder: @ref_list_hash[:ref_blinder_list][""],
								draw: 0,
								history: "0a2a1a1a(1",
								horse: Horse::new(	name: "Doktor Jaros", 
													sex: @ref_list_hash[:ref_sex_list]["M"]),
								is_favorite: false,
								is_non_runner: false,
								is_substitute: false,
								jockey: Jockey::new(name: "G. Gudmestad"),
								load_handicap: 0.0,
								load_ride: 0.0,
								number: 3,
								# race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: 2100,
								earnings_career: 87843.00,
								shoes: @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS"])
			validate_runner_shallow(expected_runner, runner_to_check, "with shoes (front) and earnings")

			runner_to_check = runner_hash[11]
			expected_runner = Runner::new(
								age: 10,
								blinder: @ref_list_hash[:ref_blinder_list][""],
								draw: 0,
								history: "4a0a6a5a(1",
								horse: Horse::new(name: "Metkutus", sex: @ref_list_hash[:ref_sex_list]["M"]),
								is_favorite: false,
								is_non_runner: false,
								is_substitute: false,
								jockey: Jockey::new(name: "J.m. Paavola"),
								load_handicap: 0.0,
								load_ride: 0.0,
								number: 11,
								# race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: 2100,
								earnings_career: 86140.00,
								shoes: @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"])
			validate_runner_shallow(expected_runner, runner_to_check, "(with trainer) with front and back shoes off")

			# -> Getting the third race (without draw)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8_runners.htm")
			
			# race_to_test = Race::new() # R2_C8
			
			# the function to test
			runner_hash = @crawler.fetch_runners_shallow()
			
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
								is_non_runner: false,
								is_substitute: false,
								jockey: Jockey::new(name: "F.corallo"),
								load_handicap: 66,
								load_ride: 64,
								number: 8,
								# race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: nil,
								earnings_career: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""])
			validate_runner_shallow(expected_runner, runner_to_check, "without draw")
			
			runner_to_check = runner_hash[9]
			expected_runner = Runner::new(
								age: 5,
								blinder: @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"],
								draw: 0,
								history: "",
								horse: Horse::new(name: "Velours D'allier", sex: @ref_list_hash[:ref_sex_list]["H"]),
								is_favorite: false,
								is_non_runner: false,
								is_substitute: false,
								jockey: Jockey::new(name: "J.zerourou"),
								load_handicap: 66,
								load_ride: 64,
								number: 9,
								# race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: nil,
								earnings_career: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""])
			validate_runner_shallow(expected_runner, runner_to_check, "without draw or history but with load_ride")
			
			
			# Checking the fetched results
			runner_to_check = runner_hash[4]
			expected_runner = Runner::new(
								age: 5,
								blinder: @ref_list_hash[:ref_blinder_list]["OEILLERES_AUSTRALIENNES"],
								draw: 0,
								history: "4h(13)1h4p2s",
								horse: Horse::new(name: "Va Longtemps", sex: @ref_list_hash[:ref_sex_list]["F"]),
								is_favorite: false,
								is_non_runner: false,
								is_substitute: false,
								jockey: Jockey::new(name: "J.plouganou"),
								load_handicap: 67,
								load_ride: 0.0,
								number: 4,
								# race: race_to_test,
								single_rating_before_race: 0.0,
								url: "",
								distance: nil,
								earnings_career: 0.0,
								shoes: @ref_list_hash[:ref_shoes_list][""])
			validate_runner_shallow(expected_runner, runner_to_check, "without draw but with load_ride and history")
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_runners_shallow OK.")
	end
	
	def test_fetch_race_results()
		
		@logger.imp("Testing fetch race results")
		test_start_time = DateTime.now()
		@logger.debug(test_start_time.strftime(@config[:gen][:default_time_format]))
		begin
			# Setting up 
			# -> Getting the first race (with distance)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C1.htm")
			
			race_to_test = Race::new() # R4_C1
			runner = nil
			
			# the function to test
			runner_hash = @crawler.fetch_race_results()
			
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
								is_non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "R4_C1_N2 (first place)")
			
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
								is_non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "R4_C1_N10 (After 10th place)")
			
			# Non-runner (is_non_runner == true, final_place == nil, single_rating_after_race == nil)
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
								is_non_runner: true,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "R4_C1_N11 (non-runner)")
			
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
								is_non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "R4_C1_N1 (normal)")
			
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
								is_non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "R4_C1_N6 (favorite)")
			@logger.ok("Tests for race with distance OK.")
			
			# -> Getting the second race (with time)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1.htm")
			
			race_to_test = Race::new() # R3_C1
			
			# the function to test
			runner_hash = @crawler.fetch_race_results()
			
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
								is_non_runner: false,
								disqualified: false)
			validate_runner_from_result_list(expected_runner, runner_to_check, "R3_C1_N11 (commentary and time)")
			
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
								is_non_runner: false,
								disqualified: true)
			validate_runner_from_result_list(expected_runner, runner_to_check, "R3_C1_N10 (commentary and 0 time)")
			
			
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
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_race_results OK.")
	end
	
	def test_fetch_runner()
		
		@logger.imp("Testing fetch runner")
		test_start_time = Time.now()
		begin
			# Setting up 
			# -> Getting the first race (with distance)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4.htm")
			
			race_to_test = Race::new() # R4_C4
			runner = nil
			
			# fetching the hash of runners (to get the URLs)
			runner_results_hash = @crawler.fetch_race_results()
			
			# Checking we did get a list and the right one
			assert("Runner list is nil", runner_results_hash != nil)
			assert_equal(17, runner_results_hash.size, "Wrong number of runners fetched")
			
			# fetching the runners' shallow data (as if we're in the fetch_runners function)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4_runners.htm")
			runner_shallow_hash = @crawler.fetch_runners_shallow()
			
			assert_equal(17, runner_shallow_hash.size, "Wrong number of runners shallow fetched")
			
			# putting each runner's URL
			runner_shallow_hash.each do |key, shallow_runner|
				# @logger.debug("number = " + key.to_s + ", shallow_runner: " + shallow_runner.to_s)
				# @logger.debug("current_number: " + current_number.to_s)
				result_runner = runner_results_hash[key]
				# @logger.debug("url before: " + shallow_runner.url)
				# @logger.debug("result_runner url: " + result_runner.url)
				shallow_runner.url = result_runner.url
				
				# @logger.debug("url after: " + shallow_runner.url)
			end
			
			# the function to test
			runner_shallow_hash.each do |key, shallow_runner|
				shallow_runner = @crawler.go_and_fetch_runner(shallow_runner)
			end
			
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			sex = @ref_list_hash[:ref_sex_list]["F"]
			
			father = Horse::new(name: "antonius pius")
			grand_father = Horse::new(name: "goldkeeper")
			mother = Horse::new(name: "cherry flower", father: grand_father)
			
			horse = Horse::new(breed: breed,
								coat: coat,
								father: father,
								name: "Antonia Major",
								mother: mother,
								sex: sex)
			
			# runner without victories or breeder
			runner_to_check = runner_shallow_hash[1]
			expected_runner = Runner::new(
								breeder: Breeder::new(name: ""),
								description: "",
								earnings_career: 3024.00,
								earnings_current_year: 1049.00,
								earnings_last_year: 1975.00,
								earnings_victory: 0.00,
								horse: horse,
								number: 1,
								owner: Owner::new(name: "MESSRS A LANG & R J MAYHEW"),
								places: 6,
								races_run: 7,
								trainer: Trainer::new(name: "C MAYHEW"),
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4_runner_ANTONIA_MAJOR.htm",
								victories: 0)
			validate_runner(expected_runner, runner_to_check, "R4_C4_N1 (without victories or breeder)")
			
			# runner without earnings, victories or places
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list][""]
			
			father = Horse::new(name: "casey tibbs")
			grand_father = Horse::new(name: "dahar")
			mother = Horse::new(name: "dahlia's legacy", father: grand_father)
			
			horse = Horse::new(breed: breed,
								coat: coat,
								father: father,
								name: "Dahlia's Destiny",
								mother: mother)
			
			runner_to_check = runner_shallow_hash[7]
			expected_runner = Runner::new(
								breeder: Breeder::new(name: ""),
								description: "",
								earnings_career: 0.00,
								earnings_current_year: 0.00,
								earnings_last_year: 0.00,
								earnings_victory: 0.00,
								horse: horse,
								number: 7,
								owner: Owner::new(name: "MR S M FERREIRA"),
								places: 0,
								races_run: 3,
								trainer: Trainer::new(name: "S M FERREIRA"),
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4_runner_DAHLIA%27S_DESTINY.htm",
								victories: 0)
			validate_runner(expected_runner, runner_to_check, "R4_C4_N7 (without earnings, victories or places)")
			
			
			# -> Getting the second race (with time)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8.htm")
			
			race_to_test = Race::new() # R2_C8
			runner = nil
			
			# fetching the hash of runners (to get the URLs)
			runner_results_hash = @crawler.fetch_race_results()
			
			# Checking we did get a list and the right one
			assert("Runner list is nil", runner_results_hash != nil)
			assert_equal(11, runner_results_hash.size, "Wrong number of runners fetched")
			
			# fetching the runners' shallow data (as if we're in the fetch_runners function)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8_runners.htm")
			runner_shallow_hash = @crawler.fetch_runners_shallow()
			
			# putting each runner's URL
			runner_shallow_hash.each do |key, shallow_runner|
				result_runner = runner_results_hash[shallow_runner.number]
				shallow_runner.url = result_runner.url
			end
			
			# the function to test
			runner_shallow_hash.each do |key, shallow_runner|
				shallow_runner = @crawler.go_and_fetch_runner(shallow_runner)
			end
			
			# runner without earnings_current_year
			breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
			coat = @ref_list_hash[:ref_coat_list]["GRIS FONCE"]
			sex = @ref_list_hash[:ref_sex_list]["H"]
			
			father = Horse::new(name: "sacro saint")
			grand_father = Horse::new(name: "saint cyrien")
			mother = Horse::new(name: "biblique", father: grand_father)
			
			horse = Horse::new(breed: breed,
								coat: coat,
								father: father,
								mother: mother,
								name: "Votez Pour Moi",
								sex: sex)
			
			runner_to_check = runner_shallow_hash[3]
			expected_runner = Runner::new(
								breeder: Breeder::new(name: "HARAS DE SAINT-VOIR"),
								description: "",
								earnings_career: 68300.00,
								earnings_current_year: 0.00,
								earnings_last_year: 53900.00,
								earnings_victory: 36480.00,
								horse: horse,
								number: 3,
								owner: Owner::new(name: "HARAS DE SAINT-VOIR"),
								places: 6,
								races_run: 12,
								trainer: Trainer::new(name: "MACAIRE (S)"),
								url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8_runner_VOTEZ_POUR_MOI.htm",
								victories: 2)
			validate_runner(expected_runner, runner_to_check, "R2_C8_N3 (without earnings_current_year)")
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_runner OK.")
	end
	
end