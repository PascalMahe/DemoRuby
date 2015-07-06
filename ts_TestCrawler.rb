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
	
	def test_fetch_meeting
		
		@logger.info("Testing fetch meetings")
		begin
			job = Job::new
			date = Date::new(2013,11,15)
			@logger.debug("Logger outputs debug messages")
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			html_meeting_list = @crawler.driver.find_element(:xpath, "//div[@id='reunions-view']")
		
			
			if html_meeting_list == nil then
				flunk("html_meeting_list is nil.")
			end
		
			meeting_list = @crawler.fetch_meetings(html_meeting_list, date, job)
			
			assert_equal(5, meeting_list.size)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
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
			
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
#	def test_fetch_meetings
#		
#		@logger.info("Testing fetch meetings")
#		begin
#
#		rescue Exception => err
#			@logger.error(err.inspect)
#			@logger.error(err.backtrace)
#			flunk(err.inspect)
#		end
#	end
	
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
			# @logger.debug("Weather : " + weather.to_s)
			
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
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end

end