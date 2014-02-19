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

def fetch_meetings(html_meeting_list, date, current_job)
	#parameter : a WebElement representing an <ul> tag, containing the list of meetings
	
	#Loop on meetings to fetch basic info : number, racetrack and url
	#Note : Elements are linked to the page currently displayed on the driver,
	# thus getting another page makes them 'stale'. Which is why we must use
	# two loops : one to get the URLs and the other to navigate to the pages.
	meeting_list = []
	html_meeting_list = html_meeting_list.find_elements(:xpath, "li/a")
	$logger.info("Loading meetings : there are " + html_meeting_list.size.to_s + " meetings.")
	html_meeting_list.each do |meeting|
		business_meeting = fetch_meeting_shallow(meeting, date, current_job)
		meeting_list.push(business_meeting)
	end
	
	# Second loop : to get all the data on meetings
	meeting_list.each do |meeting|
		fetch_meeting(meeting)
	end
	return meeting_list
end

def fetch_meeting_shallow(html_meeting, date, job)
	#parameter : a WebElement representing an <a> tag, linking to the meeting
	
	#Basic info for meetings : url, date, number, racetrack
	url = html_meeting.attribute("href")
	
	meeting_text_split = html_meeting.text.split(" - ")
	number = html_meeting[0]
	racetrack = meeting_text_split[1]
	
	#date
	if $is_test then
		meeting_date = date
	else
		#for reference, typical href attribute : 
		# http://www.pmu.fr/turf/16112013/reunion-5-AVENCHES/course-1-DU_CENTRE_EST.html
		# after split, should be :
		# ["http:", "", "www.pmu.fr", "turf", "16112013", "reunion-5-AVENCHES", "course-1-DU_CENTRE_EST.html"]
		# => date is n°4 (starting at 0)
		str_date = url.split('/')
		str_date = str_date[4]
		meeting_date = Date::new(str_date[4, 4], str_date[2, 2], str_date[0, 2])
	end
	
	meeting = Meeting::new(meeting_date, job, number, racetrack, [], url)
	#$logger.debug(meeting)
	return meeting
end

def fetch_meeting(meeting)
	# Parameter : a Meeting, containing the basic data, including the URL of the page where the rest are to be gathered
	
	#Fetching page w/ deeper info 
	$driver.get(meeting.url)
	
	#weather
	html_weather_container = $driver.find_element(:id, "container_meteo")
	weather = fetch_weather(html_weather_container)
	
	#track_condition
	weather_text = html_weather_container.text
	if weather_text.include?(" - ") then
		track_condition = weather_text.split(" - ")[0]
		# the meeting name is included in the track_condition at this point
		# it's removed by using the fact that it's in a <span>
		meeting_name = html_weather_container.find_element(:xpath, "span")
		meeting_name = meeting_name.text
		track_condition = track_condition.gsub(meeting_name, '')
		track_condition.strip!
	else
		track_condition = ""
	end
	
	meeting.weather = weather
	meeting.track_condition = track_condition
	
	#Fetching races
	# Just like meetings : two loops, one for a shallow pass to get URLs and basic data,
	# the other to get the data on each race's page
	race_table = $driver.find_element(:class, "tableauResultsHippiqueBody")
	meeting.race_list = fetch_races(race_table, meeting)
	
	$logger.debug(meeting)
	return meeting
end

def fetch_weather(html_weather)
	# Parameter : a WebElement, containing the basic data
	
	#Basic weather info
	html_weather_img = html_weather.find_element(:xpath, "div/img")
	insolation = html_weather_img.attribute("src")
	weather_text = html_weather.text
	if weather_text.include?(" - ") then
		weather_text = weather_text.split(" - ")[1] # ignoring the part before the ' - ' if it's present
	end
	
	weather_text_split = weather_text[1].split()
	temperature = weather_text_split[0]
	wind_speed = weather_text_split[2]
	wind_direction = $ref_list_hash[:ref_direction_list][weather_text_split[4]]
	
	curr_weather = Weather::new(insolation, temperature, wind_direction, wind_speed)
	$logger.debug(curr_weather)
	return curr_weather
end

def fetch_races(race_table, meeting)
	#Parameter : a WebElement wrapping a <tbody> tag, containing the races
	
	race_list = []
	html_race_list = race_table.find_elements(:xpath, "tr")
	html_race_list.each do |html_race|
		business_race = fetch_race_shallow(html_race, meeting)
		race_list.push(business_race)
	end
	
	race_list.each do |race|
		fetch_race(race)
	end
	return race_list
end

def fetch_race_shallow(html_race, meeting)
	# Parameter : a WebElement wrapping a <tr> tag, containing the shallow data about the race
	
	number = html_race.find_element(:class, "TRHcol1")
	number = number.text
	
	race_link = html_race.find_element(:xpath, "td/a")
	url = race_link.attribute("href")
	
	name = race_link.text
	
	time = html_race.find_element(:class, "TRHcol4")
	time = time.text
	
	#getting the data in the text below the link (in the second column)
	text_below = html_race.find_element(:class, "TRHcol2")
	text_below = text_below.find_element(:xpath, "div")
	text_below = text_below.text
	text_below = text_below.split(" - ")
	value = text_below[1]
	# value : 'X.XXX €'
	str_value = value.sub('.', '')
	str_value = value.sub('€', '')
	str_value = value.sub(' ', '')
	str_value.strip!
	int_value = str_value.to_i
	
	str_distance_and_racetype = text_below[0]
	# distance : numbers to the end (minus the 'm')
	int_distance_starting_index = str_distance_and_racetype.index(/[1-9]/)
	str_distance = str_distance_and_racetype.slice(int_distance_starting_index..str_distance_and_racetype.length)
	# erasing the 'm'
	str_distance = str_distance.sub('m', '')
	int_distance = str_distance.to_i
	
	
	# racetype : everything that's not distance
	str_racetype_name = str_distance_and_racetype.slice(0..int_distance_starting_index)
	str_racetype_name.strip!
	racetype = $ref_list_hash[:ref_racetype][str_racetype_name]
	
	race = Race::new(meeting, name, number, url, time, int_value, int_distance, racetype)
	#$logger.debug(race)
	return race
end

def fetch_race(race)
	# Parameter : a Race, containing the basic data, including the URL of the page where the rest are to be gathered
	# Fields to fill : detailed conditions, runners
	
	#Fetching page w/ deeper info 
	$driver.get(meeting.url)
	
	# detailed conditions
	detailed_conditions = $driver.find_element(:id, "conds_detail")
	detailed_conditions = detailed_conditions.text
	detailed_conditions.strip!
	
	$logger.debug(race)
	
	#runner
	race.runner_list = fetch_runners(race)
end

def fetch_runners(race)
	# Parameter : a Race
	# Returns a list of (completed) Runners
	
	list_runners = []
	runner_rows = driver.find_elements(:id, "//tr[@class='tableauPariBody']/tr")
	runner_rows.each do |runner_row|
		runner = fetch_runner(runner_row, race)
		list_runners.push(runner)
	end
		
	return list_runners
end

def fetch_runner(html_runner, race)
	# Parameter : a WebElement wrapping around a <tr> containing all data on the runner
	# Fields to fill :
	# - race
	# - horse
	# - jockey
	# - trainer
	# - owner
	# - breeder
	# - blinder
	# - shoes
	# - number
	# - draw
	# - single_rating
	# - final_place
	# - non_runner
	# - races_run
	# - victories
	# - places
	# - earnings_career
	# - earnings_current_year
	# - earnings_last_year
	# - earnings_victory
	# - description
	# - distance
	# - load
	# - history
	# - url
	
	# horse
	horse = fetch_horse(html_runner)
	
	# jockey
	jockey = fetch_jockey(html_runner)
	
	# trainer
	trainer = fetch_trainer(html_runner)
	
	# owner
	owner = fetch_owner(html_runner)
	
	# breeder
	breeder = fetch_breeder(html_runner)
	
	# blinder
	blinder_li_element = $driver.find_element(:xpath, "/td[@class='tableauPariBodyList']/div/ul/li[@class='eye']")
	# if blinder_li_web_element doesn't have any children, no blinder
	blinder_img_element = blinder_li_element.find_element(:xpath, "/img")
	str_blinder = ""
	if blinder_img_element != null
		str_blinder = blinder_img_element.attribute("src")
	end
	
	# shoes
	# number
	# draw
	# single_rating
	# final_place
	# non_runner
	# races_run
	# victories
	# places
	# earnings_career
	# earnings_current_year
	# earnings_last_year
	# earnings_victory
	# description
	# distance
	# load
	# history
	# url
	
	
	$logger.debug(race)
	
	#runner
	race.runner_list = fetch_runners(race)
end




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

	#$logger.imp("Dropping all tables, 'cause, you know, reasons...")
	#dbi.drop_tables()
	#$logger.info("Tables dropped")

	$logger.imp("Checking Database Existence")
	table_nb = dbi.get_table_number()
	if(table_nb < 22) then
		$logger.info("Creating tables")
		dbi.create_tables()
		$logger.info("Tables created")
	else 
		$logger.info("Tables already exist")
	end


	#create a new empty TestSuite, giving it a name
	#db_tests = Test::Unit::TestSuite.new("Database Interfacing Tests")
	#db_tests << TestDatabaseInterface.new('test_insert_breeder')#calls TestDatabaseInterface#test_insert_breeder
	#run the suite
	#Test::Unit::UI::Console::TestRunner.run(db_tests)

	$logger.imp("END TESTS")

	$logger.imp("REAL STUFF")
	# Creating real interface with database
	dbi = DatabaseInterface::new($config, false)
	$logger.info("Loading reference values")
	$ref_list_hash = dbi.load_all_refs()

	$logger.info("Preparing browser")
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
	$driver = Selenium::WebDriver.for(:firefox, :profile => profile)
	$driver.manage.timeouts.implicit_wait = 15 # seconds

	$logger.info("Starting to crawl")
	if $is_test
		base_adress = $config[:gen][:base_adress]
	else
		base_adress = $config[:gen][:base_adress_test]
	end

	# Getting main page
	$driver.get(base_adress)
	
	#TODO : loop on ALL* the days
	# *ALL = config[:gen][::time_lapse]
	date = Date::new(2013,11,15)
	
	#Fetching meetings
	html_meeting_list = $driver.find_element(:class, "listReu")
	meeting_list = fetch_meetings(html_meeting_list, date, current_job)
	
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


