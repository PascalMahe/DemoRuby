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
	# def test_crawl
		
		# @logger.info("Testing fetch meetings")
		# begin
			# job = Job::new
		
			# @crawler.crawl("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm", job)
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_meeting
		
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
			
			# assert_equal(5, meeting_list.size)
			
			
		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	def test_fetch_meeting_shallow
		
		@logger.info("Testing fetch meeting shallow")
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
								
			assert_equal(verification_meeting, meeting)
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_fetch_meetings
		
		@logger.info("Testing fetch meetings")
		begin

		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	def test_fetch_weather
		
		@logger.info("Testing fetch weather")
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
			@logger.debug("Weather : " + weather.to_s)
			
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
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
	end
	
	# def test_launch_driver
		
		# @logger.info("Testing fetch meetings")
		# begin

		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
end