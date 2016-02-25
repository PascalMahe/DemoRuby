require 'sqlite3'
require 'date'
require './ref.rb'
require './DatabaseInterface.rb'

class DatabaseInterfaceSelectByTechId < DatabaseInterface
	# row to object methods
	
	def create_runner_from_row(row, parent_race: nil)
		# Blinder : get from RefBlinder list
		blinder_id = row["id_blinder"]
		blinder = @ref_list_hash[:ref_blinder_list].get(blinder_id)
		
		# Breeder
		breeder_id = row["id_breeder"]
		breeder = load_breeder_by_id(breeder_id)
		
		# Horse
		horse_id = row["id_horse"]
		horse = load_horse_by_id(horse_id)
		
		# Jockey
		jockey_id = row["id_jockey"]
		jockey = load_jockey_by_id(jockey_id)
		
		# Owner
		owner_id = row["id_owner"]
		owner = load_owner_by_id(owner_id)
		
		# Race
		# avoiding infinite loop by providing the race
		# (and thus avoiding to load the race, that then
		# loads the runner that loads the race...)
		if parent_race == nil then
			race_id = row["id_race"]
			race = load_race_by_id(race_id)
		else
			race = parent_race
		end
		
		# Shoes : get from RefShoes list
		shoes_id = row["id_shoes"]
		shoes = @ref_list_hash[:ref_shoes_list].get(shoes_id)
		
		# Trainer
		trainer_id = row["id_trainer"]
		trainer = load_trainer_by_id(trainer_id)
		
		disqualified = boolean_load(row["disqualified"])
		is_favorite = boolean_load(row["is_favorite"])
		is_non_runner = boolean_load(row["is_non_runner"])
		is_substitute = boolean_load(row["is_substitute"])
		
		runner = Runner::new(
			age: row["age"],
			blinder: blinder,
			breeder: breeder,
			commentary: row["commentary"],
			description: row["description"],
			disqualified: disqualified,
			distance: row["distance"],
			draw: row["draw"],
			earnings_career: row["earnings_career"],
			earnings_current_year: row["earnings_current_year"],
			earnings_last_year: row["earnings_last_year"],
			earnings_victory: row["earnings_victory"],
			final_place: row["final_place"],
			history: row["history"],
			horse: horse,
			id: row["id_runner"],
			is_favorite: is_favorite,
			is_non_runner: is_non_runner,
			is_substitute: is_substitute,
			jockey: jockey,
			load_handicap: row["load_handicap"],
			load_ride: row["load_ride"],
			number: row["number"],
			owner: owner,
			places: row["places"],
			race: race,
			races_run: row["races_run"],
			shoes: shoes,
			single_rating_after_race: row["single_rating_after_race"],
			single_rating_before_race: row["single_rating_before_race"],
			time: row["time"],
			trainer: trainer,
			url: row["url"],
			victories: row["victories"])
		
		return runner
	end
	
	# LOADING QUERIES
	# REFERENCE OBJECT LISTS
	def load_ref_object_list(class_to_instanciate, query, statement)
		ref_object_list = RefObjectContainer.new(class_to_instanciate, self)
		rows = execute_select(
			query,
			statement,
			{}
		)
		rows.each do |row|
			ref_dir = class_to_instanciate.new(row["id"], row["text"])
			ref_object_list[ref_dir.text] = ref_dir
		end
		return ref_object_list
	end
		
	def load_ref_blinder_list()
		return load_ref_object_list(
			RefBlinder, 
			@sql[:select][:ref_blinder_list],
			@stat_select_ref_blinder_list
		)
	end
	
	def load_ref_breed_list()
		return load_ref_object_list(
			RefBreed, 
			@sql[:select][:ref_breed_list],
			@stat_select_ref_breed_list
		)
	end
	
	def load_ref_coat_list()
		return load_ref_object_list(
			RefCoat, 
			@sql[:select][:ref_coat_list],
			@stat_select_ref_coat_list
		)
	end
	
	def load_ref_column_list()
		return load_ref_object_list(
			RefColumn, 
			@sql[:select][:ref_column_list],
			@stat_select_ref_column_list
		)
	end
		
	def load_ref_direction_list()
		return load_ref_object_list(
			RefDirection, 
			@sql[:select][:ref_direction_list],
			@stat_select_ref_direction_list
		)
	end
	
	def load_ref_race_type_list()
		return load_ref_object_list(
			RefRaceType, 
			@sql[:select][:ref_race_type_list],
			@stat_select_ref_race_type_list
		)
	end
	
	def load_ref_sex_list()
		return load_ref_object_list(
			RefSex, 
			@sql[:select][:ref_sex_list],
			@stat_select_ref_sex_list
		)
	end
	
	def load_ref_shoes_list()
		return load_ref_object_list(
			RefShoes, 
			@sql[:select][:ref_shoes_list],
			@stat_select_ref_shoes_list
		)
	end
	
	def load_ref_track_condition_list()
		return load_ref_object_list(
			RefTrackCondition, 
			@sql[:select][:ref_track_condition_list],
			@stat_select_ref_track_condition
		)
	end
	
	def load_all_refs()
		@logger.info("Loading all reference objects")
		# @logger.info("RefDirection")
		ref_dir_list = load_ref_direction_list()
		# @logger.debug(ref_dir_list.to_s)

		# @logger.info("RefTrackCondition")
		ref_track_condition_list = load_ref_track_condition_list()
		# @logger.debug(ref_track_condition_list)

		# @logger.info("RefRaceType")
		ref_race_type_list = load_ref_race_type_list()
		# @logger.debug(ref_race_type_list)

		# @logger.info("RefColumn")
		ref_column_list = load_ref_column_list()
		# @logger.debug(ref_column_list)

		# @logger.info("RefSex")
		ref_sex_list = load_ref_sex_list()
		# @logger.debug(ref_sex_list)

		# @logger.info("RefBreed")
		ref_breed_list = load_ref_breed_list()
		# @logger.debug(ref_breed_list)

		# @logger.info("RefCoat")
		ref_coat_list = load_ref_coat_list()
		# @logger.debug(ref_coat_list)

		# @logger.info("RefBlinder")
		ref_blinder_list = load_ref_blinder_list()
		# @logger.debug(ref_blinder_list)

		# @logger.info("RefShoes")
		ref_shoes_list = load_ref_shoes_list()
		# @logger.debug(ref_shoes_list)

		@ref_list_hash = {
			:ref_direction_list => ref_dir_list,
			:ref_track_condition_list => ref_track_condition_list,
			:ref_race_type_list => ref_race_type_list,
			:ref_column_list => ref_column_list,
			:ref_sex_list => ref_sex_list,
			:ref_breed_list => ref_breed_list,
			:ref_coat_list => ref_coat_list,
			:ref_blinder_list => ref_blinder_list,
			:ref_shoes_list => ref_shoes_list	
		}
		return @ref_list_hash
	end
	
	#BUSINESS
	def load_breeder_by_id(id)
		breeder = Breeder::new
		row = execute_select_w_one_result(
			@sql[:select][:breeder_by_id], 
			@stat_select_breeder_by_id, 
			:id => id)
		if row != nil then
			breeder.id = id
			breeder.name = row["name"]
		else 
			breeder = nil
		end
		return breeder
	end
	
	def load_forecast_by_id(id)
		forecast = Forecast::new
		row = execute_select_w_one_result(
			@sql[:select][:forecast_by_id], 
			@stat_select_forecast_by_id, 
			:id => id)
		@logger.debug(row)
		
		if row != nil then
		
			forecast.id = id
			forecast.expected_result = row["expected_result"]
			forecast.result_match_rate = row["result_match_rate"]
			forecast.normalised_result_match_rate = row["normalised_result_match_rate"]
			
			#race : loaded from database
			race_id = row["id_race"]
			race = load_race_by_id(race_id)
			forecast.race = race
			
			#origin : loaded from database
			origin_id = row["id_origin"]
			origin = load_origin_by_id(origin_id)
			forecast.origin = origin
		else 
			forecast = nil
		end
		return forecast
	end
	
	def load_horse_by_id(id)
		horse = Horse::new
		row = execute_select_w_one_result(
			@sql[:select][:horse_by_id], 
			@stat_select_horse_by_id, 
			:id => id)
		if row != nil then
			horse.id = id
		
			horse.name = row["name"]
			# sex : get from RefSex list
			sex_id = row["id_sex"]
			sex = @ref_list_hash[:ref_sex_list].get(sex_id)
			horse.sex = sex
			# coat : get from RefCoatlist
			coat_id = row["id_coat"]
			coat = @ref_list_hash[:ref_coat_list].get(coat_id)
			horse.coat = coat
			# breed : get from RefBreed list
			breed_id = row["id_breed"]
			breed = @ref_list_hash[:ref_breed_list].get(breed_id)
			horse.breed = breed
			
			# father
			father_id = row["id_father"]
			@logger.debug("load_horse_by_id - father_id : " + father_id.to_s)
			if father_id != nil and father_id != "" then
				@logger.debug("load_horse_by_id - fetching father (#" + father_id.to_s + ")")
				horse.father = load_horse_by_id(father_id)
			end
			
			# mother
			mother_id = row["id_mother"]
			@logger.debug("load_horse_by_id - mother_id : " + mother_id.to_s)
			if mother_id != nil and mother_id != "" then
				@logger.debug("load_horse_by_id - fetching mother (#" + mother_id.to_s + ")")
				horse.mother = load_horse_by_id(mother_id)
			end
		else 
			horse = nil
		end	
		
		return horse
	end
	
	def load_job_by_id(id)
		job = Job::new
		row = execute_select_w_one_result(
			@sql[:select][:job_by_id], 
			@stat_select_job_by_id, 
			:id => id)
		if row != nil then
			job.id = id
			job.start_time = row["start_time"]
			# job.start_time = DateTime.parse(row["start_time"], @config[:gen][:database_date_time_format])
			job.loading_end_time = row["loading_end_time"]
			job.crawling_end_time = row["crawling_end_time"]
			job.computing_end_time = row["computing_end_time"]
		else 
			job = nil
		end		
		return job
	end
	
	def load_jockey_by_id(id)
		jockey = Jockey::new
		row = execute_select_w_one_result(
			@sql[:select][:jockey_by_id], 
			@stat_select_jockey_by_id, 
			:id => id)
		if row != nil then
			jockey.id = id
			jockey.name = row["name"]
			jockey.jacket = row["jacket"]
		else 
			jockey = nil
		end		
		
		return jockey
	end

	def load_meeting_by_id(id)
		
		row = execute_select_w_one_result(
			@sql[:select][:meeting_by_id], 
			@stat_select_meeting_by_id, 
			:id => id)
		
		if row != nil then
			country = row["country"]
			date = row["date"]
			racetrack = row["racetrack"]
			number = row["number"]
			
			# job : loaded from database
			job_id = row["id_job"]
			job = load_job_by_id(job_id)
			
			# weather : loaded from database
			weather_id = row["id_weather"]
			weather = load_weather_by_id(weather_id)
			
			# track_condition : get from RefTrackCondition list
			track_condition_id = row["id_track_condition"]
			track_condition = @ref_list_hash[:ref_track_condition_list].get(track_condition_id)
			
			meeting = Meeting::new(
						country: country, 
						date: date, 
						job: job, 
						number: number, 
						racetrack: racetrack, 
						urls_of_races_array: nil, 
						track_condition: track_condition,
						weather: weather)
			meeting.id = id
		else 
			meeting = nil
		end		
		return meeting
	end
		
	def load_origin_by_id(id)
		origin = Origin::new
		row = execute_select_w_one_result(
			@sql[:select][:origin_by_id], 
			@stat_select_origin_by_id, 
			:id => id)
			
		if row != nil then
			origin.id = id
			origin.name = row["name"]
			origin.column_order = row["column_order"]
			origin.url = row["url"]
		else 
			origin = nil
		end	
		return origin
	end
	
	def load_owner_by_id(id)
		owner = Owner::new
		row = execute_select_w_one_result(
			@sql[:select][:owner_by_id], 
			@stat_select_owner_by_id, 
			:id => id)
		if row != nil then
			owner.id = id
			owner.name = row["name"]
		else 
			owner = nil
		end	
			
		return owner
	end

	
	def load_race_by_id(id)
		
		row = execute_select_w_one_result(
			@sql[:select][:race_by_id], 
			@stat_select_race_by_id, 
			:id => id)
		
		if row != nil then
			# simple values
			bets = row["bets"]
			detailed_conditions = row["detailed_conditions"]
			distance = row["distance"]
			general_conditions = row["general_conditions"]
			name = row["name"]
			number = row["number"]
			result = row["result"]
			result_insertion_time = row["result_insertion_time"]
			# TODO convert from UTC to local time
			if result_insertion_time != nil then
			
				@logger.debug("load_race_by_id - result_insertion_time : " + result_insertion_time.to_s)
				result_insertion_time = result_insertion_time.to_time
				@logger.debug("load_race_by_id - result_insertion_time (after .to_time) : " + result_insertion_time.to_s)
				@logger.debug("load_race_by_id - result_insertion_time.utc? " + result_insertion_time.utc?.to_s)
				if result_insertion_time.utc? then
					result_insertion_time = result_insertion_time.localtime
					@logger.debug("load_race_by_id - result_insertion_time (after .localtime) : " + result_insertion_time.to_s)
				end
				
			end
			# result_insertion_time = Time.parse(str_result_insertion_time, 
												# @config[:gen][:database_date_time_format])
			time = row["time"]
			url = row["url"]
			value = row["value"]
			
			# race_type : get from RefRaceType list
			race_type_id = row["id_race_type"]
			race_type = @ref_list_hash[:ref_race_type_list].get(race_type_id)
			
			# objects
			meeting_id = row["id_meeting"]
			meeting = load_meeting_by_id(meeting_id)
			
			race = Race::new(	bets: bets,
								detailed_conditions: detailed_conditions,
								distance: distance, 
								general_conditions: general_conditions,
								id: id,
								meeting: meeting, 
								name: name, 
								number: number, 
								race_type: race_type, 
								result: result, 
								result_insertion_time: result_insertion_time, 
								time: time, 
								url: url, 
								value: value)
			
			# runner_list
			runner_list = load_runner_list_by_race(race)
			race.runner_list = runner_list
		else 
			race = nil
		end
		return race
	end
	
	def load_runner_by_id(id)
		runner = nil
		row = execute_select_w_one_result(
			@sql[:select][:runner_by_id], 
			@stat_select_runner_by_id, 
			:id => id)
		
		if row != nil then
			runner = create_runner_from_row(row)
		else 
			runner = nil
		end
		return runner
	end
	
	def load_runner_list_by_race(race)
		result_set = execute_select(
			@sql[:select][:runner_by_race_id], 
			@stat_select_runner_by_race_id, 
			:id => race.id)
		
		runner_list = []
		row = result_set.next
		while row != nil do
			runner = create_runner_from_row(row, parent_race: race)
			@logger.debug("load_runner_list_by_race - got Runner#" + 
				runner.id.to_s)
			runner_list.push(runner)
			row = result_set.next
		end
		result_set.close
		
		# if no results, return nil
		if runner_list.size == 0 then
			runner_list = nil
		end
		return runner_list
	end
	
	def load_trainer_by_id(id)
		trainer = Trainer::new
		row = execute_select_w_one_result(
			@sql[:select][:trainer_by_id], 
			@stat_select_trainer_by_id, 
			:id => id)
			
		if row != nil then
			trainer.id = id
			trainer.name = row["name"]
		else
			trainer = nil
		end
		return trainer
	end
	
	def load_weather_by_id(id)
		
		row = execute_select_w_one_result(
			@sql[:select][:weather_by_id], 
			@stat_select_weather_by_id, 
			:id => id)
		
		if row != nil then
			temperature = row["temperature"]
			wind_speed = row["wind_speed"]
			insolation = row["insolation"]
			# Wind_direction : get from RefDirection list
			wind_direction_id = row["id_wind_direction"]
			wind_direction = @ref_list_hash[:ref_direction_list].get(wind_direction_id)
			
			weather = Weather::new(insolation: insolation, temperature: temperature, wind_direction: wind_direction, wind_speed: wind_speed)
			weather.id = id
		else
			weather = nil
		end
		return weather
	end
	
	def load_weight_by_id(id)
		weight = Weight::new
		row = execute_select_w_one_result(
			@sql[:select][:weight_by_id], 
			@stat_select_weight_by_id, 
			:id => id)
			
		if row != nil then
			weight.id = id
			weight.name = row["name"]
			weight.value = row["value"]
			
			# Forecast
			forecast_id = row["id_forecast"]
			forecast = load_forecast_by_id(forecast_id)
			weight.forecast = forecast
		else
			weight = nil
		end
		return weight
	end
	
	# Select last ID from one table
	def select_last_id_from_table(table)
		
		query = @sql[:gen][:last_id]
		
		# Replace :table parameter in query with table
		# For security reasons, checking if table is in the table list
		if @config[:gen][:table_names].has_value?(table) then
			query = query.gsub(':table', table)
		end
		
		# Note : the statement is not a attribute of the DatabaseInterface object
		# (not @) because the query can change (query for RefSex, Breeder...)
		stat_select_count = @db.prepare(query)
				
		row = execute_select_w_one_result(
			query, 
			stat_select_count, 
			nil
		)
		last_id = row["MAX(id_" + table + ")"]
		@logger.debug("Got #" + last_id.to_s)
		return last_id
	end
	
end
