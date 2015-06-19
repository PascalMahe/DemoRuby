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
	
	def test_fetch_meeting
		
		@logger.info("Testing fetch meetings")
		begin
			job = Job::new
			date = Date::new(2013,11,15)
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
		
		# @logger.info("Testing fetch meetings")
		# begin

		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_meetings
		
		# @logger.info("Testing fetch meetings")
		# begin

		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
	# def test_fetch_weather
		
		# @logger.info("Testing fetch meetings")
		# begin

		# rescue Exception => err
			# @logger.error(err.inspect)
			# @logger.error(err.backtrace)
			# flunk(err.inspect)
		# end
	# end
	
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