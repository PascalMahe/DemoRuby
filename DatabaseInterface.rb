require 'sqlite3'

class DatabaseInterface
	
	def initialize(logger, database_name, config)
		@logger = logger
		@db = SQLite3::Database.new (database_name)
		# cf. http://sqlite-ruby.rubyforge.org/sqlite3/faq.html#538670696
		@db.type_translation = true
		# cf. http://sqlite-ruby.rubyforge.org/sqlite3/faq.html#538670736
		@db.results_as_hash = true
		@sql = config[:sql]
		@config = config
	end
	
	#For INSERT, UPDATE or DELETE
	def execute_query(query, statement, values_hash, is_insertion)
		if statement == nil then
			statement = @db.prepare(query)
		end
		@logger.debug("Executing query : " + query +
			", with values : " + values_hash.to_s)
		begin
			statement.bind_params(values_hash)
			statement.execute()
			if is_insertion then
				id = @db.last_insert_row_id()
				@logger.debug("Insertion Ok, got ID : " + id.to_s)
				return id
			end
		rescue SQLite3::Exception => e 
			@logger.error "Exception occured"
			@logger.error e
		end
	end
	
	#For SELECT
	def execute_select(query, statement, values_hash)
		if statement == nil then
			statement = @db.prepare(query)
		end
		@logger.debug("Executing query : " + query + ", with values : " + 
			values_hash.to_s)
		begin
			statement.bind_params(values_hash)
			return statement.execute()			
		rescue SQLite3::Exception => e 
			@logger.error "Exception occured"
			@logger.error e
		end
	end
	
	#For SELECT with one result
	def execute_select_w_one_result(query, statement, values_hash)
		@logger.debug("Executing query : " + query + 
			", with values : " + values_hash.to_s)
		if statement == nil then
			statement = @db.prepare(query)
		end
		begin
			statement.bind_params(values_hash)
			return statement.execute().first
		rescue SQLite3::Exception => e 
			@logger.error "Exception occured"
			@logger.error e
		end
	end
	
	def get_table_number()
		return @db.get_first_value(@sql[:select][:master])
	end
	
	def create_tables()
		@sql[:create].each do |query_array|
			execute_query(query_array[1])
		end
	end
	
	#INSERTION QUERIES
	#REF
	def insert_ref_object(ref_class, ref_object)
		query = @sql[:insert][:ref_object] % ref_class
		# Note : the statement is not a attribute of the DatabaseInterface object
		# (not @) because the query can change (query for RefSex, RefBreed...)
		stat_insert_ref_object = @db.prepare(query)
		ref_object.id = execute_query(
			query, 
			stat_insert_ref_object, 
			{:text => ref_object.text}, 
			true
		)
	end
	
	def insert_ref_direction(ref_direction)
		ref_direction.id = execute_query(
			@sql[:insert][:ref_direction], 
			@stat_insert_refdirection, 
			{:text => ref_direction.text}, 
			true
		)
	end
	
	def insert_ref_track_condition(ref_track_condition)
		ref_track_condition.id = execute_query(
			@sql[:insert][:ref_trackcondition], 
			@stat_insert_reftrackcondition, 
			{:text => ref_track_condition.text}, 
			true
		)
	end
	
	def insert_ref_race_type(ref_race_type)
		ref_race_type.id = execute_query(
			@sql[:insert][:ref_racetype], 
			@stat_insert_refracetype, 
			{:text => ref_race_type.text}, 
			true
		)
	end
	
	def insert_ref_column(ref_column)
		ref_column.id = execute_query(
			@sql[:insert][:ref_column], 
			@stat_insert_refcolumn, 
			{:text => ref_column.text}, 
			true
		)
	end
	
	def insert_ref_sex(ref_sex)
		ref_sex.id = execute_query(
			@sql[:insert][:ref_sex], 
			@stat_insert_refsex, 
			{:text => ref_sex.text}, 
			true
		)
	end
	
	def insert_ref_breed(ref_breed)
		ref_breed.id = execute_query(
			@sql[:insert][:ref_breed], 
			@stat_insert_refbreed, 
			{:text => ref_breed.text}, 
			true
		)
	end
	
	def insert_ref_coat(ref_coat)
		ref_coat.id = execute_query(
			@sql[:insert][:ref_coat], 
			@stat_insert_refcoat, 
			{:text => ref_coat.text}, 
			true
		)
	end
	
	def insert_ref_blinder(ref_blinder)
		ref_blinder.id = execute_query(
			@sql[:insert][:ref_blinder], 
			@stat_insert_refblinder, 
			{:text => ref_blinder.text}, 
			true
		)
	end
	
	def insert_ref_shoes(ref_shoes)
		ref_shoes.id = execute_query(
			@sql[:insert][:ref_shoes], 
			@stat_insert_shoes, 
			{:text => ref_shoes.text}, 
			true
		)
	end
	
	#BUSINESS
	def insert_weather(weather)
		values_hash = {
			:wind_direction => weather.wind_direction.id, 
			:temperature => weather.temperature,
			:wind_speed => weather.wind_speed,
			:insolation => weather.insolation
		}
		weather.id = execute_query(
			@sql[:insert][:weather], 
			@stat_insert_weather, 
			values_hash, 
			true
		)
	end
	
	def insert_job(job)
		values_hash = {
			:start_time => job.start_time, 
			:loading_end_time => job.loading_end_time,
			:crawling_end_time => job.crawling_end_time,
			:computing_end_time => job.computing_end_time
		}
		job.id = execute_query(
			@sql[:insert][:job], 
			@stat_insert_job, 
			values_hash, 
			true
		)
	end
	
	def insert_meeting(meeting)
		values_hash = {
			:track_condition => meeting.track_condition.id, 
			:job => meeting.job.id,
			:date => meeting.date,
			:racetrack => meeting.racetrack,
			:number => meeting.number,
			:url => meeting.url
		}
		meeting.id = execute_query(
			@sql[:insert][:meeting], 
			@stat_insert_meeting, 
			values_hash, 
			true
		)
	end
	
	def insert_race(race)
		values_hash = {
			:id_meeting => race.meeting.id, 
			:id_racetype => race.racetype.id,
			:time => race.time,
			:number => race.number, 
			:name => race.name,
			:country => race.country,
			:result => race.result, 
			:distance => race.distance,
			:detailed_conditions => race.detailed_conditions,
			:bets => race.bets,
			:url => race.url,
			:value => race.value
		}
		race.id = execute_query(
			@sql[:insert][:race], 
			@stat_insert_race, 
			values_hash, 
			true
		)
	end
	
	def insert_forecast(forecast)
		values_hash = {
			:id_race => forecast.race.id, 
			:id_origin => forecast.origin.id,
			:expected_result => forecast.expected_result
		}
		forecast.id = execute_query(
			@sql[:insert][:forecast], 
			@stat_insert_forecast, 
			values_hash, 
			true
		)
	end
	
	def insert_weight(weight)
		values_hash = {
			:id_forecast => weight.forecast.id, 
			:name => weight.name,
			:value => weight.value
		}
		weight.id = execute_query(
			@sql[:insert][:weight], 
			@stat_insert_weight, 
			values_hash, 
			true
		)
	end
	
	def insert_origin(origin)
		values_hash = {
			:name => origin.name, 
			:column_order => origin.column_order,
			:url => origin.url
		}
		origin.id = execute_query(
			@sql[:insert][:origin], 
			@stat_insert_origin, 
			values_hash, 
			true
		)
	end
	
	def insert_jockey(jockey)
		values_hash = {
			:name => jockey.name, 
			:column_order => jockey.column_order,
			:url => jockey.url
		}
		jockey.id = execute_query(
			@sql[:insert][:jockey], 
			@stat_insert_jockey, 
			values_hash, 
			true
		)
	end
	
	def insert_trainer(trainer)
		values_hash = {
			:name => trainer.name
		}
		trainer.id = execute_query(
			@sql[:insert][:trainer], 
			@stat_insert_trainer, 
			values_hash, 
			true
		)
	end
	
	def insert_owner(owner)
		values_hash = {
			:name => owner.name
		}
		owner.id = execute_query(
			@sql[:insert][:owner], 
			@stat_insert_owner, 
			values_hash, 
			true
		)
	end
	
	def insert_breeder(breeder)
		values_hash = {
			:name => breeder.name
		}
		breeder.id = execute_query(
			@sql[:insert][:breeder], 
			@stat_insert_owner, 
			values_hash, 
			true
		)
	end
	
	def insert_horse(horse)
		values_hash = {
			:id_sex => horse.sex.id, 
			:id_breed => horse.breed.id,
			:id_coat => horse.coat.id,
			:name => horse.name
		}
		horse.id = execute_query(
			@sql[:insert][:horse], 
			@stat_insert_horse, 
			values_hash, 
			true
		)
	end
	
	def insert_runner(runner)
		values_hash = {
			:id_race => runner.race.id, 
			:id_horse => runner.horse.id,
			:id_jockey => runner.jockey.id,
			:id_trainer => runner.trainer.id, 
			:id_owner => runner.owner.id,
			:id_breeder => runner.breeder.id,
			:id_blinder => runner.blinder.id, 
			:id_shoes => runner.shoes.id,
			:number => runner.number,
			:draw => runner.draw, 
			:single_rating => runner.single_rating,
			:non_runner => runner.non_runner,
			:races_run => runner.races_run, 
			:victories => runner.victories,
			:places => runner.places,
			:earnings_career => runner.earnings_career, 
			:earnings_current_year => runner.earnings_current_year,
			:earnings_last_year => runner.earnings_last_year,
			:earnings_victory => runner.earnings_victory, 
			:description => runner.description,
			:distance => runner.distance,
			:load => runner.load, 
			:history => runner.history,
			:url => runner.url
		}
		runner.id = execute_query(
			@sql[:insert][:runner], 
			@stat_insert_runner, 
			values_hash, 
			true
		)
	end
	
	#UPDATE
	#race : update result & result_insertion_time
	def update_race_with_result(race)
		values_hash = {
			:result => race.result,
			:result_insertion_time => 'now',
			:id => race.id
		}
		execute_query(
			@sql[:update][:race], 
			@stat_update_race, 
			values_hash, 
			false
		)
	end
	
	#runner :final_place
	def update_runner_with_final_place(runner)
		values_hash = {
			:final_place => runner.final_place,
			:id => runner.id
		}
		execute_query(
			@sql[:update][:runner], 
			@stat_update_runner, 
			values_hash, 
			false
		)
	end
	
	#forecast : result_match_rate & normalised_result_match_rate
	def update_runner_with_match_rate(forecast)
		values_hash = {
			:result_match_rate => forecast.result_match_rate,
			:normalised_result_match_rate => forecast.normalised_result_match_rate,
			:id => forecast.id
		}
		execute_query(
			@sql[:update][:forecast], 
			@stat_update_forecast, 
			values_hash, 
			false
		)
	end
	
	#LOADING QUERIES
	#REFERENCE OBJECT LISTS
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
	
	def load_ref_direction_list()
		return load_ref_object_list(
			RefDirection, 
			@sql[:select][:ref_direction_list],
			@stat_select_ref_direction_list
		)
	end
	
	def load_ref_track_condition_list()
		return load_ref_object_list(
			RefTrackCondition, 
			@sql[:select][:ref_trackcondition_list],
			@stat_select_ref_track_condition
		)
	end
	
	def load_ref_race_type_list()
		return load_ref_object_list(
			RefRaceType, 
			@sql[:select][:ref_racetype_list],
			@stat_select_ref_race_type_list
		)
	end
	
	def load_ref_column_list()
		return load_ref_object_list(
			RefColumn, 
			@sql[:select][:ref_column_list],
			@stat_select_ref_column_list
		)
	end
	
	def load_ref_sex_list()
		return load_ref_object_list(
			RefSex, 
			@sql[:select][:ref_sex_list],
			@stat_select_ref_sex_list
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
	
	def load_ref_blinder_list()
		return load_ref_object_list(
			RefBlinder, 
			@sql[:select][:ref_blinder_list],
			@stat_select_ref_blinder_list
		)
	end
	
	def load_ref_shoes_list()
		return load_ref_object_list(
			RefShoes, 
			@sql[:select][:ref_shoes_list],
			@stat_select_ref_shoes_list
		)
	end
	
	def load_all_refs()
		@logger.info("Loading all reference objects")
		@logger.info("RefDirection")
		ref_dir_list = load_ref_direction_list()
		@logger.debug(ref_dir_list.to_s)

		@logger.info("RefTrackCondition")
		ref_track_condition_list = load_ref_track_condition_list()
		@logger.debug(ref_track_condition_list)

		@logger.info("RefRaceType")
		ref_race_type_list = load_ref_race_type_list()
		@logger.debug(ref_race_type_list)

		@logger.info("RefColumn")
		ref_column_list = load_ref_column_list()
		@logger.debug(ref_column_list)

		@logger.info("RefSex")
		ref_sex_list = load_ref_sex_list()
		@logger.debug(ref_sex_list)

		@logger.info("RefBreed")
		ref_breed_list = load_ref_breed_list()
		@logger.debug(ref_breed_list)

		@logger.info("RefCoat")
		ref_coat_list = load_ref_coat_list()
		@logger.debug(ref_coat_list)

		@logger.info("RefBlinder")
		ref_blinder_list = load_ref_blinder_list()
		@logger.debug(ref_blinder_list)

		@logger.info("RefShoes")
		ref_shoes_list = load_ref_shoes_list()
		@logger.debug(ref_shoes_list)

		@ref_list_hash = {
			:ref_direction_list => ref_dir_list,
			:ref_trackcondition_list => ref_track_condition_list,
			:ref_racetype_list => ref_race_type_list,
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
	def load_job_by_id(id)
		job = Job::new
		result_set = execute_select_w_one_result(
			@sql[:select][:job_by_id], 
			@stat_select_job_by_id, 
			:id => id)
		job.id = id
		job.start_time = result_set["start_time"]
			.strftime(@config[:gen][:default_date_format])
		job.loading_end_time = result_set["loading_end_time"]
			.strftime(@config[:gen][:default_date_format])
		job.crawling_end_time = result_set["crawling_end_time"]
			.strftime(@config[:gen][:default_date_format])
		job.computing_end_time = result_set["computing_end_time"]
			.strftime(@config[:gen][:default_date_format])
		return job
	end
	
	def load_weather_by_id(id)
		weather = Weather::new
		result_set = execute_select_w_one_result(
			@sql[:select][:weather_by_id], 
			@stat_select_weather_by_id, 
			:id => id)
			
		weather.id = id
		weather.temperature = result_set["temperature"]
		weather.wind_speed = result_set["wind_speed"]
		weather.insolation = result_set["insolation"]
		# Wind_direction : get from RefDirection list
		wind_direction_id = result_set["id_wind_direction"]
		wind_direction = @ref_list_hash[:ref_direction_list].get(wind_direction_id)
		weather.wind_direction = wind_direction
		
		return weather
	end
	
	def load_meeting_by_id(id)
		meeting = Meeting::new
		result_set = execute_select_w_one_result(
			@sql[:select][:meeting_by_id], 
			@stat_select_meeting_by_id, 
			:id => id)
		meeting.id = id
		
		meeting.id = id
		meeting.date = result_set["date"]
		meeting.racetrack = result_set["racetrack"]
		meeting.number = result_set["number"]
		meeting.url = result_set["url"]
		# track_condition : get from RefTrackCondition list
		track_condition_id = result_set["id_track_condition"]
		track_condition = @ref_list_hash[:ref_trackcondition_list].get(track_condition_id)
		meeting.track_condition = track_condition
		
		# job : loaded from database
		job_id = result_set["id_job"]
		job = load_job_by_id(job_id)
		meeting.job = job
		return meeting
	end
end
