require 'psych'
#see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'selenium-webdriver'
require 'browsermob/proxy'

require_relative './common.rb'
require_relative './SimpleHtmlLogger.rb'
require_relative './ref.rb'
require_relative './environnment.rb'
require_relative './prediction.rb'
require_relative './people.rb'
require_relative './Runner.rb'

class Crawler
	CSS_TO_RUNNER_TABLE = "li.partants"
	CSS_TO_ARRIVEE_TABLE = "li.arrivee"
	CSS_TO_RUNNERS = "tr.participants-tbody-tr" #participants-view > div:nth-child(1) > table:nth-child(3) > tbody:nth-child(2) > tr
	CSS_TO_HEADER_LINE = ".participants-thead"
	CSS_TO_HEADER_TH = "th"
	CSS_TO_RUNNER_NAME = "p.participants-name"

	DISQUALIFIED_FLAG = "DAI"
	FAVORITE_FLAG = "favorite"
	NC_FLAG = "-"
	NON_RUNNER_FLAG = "participants-tbody-tr--non-partant"
	SUBSTITUTE_FLAG = "[suppl]"

	ODD_LINE_FLAG = "even"
	EVEN_LINE_FLAG = "odd"

	DETAILED_COND_INTRO = ""

	# Obstacle Steeple / Obstacle Cross / Obstacle Haies
	HEADER_LINE_TYPE_1 = 			"N° Cheval Sexe Jockey Poids H. "
	# "Plat"
	HEADER_LINE_TYPE_2 =			"N° Cheval Cde. Sexe Jockey Poid"
	# "Trot Attelé" if already finished
	HEADER_LINE_TYPE_3 = 			"N° Cheval Sexe Driver Gains Dis"
	# "Trot Monté" if already finished
	HEADER_LINE_TYPE_4 = 			"N° Cheval Sexe Jockey Poids Dis"


	# Obstacle Steeple / Obstacle Cross / Obstacle Haies
	COLUMN_MAP_TYPE_1 = {	age: "td[3]", 						blinder: true,
							distance: false, 						handicap: true,
							jockey: "span.participants-jokey", 	load_handicap: "td[5]",
							load_ride: "td[5]",					sex: "td[3]",
							shoes: false}

	# "Plat"
	COLUMN_MAP_TYPE_2 = {	age: "td[4]", 						blinder: true,
							distance: false, 					handicap: false,
							jockey: "span.participants-jokey", 	load_handicap: "td[6]",
							load_ride: "td[6]",					sex: "td[4]",
							shoes: false}

	# "Trot Attelé"
	COLUMN_MAP_TYPE_3 = {	age: "td[3]", 						blinder: false,
							distance: "td[6]", 					handicap: false,
							jockey: "span.participants-driver", load_handicap: nil,
							load_ride: nil,						sex: "td[3]",
							shoes: true}

	# "Trot Monté"
	COLUMN_MAP_TYPE_4 = {	age: "td[3]", 						blinder: false,
							distance: "td[6]", 					handicap: false,
							jockey: "span.participants-jokey", load_handicap: nil,
							load_ride: nil,						sex: "td[3]",
							shoes: true}

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


	# cf. https://stackoverflow.com/a/32713128/2112089
	def element_has_class(elmt, className)

		classes = elmt.attribute("class")
		classes_array = classes.split(" ")
		classes_array.each do |currentClass|
			if currentClass == className then
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


	def launch_driver()
		@logger.info("Preparing browser")
		browser_start_start_time = Time::now

		# proxy
		# see https://github.com/jarib/browsermob-proxy-rb
		# and http://stackoverflow.com/a/15297676/2112089
		@server = BrowserMob::Proxy::Server.new("D:/Dev/workspace/RPP/Install/browsermob-proxy-2.1.4/bin/browsermob-proxy.bat") #=> #<BrowserMob::Proxy::Server:0x000001022c6ea8 ...>

		@server.start

		@proxy = @server.create_proxy #=> #<BrowserMob::Proxy::Client:0x0000010224bdc0 ...>

		@proxy.blacklist("https://analytics.twitter.com/", 443)
		@proxy.blacklist("https://platform.twitter.com/", 443)
		@proxy.blacklist("https://connect.facebook.net/", 443)
		@proxy.blacklist("https://dcniko1cv0rz.cloudfront.net/", 443)
		@proxy.blacklist("https://dis.eu.criteo.com/", 443)
		@proxy.blacklist("https://static.criteo.net/", 443)
		@proxy.blacklist("https://i.realytics.io/", 443)
		@proxy.blacklist("https://tc-sync.realytics.io/", 443)
		@proxy.blacklist("https://tp.realytics.io/", 443)
		@proxy.blacklist("https://sb.scorecardresearch.com/", 443)
		@proxy.blacklist("https://sslwidget.criteo.com/", 443)
		@proxy.blacklist("https://us-u.openx.net", 443)
		@proxy.blacklist("http://www.joueurs-info-service.fr/", 80)
		@proxy.blacklist("https://597f24f54a2e59001542436a.tracker.adotmob.com", 443)
		@proxy.blacklist("https://ad.360yield.com/", 443)
		@proxy.blacklist("https://ad.doubleclick.net", 443)
		@proxy.blacklist("https://ads.stickyadstv.com/", 443)
		@proxy.blacklist("https://ads.yahoo.com/", 443)
		@proxy.blacklist("https://ads.yieldmo.com/", 443)
		@proxy.blacklist("https://bat.bing.com/", 443)
		@proxy.blacklist("https://cm.adform.net/", 443)
		@proxy.blacklist("https://cm.g.doubleclick.net/", 443)
		@proxy.blacklist("https://cosy.smaato.net/", 443)
		@proxy.blacklist("https://cotads.adscale.de/", 443)
		@proxy.blacklist("https://d5p.de17a.com/", 443)
		@proxy.blacklist("https://dis.criteo.com/", 443)
		@proxy.blacklist("https://dsum-sec.casalemedia.com/", 443)
		@proxy.blacklist("https://email-reflex.com/", 443)
		@proxy.blacklist("https://eule1.pmu.fr/", 443)
		@proxy.blacklist("https://fo-ssp.omnitagjs.com", 443)
		@proxy.blacklist("https://gum.criteo.com/", 443)
		@proxy.blacklist("https://ib.adnxs.com/", 443)
		@proxy.blacklist("https://ih.adscale.de/", 443)
		@proxy.blacklist("https://match.sharethrough.com/", 443)
		@proxy.blacklist("https://pixel.advertising.com/", 443)
		@proxy.blacklist("https://pixel.rubiconproject.com/", 443)
		@proxy.blacklist("https://rtb-csync.smartadserver.com/", 443)
		@proxy.blacklist("https://s.sspqns.com/", 443)
		@proxy.blacklist("https://sb.scorecardresearch.com/", 443)
		@proxy.blacklist("https://secure.adnxs.com/", 443)
		@proxy.blacklist("https://simage2.pubmatic.com/", 443)
		@proxy.blacklist("https://sp.analytics.yahoo.com/", 443)
		@proxy.blacklist("https://static.ads-twitter.com/", 443)
		@proxy.blacklist("https://stats.g.doubleclick.net", 443)
		@proxy.blacklist("https://sync.adotmob.com/", 443)
		@proxy.blacklist("https://sync.outbrain.com/", 443)
		@proxy.blacklist("https://sync.teads.tv/", 443)
		@proxy.blacklist("https://t.co/", 443)
		@proxy.blacklist("https://ums.adtech.de/", 443)
		@proxy.blacklist("https://us-u.openx.net/", 443)
		@proxy.blacklist("https://usync.nexage.com/", 443)
		@proxy.blacklist("https://visitor.omnitagjs.com/", 443)
		@proxy.blacklist("https://www.google-analytics.com/", 443)
		@proxy.blacklist("https://www.google.fr/", 443)
		@proxy.blacklist("https://x.bidswitch.net/", 443)


		@proxy.whitelist("https://www.alerting.pmu.fr", 443)
		@proxy.whitelist("https://www.pmu.fr/", 443)

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
		# profile.add_extension("./Install/firebug-1.12.6.xpi") # NB: FF takes ~2.5 more seconds to load w/ Firebug (from 6.1 to 8.8)
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

		options = Selenium::WebDriver::Firefox::Options.new
		options.profile = profile

		#Loading browser
		# driver = Selenium::WebDriver.for(:chrome, :profile => profile, detach: false)
		driver = Selenium::WebDriver.for(:firefox, options: options)
		# , :profile => profile
		# @driver = Selenium::WebDriver.for(:remote,:url => "http://localhost:4444/wd/hub",:desired_capabilities =>:htmlunit)

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
		if @driver != nil
			@driver.close
		end
		if @driver != nil
			@driver.quit
		end
		@server.stop

		if @profile != nil
			@profile.close
		end
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
			date = date - 1

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
			# @logger.debug("Country: " + country)
		# end
		country = nil
		# @logger.debug("Racetrack: " + racetrack)

		# weather
		weather = nil
		p_tag_for_weather = @driver.
					find_element(:xpath, "//div[@class='course-infos-meteo']/p")
		if p_tag_for_weather != nil then
			weather = fetch_weather(p_tag_for_weather)
			@logger.debug("Weather: " + weather.to_s)
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
		@logger.debug("fetch_meeting_shallow - Urls_of_races_array: " + urls_of_races_array.to_s)

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

		@logger.debug("fetch_weather - insolation: " + insolation)

		weather_text = p_tag_for_weather.text


		weather_text_components = weather_text.split(", vent")
		# the class should look like this: "6°C, vent 7 km/h"
		# we're only interested the P4 part

		@logger.debug("fetch_weather - weather_text: " + weather_text)
		@logger.debug("fetch_weather - weather_text_components: " + weather_text_components.to_s)

		str_temperature = weather_text_components[0].gsub("\u00B0C", "").strip()
		str_wind_speed = weather_text_components[1].gsub("km/h", "").strip()

		@logger.debug("fetch_weather - temperature: " + str_temperature)
		@logger.debug("fetch_weather - wind_speed: " + str_wind_speed)

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
		# @logger.debug("runner_list: " + runner_list.to_s)

		return race
	end

	def fetch_race_shallow(url_of_race)

		header_tag_array = @driver.find_elements(:css, ".course-infos-header-extras-main > li")

		# header_text =>	Plat | 12 000 € | 2400 m | 5 partants
		# 					Trot Attelé | 20 000 € | 2150 m | 16 partants
		#					Obstacle Steeple | 15 000 € | 4100 m | 9 partants
		#					race_type | value | distance | number of participants (ignored)

		# race_type
		race_type_tag = header_tag_array[0]
		race_type_raw = race_type_tag.text.strip()
		race_type = @ref_list_hash[:ref_race_type_list][race_type_raw]
		@logger.debug("fetch_race_shallow - race_type: " + race_type.to_s)

		# value
		value_tag = header_tag_array[1]
		race_type_raw = race_type_tag.text.strip()
		value_str = race_type_tag.text.strip().gsub("€" , "").gsub(" ", "")
		value = value_str.to_i
		@logger.debug("fetch_race_shallow - value: " + value.to_s)

		# distance
		distance_tag = header_tag_array[2]
		distance_str = distance_tag.text.strip().gsub("m", "")
		distance = distance_str.to_i
		@logger.debug("fetch_race_shallow - distance: " + distance.to_s)

		# bets
		# under "Les plus joues" now
		bet_button_tag = @driver.find_element(:xpath, "//i[@class='icon icon-plus-joues']")
		bet_button_tag.click

		bets = nil
		bet_potential_tags = @driver.find_elements(:xpath, "//td[@class='masse-enjeux-val']")

		@logger.debug("fetch_race_shallow - number of potential bet tags: " + bet_potential_tags.length.to_s)
		bet_potential_tags.each do |bet_potential_tag|
			bet_potential_text = bet_potential_tag.text
			@logger.debug("fetch_race_shallow - bet_potential_text: " + bet_potential_text.to_s)
			corresponding_label = bet_potential_tag.find_element(:xpath, "../td[@class='label']")
			@logger.debug("fetch_race_shallow - corresponding_label: " + corresponding_label.to_s)
			if corresponding_label.text.include?("Placé")
				# should look like:
				bets_str = bet_potential_text.gsub("€", "").gsub(" ", "").gsub(",", ".").strip()
				bets = bets_str.to_f

			end
		end
		@logger.debug("fetch_race_shallow - bets: " + bets.to_s)


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

			@logger.debug("fetch_race_shallow - detailed_cond: " + detailed_cond)

			# close popin
			# btn_close_popin = @driver.find_element(:css, "div.popin-close")
			# btn_close_popin.click
			# if $globalState.is_test then
				# @driver.navigate.back
			# end
		end

		# @logger.debug("detailed_cond: " + detailed_cond)

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

		@logger.debug("fetch_race_shallow - general_conditions: " + general_cond_str)

		# name
		# inside h1.course-infos-header-title 	=> R2C1 - PRIX DE CANNES NORVEGE
		#                             			=> R6C2 - PRIX FANDANGO
		# split#1
		race_title_tag = @driver.find_element(:css, "h1.course-infos-header-title")
		race_title_str = race_title_tag.text
		# @logger.debug("race_title_str: " + race_title_str)
		race_title_array = race_title_str.split(" - ")
		name = race_title_array[1].strip()
		@logger.debug("fetch_race_shallow - name: " + name)

		# number
		# inside h1.course-infos-header-title 	=> R2C1 - PRIX DE CANNES NORVEGE
		#                             			=> R6C2 - PRIX FANDANGO
		# split#0
		str_number = race_title_array[0].strip()
		str_number_array = str_number.split("C")
		number = str_number_array[1].to_i
		@logger.debug("fetch_race_shallow - number: " + number.to_s)

		# result
		# //*[@id='main']/div/div[4]/div/div[3]/div/div[1]/div/div/p[2]
		begin
			result_tag = @driver.find_element(:css, "ul.participants-arrivee-list-chevaux participants-arrivee-list-chevaux--definitive")
			result = result_tag.text.strip
			@logger.debug("fetch_race_shallow - result: " + result)

			# result_insertion_time
			if result != '' then
				result_insertion_time = Time::new
				@logger.debug("fetch_race_shallow - result_insertion_time: " +
					result_insertion_time.
						strftime(@config[:gen][:default_date_time_format])
				)
			else
				result_insertion_time = nil
				@logger.debug("fetch_race_shallow - result_insertion_time: nil")
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

		# @logger.debug("date_hours_i: " + date_hours_i.to_s)
		# @logger.debug("date_min_i: " + date_min_i.to_s)

		time = Time::new(1, 1, 1, date_hours_i, date_min_i)
		@logger.debug("fetch_race_shallow - time: " +
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
			# wait for table to show up
			Selenium::WebDriver::Wait.new(:timeout => 3)
			runner_table_button.click
			wait = Selenium::WebDriver::Wait.new(:timeout => 15)
			element = wait.until {
				@driver.find_element(:css => CSS_TO_RUNNER_TABLE + ".selected")
			}

		end

		column_map = get_column_map()

		runner_list = Hash.new
		list_of_runners = @driver.find_elements(:css, CSS_TO_RUNNERS)
		i = 1
		list_of_runners.each do |runner_elmt|
			@logger.info("fetch_runners - Fetching runner #" + i.to_s)
			current_runner = fetch_runner(runner_elmt, column_map)
			runner_list[current_runner.number] = current_runner
			i = i + 1
		end

		# if the race is over, its results are fetched
		if is_element_present(:css, "p.course-infos-statut-details--arrivee", @driver) then
			@logger.info("fetch_runners - Fetching race results.")
			fetch_race_results(runner_list, column_map)
		else
			@logger.info("fetch_runners - Race not finisehd, not fetching race results.")
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
		# race_type (for logging)
		header_tag_array = @driver.find_elements(:css, ".course-infos-header-extras-main > li")


		race_type_tag = header_tag_array[0]
		race_type_raw = race_type_tag.text.strip()

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

		is_finished = not(is_element_present(:css, "p.course-infos-statut-details--depart", @driver))

		# shortening for check
		# to same size as HEADER_LINES because that's the size of the shortest
		# string to differentiate between the 4 possibilities.
		str_flattened_header = str_flattened_header[0, HEADER_LINE_TYPE_1.length]
		@logger.info("get_column_map - for race: " + debug_url +
						" - race type: " + race_type_raw + " is finished: " + is_finished.to_s + " - found header line: " + str_flattened_header)

		column_map = nil

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
			else
				raise "Unknown type of race."
		end
		# @logger.debug("get_column_map - returning: " + column_map.to_s)
		return column_map
	end


	def fetch_race_results(runner_list, column_map)

		# Click on button to show result table

		# loop on table lines
		#  -> fetch_result_shallow
		runner_table_button = @driver.find_element(:css, CSS_TO_ARRIVEE_TABLE)
		# wait for table to show up
		Selenium::WebDriver::Wait.new(:timeout => 3)
		runner_table_button.click
		wait = Selenium::WebDriver::Wait.new(:timeout => 15)
		element = wait.until {
			@driver.find_element(:css => CSS_TO_ARRIVEE_TABLE + ".selected")
		}

		list_of_runners = @driver.find_elements(:css, CSS_TO_RUNNERS)
		i = 1
		list_of_runners.each do |runner_elmt|
			@logger.info("fetch_race_results - Fetching runner #" + i.to_s)

			number_elmt = runner_elmt.find_element(:css, "span.participants-num")
			number_raw = number_elmt.text.strip()
			number = number_raw.to_i

			runner = runner_list[number]

			current_runner = fetch_result_shallow(runner, runner_elmt, column_map)
			# Is this next line necesary?
			runner_list[current_runner.number] = current_runner
			i = i + 1
		end

	end

	def fetch_runner(runner_tr_element, column_map)
		runner = fetch_runner_shallow(runner_tr_element, column_map)
		fetch_runner_deep(runner, runner_tr_element)
		return runner
	end

	def fetch_runner_shallow(runner_tr_element, column_map)
		# Fields to fill:
		# - blinder V
		# - distance V
		# - handicap V
		# - history V
		# - is_favorite V
		# - is_non_runner V
		# - is_pregnant V
		# - is_substitute V
		# - jockey V
		# - load_handicap V
		# - load_ride V
		# - name (horse) V
		# - number V
		# - shoes V
		# - trainer

		number_elmt = runner_tr_element.find_element(:css, "span.participants-num")
		number_raw = number_elmt.text.strip()
		number = number_raw.to_i
		@logger.debug("fetch_runner_shallow - number: " + number.to_s)

		name_elmt = runner_tr_element.find_element(:css, CSS_TO_RUNNER_NAME)
		name = name_elmt.text.strip()
		@logger.debug("fetch_runner_shallow - name: " + name)
		horse = Horse::new(name: name)

		is_non_runner = element_has_class(runner_tr_element, "participants-tbody-tr--non-partant")
		@logger.debug("fetch_runner_shallow - is_non_runner: " + is_non_runner.to_s)

		blinder = nil
		distance = 0
		handicap = 0.0
		history = nil
		is_favorite = false
		is_pregnant = false
		is_substitute = false
		jockey = nil
		load_handicap = 0.0
		load_ride = 0.0
		shoes = nil
		trainer = nil
		if not is_non_runner then

			blinder = nil
			if column_map[:blinder] then
				if is_element_present(:css, "use", runner_tr_element) then
					blinder_elmt = runner_tr_element.find_element(:css, "use")
					blinder_link_raw = blinder_elmt.attribute("xlink:href")
					blinder_text = blinder_link_raw.split("#")[1] # second element when splitting the string on the '#'
					blinder = @ref_list_hash[:ref_blinder_list][blinder_text]
					@logger.debug("fetch_runner_shallow - blinder: " + blinder.to_s)
				end
			end

			if column_map[:distance] then
				distance_elmt = runner_tr_element.find_element(:xpath, "td[6]")
				distance_raw = distance_elmt.text.strip()
				distance = distance_raw.to_i
				@logger.debug("fetch_runner_shallow - distance: " + distance.to_s)
			end

			if column_map[:handicap] then
				handicap_elmt = runner_tr_element.find_element(:xpath, "td[6]")
				handicap_raw = handicap_elmt.text.strip()
				handicap = handicap_raw.gsub(",",".").to_f
				@logger.debug("fetch_runner_shallow - handicap: " + handicap.to_s)
			end

			history_elmt = runner_tr_element.find_element(:css, "span.participants-performances")
			history = history_elmt.text.strip()
			@logger.debug("fetch_runner_shallow - history: " + history)

			is_favorite = element_has_class(runner_tr_element, "participants-tbody-tr--favorite")
			@logger.debug("fetch_runner_shallow - is_favorite: " + is_favorite.to_s)


			is_pregnant = is_element_present(:css, "svg.jument_pleine", runner_tr_element)
			@logger.debug("fetch_runner_shallow - is_pregnant: " + is_pregnant.to_s)

			is_substitute = is_element_present(:css, "li.participants-details--suppl", runner_tr_element)
			@logger.debug("fetch_runner_shallow - is_substitute: " + is_substitute.to_s)

			jockey_name_elmt = runner_tr_element.find_element(:css, column_map[:jockey])
			jockey_name = jockey_name_elmt.text.strip()
			jockey = Jockey::new(name: jockey_name)
			@logger.debug("fetch_runner_shallow - jockey_name: " + jockey.to_s)

			if column_map[:load] then
				load_elmt = runner_tr_element.find_element(:xpath, column_map[:load])
				load_raw = load_elmt.text.strip()
				load_array = load_raw.split("<br>")

				#load_handicap
				load_handicap_raw = load_array[0]
				if load_handicap_raw == "-" then
					load_handicap = 0.0
				else
					load_handicap = load_handicap_raw.to_f
				end
				@logger.debug("fetch_runner_shallow - load_handicap: " + load_handicap.to_s)

				#load_ride
				load_ride_raw = load_array[1]
				if load_ride_raw == "-" then
					load_ride = 0.0
				else
					load_ride = load_ride_raw.to_f
				end
				@logger.debug("fetch_runner_shallow - load_ride: " + load_ride.to_s)
			end

			shoes = nil
			if column_map[:shoes] then
				if is_element_present(:css, "svg.deferre_anterieurs", runner_tr_element) then
					shoes_text = "deferre_anterieurs"
					# @logger.debug("fetch_runner_shallow - shoes_text: " + shoes_text)
					shoes = @ref_list_hash[:ref_shoes_list][shoes_text]
				elsif is_element_present(:css, "svg.deferre_anterieurs_posterieurs", runner_tr_element) then
					shoes_text = "deferre_anterieurs_posterieurs"
					# @logger.debug("fetch_runner_shallow - shoes_text: " + shoes_text)
					shoes = @ref_list_hash[:ref_shoes_list][shoes_text]
				elsif is_element_present(:css, "svg.deferre_posterieurs", runner_tr_element) then
					shoes_text = "svg.deferre_posterieurs"
					# @logger.debug("fetch_runner_shallow - shoes_text: " + shoes_text)
					shoes = @ref_list_hash[:ref_shoes_list][shoes_text]
				end
				@logger.debug("fetch_runner_shallow - shoes: " + shoes.to_s)
			end


			trainer_name_elmt = runner_tr_element.find_element(:css, "span.participants-entraineur")
			trainer_name = trainer_name_elmt.text.strip()
			trainer = Trainer::new(name: trainer_name)
			@logger.debug("fetch_runner_shallow - trainer: " + trainer.to_s)
		end


		runner = Runner::new(
			blinder: blinder,
			distance: distance,
			handicap: handicap,
			horse: horse,
			history: history,
			is_favorite: is_favorite,
			is_non_runner: is_non_runner,
			is_pregnant: is_pregnant,
			is_substitute: is_substitute,
			jockey: jockey,
			load_handicap: load_handicap,
			load_ride: load_ride,
			number: number,
			shoes: shoes,
			trainer: trainer
		)

		return runner
	end

	def fetch_runner_deep(runner, runner_tr_element)
		# Fields to fill:
		# - age V
		# - breed V
		# - breeder V
		# - coat V
		# - earnings_career V
		# - earnings_current_year V
		# - earnings_last_year V
		# - earnings_victory V
		# - father V
		# - mother V
		# - mother's father V
		# - owner V
		# - places V
		# - races_run V
		# - sex V
		# - victories V

		# open popin
		link_to_details_elmt = @driver.find_element(:css, CSS_TO_RUNNER_NAME)
		link_to_details_elmt.click()
		@logger.debug("fetch_runner_deep - opening popin.")

		# age, breed, coat & sex
		age_raw = nil
		breed_raw = nil
		sex_raw = nil
		coat_raw = nil

		identity_tags = @driver.find_elements(:css, "li.fiche-cheval-header-identite-data")
		identity_tags.each do |identity_tag|
			identity_tag_text = identity_tag.text
			@logger.debug("fetch_runner_deep - identity_tag.text: " + identity_tag.text)
			identity_tag_text_array = identity_tag_text.split(" : ")
			identifying_text = identity_tag_text_array[0]
			id_text = identity_tag_text_array[1]

			if identifying_text.include?("Âge") then
				age_raw = id_text.strip()
				@logger.debug("fetch_runner_deep - age_raw: " + age_raw.to_s)
			elsif identifying_text.include?("Race") then
				breed_raw = id_text.strip()
				@logger.debug("fetch_runner_deep - breed_raw: " + breed_raw.to_s)
			elsif identifying_text.include?("Sexe") then
				sex_raw = id_text.strip()
				@logger.debug("fetch_runner_deep - sex_raw: " + sex_raw.to_s)
			elsif identifying_text.include?("Robe") then
				coat_raw = id_text.strip()
				@logger.debug("fetch_runner_deep - coat_raw: " + coat_raw.to_s)
			end
		end

		@logger.debug("fetch_runner_deep - age_raw: " + age_raw.to_s)
		@logger.debug("fetch_runner_deep - breed_raw: " + breed_raw.to_s)
		@logger.debug("fetch_runner_deep - sex_raw: " + sex_raw.to_s)
		@logger.debug("fetch_runner_deep - coat_raw: " + coat_raw.to_s)


		age = age_raw.gsub(" ANS", "").to_i
		@logger.debug("fetch_runner_deep - age: " + age.to_s)

		breed = @ref_list_hash[:ref_breed_list][breed_raw]
		@logger.debug("fetch_runner_deep - breed: " + breed.to_s)

		coat = @ref_list_hash[:ref_coat_list][coat_raw]
		@logger.debug("fetch_runner_deep - coat: " + coat.to_s)

		sex = @ref_list_hash[:ref_sex_list][sex_raw]
		@logger.debug("fetch_runner_deep - sex: " + sex.to_s)

		# races
		races_run_elmt = @driver.find_element(:css, "span.fiche-cheval-courses-legend-value--total")
		races_run_raw = races_run_elmt.text.strip()
		races_run = races_run_raw.to_i
		@logger.debug("fetch_runner_deep - races_run: " + races_run.to_s)

		victories_elmt = @driver.find_element(:css, "li.fiche-cheval-courses-legend-item--victoires")
		victories_raw = victories_elmt.text.gsub("Victoires", "").strip()
		victories = victories_raw.to_i
		@logger.debug("fetch_runner_deep - victories: " + victories.to_s)

		places_elmt = @driver.find_element(:css, "li.fiche-cheval-courses-legend-item--places")
		places_raw = places_elmt.text.gsub("2ème & 3ème", "").strip()
		places = places_raw.to_i
		@logger.debug("fetch_runner_deep - places: " + places.to_s)

		# earnings
		earnings_career_elmt = @driver.find_element(:css, "span.fiche-cheval-gains-total-text")
		earnings_career_raw = earnings_career_elmt.text.strip()
		earnings_career_raw = earnings_career_raw.gsub("-", "0")
		earnings_career_raw = earnings_career_raw.gsub("€", "")
		earnings_career_raw = earnings_career_raw.gsub(" ", "")
		earnings_career = earnings_career_raw.to_i
		@logger.debug("fetch_runner_deep - earnings career: " + earnings_career.to_s)

		earnings_victory_father_elmt = @driver.find_element(:css, "div.fiche-cheval-gains-victory")
		earnings_victory_elmt = earnings_victory_father_elmt.find_element(:css, "span.fiche-cheval-gains-legend-value")
		earnings_victory_raw = earnings_victory_elmt.text.strip()
		earnings_victory_raw = earnings_victory_raw.gsub("-", "0")
		earnings_victory_raw = earnings_victory_raw.gsub("€", "")
		earnings_victory_raw = earnings_victory_raw.gsub(" ", "")
		earnings_victory = earnings_victory_raw.to_i
		@logger.debug("fetch_runner_deep - earnings victory: " + earnings_victory.to_s)

		earnings_current_year_father_elmt = @driver.find_element(:css, "div.fiche-cheval-gains-current")
		earnings_current_year_elmt = earnings_current_year_father_elmt.find_element(:css, "span.fiche-cheval-gains-legend-value")
		earnings_current_year_raw = earnings_current_year_elmt.text.strip()
		earnings_current_year_raw = earnings_current_year_raw.gsub("-", "0")
		earnings_current_year_raw = earnings_current_year_raw.gsub("€", "")
		earnings_current_year_raw = earnings_current_year_raw.gsub(" ", "")
		earnings_current_year = earnings_current_year_raw.to_i
		@logger.debug("fetch_runner_deep - earnings current year: " + earnings_current_year.to_s)

		# breeder, owner
		breeder_name = nil
		owner_name = nil

		potential_elmt_array = @driver.find_elements(:css, "li.fiche-cheval-header-entourage-data")
		potential_elmt_array.each do |potential_elmt|
			potential_text = potential_elmt.text
			if potential_text.include?("Éleveur") then
				breeder_name = potential_text.gsub("Éleveur :", "").strip()
			elsif potential_text.include?("Propriétaire") then
				owner_name = potential_text.gsub("Propriétaire :", "").strip()
			end
		end

		@logger.debug("fetch_runner_deep - breeder's name: " + breeder_name)
		breeder = Breeder::new(name: breeder_name)

		@logger.debug("fetch_runner_deep - owner's name: " + owner_name)
		owner = Owner::new(name: owner_name)

		# ancestry
		ancestry_elmt_array = @driver.find_elements(:css, "li.fiche-cheval-header-origine-data")
		father_name = nil
		mother_name = nil
		mothers_father_name = nil

		ancestry_elmt_array.each do |ancestry_elmt|
			ancestry_text = ancestry_elmt.text
			if ancestry_text.include?("Père") then
				father_name = ancestry_text.gsub("Père :", "").strip()
			elsif ancestry_text.include?("Mère") then
				mother_name = ancestry_text.gsub("Mère :", "").strip()
			elsif ancestry_text.include?("Père de la mère") then
				mothers_father_name = ancestry_text.gsub("Père de la mère :", "").strip()
			end
		end

		@logger.debug("fetch_runner_deep - father's name: " + father_name)
		father = Horse::new(name: father_name)

		@logger.debug("fetch_runner_deep - mother's name: " + mother_name)

		@logger.debug("fetch_runner_deep - mother's father's name: " + mothers_father_name)

		mother = Horse::new(name: mother_name,
							father: Horse::new(name: mothers_father_name)
				)

		# set all attributes
		runner.horse.breed = breed
		runner.horse.coat = coat
		runner.horse.father = father
		runner.horse.mother = mother
		runner.horse.sex = sex

		runner.age = age
		runner.breeder = breeder
		runner.earnings_career = earnings_career
		runner.earnings_current_year = earnings_current_year
		runner.earnings_last_year = earnings_last_year
		runner.earnings_victory = earnings_victory
		runner.owner = owner
		runner.places = places
		runner.races_run = races_run
		runner.victories = victories

		# close popin
		button_to_close_popin_elmt = @driver.find_element(:css, "div#popin-close")
		button_to_close_popin_elmt.click()
		@logger.debug("fetch_runner_deep - closing popin.")
	end

	def fetch_result_shallow(runner, runner_tr_element, column_map)
		# Fields to fill:
		# - commentary V
		# - final_place (and disqualified) V
		# - km_time V
		# - odds_ref V
		# - odds_direct V

		commentary_elmt = runner_tr_element.find_element(:css, "td.participants-tbody-td--commentaire")
		commentary = commentary_elmt.text.strip()
		runner.commentary = commentary

		final_place_elmt = runner_tr_element.find_element(:css, "span.participants-place")
		final_place_raw = final_place_elmt.text.strip()
		final_place_raw = final_place_raw.gsub("er", "")
		final_place_raw = final_place_raw.gsub("Er", "")
		final_place_raw = final_place_raw.gsub("ème", "")
		final_place_raw = final_place_raw.gsub("Eme", "")
		final_place_raw = final_place_raw.gsub("Ème", "")

		final_place = 99
		disqualified = true
		if "DAI" != final_place_raw then
			disqualified = false
			final_place = final_place_raw.to_i
		end
		@logger.debug("fetch_result_shallow - final_place: " + final_place.to_s)

		runner.final_place = final_place
		runner.disqualified = disqualified

		if column_map[:km_time] then
			km_time_elmt = runner_tr_element.find_element(:xpath, "td[5]")
			km_time = km_time_elmt.text.strip()
			@logger.debug("fetch_result_shallow - km_time: " + km_time)
			runner.km_time(km_time)
		end

		odds_ref_elmt = runner_tr_element.find_element(:css, "td.participants-tbody-td--rapport-probable-first")
		odds_ref_raw = odds_ref_elmt.text.strip()
		odds_ref = odds_ref_raw.to_f
		@logger.debug("fetch_result_shallow - odds_ref: " + odds_ref.to_s)
		runner.odds_ref = odds_ref

		odds_direct_elmt = runner_tr_element.find_element(:css, "td.participants-tbody-td--rapport-probable-last")
		odds_direct_raw = odds_direct_elmt.text.strip()
		odds_direct = odds_direct_raw.to_f
		@logger.debug("fetch_result_shallow - odds_direct: " + odds_direct.to_s)
		runner.odds_direct = odds_direct

		return runner
	end

end
