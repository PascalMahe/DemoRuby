require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'test/unit'
require 'selenium-webdriver'
require './common.rb'
require './SimpleHtmllogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
require './DatabaseInterface.rb'

###########################################################################################
#################################                        ##################################
#################################    MAIN SCRIPT HERE    ##################################
#################################                        ##################################
###########################################################################################


begin #general exception catching block

	start_time = Time.now
	
	# Initializing logger
	$logger = SimpleHtmlLogger::new(SimpleHtmlLogger::Debug)
	
	$logger.info("Loading config")
	
	$config = load_config()
	$is_test = true
	
	$logger.info("START TIME: " + start_time.strftime($config[:gen][:default_date_time_format]))
	$logger.debug("Config : " + $config.to_s)

	loading_end_time = Time.now

	# Creating job 
	current_job = Job::new
	current_job.start_time = start_time
	current_job.loading_end_time = loading_end_time

	# Creating test interface with database
	$logger.imp("TESTS")
	dbi = DatabaseInterface::new($config, $is_test)


	$logger.imp("END TESTS")

	$logger.imp("REAL STUFF")
	# Creating real interface with database
	dbi = DatabaseInterface::new($config, false)
	$logger.info("Loading reference values")
	$ref_list_hash = dbi.load_all_refs()

	$logger.info("Preparing browser")
	# preparing FF : adding Firebug 
	profile = Selenium::WebDriver::Firefox::Profile.new

	#Loading browser
	$driver = Selenium::WebDriver.for(:firefox)
	# $driver.manage.timeouts.implicit_wait = 15 # seconds

	$logger.info("Starting to crawl")

	base_adress = $config[:gen][:base_adress_test_fetching]


	# Getting main page
	$driver.get(base_adress)
	date = Date::new(2014,02,20)
	
	#Fetching meetings
	html_meeting_list = $driver.find_element(:xpath, "//div[@id='timeline-view']/div[@class='course-line'")
	page_list = []
	html_meeting_list.each do |html_meeting|
		link = $driver.find_element(:xpath, "a")
		page_list.add(link.attribute("href"))
	end
	
	page_list.each do |link|
		$driver.get(link)
		button = $driver.find_element(:xpath, "//div[@id='conditions]/a'")
		button.click
		button.send_keys(:control, 's')
	end
	
	$logger.info("Ending crawl")
	crawling_end_time = Time.now
	current_job.crawling_end_time = crawling_end_time
	
	$logger.info("Starting computations")
	$logger.info("Ending computations")
	computing_end_time = Time.now
	
	$logger.debug(current_job)
	$logger.imp("END REAL STUFF")
	
#rescue ArgumentError, NameError => err
#	$logger.error(err)
#	puts err
rescue Exception => err
	$logger.error(err.inspect)
	$logger.error(err.backtrace)
end

$logger.end_log


