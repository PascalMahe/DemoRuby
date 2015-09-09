require 'psych' 
#see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'selenium-webdriver'
require './common.rb'
require './SimpleHtmlLogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class Crawler
	CSS_TO_RUNNERS = ".ligne-participant"

	attr_accessor:driver
	
	################################################
	###############       INIT       ###############
	################################################
	
	def initialize(logger, ref_list_hash, config)
		@logger = logger
		@ref_list_hash = ref_list_hash
		@config = config
		@driver = launch_driver()
	end
	
	def launch_driver()
		@logger.info("Preparing browser")
		browser_start_start_time = Time::now
		
		# Proxy problem: see 
		# http://tech.danbarrese.com/2013/04/08/solved-use-watir-webdriver-behind-proxy/
		# and http://code.google.com/p/selenium/issues/detail?id=4300
		# ENV['no_proxy'] = '127.0.0.1'
		
		# preparing FF: adding Firebug 
		# see this page for version: https://getfirebug.com/downloads/
		profile = Selenium::WebDriver::Firefox::Profile.new
		
		# No longer working from MMA
		# PROXY = 'proxy-internet.societe.mma.fr:8080'
		# profile.proxy = Selenium::WebDriver::Proxy.new(
		  #:http     => PROXY,
		  #:ftp      => PROXY,
		  #:ssl      => PROXY
		# )
		profile.add_extension("./Install/firebug-1.12.6.xpi") # NB : FF takes ~2.5 more seconds to load w/ Firebug (from 6.1 to 8.8)
		profile["general.useragent.override"] = "Selenium UA"
		profile["nglayout.initialpaint.delay"] = 0
		profile["browser.tabs.animated"] = false
		profile["image.animation_modr"] = "none"
		profile["browser.sessionhistory.max_total_viewer"] = 1
		profile["browser.sessionhistory.max_entries"] = 3
		profile["browser.sessionhistory.max_total_viewers"] = 1
		profile["browser.sessionhistory.max_tabs_undo"] = 0
		profile["network.http.pipeline"] = true
		profile["network.http.pipeline.maxrequests"] = 8
		profile["browser.cache.memory.enable"] = true
		profile["browser.cache.disk.enable"] = true
		profile["browser.search.suggest.enabled"] = false
		profile["browser.formfill.enable"] = false
		profile["browser.download.manager.scanWhenDone"] = false
		profile["browser.bookmarks.max_backups"] = 0
				
		#Loading browser
		driver = Selenium::WebDriver.for(:firefox,:profile => profile)
		# @driver = Selenium::WebDriver.for(:firefox)
		# @driver = Selenium::WebDriver.for(:remote, :url => "http://localhost:4444/wd/hub", :desired_capabilities => :htmlunit)
		
		driver.manage.timeouts.implicit_wait = 15 # seconds
		browser_start_end_time = Time::now
		browser_start_total_time = browser_start_end_time - browser_start_start_time
		logStr = "Browser prepared (" + browser_start_total_time.to_s + "s)"
		@logger.info(logStr)
		return driver
	end
	
	def close_driver()
		@driver.quit
	end
	
	################################################
	#############       CRAWLING       #############
	################################################
	
	def crawl(base_adress, current_job)
		# Getting main page
		@driver.get(base_adress)
		
		#TODO: loop on ALL* the days
		# *ALL = config[:gen][::time_lapse]
		date = Date::new(2013,11,15)
		
		#Fetching meetings
		html_meeting_list = @driver.find_element(:id, "reunions-view")
		
		meeting_list = fetch_meetings(html_meeting_list, date, current_job)
		return meeting_list
	end

	
    def fetch_meetings(html_meeting_list, date, current_job)
		# html_meeting_list parameter: a WebElement representing a <div> tag 
		# containing the meetings' tags
		
		# Loop on meetings to fetch basic info (number, racetrack, weather and 
		# track_condition (in the original tag's children)), get the tag 
		# listing the races (from the meeting number) in order to get the 
		# date and races' URLs.
		# Note: Elements are linked to the page currently displayed on the 
		# driver, thus getting another page makes them 'stale'. Which is why we
		# must use two loops: one to get the URLs and the other to navigate to 
		# the pages.
		meeting_list = []
		
		html_meeting_list = html_meeting_list.
					find_elements(:css, "div.reunion-line")
		@logger.info("Loading meetings: there are " + 
					html_meeting_list.size.to_s + " meetings.")
		html_meeting_list.each do |meeting|
			business_meeting = 
				fetch_meeting_shallow(meeting, date, current_job)
			meeting_list.push(business_meeting)
			# @logger.debug("current business_meeting is a(n) " + business_meeting.class.to_s)
			if business_meeting.is_a?(Meeting) then
				# @logger.debug("business_meeting: " + business_meeting.date.to_s + ":" + business_meeting.number)
			end
		end
		
		@logger.imp("Fetched meetings (shallow) all " + meeting_list.length.to_s + " of 'em. Fetching deep meetings.")
		
		
		# Second loop: to get all the data on meetings
		meeting_list.each do |shallow_meeting|
			
			# @logger.debug("shallow_meeting: " +
				# shallow_meeting.date.to_s + ":" + shallow_meeting.number +
				# " (" + shallow_meeting.race_list.length.to_s + " races)")
			deep_meeting = fetch_meeting(shallow_meeting)
		end
				
		return meeting_list
	end

	def fetch_meeting_shallow(html_meeting, date, job)
		# parameter: a WebElement representing an <div> tag, linking to the meeting
		
		# number, racetrack, weather and track_condition are in the original tag's
		# children, date (is deduced from a race's tag
		
		# number
		number = html_meeting.attribute("data-reunionid")
		# @logger.debug("Number : " + number)
		
		# racetrack
		strong_tag_for_racetrack = html_meeting.
					find_element(:css, "strong")
		racetrack = strong_tag_for_racetrack.attribute("title")
		country = nil
		if racetrack.index("(") != nil then
			racetrackArray = racetrack.split("(")
			racetrack = racetrackArray[0].strip()
			country = racetrackArray[1]
			country = country.gsub(")", "").strip
			# @logger.debug("Country : " + country)
		end
		# @logger.debug("Racetrack : " + racetrack)
		
		
		# track_condition
		track_condition = nil
		begin # try/catch block for NoSuchElementError if not track_condition
			span_tag_for_track_condition = html_meeting.
					find_element(:xpath, "div/div/p/span[@class='etat-terrain']")
		
			track_condition_text = span_tag_for_track_condition.text
			# @logger.debug("Track condition text : " + track_condition_text)
			track_condition = @ref_list_hash[:ref_track_condition_list][track_condition_text]
			# @logger.debug("Track condition : " + track_condition.to_s)
		rescue
			@logger.debug("Track condition : nil")
		end
		
		# weather
		weather = nil
		div_tag_for_weather = html_meeting.
					find_element(:css, "div.picto-meteo")
		if div_tag_for_weather != nil then
			weather = fetch_weather(div_tag_for_weather)
			# @logger.debug("Weather : " + weather.to_s)
		end
		
		# getting second tag
		secondary_id = "numOfficiel-" + number
		secondary_div_tag = @driver.find_element(:id, secondary_id)
		
		# urls_of_races_array
		link_to_races_tags = secondary_div_tag.find_elements(:css, "a.course")
		urls_of_races_array = []
		link_to_races_tags.each do |link_to_race_tag|
			urls_of_races_array.push(link_to_race_tag.attribute("href"))
		end
		# @logger.debug("Urls_of_races_array : " + urls_of_races_array.to_s)
		
		#date
		if $globalState.is_test then
			first_race_href = "#12062015/R8/C1"
		else
			first_race_href = urls_of_races_array[0]
			 # should be like this : '#12062015/R8/C1'
		end
		str_meeting_date = first_race_href.split("/")[0] # => '#12062015'
		str_meeting_date = str_meeting_date.gsub("#", "") # => '12062015'
		str_year = str_meeting_date[4, 4]
		str_month = str_meeting_date[2, 2]
		str_day = str_meeting_date[0, 2]
		year = str_year.to_i
		month = str_month.to_i
		day = str_day.to_i
		
		meeting_date = Date::new(year, month, day) # => 2015, 06, 15
		
		# @logger.debug("Meeting_date : " + meeting_date.to_s)
		
		meeting = Meeting::new(country: country,
								date: meeting_date, 
								job: job, 
								number: number, 
								racetrack: racetrack, 
								urls_of_races_array: urls_of_races_array, 
								track_condition: track_condition, 
								weather: weather)
		# @logger.debug(meeting)
		return meeting
	end

	def fetch_meeting(meeting)
		# Parameter: a Meeting, containing all the data (fetched in fetch_meeting_shallow) 
		# for the race list
		# => Fetch the list with a loop on the urls_of_races_array
		
		meeting.urls_of_races_array.each do |url_of_race|
			race = fetch_race(url_of_race, meeting)
			meeting.race_list.push(race)
		end
		return meeting
	end

	def fetch_weather(div_tag_for_weather)
		# @logger.debug("div_tag_for_weather : " + div_tag_for_weather.to_s)
		weather_class = div_tag_for_weather.attribute("class")
		# @logger.debug("weather_class : " + weather_class)
		wheather_insolation = weather_class.split(" ")[1] 
		# @logger.debug("wheather_insolation : " + wheather_insolation)
		# the class should look like this: "picto-meteo P4"
		# we're only interested the P4 part
		
		# missing temperature and wind_speed to complete the Weather object
		# => they are in another tag, a div.popin_bottom
		# There are multiple div.popin_bottom tags, one per meeting  (for the weather)
		# plus one per icon in the meeting's (div#reunion_line) div.paris-evenements tag
		# => if not-test, hover over the picto element the find the div.popin_bottom that's
		# visible and get data from it
		@driver.action.move_to(div_tag_for_weather).perform
		popin_bottoms_tags = @driver.find_elements(:css, "div.popin")
		
		my_popin_bottom = nil 
		popin_bottoms_tags.each do |popin_bottom|
			# @logger.debug("current popin_bottom : " + popin_bottom.to_s)
			if popin_bottom.displayed? then
				my_popin_bottom = popin_bottom
				break
			end	
		end
		# @logger.debug("my_popin_bottom : " + my_popin_bottom.to_s)
		if my_popin_bottom != nil then
			str_weather_raw = my_popin_bottom.text.strip
			
			weather_components = str_weather_raw.split("\u00B0C\n") 
			# from test page, may break on real page
			
			str_temperature = weather_components[0]
			
			str_wind_speed = weather_components[1]
			
			
			str_temperature = str_temperature.gsub("Temp :   ", "").gsub("°C", "").strip()
			temperature = str_temperature.to_i
			str_wind_speed = str_wind_speed.gsub("Vent :    ", "").gsub("km/h", "").strip()
			wind_speed = str_wind_speed.to_i
		end
		
		# @logger.debug("temperature : " + temperature.to_s)
		# @logger.debug("wind_speed : " + wind_speed.to_s)
		weather = Weather::new(
			insolation: wheather_insolation, 
			temperature: temperature, 
			wind_speed: wind_speed)
		return weather
	end

	def fetch_race(url_of_race, meeting)
		# Parameter: the URL of the page where the data is to be gathered
		# and the Meeting containing this race
		# Fields to fill: bets, country, detailed_conditions, distance, 
		# general_conditions, name, number, race_type, result, result_insertion_time, 
		# runner_list, time, url and value
			
		#Fetching page
		@logger.info("fetch_race - Fetching race: " + url_of_race) 
		@driver.get(url_of_race)
		
		# bets
		# div#masses-enjeu/div[1]/div => Placé : XXX,XX €
		bet_tag = @driver.find_element(:xpath, "//div[@id='masses-enjeu']/div[1]")
		bets_text = bet_tag.text
		bets_text_array = bets_text.split(":")
		bets_str_raw = bets_text_array[1]
		bets_str = bets_str_raw.gsub("€", "").gsub(" ", "").gsub(",", ".").strip()
		bets = bets_str.to_f
		# @logger.debug("bets : " + bets.to_s)
		
		# detailed conditions
		# a.conditions-show -> btn to click
		# div.popin-detail (visible after the click)
		# -> div[1]/div.content
		# closed by clicking on div.popin-close
		btn_detailed_conditions = @driver.find_element(:css, "a.conditions-show")
		btn_detailed_conditions.click
		div_detailed_cond_tag_array = @driver.
			# find_element(:xpath, "//div[@class='detail-popin']")
			find_elements(:css, "div.detail-popin")
		if div_detailed_cond_tag_array.length > 0 then
			div_detailed_cond_tag = div_detailed_cond_tag_array[0]
			detailed_cond = div_detailed_cond_tag.text.strip()
			
			# close popin
			btn_close_popin = @driver.find_element(:css, "div.popin-close")
			btn_close_popin.click
			if $globalState.is_test then
				@driver.navigate.back
			end
		else 
			detailed_cond = "" #if there's no detail element
		end
		
		# @logger.debug("detailed_cond : " + detailed_cond)
		
		# distance
		# inside div#conditions => 	Plat - 		7759 € - 	1200m - 8 partants  - Handicap Corde à droite 
		# 							Monté - 	65000 € - 	2700m - 10 partants Corde à gauche 
		#							Attelé - 	20000 € - 	2100m - 12 partants  - Internationale - Autostart Corde à gauche 
		# split#2
		general_cond_tag = @driver.find_element(:id, "conditions")
		general_cond_str_raw = general_cond_tag.text
		
		general_cond_array = general_cond_str_raw.split("-")
		distance_str = general_cond_array[2].gsub("m", "").strip()
		distance = distance_str.to_i
		# @logger.debug("distance : " + distance.to_s)
		
		# general_conditions
		# inside div#conditions => 	Plat - 		7759 € - 	1200m - 8 partants  - Handicap Corde à droite 
		# 							Monté - 	65000 € - 	2700m - 10 partants Corde à gauche 
		#							Attelé - 	20000 € - 	2100m - 12 partants  - Internationale - Autostart Corde à gauche 
		# group from split("partants")#1
		general_conditions_partants_array = general_cond_str_raw.split("partants")
		general_conditions_raw = general_conditions_partants_array[1]
		general_conditions = general_conditions_raw.strip()
		if general_conditions.index("-") then
			general_conditions = general_conditions.slice(1, general_conditions.length - 1)
			general_conditions = general_conditions.strip()
		end
		# @logger.debug("general_conditions : " + general_conditions)
		
		# name
		# inside h2.course-title/b[1] => VAAL - JOBURG'S PRAWN FEST HANDICAP
		# split#1
		race_title_tag = @driver.find_element(:xpath, "//h2[@class='course-title']")
		race_title_str = race_title_tag.text
		# @logger.debug("race_title_str : " + race_title_str)
		race_title_array = race_title_str.split("-")
		name = race_title_array[2].strip()
		# @logger.debug("name : " + name)
		
		# number
		# li.current
		# attribute data-courseid
		current_racer_tag = @driver.find_element(:css, "li.current")
		number = current_racer_tag.attribute("data-courseid")
		# @logger.debug("number : " + number)
		
		# race_type
		# inside div#conditions => Plat - 7759 € - 1200m - 8 partants  - Handicap Corde à droite 
		# split#0
		race_type_raw = general_cond_array[0].strip()
		race_type = @ref_list_hash[:ref_race_type_list][race_type_raw]
		# @logger.debug("race_type : " + race_type.to_s)
		
		# result
		# dd.infos-arrivee-list
		result_tag = @driver.find_element(:css, "dd.infos-arrivee-list")
		result = result_tag.text.strip
		# @logger.debug("result : " + result)
		
		# result_insertion_time
		if result != '' then
			result_insertion_time = Time::new
			# @logger.debug("result_insertion_time : " + 
				# result_insertion_time.strftime(@config[:gen][:default_date_time_format])
			# )
		else 
			result_insertion_time = nil
			# @logger.debug("result_insertion_time : nil")
		end
						
		# time
		# h2.course-title => 20 Février 2014 • R4C3 - 12h15• VAAL - JOBURG'S PRAWN FEST HANDICAP
		# split(-)#1.split(•)#0
		race_long_title_tag = @driver.find_element(:css, "h2.course-title")
		race_long_title_text = race_long_title_tag.text 
		race_long_title_array = race_long_title_text.split("-") # => ["20 Février 2014 • R4C3 ", " 12h15• VAAL ", " JOBURG'S PRAWN FEST HANDICAP"]
		race_title_and_date_text = race_long_title_array[1] # => " 12h15• VAAL "
		race_title_and_date_array = race_title_and_date_text.split("•") # => ["12h15", " VAAL "]
		date_str = race_title_and_date_array[0].strip() #=> "12h15"
		date_str_array = date_str.split("h") # => ["12", "15"]
		date_hours_i = date_str_array[0].to_i # => 12
		date_min_i = date_str_array[1].to_i # => 15
		
		# @logger.debug("date_hours_i : " + date_hours_i.to_s)
		# @logger.debug("date_min_i : " + date_min_i.to_s)

		time = Time::new(1, 1, 1, date_hours_i, date_min_i)
		# @logger.debug("time : " + 
			# time.strftime(@config[:gen][:default_time_format])
		# )

		# url
		url = url_of_race
		
		# value
		# inside div#conditions => Plat - 7759 € - 1200m - 8 partants  - Handicap Corde à droite 
		# split#1
		value_str = general_cond_array[1].strip().gsub("€" , "")
		value = value_str.to_i
		
		race = Race::new(bets: bets,
					detailed_conditions: detailed_cond,
					distance: distance,  
					general_conditions: general_conditions,
					meeting: meeting, 
					name: name, 
					number: number, 
					race_type: race_type,
					result: result,
					result_insertion_time: result_insertion_time,
					time: time,
					url: url,  
					value: value
		)
		
		# @logger.debug(race)
		
		# runner_list
		@logger.debug("fetch_race - Fetching runners.")
		runner_list = fetch_runners(race)
		# @logger.debug("runner_list : " + runner_list.to_s)
	end

	def fetch_runners(race)
		# Parameter: a Race
		# Returns a list of (completed) Runners
		@logger.info("fetch_runners - Fetching race at page: " + race.url)
		
		# Go to race page
		if driver.current_url != race.url and race.url != nil then
			@logger.info("fetch_runners - getting race url: " + race.url)
			@driver.get(race.url)
		end
		
		# if the race is finished, the driver lands on the results page
		# otherwise it goes to the runner's table
		
		# if the race is over, its results are fetched
		# (in a separate loop because it involves going to a different page)
		result_list = Hash.new
		html_info_arrivee = @driver.find_elements(:id, "infos-arrivee")
		if html_info_arrivee.length > 0 then
			@logger.info("fetch_runners - Fetching race results.")
			result_list = fetch_race_results(race)
			go_to_runners_page()
		end
		
		@logger.info("fetch_runners - Fetching runners (shallow).")
		list_runners = fetch_list_runners(race)
		
		if not result_list.empty? then
			@logger.info("fetch_runners - joining deep and shallow runners.")
			list_runners = join_runner_list_and_result_list(list_runners, result_list)
		end
		
		return list_runners
	end
	
	def go_to_runners_page()
		# Goes to the page where the shallow runners are
		
		btn_to_runners_table_elmt = @driver.find_element(:xpath, "//div[@id='participants-view']/div[2]/a[2]")
		btn_to_runners_table_elmt.click
		@logger.debug("Going to runner's page: now on page " + @driver.current_url)
	end
	
	def go_and_fetch_runner(runner)
		# @logger.debug("go_and_fetch_runner - Does the runner have a URL?")
		# @logger.debug("go_and_fetch_runner - It can't, since that info is not on the runners page. Going by popin for now.")
		
		# FIXME when we attack the real site
		go_back = true
		
		if runner.url != nil and runner.url != "" then
			@driver.get(runner.url)
			
		else
			# if the runner doesn't have a URL, we have to 
			# find its line on the page and click on its 
			# name to make the popin appear
			
			# find the runner's name and click on it
			name = runner.horse.name
			name = name.upcase
			
			runner_name_elmt = @driver.find_element(:xpath, '//span[@title="' + name + '"]') 
			# reversing the ' and the "
			# because the horse's names can have apostrophes (fuckers...)
			runner_link_elmt = runner_name_elmt.find_element(:css, "a")
			runner_link_elmt.click
		end
		
		runner = fetch_runner(runner)
		# @logger.debug("go_and_fetch_runner - Fetched runner. Going back to runners page.")
		# @logger.debug("go_and_fetch_runner - Current page: " + driver.current_url)
		if go_back then
			@driver.navigate.back
			# @logger.debug("go_and_fetch_runner - Going back by stepping once in the browser's history.")
		else
			# click to close popin
			# @logger.debug("go_and_fetch_runner - Going back by closing the popin.")
			close_popin_elmt = @driver.find_element(:id, "popin-close")
			close_popin_elmt.click
			
		end
		# @logger.debug("go_and_fetch_runner - Went back to: " + driver.current_url)
	end
	
	def fetch_list_runners(race)
		@logger.info("fetch_list_runners - Fetching runners (shallow).")
		list_runners = fetch_runners_shallow(race)
				
		if $globalState.is_test then
			# in the tests, we have to go back to the results' page to 
			# deep fetch the runners (the test runners' page doesn't have
			# a link to the individual runners' pages)
			@driver.navigate.back
		end
		
		@logger.info("fetch_list_runners - Fetching runners (deep).")
		list_runners.each do |key, runner|
			@logger.info("fetch_list_runners - Fetching runner (deep): " + key.to_s)
			go_and_fetch_runner(runner)
		end
		return list_runners
	end
	
	def join_runner_list_and_result_list(list_runners, result_list)
		# joining the lists: for each runner in a list,
		# we join it to the runner in the other list then add it 
		# to the joint list. If it's not in the other list, it's
		# added directly. In both cases, it must not be in the list
		# before being added.
		
		joint_list = Hash.new
		
		list_runners.each do |key, runner|
			# @logger.debug("jrlarl - current runner: " + key.to_s)
			
			if joint_list[key] == nil then
				# @logger.debug("jrlarl - taking runner from list_runners: " + runner.to_s)
				other_runner = result_list[key]
				if other_runner != nil then
					# @logger.debug("jrlarl - runner from runner_list is not nil, joining")
					runner.join!(other_runner)
				end
				# @logger.debug("jrlarl - runner: " + runner.to_s)
				# @logger.debug("jrlarl - adding runner to joint_list (pos. " + key.to_s + ")")
				joint_list[key] = runner
			end
		end
		
		result_list.each do |key, runner|
			# @logger.debug("jrlarl - taking runner from result_list (pos. " + key.to_s + ")")
			# @logger.debug("jrlarl - at that pos. is: " + joint_list[key].to_s)
			if joint_list[key] == nil then
				# @logger.debug("jrlarl - adding runner to joint_list (pos. " + key.to_s + ")")
				joint_list[key] = runner
			end
		end
		return joint_list
	end
	
	def fetch_runners_shallow(race)
		# Parameter: a race
		# Fields to fill:
		# - age (horse)
		# - blinder (runner)
		# - distance (runner)
		# - draw (runner)
		# - earnings_career (runner)
		# - history (shortened history) (runner)
		# - jockey
		# - load_handicap (runner)
		# - load_ride (runner)
		# - name (horse)
		# - non_runner (runner)
		# - number (runner)
		# - race (runner)
		# - shirt (?) -> nobody cares...
		# - shoes (?) -> nobody cares...
		# - single_rating_before_race (runner)
		# - sex (horse)
		# - url (runner)
		
		# see fetch_race_results for :
		# - commentary (runner)
		# - disqualified (runner)
		# - diff. with precedent -> distance (runner)
		# - final_place (runner)
		# - number (runner)
		# - single_rating_after_race (rapports) (runner)
		# - time (runner)
		
		# see fetch_runner for:
		# - breed (pur-sang...) (horse)
		# - breeder
		# - coat (horse)
		# - description (runner)
		# - earnings_career (runner)
		# - earnings_current_year (runner)
		# - earnings_last_year (runner)
		# - earnings_victory (runner)
		# - father (runner)
		# - mother (runner)
		# - mother's father (runner)
		# - owner
		# - places (runner)
		# - races_run (runner)
		# - trainer
		# - victories (runner)
		
		result = Hash.new
		
		@logger.debug("fetch_runners_shallow - On page (should end with '_runners.htm'): " + @driver.current_url)
		
		html_runner_list = @driver.find_elements(:css, CSS_TO_RUNNERS)
		html_runner_list.each do | html_runner |
			
			# url (runner)
			# not available yet, suspected to be a failure of the 
			# process for saving test pages
			url = ""
			
			# number (runner)
			number_elmt = html_runner.find_element(:xpath, "td[1]")
			number_raw = number_elmt.text.strip
			number = number_raw.to_i
			
			# @logger.trace("fetch_runners_shallow - Fetching runner: " + number.to_s)
			
			# name (horse)
			horse_name_elmt = html_runner.find_element(:xpath, "td[2]")
			horse_name_raw = horse_name_elmt.text.strip
			horse_name = horse_name_raw
			
			runner_class_raw = html_runner.attribute("class")
			runner_class = runner_class_raw.strip
			
			non_runner = false
			age = 0
			blinder = nil
			draw = 0
			history = nil
			horse = nil
			jockey = nil
			load_handicap = 0.0
			load_ride = 0.0
			single_rating = 0.0
			
			if runner_class.index("non-partant") != nil then
				# non partant
				non_runner = true
				
				horse = Horse::new(name: horse_name)
				
				# @logger.trace("fetch_runners_shallow - non_runner branch ")
			else
				# partant
				non_runner = false
				
				# @logger.trace("fetch_runners_shallow - runner branch ")
				
				# sex (horse)
				sex_elmt = html_runner.find_element(:xpath, "td[5]")
				sex_raw = sex_elmt.text.strip
				sex = sex_raw
				
				# age (horse)
				age_elmt = html_runner.find_element(:xpath, "td[6]")
				age_raw = age_elmt.text.strip
				age = age_raw.to_i
				
				# jockey
				jockey_name_elmt = html_runner.find_element(:xpath, "td[7]")
				jockey_name_raw = jockey_name_elmt.text.strip
				jockey_name = jockey_name_raw
				
				# here, 2 possibilities : the one with a number (draw or load_handicap), as in R4_C3
				# and another one with the trainer, as in R1_C7
				unknown_elmt = html_runner.find_element(:xpath, "td[8]")
				unknown_raw = unknown_elmt.text.strip
				unknown = unknown_raw.to_i 
				# returns 0 if no parseable string -> 0 indicates a trainer
				
				if unknown == 0 then
					# trainer case
					# @logger.trace("fetch_runners_shallow - trainer branch ")
					
					# shoes
					shoes_elmt_potential = html_runner.find_elements(:xpath, "td[4]/b")
					if shoes_elmt_potential.length > 0 then
						shoes_elmt = shoes_elmt_potential[0]
						shoes_raw = shoes_elmt.attribute("class")
						shoes = shoes_raw
						if shoes == nil then
							shoes = "" # because nil and "" represent different information
									   # nil means draw branch (ie no shoe information)
									   # "" means trainer branch and no shoes off
						end
					end
					
					# distance
					distance_elmt = html_runner.find_element(:xpath, "td[9]")
					distance_raw = distance_elmt.text.strip
					distance = distance_raw.to_i
					@logger.debug("fetch_runners_shallow - distance: " + distance.to_s)
					
					# history
					history_xpath = "td[10]"
					
					# earnings_career
					earnings_career_elmt = html_runner.find_element(:xpath, "td[11]")
					earnings_career_raw = earnings_career_elmt.text
					earnings_career_raw = earnings_career_raw.gsub(",", ".")
					earnings_career_raw = earnings_career_raw.gsub("€", "")
					earnings_career_raw = earnings_career_raw.gsub(" ", "")
					earnings_career_raw = earnings_career_raw.strip
					earnings_career = earnings_career_raw.to_f
					
					# single_rating
					single_rating_xpath = "td[12]"
				else
					# number case
					# @logger.trace("fetch_runners_shallow - draw branch ")
					draw = nil
					
					# blinder (runner)
					blinder_elmt = html_runner.find_element(:xpath, "td[4]/b")
					blinder_raw = blinder_elmt.attribute("class")
					blinder = blinder_raw
					
					# here, again, 2 possible cases :
					# with or without draw
					# only difference is the number of <td> elements : 
					# 12 without, 13 with draw
					td_list = html_runner.find_elements(:xpath, "td")
					index_load_handicap = 8
					if td_list.length > 12 then
						# with draw
						draw = unknown
						index_load_handicap = 9
					end
					# @logger.debug("fetch_runners_shallow - index_load_handicap: " + index_load_handicap.to_s)
					
					# load_handicap (runner)
					xpath_to_load_handicap_elmt = "td[" + index_load_handicap.to_s + "]"
					# @logger.debug("fetch_runners_shallow - xpath_to_load_handicap_elmt: " + xpath_to_load_handicap_elmt)
					load_handicap_elmt = html_runner.find_element(:xpath, xpath_to_load_handicap_elmt)
					load_handicap_raw = load_handicap_elmt.text
					load_handicap_raw = load_handicap_raw.gsub(",", ".")
					load_handicap_raw = load_handicap_raw.strip
					load_handicap = load_handicap_raw.to_f 
					# returns 0.0 if string not parseable -> ie '-' will return 0.0
					
					# load_ride (runner)
					# load_ride_elmt = html_runner.find_element(:xpath, "td[10]")
					xpath_to_load_ride_elmt = "td[" + (index_load_handicap + 1).to_s + "]"
					# @logger.debug("fetch_runners_shallow - xpath_to_load_ride_elmt: " + xpath_to_load_ride_elmt)
					load_ride_elmt = html_runner.find_element(:xpath, xpath_to_load_ride_elmt)
					load_ride_raw = load_ride_elmt.text
					load_ride_raw = load_ride_raw.gsub(",", ".")
					load_ride_raw = load_ride_raw.strip
					load_ride = load_ride_raw.to_f 
					# returns 0.0 if string not parseable -> ie '-' will return 0.0
					
					# history
					# history_xpath = "td[12]"
					history_xpath = "td[" + (index_load_handicap + 3).to_s + "]"
					# @logger.debug("fetch_runners_shallow - history_xpath: " + history_xpath)
					
					# single_rating
					# single_rating_xpath = "td[13]"
					single_rating_xpath = "td[" + (index_load_handicap + 4).to_s + "]"
					# @logger.debug("fetch_runners_shallow - single_rating_xpath: " + single_rating_xpath)
				end	
				
				# history
				history_elmt = html_runner.find_element(:xpath, history_xpath)
				history_raw = history_elmt.text.strip
				history = history_raw
				
				# single_rating
				single_rating_before_race_elmt = html_runner.find_element(:xpath, single_rating_xpath)
				single_rating_before_race_raw = single_rating_before_race_elmt.text
				single_rating_before_race_raw = single_rating_before_race_raw.gsub(",", ".")
				single_rating_before_race_raw = single_rating_before_race_raw.strip
				# @logger.debug("fetch_runners_shallow - single_rating_before_race_raw = " + single_rating_before_race_raw)
				single_rating_before_race = single_rating_before_race_raw.to_f 
				
				horse = Horse::new(name: horse_name, sex: sex)
				
				jockey = Jockey::new(name: jockey_name)
			end
			# @logger.trace("fetch_runners_shallow - back to main branch ")
			
			runner = Runner::new(
				age: age,
				blinder: blinder,
				distance: distance,
				draw: draw,
				earnings_career: earnings_career,
				history: history,
				horse: horse,
				jockey: jockey,
				load_handicap: load_handicap,
				load_ride: load_ride,
				non_runner: non_runner,
				number: number,
				race: race,
				single_rating_before_race: single_rating_before_race,
				shoes: shoes,
				url: url
			)
			
			# @logger.debug("fetch_runners_shallow - Fetched runner: " + runner.to_s)
			# @logger.debug("Fetched runner: " + runner.horse.name + ", single_rating_before_race = " + runner.single_rating_before_race.to_s)
			
			result[number] = runner
		end
		
		return result
	end

	def fetch_race_results(race)
		# Parameter: a Race
		# Fields to fill:
		# - commentary (runner)
		# - disqualified (runner)
		# - diff. with precedent -> distance (runner)
		# - final_place (runner)
		# - is_favorite (runner)
		# - non_runner (rapports) (runner)
		# - number (runner)
		# - single_rating_after_race (rapports) (runner)
		# - time (runner)
		
		# see fetch_runner_shallow for :
		# - age (horse)
		# - blinder (runner)
		# - distance (runner)
		# - draw (runner)
		# - earnings_career (runner)
		# - history (shortened history) (runner)
		# - jockey
		# - load_handicap (runner)
		# - load_ride (runner)
		# - name (horse)
		# - non_runner (runner)
		# - number (runner)
		# - race (runner)
		# - shirt (?) -> nobody cares...
		# - shoes (?) -> nobody cares...
		# - single_rating (runner)
		# - sex (horse)
		# - trainer
		# - url (runner)
				
		# see fetch_runner for:
		# - breed (pur-sang...) (horse)
		# - breeder
		# - coat (horse)
		# - description (runner)
		# - earnings_career (runner)
		# - earnings_current_year (runner)
		# - earnings_last_year (runner)
		# - earnings_victory (runner)
		# - father (runner)
		# - mother (runner)
		# - mother's father (runner)
		# - owner
		# - places (runner)
		# - races_run (runner)
		# - trainer
		# - victories (runner)
		
		result = Hash.new
		
		html_runner_list = @driver.find_elements(:css, CSS_TO_RUNNERS)
		html_runner_list.each do |html_runner|
		
			td_list = html_runner.find_elements(:xpath, "td")
			
			disqualified = false
			is_favorite = false
			non_runner = false
			
			if td_list.size < 7 then
				# non-runner
				non_runner = true
				commentary = ""
				time = ""
				distance = ""
				final_place = nil
				single_rating = nil
				
			else
				# commentary
				commentary_html = html_runner.find_element(:xpath, "td[8]")
				commentary = commentary_html.text.strip
				
				# time
				time = ""
				
				# distance
				distance = ""
				
				distance_or_time_html = html_runner.find_element(:xpath, "td[6]")
				distance_or_time = distance_or_time_html.text.strip
				if (distance_or_time.index("\"") != nil) or (distance_or_time.index("'") != nil) then
					time = distance_or_time
				else
					distance = distance_or_time
				end
				
				# final_place & disqualified
				final_place_html = html_runner.find_element(:xpath, "td[1]")
				final_place_raw = final_place_html.text.strip
				
				if final_place_raw.index("DAI") == nil then
					if final_place_raw.index("-") == nil then
						# '1er', '2è', '3è'... to '10è'
						final_place_raw = final_place_raw.gsub("è", "")
						final_place_raw = final_place_raw.gsub("er", "")
						final_place_raw = final_place_raw.strip
						final_place_raw = final_place_raw.to_i
					else 
						# '-'
						final_place_raw = nil
					end
				else 
					# 'DAI'
					final_place_raw = nil
					disqualified = true
				end
				final_place = final_place_raw
				
				# single_rating
				single_rating_after_race_html = html_runner.find_element(:xpath, "td[7]")
				single_rating_after_race_raw = single_rating_after_race_html.text.strip
				single_rating_after_race_raw = single_rating_after_race_raw.gsub(",", ".")
				# @logger.debug("fetch_race_results - single_rating_raw = " + single_rating_after_race_raw)
				single_rating_after_race = single_rating_after_race_raw.to_f
				
			end
			
			# is_favorite
			
			complete_class = html_runner.attribute("class")
			if complete_class.index("favorite") != nil then
				is_favorite = true
			end
			
			# url //*[@id="participants-view"]/div[1]/table/tbody/tr[3]/td[3]/span[1]
			html_link_to_runner = html_runner.find_element(:xpath, "td[3]/span[1]/a")
			url = html_link_to_runner.attribute("href")

			# number (== hash key)
			number = get_runner_number_from_result_page(html_runner)
			
			runner = Runner::new(
				commentary: commentary,
				disqualified: disqualified,
				distance: distance,
				final_place: final_place,
				is_favorite: is_favorite,
				non_runner: non_runner,
				number: number,
				single_rating_after_race: single_rating_after_race,
				time: time,
				url: url
			)
			
			# @logger.debug(runner.to_s)
			
			result[number] = runner
		end
		
		return result
	end

	def get_runner_number_from_result_page(runner_web_elmt)
		number_html = runner_web_elmt.find_element(:xpath, "td[2]")
		number = number_html.text.strip.to_i
		return number
	end
	
	def fetch_runner(runner)
		# Fields to fill:
		# - breed (pur-sang...) (horse)
		# - breeder (runner)
		# - coat (horse)
		# - description (runner)
		# - earnings_career (runner)
		# - earnings_current_year (runner)
		# - earnings_last_year (runner)
		# - earnings_victory (runner)
		# - father (runner)
		# - mother (runner)
		# - mother's father (runner)
		# - owner
		# - places (runner)
		# - races_run (runner)
		# - trainer
		# - victories (runner)
		
		# see fetch_runner_shallow for:
		# - age (horse)
		# - blinder (runner)
		# - distance (runner)
		# - draw (runner)
		# - earnings_career (runner)
		# - history (shortened history) (runner)
		# - jockey
		# - load_handicap (runner)
		# - load_ride (runner)
		# - name (horse)
		# - non_runner (runner)
		# - number (runner)
		# - race (runner)
		# - shirt (?) -> nobody cares...
		# - shoes (?) -> nobody cares...
		# - single_rating_before_race (runner)
		# - sex (horse)
		# - trainer
		# - url (runner)
		
		# see fetch_race_results for :
		# - commentary (runner)
		# - disqualified (runner)
		# - diff. with precedent -> distance (runner)
		# - final_place (runner)
		# - is_favorite (runner)
		# - non_runner (rapports) (runner)
		# - number (runner)
		# - single_rating_after_race (rapports) (runner)
		# - time (runner)
		description = ""

		races_run_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-courses']/ul/li[1]/b")
		races_run_raw = races_run_elmt.text.strip()
		races_run = races_run_raw.to_i
		
		victories_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-courses']/ul/li[2]/b")
		victories_raw = victories_elmt.text.strip()
		victories = victories_raw.to_i
		
		places_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-courses']/ul/li[3]/b")
		places_raw = places_elmt.text.strip()
		places = places_raw.to_i
		
		trainer_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-entraineur']/b[1]")
		trainer_name = trainer_elmt.text.strip()
		if trainer_name.index("-") != nil and trainer_name.length == 1 then
			trainer_name = ""
		end
		trainer = Trainer::new(name: trainer_name)
		
		owner_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-entraineur']/b[2]")
		owner_name = owner_elmt.text.strip()
		if owner_name.index("-") != nil and owner_name.length == 1  then
			owner_name = ""
		end
		owner = Owner::new(name: owner_name)
		
		breeder_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-entraineur']/b[3]")
		breeder_name = breeder_elmt.text.strip()
		# @logger.debug("fetch_runner - " + runner.number.to_s + " breeder_raw = " + breeder_name)
		if breeder_name.index("-") != nil and breeder_name.length == 1 then
			breeder_name = ""
		end
		breeder = Breeder::new(name: breeder_name)
		
		earnings_career_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-gains']/ul/li[1]/b")
		earnings_career_raw = earnings_career_elmt.text.strip()
		earnings_career_raw = earnings_career_raw.gsub(",", ".")
		earnings_career_raw = earnings_career_raw.gsub("€", "")
		earnings_career_raw = earnings_career_raw.gsub(" ", "")
		earnings_career = 0.0
		# @logger.debug("fetch_runner - " + runner.number.to_s + " earnings_career_raw = " + earnings_career_raw)
		if earnings_career_raw.index("-") == nil then
			earnings_career = earnings_career_raw.to_f
		end
		
		earnings_last_year_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-gains']/ul/li[2]/b")
		earnings_last_year_raw = earnings_last_year_elmt.text.strip()
		earnings_last_year_raw = earnings_last_year_raw.gsub(",", ".")
		earnings_last_year_raw = earnings_last_year_raw.gsub("€", "")
		earnings_last_year_raw = earnings_last_year_raw.gsub(" ", "")
		earnings_last_year = 0.0
		# @logger.debug("fetch_runner - " + runner.number.to_s + " earnings_last_year_raw = " + earnings_last_year_raw)
		if earnings_last_year_raw.index("-") == nil then
			earnings_last_year = earnings_last_year_raw.to_f
		end
		
		earnings_victory_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-gains']/ul/li[3]/b")
		earnings_victory_raw = earnings_victory_elmt.text.strip()
		earnings_victory_raw = earnings_victory_raw.gsub(",", ".")
		earnings_victory_raw = earnings_victory_raw.gsub("€", "")
		earnings_victory_raw = earnings_victory_raw.gsub(" ", "")
		earnings_victory = 0.0
		# @logger.debug("fetch_runner - " + runner.number.to_s + " earnings_victory_raw = " + earnings_victory_raw)
		if earnings_victory_raw.index("-") == nil then
			earnings_victory = earnings_victory_raw.to_f
		end
		
		earnings_current_year_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-gains']/ul/li[4]/b")
		earnings_current_year_raw = earnings_current_year_elmt.text.strip()
		earnings_current_year_raw = earnings_current_year_raw.gsub(",", ".")
		earnings_current_year_raw = earnings_current_year_raw.gsub("€", "")
		earnings_current_year_raw = earnings_current_year_raw.gsub(" ", "")
		earnings_current_year = 0.0
		# @logger.debug("fetch_runner - " + runner.number.to_s + " earnings_current_year_raw = " + earnings_current_year_raw)
		if earnings_current_year_raw.index("-") == nil then
			earnings_current_year = earnings_current_year_raw.to_f
		end
		
		father_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-ascendance']/ul/li[1]/span[2]/b")
		father_name = father_elmt.text.strip()
		father = Horse::new(name: father_name)
		
		mothers_father_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-ascendance']/ul/li[3]/span[2]/b")
		mothers_father_name = mothers_father_elmt.text.strip()
		mothers_father = Horse::new(name: mothers_father_name)
		
		mother_elmt = @driver.find_element(:xpath, "//div[@class='fiche-cheval-ascendance']/ul/li[2]/span[2]/b")
		mother_name = mother_elmt.text.strip()
		mother = Horse::new(name: mother_name, father: mothers_father)
		
		content_elmt = @driver.find_element(:xpath, "//div[@class='content']/h3")
		content = content_elmt.text.strip
		content_array = content.split(",")
		# @logger.debug("fetch_runner - content_array : " + content_array.to_s)
		breed_raw = content_array[0]
		breed = breed_raw.strip
		
		coat = ""
		if content_array.size >= 4 then
			coat_raw = content_array[3]
			# @logger.debug("fetch_runner - coat_raw : " + coat_raw)
			coat = coat_raw.strip
		end
		
		runner.horse.breed = breed
		runner.breeder = breeder
		runner.horse.coat = coat
		runner.description = description
		runner.earnings_career = earnings_career
		runner.earnings_current_year = earnings_current_year
		runner.earnings_last_year = earnings_last_year
		runner.earnings_victory = earnings_victory
		runner.horse.father = father				
		runner.horse.mother = mother
		runner.owner = owner
		runner.places = places
		runner.races_run = races_run
		runner.trainer = trainer
		runner.victories = victories
		
		return runner
	end

end