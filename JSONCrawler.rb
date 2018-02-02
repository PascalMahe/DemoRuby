require 'psych' 
#see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'net/http'
require 'json'

require './common.rb'
require './SimpleHtmlLogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class JSONCrawler
	
	BASE_URL = "https://www.pmu.fr/services/turfInfo/client/1/programme/"
	
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
			
			#TODO: loop on ALL* the days
			# *ALL = config[:gen][:earliest_date]
			date = Date.today()
			date = date - 1 
			
			#Fetching meetings
			meeting_list = fetch_meetings(date, current_job)
			
		rescue => e
			@logger.error("Error while crawling: " + e.inspect)
			@logger.error(e.backtrace)
		end
		
		return meeting_list
	end

	
    def fetch_meetings(date, current_job)
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
		
		url = BASE_URL + str_formatted_date
		uri = URI(url)
		
		start_time = Time.now
		
		response = Net::HTTP.get(uri)
		getting_response_time = Time.now
		
		getting_response_duration = getting_response_time - start_time
		@logger.info("fetch_meetings - Getting JSON response took: " + format_time_diff(getting_response_duration))
		
		jsonResponse = JSON.parse(response)
		
		
		jsonResponse["programme"]["reunions"].each do |jsonMeeting|
			
			meeting_nb = jsonMeeting["numOfficiel"]
			@logger.debug("fetch_meetings - meeting: " + str_formatted_date + "/R" + meeting_nb.to_s)
			
			begin			
				business_meeting = 
					fetch_meeting(date, meeting_nb, current_job, jsonMeeting)
				meeting_list.push(business_meeting)
			rescue => e
				@logger.error("Error while fetching meeting R" + meeting_nb.to_s + " in date: " + str_formatted_date + " - Error: " + e.message)
				@logger.error(e.backtrace)
			end
			meeting_nb = meeting_nb + 1
		end
				
		return meeting_list
	end

	def fetch_meeting(date, meeting_nb, job, jsonMeeting)
		
		# Fetches all data on a meeting, including races
		
		# meeting_nb, job and date are parameters
		# id is generated at insert
		# race_list is created empty and completed in fetch_races
		# all else is fetched in fetch_meeting_shallow
		
		meeting = fetch_meeting_shallow(date, meeting_nb, job, jsonMeeting)
		
		meeting.race_list = fetch_races(jsonMeeting, meeting_nb)
		
		return meeting
	end

	def fetch_meeting_shallow(date, number, job, jsonMeeting)
		# fetches 	country
		#			racetrack
		#			track_condition
		#			weather
		
		# number
		@logger.debug("fetch_meeting_shallow - Number: " + number.to_s)
		
		# racetrack [""]
		racetrack = jsonMeeting["hippodrome"]["libelle_long"]
		@logger.debug("Racetrack: " + racetrack.to_s)
		
		# country 
		country = jsonMeeting["pays"]["libelle"]
		
		# weather
		weather = nil
		if jsonMeeting["meteo"] then
			weather = Weather::new(jsonMeeting["meteo"])
			@logger.debug("Weather: " + weather.to_s)
		end
		
		# track_condition
		track_condition = nil
		track_condition_raw = jsonMeeting["courses"][0]["penetrometre"]["valeurMesure"]
		if track_condition_raw != nil then
			track_condition = @ref_list_hash[:ref_track_condition_list][track_condition_raw]
		end
		@logger.debug("fetch_meeting_shallow - track_condition: " + track_condition.to_s)
		
		meeting = Meeting::new(country: country,
								date: date, 
								job: job, 
								number: number, 
								racetrack: racetrack, 
								track_condition: track_condition, 
								weather: weather)
		# @logger.debug(meeting)
		return meeting
	end

	def fetch_races(jsonMeeting, meeting_nb)
		race_list = []
		
		jsonMeeting["courses"].each do |jsonRace|
			race_nb = jsonMeeting["numOfficiel"]
			begin			
				race = fetch_race(jsonRace, race_nb)
				race_list.push(race)
			rescue => e
				@logger.error("Error while fetching race: R" + meeting_nb.to_s + "C" + race_nb.to_s + 
								" - Error: " + e.inspect)
				@logger.error(e.backtrace)
			end
		end
		
		return race_list
	end
	
	def fetch_race(jsonRace, meeting_nb)
		# Parameter: the URL of the page where the data is to be gathered
		# and the Meeting containing this race
		# Fields to fill: 	bets, 
		# 					detailed_conditions, 
		#					distance, 
		# 					general_conditions, 
		# 					name, 
		# 					number, 
		# 					race_type, 
		# 					result, 
		# 					result_insertion_time, 
		# 					runner_list, 
		# 					time, 
		# 					url,
		# 					value
		# country (lost after upgrade)
		
		race_nb = jsonRace["numExterne"]
		
		#Fetching page
		@logger.info("fetch_race - Fetching race: " + race_nb)
		
		race = fetch_race_shallow(jsonRace, race_nb)
		
		# runner_list
		@logger.debug("fetch_race - Fetching runners.")
		race.runner_list = fetch_runners(meeting_nb, race_nb)
		# @logger.debug("runner_list: " + runner_list.to_s)
		
		return race
	end

	def fetch_race_shallow(jsonRace, race_nb)
		
		# race_type
		race_type_raw = jsonRace["specialite"]
		race_type = @ref_list_hash[:ref_race_type_list][race_type_raw]
		@logger.debug("fetch_race_shallow - race_type: " + race_type.to_s)
		
		# value
		race_type_raw = jsonRace["montantPrix"].to_i
		@logger.debug("fetch_race_shallow - value: " + value.to_s)
		
		# distance
		distance = jsonRace["distance"].to_i
		@logger.debug("fetch_race_shallow - distance: " + distance.to_s)
		
		# bets
		# under "Les plus joues" now
		
		@logger.debug("fetch_race_shallow - bets: " + bets.to_s)
		
		
		# detailed conditions
		detailed_cond = jsonRace["conditions"]
		@logger.debug("fetch_race_shallow - detailed_cond: " + detailed_cond)
		
		# general_conditions (rope & sex_rule)
		# inside div#conditions =>	Courses à conditions - Corde à droite - Terrain bon Détails des conditions
		#							Courses à conditions - Corde à droite - Terrain bon Détails des conditions
		#							Groupe I - Corde à droite Détails des conditions
		#							Inconnu - Corde à gauche Détails des conditions
		rope_raw = jsonRace["corde"]
		race_type = @ref_list_hash[:ref_rope_list][rope_raw]
		
		sex_rule_raw = jsonRace["conditionSexe"]
		race_type = @ref_list_hash[:ref_sex_rule_list][sex_rule_raw]
		
		general_cond_str = rope + " " + sex_rule
		@logger.debug("fetch_race_shallow - general_conditions: " + general_cond_str)
		
		# name
		name = jsonRace["libelle"]
		@logger.debug("fetch_race_shallow - name: " + name)
		
		# number
		number = race_nb
		@logger.debug("fetch_race_shallow - number: " + number.to_s)
		
		# result
		
		@logger.debug("fetch_race_shallow - result: " + result)
						
		# time
		
		time = Time::new(1, 1, 1, date_hours_i, date_min_i)
		@logger.debug("fetch_race_shallow - time: " + 
			time.strftime(@config[:gen][:default_time_format])
		)
		
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
					rope: rope,
					sex_rule: sex_rule,
					time: time,
					url: url,  
					value: value
		)
		
		@logger.debug("fetch_race - race: " + race.to_s)
		return race
	end
	
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