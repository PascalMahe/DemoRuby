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
		html_meeting_list = @driver.find_element(:xpath, "//div[@id='reunions-view']")
		
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
		end
		
		# Second loop: to get all the data on meetings
		meeting_list.each do |meeting|
			meeting_list.push(fetch_meeting(meeting))
		end
		return meeting_list
	end

	def fetch_meeting_shallow(html_meeting, date, job)
		# parameter: a WebElement representing an <div> tag, linking to the meeting
		
		# number, racetrack, weather and track_condition are in the original tag's
		# children, date (is deduced from a race's tag
		@logger.debug("fetch_meeting_shallow")
		
		# number
		number = html_meeting.attribute("data-reunionid")
		@logger.debug("Number : " + number)
		
		# racetrack
		strong_tag_for_racetrack = html_meeting.
					find_element(:css, "strong")
		racetrack = strong_tag_for_racetrack.attribute("title")
		@logger.debug("Racetrack : " + racetrack)
		
		# track_condition
		track_condition = nil
		span_tag_for_track_condition = html_meeting.
				find_element(:xpath, "div/div/p/span[@class='etat-terrain']")
		if span_tag_for_track_condition != nil then
			track_condition_text = span_tag_for_track_condition.text
			@logger.debug("Track condition text : " + track_condition_text)
			track_condition = @ref_list_hash[:ref_track_condition_list][track_condition_text]
			@logger.debug("Track condition : " + track_condition.to_s)
		end
		
		# weather
		weather = nil
		div_tag_for_weather = html_meeting.
					find_element(:css, "div.picto-meteo")
		if div_tag_for_weather != nil then
			weather = fetch_weather(div_tag_for_weather)
			@logger.debug("Weather : " + weather.to_s)
		end
		
		# getting second tag
		secondary_id = "numOfficiel-" + number
		secondary_div_tag = @driver
					.find_element(:css, "div#" + secondary_id)
		
		# urls_of_races_array
		link_to_races_tags = secondary_div_tag.find_elements(:css, "a.course")
		urls_of_races_array = []
		link_to_races_tags.each do |link_to_race_tag|
			urls_of_races_array.push(link_to_race_tag.attribute("href"))
		end
		@logger.debug("Urls_of_races_array : " + urls_of_races_array.to_s)
		
		#date
		if $globalState.is_test then
			first_race_href = "#12062015/R8/C1"
		else
			first_race_href = urls_of_races_array[0] # should be like this : '#12062015/R8/C1'
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
		
		@logger.debug("Meeting_date : " + meeting_date.to_s)
		
		meeting = Meeting::new(date: meeting_date, 
								job: job, 
								number: number, 
								racetrack: racetrack, 
								urls_of_races_array: urls_of_races_array, 
								track_condition: track_condition, 
								weather: weather)
		@logger.debug(meeting)
		return meeting
	end

	def fetch_meeting(meeting)
		# Parameter: a Meeting, containing all the data (fetched in fetch_meeting_shallow) 
		# for the race list
		# => Fetch the list with a loop on the urls_of_races_array
		
		meeting.urls_of_races_array.each do |url_of_race|
			race = fetch_race(meeting, url_of_race)
			meeting.race_list.push(race)
		end
	end

	def fetch_weather(div_tag_for_weather)
		@logger.debug("div_tag_for_weather : " + div_tag_for_weather.to_s)
		weather_class = div_tag_for_weather.attribute("class")
		@logger.debug("weather_class : " + weather_class)
		wheather_insolation = weather_class.split(" ")[1] 
		@logger.debug("wheather_insolation : " + wheather_insolation)
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
		@logger.debug("my_popin_bottom : " + my_popin_bottom.to_s)
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
		
		@logger.debug("temperature : " + temperature.to_s)
		@logger.debug("wind_speed : " + wind_speed.to_s)
		weather = Weather::new(
			insolation: wheather_insolation, 
			temperature: temperature, 
			wind_speed: wind_speed)
		return weather
	end

	# def fetch_races(race_table, meeting)
		## Parameter: a WebElement wrapping a <tbody> tag, containing the races
		
		# race_list = []
		# html_race_list = race_table.find_elements(:xpath, "tr")
		# html_race_list.each do |html_race|
			# business_race = fetch_race_shallow(html_race, meeting)
			# race_list.push(business_race)
		# end
		
		# race_list.each do |race|
			# fetch_race(race)
		# end
		# return race_list
	# end

	# def fetch_race_shallow(html_race, meeting)
		## Parameter: a WebElement wrapping a <tr> tag, containing the shallow data about the race
		
		# number = html_race.find_element(:class, "TRHcol1")
		# number = number.text
		
		# race_link = html_race.find_element(:xpath, "td/a")
		# url = race_link.attribute("href")
		
		# name = race_link.text
		
		# time = html_race.find_element(:class, "TRHcol4")
		# time = time.text
		
		## getting the data in the text below the link (in the second column)
		# text_below = html_race.find_element(:class, "TRHcol2")
		# text_below = text_below.find_element(:xpath, "div")
		# text_below = text_below.text
		# text_below = text_below.split(" - ")
		# if text_below.length == 3 then
			## if the size is 3, it means there's another ' - ' sequence
			## -> it's because racetype can have a ' - ' sequence in it (eg 'Attelé Européenne - Autostart')
			## => agregate 0 & 1 and put 2 in 1
			# text_below[0] = text_below[0] + ' - ' + text_below[1]
			# text_below[1] = text_below[2]
			# text_below.pop #removing last element
		# end
		# value = text_below[1]
		## value: 'X.XXX €'
		# str_value = value.sub('.', '')
		# str_value = value.sub('€', '')
		# str_value = value.sub(' ', '')
		# str_value.strip!
		# int_value = str_value.to_i
		
		# str_distance_and_racetype = text_below[0]
		## distance: numbers to the end (minus the 'm')
		# int_distance_starting_index = str_distance_and_racetype.index(/[1-9]/)
		
		# str_distance = str_distance_and_racetype.slice(int_distance_starting_index..str_distance_and_racetype.length)
		## erasing the 'm'
		# str_distance = str_distance.sub('m', '')
		
		# int_distance = str_distance.to_i
		
		
		## racetype: everything that's not distance
		# str_racetype_name = str_distance_and_racetype.slice(0..int_distance_starting_index)
		# str_racetype_name.strip!
		# racetype = $ref_list_hash[:ref_race_type_list][str_racetype_name]
		
		# race = Race::new(meeting, name, number, url, time, int_value, int_distance, racetype)
		## @logger.debug(race)
		# return race
	# end

	def fetch_race(url_of_race, meeting)
		# Parameter: the URL of the page where the data is to be gathered
		# and the Meeting containing this race
		# Fields to fill: bets, country, detailed_conditions, distance, 
		# general_conditions, name, number, race_type, result, result_insertion_time, 
		# runner_list, time, url and value
			
		#Fetching page
		@driver.get(url_of_race)
		
		# bets
		# div#masses-enjeu/div[1]/div => Placé : XXX,XX €
		massesEnjeuTag = @driver.find_element(:xpath, "div[id='masses-enjeu']/div[1]/div")
		bets = betTag.text
		betsTextArray = bets.split(":")
		betsStrRaw = betsTextArray[1]
		bets = betsStrRaw.gsub("€", "").strip()
		
		# country
		# ???
		country = nil
		
		# detailed conditions
		# a.conditions-show -> btn to click
		# div.popin-detail (visible after the click)
		# -> div[1]/div.content
		# closed by clicking on div.popin-close
		btnToDetailedConditions = @driver.find_element(:css, "a.conditions-show")
		btnToDetailedConditions.clickAndWait
		divDetailedCondTag = @driver.
			find_element(:xpath, "div[@class='popin-detail']/div[1]/div.content")
		detailedCond = detailedCondTag.text.strip()
		
		# close popin
		if $globalState.is_test then
			btnToClosePopin = @driver.find_element(:css, "div.popin-close")
			btnToClosePopin.clickAndWait
		else
			@driver.back()
		end
		
		# distance
		# inside div#conditions => Plat - 7759 € - 1200m - 8 partants  - Handicap Corde à droite 
		# split#2
		generalCondTag = @driver.find_element(:css, "div#conditions")
		generalCondStrRaw = generalCondTag.text
		
		generalCondArray = generalCondStrRaw.split("-")
		distance = generalCondArray[2].strip()
		
		# general_conditions
		# inside div#conditions => Plat - 7759 € - 1200m - 8 partants  - Handicap Corde à droite 
		# split#4
		general_conditions = generalCondArray[4].strip()
		
		# name
		# inside h2.course-title/b[1] => VAAL - JOBURG'S PRAWN FEST HANDICAP
		# split#1
		raceTitleTag = @driver.find_element(:xpath, "//h2[class='course-title']/b[1]")
		raceTitleStr = raceTitleTag.text
		raceTitleArray = raceTitleStr.split("-")
		name = raceTitleArray[1].strip()
		
		# number
		# li.current
		# attribute data-courseid
		currentRaceTag = @driver.find_element(:css, "li.current")
		number = currentRaceTag.attribute("data-courseid")
		
		# race_type
		# inside div#conditions => Plat - 7759 € - 1200m - 8 partants  - Handicap Corde à droite 
		# split#0
		race_type = generalCondArray[0].strip()
		
		# result
		# dd.infos-arrivee-list
		resultTag = @driver.find_element(:css, "dd.infos-arrivee-list")
		result = resultTag.text.strip
		
		# result_insertion_time
		if result != '' then
			result_insertion_time = Time::new
		else 
			result_insertion_time = nil
		end
		
		# runner_list
		runner_list = fetch_runners(race)
		
		# time
		# h2.course-title => 20 Février 2014 • R4C3 - 12h15• VAAL - JOBURG'S PRAWN FEST HANDICAP
		# split(-)#1.split(•)#0
		raceLongTitleTag = @driver.find_element(:xpath, "h2.course-title")
		raceLongTitleText = raceLongTitleTag.text
		raceLongTitleArray = raceLongTitleText.split("-")
		raceTitleAndDateText = raceLongTitleArray[1]
		raceTitleAndDateArray = raceTitleAndDateText.split("•")
		dateStr = raceTitleAndDateArray[0].strip()
		time = Time::new(dateStr)

		# url
		url = url_of_race
		
		# value
		# inside div#conditions => Plat - 7759 € - 1200m - 8 partants  - Handicap Corde à droite 
		# split#1
		value = generalCondArray[1].strip().gsub("€" , "")
		
		#@logger.debug(race)
		
		#runner
		
	end

	def fetch_runners(race)
		# Parameter: a Race
		# Returns a list of (completed) Runners
		
		list_runners = []
		runner_rows = @driver.find_elements(:id, "//tr[@class='tableauPariBody']/tr")
		runner_rows.each do |runner_row|
			runner = fetch_runner_shallow(runner_row, race)
			list_runners.push(runner)
		end
		list_runners.each do |runner|
			fetch_runner(runner)
		end
			
		return list_runners
	end

	def fetch_runner_shallow(html_runner, race)
		# Parameter: a WebElement wrapping around a <tr> containing all data on the runner
		# Fields to fill:
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
		# - load
		# - distance
		# - history
		# - url
		
		# final_place => see fetch_race_results
		
		# see fetch_runner for:
		# - races_run
		# - victories
		# - places
		# - earnings_career
		# - earnings_current_year
		# - earnings_last_year
		# - earnings_victory
		# - description

		
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
		blinder_li_element = @driver.find_element(:xpath, "/td[@class='tableauPariBodyList']/div/ul/li[@class='eye']")
		# if blinder_li_web_element doesn't have any children, no blinder
		blinder_img_element = blinder_li_element.find_element(:xpath, "/img")
		str_blinder = ""
		if blinder_img_element != null
			str_blinder = blinder_img_element.attribute("src")
		end
		
		# shoes & draw are in the same column
		# difference is: shoe's an <img>, draw's a number
		shoes_or_draw_element = @driver.find_element(:xpath, "/td[@class='tableauPariBodyList']/div/ul/li[@class='eye']")
		# if shoes_or_draw_element doesn't have any children, no shoes
		shoes_or_draw_element = blinder_li_element.find_element(:xpath, "/img")
		str_shoes = ""
		str_draw = ""
		int_draw = 0
		if shoes_or_draw_element != null
			str_shoes = shoes_or_draw_element.attribute("src")
		else 
			str_draw = shoes_or_draw_element.text
			int_draw = str_draw.to_i # to_i returns 0 if str_draw is a NaN (cf. http://www.ruby-doc.org/core-2.1.0/String.html#method-i-to_i)
		end
		
		# number
		number_element = @driver.find_element(:xpath, "/td[@class='tableauPariColNCheval']")
		str_number = number_element.text
		int_number = str_number.to_i
		
		# single_rating
		single_rating_element = @driver.find_element(:xpath, "/td[@class='tableauPariColCote']")
		str_single_rating = single_rating_element.text
		fl_single_rating = str_single_rating.to_f
		
		# non_runner
		# non_runner = true if the jockey column contains "Non Partant"
		non_runner_element = @driver.find_element(:xpath, "/td/div[@class='detailCourseCarrousselBody']/ul/li[@class='monte']")
		str_non_runner = non_runner_element.text
		b_non_runner = str_non_runner.eql?("Non Partant")
		
		# load
		# distance
		# history
		# url
		
		
		@logger.debug(race)
		
		#runner
		race.runner_list = fetch_runners(race)
	end

	def fetch_horse(html_element_runner)
		# Parameter: a WebElement wrapping a <tr> containing the data to fetch to create a horse
	end

	def fetch_jockey(html_element_runner)
		# Parameter: a WebElement wrapping a <tr> containing the data to fetch to create a jockey
	end

	def fetch_trainer(html_element_runner)
		# Parameter: a WebElement wrapping a <tr> containing the data to fetch to create a trainer
	end

	def fetch_owner(html_element_runner)
		# Parameter: a WebElement wrapping a <tr> containing the data to fetch to create an owner
	end

	def fetch_breeder(html_element_runner)
		# Parameter: a WebElement wrapping a <tr> containing the data to fetch to create a breeder
	end

	def fetch_runner(runner)
		# Parameter: a Runner, including the URL of the page in which to look for deeper data
	end

end

