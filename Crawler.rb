require 'psych' 
#see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'selenium-webdriver'
require 'browsermob/proxy'

require './common.rb'
require './SimpleHtmlLogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class Crawler
	CSS_TO_RUNNER_TABLE = "li.partants"
	CSS_TO_RUNNERS = "tr.participants-tbody-tr" #participants-view > div:nth-child(1) > table:nth-child(3) > tbody:nth-child(2) > tr
	CSS_TO_HEADER_LINE = ".participants-thead"
	CSS_TO_HEADER_TH = "th"
	
	DISQUALIFIED_FLAG = "DAI"
	FAVORITE_FLAG = "favorite"
	NC_FLAG = "-"
	NON_RUNNER_FLAG = "participants-tbody-tr--non-partant"
	SUBSTITUTE_FLAG = "[suppl]"
	
	ODD_LINE_FLAG = "even"
	EVEN_LINE_FLAG = "odd"
	
	DETAILED_COND_INTRO = ""
	
	# Plat 1
	HEADER_LINE_TYPE_1 =	"N° Cheval Cde. Sexe Jockey Poids H. Val. Performances Rapports prob. Œillère Age Entraineur Poids M. Hand."
	# Plat 2
	HEADER_LINE_TYPE_2 = 	"N° Cheval Cde. Sexe Jockey Poids H. Val. Performances Rapports prob. Sélect. Œillère Age Entraineur Poids M. Hand."
	# Obstacle Steeple / Obstacle Cross
	HEADER_LINE_TYPE_3 = 	"N° Cheval Sexe Jockey Poids H. Val. Performances Rapports prob. Œillère Age Entraîneur Poids M. Hand."
	# Trot Monté
	HEADER_LINE_TYPE_4 = 	"N° Cheval Sexe Jockey Poids Dist. (m) Performances Rapports prob. Sélect. Fer Age Entraineur (kg) Gains (€)"
	# Trot Attelé 1
	HEADER_LINE_TYPE_5 = 	"Place N° Cheval Driver Red. Km Rapports prob. Commentaires d'après-course Œil"
	# Trot Attelé 2
	HEADER_LINE_TYPE_6 = 	"N° Cheval Sexe Driver Gains Distance Performances Rapports prob. Sélect. Fer Age Entraineur (€) (km)"
		
	COLUMN_MAP_TYPE_1 = {	blinder: nil, 			shoes: "td[4]/b",
							draw: nil, 				distance: "td[10]",
							trainer: "td[9]",		earnings_carrer: "td[12]",
							history: "td[11]", 		load_handicap: "td[8]",
							load_ride: nil, 		single_rating: "td[13]"}
							
	COLUMN_MAP_TYPE_2 = {	blinder: "td[4]/b", 	shoes: nil,
							draw: "td[8]", 			distance: nil,
							trainer: "td[11]", 		earnings_carrer: nil,
							history: "td[12]", 		load_handicap: "td[9]",
							load_ride: "td[10]",	single_rating: "td[13]"}
							
	COLUMN_MAP_TYPE_3 = {	blinder: "td[4]/b", 	shoes: nil,
							draw: nil, 				distance: nil,
							trainer: "td[10]", 		earnings_carrer: nil,
							history: "td[11]", 		load_handicap: "td[8]",
							load_ride: "td[9]", 	single_rating: "td[12]"}

	COLUMN_MAP_TYPE_4 = {	blinder: "td[4]/b", 	shoes: nil,
							draw: nil, 				distance: nil,
							trainer: "td[10]", 		earnings_carrer: nil,
							history: "td[11]", 		load_handicap: "td[8]",
							load_ride: "td[9]", 	single_rating: "td[12]"}

	COLUMN_MAP_TYPE_5 = {	blinder: "td[4]/b", 	shoes: nil,
							draw: nil, 				distance: nil,
							trainer: "td[10]", 		earnings_carrer: nil,
							history: "td[11]", 		load_handicap: "td[8]",
							load_ride: "td[9]", 	single_rating: "td[12]"}

	COLUMN_MAP_TYPE_5 = {	blinder: "td[4]/b", 	shoes: nil,
							draw: nil, 				distance: nil,
							trainer: "td[10]", 		earnings_carrer: nil,
							history: "td[11]", 		load_handicap: "td[8]",
							load_ride: "td[9]", 	single_rating: "td[12]"}

	attr_accessor:driver
	attr_accessor:server
	attr_accessor:proxy
	
	################################################
	###############       INIT       ###############
	################################################
	
	def initialize(logger, ref_list_hash, config, is_test)
		@logger = logger
		@ref_list_hash = ref_list_hash
		@config = config
		
		if is_test
			@base_address = @config[:gen][:base_address_test]
		else
			@base_address = @config[:gen][:base_address]
		end
		@logger.debug("initialize - base_address: " + @base_address)
		
		@driver = launch_driver()
	end
	
	def launch_driver()
		@logger.info("Preparing browser")
		browser_start_start_time = Time::now
		
		# proxy
		# see https://github.com/jarib/browsermob-proxy-rb
		# and http://stackoverflow.com/a/15297676/2112089
		@server = BrowserMob::Proxy::Server.new("D:/Perso/Dev/workspace/DemoRuby/Install/browsermob-proxy-2.1.4/bin/browsermob-proxy.bat") #=> #<BrowserMob::Proxy::Server:0x000001022c6ea8 ...>
		
		@server.start

		@proxy = @server.create_proxy #=> #<BrowserMob::Proxy::Client:0x0000010224bdc0 ...>

		@proxy.blacklist("https://analytics.twitter.com/", 410)
		@proxy.blacklist("https://platform.twitter.com/", 410)
		@proxy.blacklist("https://connect.facebook.net/", 410)
		@proxy.blacklist("https://dcniko1cv0rz.cloudfront.net/", 410)
		@proxy.blacklist("https://dis.eu.criteo.com/", 410)
		@proxy.blacklist("https://static.criteo.net/", 410)
		@proxy.blacklist("https://i.realytics.io/", 410)
		@proxy.blacklist("https://tc-sync.realytics.io/", 410)
		@proxy.blacklist("https://tp.realytics.io/", 410)
		@proxy.blacklist("https://sb.scorecardresearch.com/", 410)
		@proxy.blacklist("https://sslwidget.criteo.com/", 410)
		@proxy.blacklist("https://us-u.openx.net", 410)
		@proxy.blacklist("http://www.joueurs-info-service.fr/", 80)
		
		profile = Selenium::WebDriver::Firefox::Profile.new #=> #<Selenium::WebDriver::Firefox::Profile:0x000001022bf748 ...>
		
		
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
		# profile.add_extension("./Install/firebug-1.12.6.xpi") # NB : FF takes ~2.5 more seconds to load w/ Firebug (from 6.1 to 8.8)
		profile["browser.bookmarks.max_backups"] = 0
		profile["browser.cache.memory.enable"] = true
		profile["browser.cache.disk.enable"] = true
		profile["browser.download.manager.scanWhenDone"] = false
		profile["browser.formfill.enable"] = false
		profile["network.http.pipeline"] = true
		profile["network.http.pipeline.maxrequests"] = 8
		profile["browser.search.suggest.enabled"] = false
		profile["browser.sessionhistory.max_entries"] = 3
		profile["browser.sessionhistory.max_tabs_undo"] = 0
		profile["browser.sessionhistory.max_total_viewer"] = 1
		profile["browser.sessionhistory.max_total_viewers"] = 1
		
		profile["browser.tabs.animated"] = false
		profile["image.animation_modr"] = "none"
		profile["general.useragent.override"] = "Selenium UA"
		profile["nglayout.initialpaint.delay"] = 0

		profile.proxy = proxy.selenium_proxy		

		# URL to block:
		# https://analytics.twitter.com/
		# https://platform.twitter.com/
		# https://connect.facebook.net/
		# https://dcniko1cv0rz.cloudfront.net/
		# https://dis.eu.criteo.com/
		# https://static.criteo.net/
		# https://i.realytics.io/
		# https://tc-sync.realytics.io/
		# https://tp.realytics.io/
		# https://sb.scorecardresearch.com/
		# https://sslwidget.criteo.com/
		# https://us-u.openx.net
		
		#Loading browser
		driver = Selenium::WebDriver.for(:firefox,:profile => profile)
		# @driver = Selenium::WebDriver.for(:firefox)
		# @driver = Selenium::WebDriver.for(:remote, :url => "http://localhost:4444/wd/hub", :desired_capabilities => :htmlunit)
		
		driver.manage.timeouts.implicit_wait = 5 # seconds
		browser_start_end_time = Time::now
		browser_start_total_time = browser_start_end_time - browser_start_start_time
		logStr = "Browser prepared (" + 
			format_time_diff(browser_start_total_time)	+ 
			")"
		@logger.info(logStr)
		return driver
	end
	
	def close_driver()
		@driver.quit
		@server.stop
		@profile.close
	end
	
	################################################
	#############       FOR TEST       #############
	################################################
	
	def getRef()
		return @ref_list_hash[:ref_race_type_list]
	end
	
	
	def getTraCon()
		ref_to_ret = @ref_list_hash[:ref_race_type_list]["Attelé"]
		
		# @logger.level = SimpleHtmlLogger::DEBUG
		@logger.debug("getTraCon - ")
		@logger.debug(@ref_list_hash[:ref_race_type_list])
		# @logger.level = SimpleHtmlLogger::INFO
		
		return ref_to_ret
	end
	
	
	################################################
	#############       CRAWLING       #############
	################################################
	
	def crawl(current_job)
	
		begin
			start_time = Time.now
			# Getting main page
			@driver.get(@base_address)
			
			getting_page_time = Time.now
			getting_page_duration = getting_page_time - start_time
			@logger.info("Getting base page took: " + format_time_diff(getting_page_duration))
			
			#TODO: loop on ALL* the days
			# *ALL = config[:gen][:earliest_date]
			date = Date.today()
			
			#Fetching meetings
			nb_last_meeting = get_number_of_last_meeting()
			@logger.debug("crawl - nb_last_meeting: " + nb_last_meeting.to_s)
			
			meeting_list = fetch_meetings(nb_last_meeting, date, current_job)
			
		rescue => e
			@logger.error("Error while crawling: " + e.inspect)
			@logger.error(e.backtrace)
		end
		
		@driver.quit
		return meeting_list
	end
	
	def get_number_of_last_meeting()
		html_meeting_list = @driver.find_elements(:css, "div.reunion-infos")
		last_meeting = html_meeting_list.last
		str_number_of_last_meeting = last_meeting.attribute("data-reunionid")
		return Integer(str_number_of_last_meeting)
	end

	
    def fetch_meetings(nb_last_meeting, date, current_job)
		# Loop on number of meetings to fetch basic info (number, racetrack, weather and 
		# track_condition (in the original tag's children)), get the tag 
		# listing the races (from the meeting number) in order to get the 
		# date and races' URLs.
		# Note: Elements are linked to the page currently displayed on the 
		# driver, thus getting another page makes them 'stale'. Which is why we
		# must use two loops: one to get the URLs and the other to navigate to 
		# the pages.
		meeting_list = []
		
		str_formatted_date = date.strftime(@config[:gen][:pmu_url_date_format])
		@logger.debug("fetch_meetings - str_formatted_date: " + str_formatted_date)
		
		for i in 1..nb_last_meeting do
			current_URL = @base_address + str_formatted_date + "/R" + i.to_s + "/C1"
			@logger.debug("fetch_meetings - current_URL: " + current_URL)
			driver.get(current_URL)
			begin			
				business_meeting = 
					fetch_meeting(date, i, current_job, current_URL)
				meeting_list.push(business_meeting)
			rescue => e
				@logger.error("Error while fetching meeting R" + i.to_s + " in date: " + str_formatted_date + " - Error: " + e.message)
				@logger.error(e.backtrace)
			end
		end
				
		return meeting_list
	end

	def fetch_meeting(date, number, job, current_URL)
		
		# Fetches all data on a meeting, including races
		
		# number, job and date are parameters
		# id is generated at insert
		# race_list is created empty and completed in fetch_races
		# all else is fetched in fetch_meeting_shallow
		
		meeting = fetch_meeting_shallow(date, number, job, current_URL)
		
		meeting.race_list = fetch_races(meeting)
		
		return meeting
	end

	def fetch_meeting_shallow(date, number, job, meeting_URL)
		# fetches 	country => lost for the moment
		#			racetrack
		#			track_condition
		#			urls_of_races_array 
		#			weather
		
		# number
		@logger.debug("fetch_meeting_shallow - Number: " + number.to_s)
		
		# racetrack
		li_tag_arount_racetrack = @driver.
					find_element(:css, "li.bandeau-nav-content-scroll-item--current")
					
		div_tag_around_racetrack = li_tag_arount_racetrack.
					find_element(:css, "div.reunion-hippodrome")
					
		span_tag_for_racetrack = div_tag_around_racetrack.
					find_element(:css, "span")
		
		racetrack = span_tag_for_racetrack.attribute("title")
		
		# country = "France"
		# if racetrack.index("(") != nil then
			# racetrackArray = racetrack.split("(")
			# racetrack = racetrackArray[0].strip()
			# country = racetrackArray[1]
			# country = country.gsub(")", "").strip
			# @logger.debug("Country : " + country)
		# end
		country = nil
		# @logger.debug("Racetrack : " + racetrack)
		
		# weather
		weather = nil
		p_tag_for_weather = @driver.
					find_element(:xpath, "//div[@class='course-infos-meteo']/p")
		if p_tag_for_weather != nil then
			weather = fetch_weather(p_tag_for_weather)
			@logger.debug("Weather : " + weather.to_s)
		end
		
		
		# urls_of_races_array
		p_race_number_list = @driver.find_elements(:css, "p.bandeau-nav-content-scroll-item-numero")
		urls_of_races_array = []
		base_url = meeting_URL.slice(0, meeting_URL.length - 2)
		@logger.debug("fetch_meeting_shallow - p_race_number_list.length: " + p_race_number_list.length.to_s)
		p_race_number_list.each do |p_around_race_number|
			span_to_race_number = p_around_race_number.find_element(:css, "span")
			race_number = span_to_race_number.text
			race_url = base_url + race_number
			urls_of_races_array.push(race_url)
		end
		@logger.debug("fetch_meeting_shallow - Urls_of_races_array : " + urls_of_races_array.to_s)
		
		# track_condition
		track_condition = @ref_list_hash[:ref_track_condition_list][""]
		
		
		p_tag_for_track_condition = @driver.find_element(:xpath, "//div[@class='course-infos-conditions']/p")
		text_from_p_elmt = p_tag_for_track_condition.text
		text_from_p_components = text_from_p_elmt.split(" - ")
		potential_track_condition = text_from_p_components[text_from_p_components.length - 1]
		if potential_track_condition.include?("Terrain") then
			potential_track_condition = potential_track_condition.gsub(" D\u00E9tails des conditions", "").strip()
			track_condition = @ref_list_hash[:ref_track_condition_list][potential_track_condition]
		end
		@logger.debug("fetch_meeting_shallow - track_condition: " + track_condition.to_s)
		
		meeting = Meeting::new(country: country,
								date: date, 
								job: job, 
								number: number, 
								racetrack: racetrack, 
								urls_of_races_array: urls_of_races_array, 
								track_condition: track_condition, 
								weather: weather)
		# @logger.debug(meeting)
		return meeting
	end

	def fetch_weather(p_tag_for_weather)
		
		span_tag_for_insolation = p_tag_for_weather.find_element(:css, "span")
		weather_class = span_tag_for_insolation.attribute("class")
		# the class should look like this: "icon-meteo-P4"
		# we're only interested the P4 part
		weather_components = weather_class.split("-")
		insolation = weather_components[weather_components.length - 1]
		
		@logger.debug("fetch_weather - insolation : " + insolation)
		
		weather_text = p_tag_for_weather.text
		
		
		weather_text_components = weather_text.split(", vent")
		# the class should look like this: "6°C, vent 7 km/h"
		# we're only interested the P4 part
		
		@logger.debug("fetch_weather - weather_text : " + weather_text)
		@logger.debug("fetch_weather - weather_text_components : " + weather_text_components.to_s)
		
		str_temperature = weather_text_components[0].gsub("\u00B0C", "").strip()
		str_wind_speed = weather_text_components[1].gsub("km/h", "").strip()
		
		@logger.debug("fetch_weather - temperature : " + str_temperature)
		@logger.debug("fetch_weather - wind_speed : " + str_wind_speed)
		
		temperature = Integer(str_temperature)
		wind_speed = Integer(str_wind_speed)
		
		weather = Weather::new(
			insolation: insolation, 
			temperature: temperature, 
			wind_speed: wind_speed)
		return weather
	end

	def fetch_races(meeting)
		race_list = []
		
		meeting.urls_of_races_array.each do |current_race_url|
			begin			
				race = fetch_race(current_race_url, meeting)
				race_list.push(race)
			rescue => e
				@logger.error("Error while fetching race at URL: " + current_race_url + " - Error: " + e.inspect)
				@logger.error(e.backtrace)
			end
		end
		
		return race_list
	end
	
	def fetch_race(url_of_race, meeting)
		# Parameter: the URL of the page where the data is to be gathered
		# and the Meeting containing this race
		# Fields to fill: 	bets, -> tooltip
		# 					detailed_conditions, -> tooltip
		#					distance, 
		# 					general_conditions, 
		# 					name, 
		# 					number, 
		# 					race_type, 
		# 					result, 
		# 					result_insertion_time, 
		# 					runner_list, 
		# 					time, 
		# 					url -> parameter
		# 					value
		# country (lost after upgrade)
		
		#Fetching page
		@logger.info("fetch_race - Fetching race: " + url_of_race) 
		@driver.get(url_of_race)
		
		race = fetch_race_shallow(url_of_race)
		
		# runner_list
		@logger.debug("fetch_race - Fetching runners.")
		race.runner_list = fetch_runners(race)
		# @logger.debug("runner_list : " + runner_list.to_s)
		
		return race
	end

	def fetch_race_shallow(url_of_race)
		
		header_tag = @driver.find_element(:xpath, "//header[@class='course-infos-header']/p")
		header_text = header_tag.text
		# header_text =>	Plat | 12 000 € | 2400 m | 5 partants 
		# 					Trot Attelé | 20 000 € | 2150 m | 16 partants
		#					Obstacle Steeple | 15 000 € | 4100 m | 9 partants 
		#					race_type | value | distance | number of participants (ignored)
		header_text_components = header_text.split(" | ")
		
		distance_str = header_text_components[2].gsub("m", "").strip()
		distance = distance_str.to_i
		@logger.debug("fetch_race_shallow - distance : " + distance.to_s)
		
		# race_type
		race_type_raw = header_text_components[0].strip()
		race_type = @ref_list_hash[:ref_race_type_list][race_type_raw]
		@logger.debug("fetch_race_shallow - race_type : " + race_type.to_s)
		
		# value
		value_str = header_text_components[1].strip().gsub("€" , "").gsub(" ", "")
		value = value_str.to_i
		@logger.debug("fetch_race_shallow - value : " + value.to_s)
		
		# bets
		# //*[@id='main']/div/div[4]/div/div[4]/div/div[1]/ul/li[3]
		bet_button_tag = @driver.find_element(:xpath, "//i[@class='icon icon-enjeux']")
		bet_button_tag.click
		
		bets = nil
		bet_potential_tags = @driver.find_elements(:xpath, "//li[@class='masse-enjeu']")
		bet_potential_tags.each do |bet_potential_tag|
			bet_potential_text = bet_potential_tag.text
			if bet_potential_text.include?("Placé") then
				# should look like :
				# Placéà 15h50 :22 871 €
				
				bets_text_array = bet_potential_text.split(":")
				bets_str_raw = bets_text_array[1]
				bets_str = bets_str_raw.gsub("€", "").gsub(" ", "").gsub(",", ".").strip()
				bets = bets_str.to_f
				
				@logger.debug("fetch_race_shallow - bets : " + bets.to_s)
			end
		end
		
		
		# detailed conditions
		# a.course-infos-conditions-link -> btn to click
		# p.details-conditions-tooltip-content-texte (visible after the click)
		# closed by moving the mouse away
		btn_detailed_conditions = @driver.find_element(:css, "a.course-infos-conditions-link")
		btn_detailed_conditions.click
		div_detailed_cond_tag_array = @driver.
			find_elements(:css, "p.details-conditions-tooltip-content-texte")
		detailed_cond = "" #if there's no detail element
		if div_detailed_cond_tag_array.length > 0 then
			div_detailed_cond_tag = div_detailed_cond_tag_array[0]
			detailed_cond = div_detailed_cond_tag.text.strip()
			
			@logger.debug("fetch_race_shallow - detailed_cond : " + detailed_cond)
			
			# close popin
			# btn_close_popin = @driver.find_element(:css, "div.popin-close")
			# btn_close_popin.click
			# if $globalState.is_test then
				# @driver.navigate.back
			# end
		end
		
		# @logger.debug("detailed_cond : " + detailed_cond)
		
		# general_conditions
		# inside div#conditions =>	Courses à conditions - Corde à droite - Terrain bon Détails des conditions
		#							Courses à conditions - Corde à droite - Terrain bon Détails des conditions
		#							Groupe I - Corde à droite Détails des conditions
		#							Inconnu - Corde à gauche Détails des conditions
		
		general_cond_tag = @driver.find_element(:xpath, "//div[@class='course-infos-conditions']/p")
		general_cond_str = general_cond_tag.text
		general_cond_str.gsub(" Détails des conditions", "")
		
		if general_cond_str.include?("Terrain") then
			general_cond_str = general_cond_str.split("Terrain")[0].strip
		end
		
		@logger.debug("fetch_race_shallow - general_conditions : " + general_cond_str)
		
		# name
		# inside h1.course-infos-header-title 	=> R2C1 - PRIX DE CANNES NORVEGE
		#                             			=> R6C2 - PRIX FANDANGO
		# split#1
		race_title_tag = @driver.find_element(:css, "h1.course-infos-header-title")
		race_title_str = race_title_tag.text
		# @logger.debug("race_title_str : " + race_title_str)
		race_title_array = race_title_str.split(" - ")
		name = race_title_array[1].strip()
		@logger.debug("fetch_race_shallow - name : " + name)
		
		# number
		# inside h1.course-infos-header-title 	=> R2C1 - PRIX DE CANNES NORVEGE
		#                             			=> R6C2 - PRIX FANDANGO
		# split#0
		str_number = race_title_array[0].strip()
		str_number_array = str_number.split("C")
		number = str_number_array[1].to_i
		@logger.debug("fetch_race_shallow - number : " + number.to_s)
		
		# result
		# //*[@id='main']/div/div[4]/div/div[3]/div/div[1]/div/div/p[2]
		begin
			result_tag = @driver.find_element(:css, "ul.participants-arrivee-list-chevaux participants-arrivee-list-chevaux--definitive")
			result = result_tag.text.strip
			@logger.debug("fetch_race_shallow - result : " + result)
			
			# result_insertion_time
			if result != '' then
				result_insertion_time = Time::new
				@logger.debug("fetch_race_shallow - result_insertion_time : " + 
					result_insertion_time.
						strftime(@config[:gen][:default_date_time_format])
				)
			else 
				result_insertion_time = nil
				@logger.debug("fetch_race_shallow - result_insertion_time : nil")
			end
		rescue Selenium::WebDriver::Error::NoSuchElementError => nsee
			# do nothing, maybe it's not finished yet
			# @logger.debug("fetch_race_shallow - no result_tag")
		end
						
		# time
		# //*[@id='main']/div/div[4]/div/div[2]/div/div[2]/ul/li[1]/p[2]/span
		# Hier -  14h05
		# 29 Mai. 12h00
		# 16h55
		# Demain -  15h35
		race_long_title_tag = @driver.find_element(:css, "p.course-infos-statut-details")
		race_long_title_text = race_long_title_tag.text.strip
		
		if race_long_title_text.include?("-") then
			race_long_title_text = race_long_title_text.split("-")[1].strip
		elsif race_long_title_text.include?(".") then 
			race_long_title_text = race_long_title_text.split(".")[1].strip
		end
		
		date_str_array = race_long_title_text.split("h") # => ["12", "15"]
		date_hours_i = date_str_array[0].to_i # => 12
		date_min_i = date_str_array[1].to_i # => 15
		
		# @logger.debug("date_hours_i : " + date_hours_i.to_s)
		# @logger.debug("date_min_i : " + date_min_i.to_s)

		time = Time::new(1, 1, 1, date_hours_i, date_min_i)
		@logger.debug("fetch_race_shallow - time : " + 
			time.strftime(@config[:gen][:default_time_format])
		)

		# url
		url = url_of_race
		
		race = Race::new(bets: bets,
					detailed_conditions: detailed_cond,
					distance: distance,  
					general_conditions: general_cond_str,
					# meeting: meeting, 
					name: name, 
					number: number, 
					race_type: race_type,
					result: result,
					result_insertion_time: result_insertion_time,
					time: time,
					url: url,  
					value: value
		)
		
		@logger.debug("fetch_race - race: " + race.to_s)
		return race
	end
	
	# TODO:
	# break up fetch_runners so that it calls a few functions:
	# fetch_runners
	#   |-> fetch_runner
	#          |-> fetch_runner_shallow (runners' page)
	#          |-> fetch_runner_deep (popin)
	#   |-> fetch_results
	#          |-> fetch_result_shallow
	
	def fetch_runners(race)
		# Parameter: a Race
		# Returns a list of (completed) Runners
		@logger.info("fetch_runners - Fetching runners for race @: " + race.url)
		
		# Go to race page
		if driver.current_url != race.url and race.url != nil then
			@logger.info("fetch_runners - getting race url: " + race.url)
			@driver.get(race.url)
		end
		
		# if the race is finished, the driver lands on the results page
		# -> display runners' table
		if is_element_present(:css, CSS_TO_RUNNER_TABLE, @driver) then
			runner_table_button = @driver.find_element(:css, CSS_TO_RUNNER_TABLE)
			runner_table_button.click
		end
		
		column_map = get_column_map()
		
		runner_list = Hash.new
		list_of_runners = @driver.find_elements(:css, CSS_TO_RUNNERS)
		i = 0
		list_of_runners.each do |runner_elmt|
			@logger.info("fetch_runners - Fetching runner #" + i.to_s)
			current_runner = fetch_runner(runner_elmt)
			result[current_runner.number] = runner
			i = i + 1
		end
		
		# if the race is over, its results are fetched
		
		if is_element_present(:css, "p.course-infos-statut-details--arrivee", @driver) then
			@logger.info("fetch_runners - Fetching race results.")
			fetch_race_results(runner_list)
		end
		
		return runner_list
	end
	
	def go_to_runners_page()
		# Goes to the page where the shallow runners are
		
		btn_to_runners_table_elmt = @driver.find_element(:css, ".partants")
		btn_to_runners_table_elmt.click
		@logger.debug("Going to runner's page: now on page " + @driver.current_url)
	end
	

	def get_runner_number_from_result_page(runner_web_elmt)
		number_html = runner_web_elmt.find_element(:xpath, "td[2]")
		number = number_html.text.strip.to_i
		return number
	end
	
	def get_column_map()
		header_tag = @driver.find_element(:xpath, "//header[@class='course-infos-header']/p")
		header_text = header_tag.text
		# header_text =>	Plat | 12 000 € | 2400 m | 5 partants 
		# 					Trot Attelé | 20 000 € | 2150 m | 16 partants
		#					Obstacle Steeple | 15 000 € | 4100 m | 9 partants 
		#					race_type | value | distance | number of participants (ignored)
		header_text_components = header_text.split(" | ")
		
		# race_type
		race_type_raw = header_text_components[0].strip()
	
	
		html_header = @driver.find_element(:css, CSS_TO_HEADER_LINE)
		# cf. column_map.txt
		
		html_th_headers = html_header.find_elements(:css, CSS_TO_HEADER_TH)
		str_flattened_header = ""
		html_th_headers.each do |header|
			current_text = header.text.strip
			# ignoring the texts like 12h32 and 14h50
			# because they vary from race to race
			if /\d\dh\d\d/.match(current_text) == nil then
				if str_flattened_header.length > 0 then
					str_flattened_header = str_flattened_header + " "
				end
				
				str_flattened_header = str_flattened_header + current_text
			end
			
		end
		
		debug_url = @driver.current_url.slice(33, 5)
		
		@logger.debug("get_column_map - for race : " + debug_url +
						" - race type: " + race_type_raw + " - found header line : " + str_flattened_header)
		
		column_map = nil
		
		# @logger.debug("get_column_map - header = HEADER_LINE_TYPE_1 : " +
						# (str_flattened_header == HEADER_LINE_TYPE_1).to_s)
		# @logger.debug("get_column_map - header = HEADER_LINE_TYPE_1_BIS : " +
						# (str_flattened_header == HEADER_LINE_TYPE_1_BIS).to_s)
		# @logger.debug("get_column_map - header = HEADER_LINE_TYPE_2 : " +
						# (str_flattened_header == HEADER_LINE_TYPE_2).to_s)
		# @logger.debug("get_column_map - header = HEADER_LINE_TYPE_3 : " +
						# (str_flattened_header == HEADER_LINE_TYPE_3).to_s)
		# @logger.debug("get_column_map - header = HEADER_LINE_TYPE_4 : " +
						# (str_flattened_header == HEADER_LINE_TYPE_4).to_s)
		case(str_flattened_header)
			when HEADER_LINE_TYPE_1 then
				@logger.debug("get_column_map - header 1 -> column_map type 1")
				column_map = COLUMN_MAP_TYPE_1
			when HEADER_LINE_TYPE_2 then
				@logger.debug("get_column_map - header 2 -> column_map type 2")
				column_map = COLUMN_MAP_TYPE_2
			when HEADER_LINE_TYPE_3 then
				@logger.debug("get_column_map - header 3 -> column_map type 3")
				column_map = COLUMN_MAP_TYPE_3
			when HEADER_LINE_TYPE_4 then
				@logger.debug("get_column_map - header 4 -> column_map type 4")
				column_map = COLUMN_MAP_TYPE_4
			when HEADER_LINE_TYPE_5 then
				@logger.debug("get_column_map - header 5 -> column_map type 5")
				column_map = COLUMN_MAP_TYPE_5
			else
				raise "Unknown type of race."
		end
		# @logger.debug("get_column_map - returning : " + column_map.to_s)
		return column_map
	end
	
	# cf. https://stackoverflow.com/a/32713128/2112089
	def element_has_class(elmt, className)
		classes = elmt.getAttribute("class")
		classes_array = classes.split(" ")
		classes_array.each do |currentClass|
			if currentClass == "" then
				return true
			end
		end
		return false
	end
	
	def is_element_present(how, what, where)
		@driver.manage.timeouts.implicit_wait = 0
		result = where.find_elements(how, what).size() > 0
		if result
			result = where.find_element(how, what).displayed?
		end
		@driver.manage.timeouts.implicit_wait = 30
		return result
	end
	
	def find_element_clean(how, what, from)
		result = nil
		implicit_wait = @driver.manage.timeouts.implicit_wait
		@driver.manage.timeouts.implicit_wait = 0
		result = from.find_element(how, what).size() > 0
		
		@driver.manage.timeouts.implicit_wait = implicit_wait
		return result
	end
	
	def fetch_runners_shallow()
		# Fields to fill:
		# - age (runner)							
		# - blinder (runner)
		# - distance (runner)
		# - draw (runner)
		# - earnings_career (runner)
		# - history (shortened history) (runner)
		# - is_non_runner (runner)
		# - is_substitute (runner)
		# - jockey
		# - load_handicap (runner)
		# - load_ride (runner)
		# - name (horse)
		# - number (runner)
		# X race (runner)
		# - shirt (?) -> nobody cares...
		# - shoes (runner)
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
		
		# if race is finished, click on link to runner's table 
		if is_element_present(:css, "p.course-infos-statut-details--arrivee", @driver) then
			@driver.find_element(:css, "li.partants").click()
		end
		
		column_map = get_column_map()
		# @logger.debug("fetch_runners_shallow - column_map : " + column_map.to_s)
		
		html_runner_list = @driver.find_elements(:css, CSS_TO_RUNNERS)
		i = 0
		html_runner_list.each do | html_runner |
			@logger.debug("fetch_runners_shallow - runner #" + i.to_s)
			i = i + 1
			sex = nil
			
			runner_class_raw = html_runner.attribute("class")
			runner_class = runner_class_raw.strip
			
			is_non_runner = false
			age = 0
			blinder_text = ""
			draw = 0
			earnings_career = 0.0
			history = ""
			horse = nil
			is_substitute = false
			jockey = Jockey::new(name: "")
			load_handicap = 0.0
			load_ride = 0.0
			sex_text = ""
			single_rating_before_race = 0.0
			shoes_text = ""
			
			
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
			horse_name_elmt = html_runner.find_element(:css, "p.participants-name")
			horse_name_raw = horse_name_elmt.text.strip
			# @logger.debug("fetch_runners_shallow - horse_name_raw: " + horse_name_raw)
			horse_name = horse_name_raw
			@logger.debug("fetch_runners_shallow - horse_name: " + horse_name)
			
			# substitute
			name_and_substitute_elmt = html_runner.find_element(:xpath, "td[2]")
			name_and_substitute_string = name_and_substitute_elmt.text.strip
			if name_and_substitute_string.index(SUBSTITUTE_FLAG) != nil then
				is_substitute = true
			end
			
			
			if runner_class.index(NON_RUNNER_FLAG) != nil then
				# non partant
				is_non_runner = true
				
				horse = Horse::new(name: horse_name)
				
				# @logger.trace("fetch_runners_shallow - is_non_runner branch ")
			else
				# partant
				is_non_runner = false
				
				# @logger.debug("fetch_runners_shallow - runner branch ")
				
				# sex (horse)
				sex_elmt = find_element_clean(html_runner, :xpath, "td[3]")
				sex_raw = sex_elmt.text.strip
				sex_text = sex_raw
				
				# age (runner)
				age_elmt = html_runner.find_element(:xpath, "td[6]")
				age_raw = age_elmt.text.strip
				age = age_raw.to_i
				
				# jockey
				jockey_name_elmt = html_runner.find_element(:xpath, "td[7]")
				jockey_name_raw = jockey_name_elmt.text.strip
				jockey_name = jockey_name_raw
				
				# here, multiple possibilities, so we get a bit more flexible
								
				blinder_xpath = column_map[:blinder] # "td[4]/b"
				draw_xpath = column_map[:draw]
				distance_xpath = column_map[:distance]
				trainer_xpath = column_map[:trainer]
				gains_xpath = column_map[:earnings_carrer]
				history_xpath = column_map[:history]
				load_handicap_xpath = column_map[:load_handicap]
				load_ride_xpath = column_map[:load_ride]
				shoes_xpath = column_map[:shoes]
				single_rating_xpath = column_map[:single_rating]
				
				# blinder (runner)
				if blinder_xpath != nil then
					blinder_elmt = html_runner.
						find_element(:xpath, blinder_xpath)
					blinder_raw = blinder_elmt.attribute("class")
					blinder_text = blinder_raw
				end
				
				# draw
				if draw_xpath != nil then
					draw_elmt = html_runner.
						find_element(:xpath, draw_xpath)					
					draw_raw = draw_elmt.text.strip
					draw = draw_raw.to_i
				end
				
				# shoes
				if shoes_xpath != nil then
					# @logger.debug("fetch_runners_shallow - shoes_xpath : " + shoes_xpath)
					shoes_elmt = html_runner.
						find_element(:xpath, shoes_xpath)					
					shoes_raw = shoes_elmt.attribute("class")
					shoes_text = shoes_raw
				end
				
				# distance
				if distance_xpath != nil then
					distance_elmt = html_runner.
						find_element(:xpath, distance_xpath)
					distance_raw = distance_elmt.text.strip
					distance = distance_raw.to_i
				end
				
				# earnings_career
				if gains_xpath != nil then
					earnings_career_elmt = html_runner.
						find_element(:xpath, gains_xpath)
					earnings_career_raw = earnings_career_elmt.text
					earnings_career_raw = earnings_career_raw.gsub(",", ".")
					earnings_career_raw = earnings_career_raw.gsub("€", "")
					earnings_career_raw = earnings_career_raw.gsub(" ", "")
					earnings_career_raw = earnings_career_raw.strip
					earnings_career = earnings_career_raw.to_f
				end
				
				# load_handicap (runner)
				if load_handicap_xpath != nil then
					load_handicap_elmt = html_runner.
						find_element(:xpath, load_handicap_xpath)
					load_handicap_raw = load_handicap_elmt.text
					load_handicap_raw = load_handicap_raw.gsub(",", ".")
					load_handicap_raw = load_handicap_raw.strip
					load_handicap = load_handicap_raw.to_f 
					# returns 0.0 if string not parseable -> ie '-' will return 0.0
				end
				
				# load_ride (runner)
				if load_ride_xpath != nil then
					load_ride_elmt = html_runner.
						find_element(:xpath, load_ride_xpath)
					load_ride_raw = load_ride_elmt.text
					load_ride_raw = load_ride_raw.gsub(",", ".")
					load_ride_raw = load_ride_raw.strip
					load_ride = load_ride_raw.to_f 
					# returns 0.0 if string not parseable -> ie '-' will return 0.0
				end
				
				# history
				if history_xpath != nil then
					history_elmt = html_runner.
						find_element(:xpath, history_xpath)
					history_raw = history_elmt.text.strip
					history = history_raw
				end
				
				# single_rating
				if single_rating_xpath != nil then
					single_rating_before_race_elmt = html_runner.
						find_element(:xpath, single_rating_xpath)
					single_rating_before_race_raw = single_rating_before_race_elmt.text
					single_rating_before_race_raw = single_rating_before_race_raw.gsub(",", ".")
					single_rating_before_race_raw = single_rating_before_race_raw.strip
					# @logger.debug("fetch_runners_shallow - single_rating_before_race_raw = " + single_rating_before_race_raw)
					single_rating_before_race = single_rating_before_race_raw.to_f 
				end
				
				horse = Horse::new(name: horse_name)
				
				jockey = Jockey::new(name: jockey_name)
				sex = @ref_list_hash[:ref_sex_list][sex_text]
				
			end
			# @logger.trace("fetch_runners_shallow - back to main branch ")
			horse.sex = sex
			shoes = @ref_list_hash[:ref_shoes_list][shoes_text]
			
			# @logger.debug("fetch_runners_shallow - shoes_text : " + shoes_text)
			blinder = @ref_list_hash[:ref_blinder_list][blinder_text]
			
			runner = Runner::new(
				age: age,
				blinder: blinder,
				distance: distance,
				draw: draw,
				earnings_career: earnings_career,
				history: history,
				horse: horse,
				is_non_runner: is_non_runner,
				is_substitute: is_substitute,
				jockey: jockey,
				load_handicap: load_handicap,
				load_ride: load_ride,
				number: number,
				# race: race,
				single_rating_before_race: single_rating_before_race,
				shoes: shoes,
				url: url
			)
			
			# @logger.debug("fetch_runners_shallow - Fetched runner: " 
			# 				+ runner.to_s)
			# @logger.debug("Fetched runner: " + runner.horse.name + 
			# 				", single_rating_before_race = " +
			# 				runner.single_rating_before_race.to_s)
			
			result[number] = runner
			
		end
		
		return result
	end

	def fetch_race_results()
		# Fields to fill:
		# - commentary (runner)
		# - disqualified (runner)
		# - diff. with precedent -> distance (runner)
		# - final_place (runner)
		# - is_favorite (runner)
		# - is_non_runner (rapports) (runner)
		# - number (runner)
		# - single_rating_after_race (rapports) (runner)
		# - time (runner)
		
		# see fetch_runner_shallow for :
		# - age (runner)
		# - blinder (runner)
		# - distance (runner)
		# - draw (runner)
		# - earnings_career (runner)
		# - history (shortened history) (runner)
		# - jockey
		# - load_handicap (runner)
		# - load_ride (runner)
		# - name (horse)
		# - is_non_runner (runner)
		# - number (runner)
		# X race (runner)
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
			is_non_runner = false
			
			if td_list.size < 7 then
				# non-runner
				is_non_runner = true
				commentary = ""
				time = ""
				distance = ""
				final_place = 0
				single_rating_after_race = 0.0
				
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
				if (distance_or_time.index("\"") != nil) or 
					(distance_or_time.index("'") != nil) then
					time = distance_or_time
				else
					distance = distance_or_time
				end
				
				# final_place & disqualified
				final_place_html = html_runner.find_element(:xpath, "td[1]")
				final_place_raw = final_place_html.text.strip
				
				if final_place_raw.index(DISQUALIFIED_FLAG) == nil then
					if final_place_raw.index(NC_FLAG) == nil then
						# '1er', '2è', '3è'... to '10è'
						final_place_raw = final_place_raw.gsub("è", "")
						final_place_raw = final_place_raw.gsub("er", "")
						final_place_raw = final_place_raw.strip
						final_place_raw = final_place_raw.to_i
					else 
						# '-'
						final_place_raw = 0
					end
				else 
					# 'DAI'
					final_place_raw = 0
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
			if complete_class.index(FAVORITE_FLAG) != nil then
				is_favorite = true
			end
			
			# url //*[@id="participants-view"]/div[1]/table/tbody/tr[3]/td[3]/span[1]
			
			# html_link_to_runner = html_runner.find_element(:xpath, "td[3]/span[1]/a")
			# url = html_link_to_runner.attribute("href")
			url = ""
			
			# number (== hash key)
			
			number = get_runner_number_from_result_page(html_runner)
			@logger.debug("fetch_race_results - number = " + number.to_s)
			
			runner = Runner::new(
				commentary: commentary,
				disqualified: disqualified,
				distance: distance,
				final_place: final_place,
				is_favorite: is_favorite,
				is_non_runner: is_non_runner,
				number: number,
				single_rating_after_race: single_rating_after_race,
				time: time,
				url: url
			)
			
			@logger.debug("fetch_race_results - runner: " + runner.to_s)
		
			result[number] = runner
		end
		
		return result
	end

	def fetch_runner(runner_tr_element, column_map)
		runner = fetch_runner_shallow(runner_tr_element, column_map)
		fetch_runner_deep(runner, runner_tr_element, column_map)
		return runner
	end
	
	def fetch_runner_shallow(runner_tr_element, column_map)
		# Fields to fill:
		# - age V
		# - blinder V
		# - distance V
		# - handicap V
		# - history V
		# - is_favorite V
		# - is_non_runner V
		# - is_pregnant V
		# - is_replaced V
		# - jockey V
		# - load_handicap V
		# - load_ride V
		# - name (horse) V
		# - number V
		# - sex (horse) V
		# - shoes V
		# - trainer
		
		age_and_sex_elmt = runner_tr_element.find_element(:xpath, "tr[3]")
		age_and_sex_raw = age_and_sex_elmt.text.strip()
		age_and_sex_array = age_and_sex_raw.split("<br>")
		age_raw = age_and_sex_array[0]
		age = age_raw.to_i
		
		blinder = nil
		if column_map[:blinder] then
			if is_element_present(:css, "use", runner_tr_element) then
				blinder_elmt = runner_tr_element.find_element(:css, "use")			
				blinder_link_raw = blinder_elmt.attribute("xlink:href")
				blinder_text = blinder_link_raw.split("#")[1] # second element when splitting the string on the '#'
				# @logger.debug("fetch_runner_shallow - blinder_text : " + blinder_text)
				blinder = @ref_list_hash[:ref_blinder_list][blinder_text]
			end
		end
		
		if column_map[:distance] then
			distance_elmt = runner_tr_element.find_element(:xpath, "td[6]")
			distance_raw = distance_elmt.text.strip()
			distance = distance_raw.to_i
		end
		
		if column_map[:handicap] then
			handicap_elmt = runner_tr_element.find_element(:xpath, "td[6]")
			handicap_raw = handicap_elmt.text.strip()
			handicap = handicap_raw.gsub(",",".").to_f
		end
		
		history_elmt = runner_tr_element.find_element(:css, "span.participants-performances")
		history = history_elmt.text.strip()
		
		is_favorite = element_has_class(runner_tr_element, "participants-tbody-tr--favorite")
		
		is_non_runner = element_has_class(runner_tr_element, "participants-tbody-tr--non-partant")
		
		is_pregnant = is_element_present(:css, "svg.jument_pleine", runner_tr_element)
		
		is_replaced = is_element_present(:css, "li.participants-details--suppl", runner_tr_element)
		
		jockey_name_elmt = runner_tr_element.find_element(:xpath, column_map[:jockey])
		jockey_name = jockey_name_elmt.text.strip()
		jockey = Jockey::new(name: jockey_name)
		
		if column_map[:load] then
			load_elmt = runner_tr_element.find_element(:xpath, column_map[:load])
			load_raw = load_elmt.text.strip()
			load_array = load_raw.split("<br>")
			
			#load_handicap
			load_handicap_raw = load_array[0]
			if load_handicap_raw == "-" then
				load_handicap = 0
			else 
				load_handicap = load_handicap_raw.to_f
			end
			
			#load_ride
			load_ride_raw = load_array[1]
			if load_ride_raw == "-" then
				load_ride = 0
			else 
				load_ride = load_ride_raw.to_f
			end
		end
		
		number_elmt = runner_tr_element.find_element(:css, "span.participants-num")
		number_raw = number_elmt.text.strip()
		numer = number_raw.to_i
		
		name_elmt = runner_tr_element.find_element(:css, "p.participants-name")
		name_raw = name_elmt.text.strip()
		name = name_raw.to_i
		
		sex_raw = age_and_sex_array[1]
		sex = sex_raw.to_i
		
		shoes = nil
		if column_map[:shoes] then
			if is_element_present(:css, "svg.deferre_anterieurs", runner_tr_element) then
				shoes_text = "deferre_anterieurs"
				# @logger.debug("fetch_runner_shallow - shoes_text : " + shoes_text)
				shoes = @ref_list_hash[:ref_shoes_list][shoes_text]
			elsif is_element_present(:css, "svg.deferre_anterieurs_posterieurs", runner_tr_element) then
				shoes_text = "deferre_anterieurs_posterieurs"
				# @logger.debug("fetch_runner_shallow - shoes_text : " + shoes_text)
				shoes = @ref_list_hash[:ref_shoes_list][shoes_text]
			elsif is_element_present(:css, "svg.deferre_posterieurs", runner_tr_element) then
				shoes_text = "svg.deferre_posterieurs"
				# @logger.debug("fetch_runner_shallow - shoes_text : " + shoes_text)
				shoes = @ref_list_hash[:ref_shoes_list][shoes_text]
			end
		end
		
		horse = Horse::new(name: name, sex: sex)
		
		trainer_name_elmt = runner_tr_element.find_element(:css, "span.participants-entraineur")
		trainer_name = trainer_name_elmt.text.strip()
		trainer = Trainer::new(name: trainer_name)
		
		runner = Runner::new(
			age: age,
			blinder: blinder,
			distance: distance,
			handicap: handicap,
			history: history,
			is_favorite: is_favorite,
			is_non_runner: is_non_runner,
			is_pregnant: is_pregnant,
			is_replaced: is_replaced,
			jockey: jockey,
			load_handicap: load_handicap,
			load_ride: load_ride,
			number: number,
			shoes: shoes,
			trainer: trainer
		)
		
		return runner
	end

end