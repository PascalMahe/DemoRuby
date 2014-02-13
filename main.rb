require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'test/unit'
require 'selenium-webdriver'
require './common.rb'
require './SimpleHtmlLogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
require './DatabaseInterface.rb'

begin #general exception catching block

	start_time = Time.now
	config = load_config()
	is_test = true
	logger = config[:logger]
	logger.info("START TIME: " + start_time.strftime(config[:gen][:default_date_time_format]))
	logger.debug("Config : " + config.to_s)

	loading_end_time = Time.now

	# Creating job 
	current_job = Job::new
	current_job.start_time = start_time
	current_job.loading_end_time = loading_end_time

	# Creating test interface with database
	logger.imp("TESTS")
	dbi = DatabaseInterface::new(config, is_test)

	#logger.imp("Dropping all tables, 'cause, you know, reasons...")
	#dbi.drop_tables()
	#logger.info("Tables dropped")

	logger.imp("Checking Database Existence")
	table_nb = dbi.get_table_number()
	if(table_nb < 22) then
		logger.info("Creating tables")
		dbi.create_tables()
		logger.info("Tables created")
	else 
		logger.info("Tables already exist")
	end


	#create a new empty TestSuite, giving it a name
	#db_tests = Test::Unit::TestSuite.new("Database Interfacing Tests")
	#db_tests << TestDatabaseInterface.new('test_insert_breeder')#calls TestDatabaseInterface#test_insert_breeder
	#run the suite
	#Test::Unit::UI::Console::TestRunner.run(db_tests)


	logger.imp("END TESTS")

	logger.imp("REAL STUFF")
	# Creating real interface with database
	dbi = DatabaseInterface::new(config, false)
	logger.info("Loading reference values")
	ref_list_hash = dbi.load_all_refs()

	logger.info("Preparing browser")
	# preparing FF : adding Firebug 
	profile = Selenium::WebDriver::Firefox::Profile.new
	profile.add_extension("./Install/firebug-1.11.4-fx.xpi")

	PROXY = 'proxy-internet.societe.mma.fr:8080'
	profile.proxy = Selenium::WebDriver::Proxy.new(
	  :http     => PROXY,
	  :ftp      => PROXY,
	  :ssl      => PROXY
	)
	
	# Proxy problem : see http://tech.danbarrese.com/2013/04/08/solved-use-watir-webdriver-behind-proxy/
	# and http://code.google.com/p/selenium/issues/detail?id=4300
	ENV['no_proxy'] = '127.0.0.1'
	
	#Loading browser
	driver = Selenium::WebDriver.for(:firefox, :profile => profile)
	driver.manage.timeouts.implicit_wait = 15 # seconds

	logger.info("Starting to crawl")
	if is_test
		base_adress = config[:gen][:base_adress]
	else
		base_adress = config[:gen][:base_adress_test]
	end

	# Getting main page
	driver.get(base_adress)
	
	#TODO : loop on ALL* the days
	# *ALL = config[:gen][::time_lapse]
	date = Date::new(2013,11,15)
	
	#Fetching meetings
	#Loop on meetings
	meeting_list = []
	html_meeting_list = driver.find_element(:class, "listReu")
	html_meeting_list = html_meeting_list.find_elements(:xpath, "li/a")
	logger.info("Loading meetings : there are " + html_meeting_list.size.to_s + " meetings.")
	html_meeting_list.each do |meeting|
		curr_meeting = Meeting::new
		#Basic info for meetings
		
		curr_meeting.date = date
		curr_meeting.url = meeting.attribute("href")
		meeting_text_split = meeting.text.split(" - ")
		curr_meeting.number = meeting_text_split[0]
		curr_meeting.racetrack = meeting_text_split[1]
		meeting_list.push(curr_meeting)
		logger.debug(curr_meeting)
		curr_meeting.job = current_job
		
		#Fetching races & weather
		driver.get(curr_meeting.url)
		curr_weather = Weather::new
		curr_meeting.weather = curr_weather
		#Basic weather info
		html_weather_container = driver.find_element(:id, "container_meteo")
		html_weather_img = html_weather_container.find_element(:xpath, "div/img")
		curr_weather.insolation = html_weather_img.attribute("src")
		weather_text = html_weather_container.text
		weather_text_split_once = weather_text.split(" - ") #PAS TOUJOURS PRESENT, A REVOIR
		curr_meeting.track_condition = ref_list_hash[:ref_track_condition_list][weather_text_split_once[0]]
		weather_text_split_twice = weather_text_split_once[1].split()
		weather.temperature = weather_text_split_twice[0]
		weather.wind_speed = weather_text_split_twice[2]
		weather.wind_direction = weather_text_split_twice[4]
		logger.debug(weather)
	end
	

#rescue ArgumentError, NameError => err
#	logger.error(err)
#	puts err
rescue Exception => err
	logger.error(err.inspect)
	logger.error(err.backtrace)
end

logger.end_log





















