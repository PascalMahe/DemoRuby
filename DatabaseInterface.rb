require 'sqlite3'

class DatabaseInterface
	
	def initialize(logger, database_name, sql_hash)
		@logger = logger
		@db = SQLite3::Database.new (database_name)
		# cf. http://sqlite-ruby.rubyforge.org/sqlite3/faq.html#538670696
		@db.type_translation = true
		# cf. http://sqlite-ruby.rubyforge.org/sqlite3/faq.html#538670736
		@db.results_as_hash = true
		@sql = sql_hash
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
		if statement == nil then
			statement = @db.prepare(query)
		end
		@logger.debug("Executing query : " + query + 
			", with values : " + values_hash.to_s)
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
	def insert_ref_direction(ref_direction)
		ref_direction.id = execute_query(
			@sql[:insert][:refdirection], 
			@stat_insert_refdirection, 
			{:text => ref_direction.text}, 
			true
		)
	end
	
	def insert_ref_track_condition(ref_track_condition)
		ref_track_condition.id = execute_query(
			@sql[:insert][:reftrackcondition], 
			@stat_insert_reftrackcondition, 
			{:text => ref_track_condition.text}, 
			true
		)
	end
	
	def insert_ref_race_type(ref_race_type)
		ref_race_type.id = execute_query(
			@sql[:insert][:refracetype], 
			@stat_insert_refracetype, 
			{:text => ref_race_type.text}, 
			true
		)
	end
	
	def insert_ref_column(ref_column)
		ref_column.id = execute_query(
			@sql[:insert][:refcolumn], 
			@stat_insert_refcolumn, 
			{:text => ref_column.text}, 
			true
		)
	end
	
	def insert_ref_sex(ref_sex)
		ref_sex.id = execute_query(
			@sql[:insert][:refsex], 
			@stat_insert_refsex, 
			{:text => ref_sex.text}, 
			true
		)
	end
	
	def insert_ref_breed(ref_breed)
		ref_breed.id = execute_query(
			@sql[:insert][:refbreed], 
			@stat_insert_refbreed, 
			{:text => ref_breed.text}, 
			true
		)
	end
	
	def insert_ref_coat(ref_coat)
		ref_coat.id = execute_query(
			@sql[:insert][:refcoat], 
			@stat_insert_refcoat, 
			{:text => ref_coat.text}, 
			true
		)
	end
	
	def insert_ref_blinder(ref_blinder)
		ref_blinder.id = execute_query(
			@sql[:insert][:refblinder], 
			@stat_insert_refblinder, 
			{:text => ref_blinder.text}, 
			true
		)
	end
	
	def insert_ref_shoes(ref_shoes)
		ref_shoes.id = execute_query(
			@sql[:insert][:shoes], 
			@stat_insert_shoes, 
			{:text => ref_shoes.text}, 
			true
		)
	end
	
	#BUSINESS
	def insert_weather(weather)
		values_hash = {
			:wind_direction => weather.wind_direction, 
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
			:id_track_condition => meeting.id_track_condition, 
			:id_job => meeting.id_job,
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
		ref_direction_list = {}
		rows = execute_select(
			query,
			statement,
			{}
		)
		rows.each do |row|
			ref_dir = class_to_instanciate.new(row["id"], row["name"])
			ref_direction_list[ref_dir] = ref_dir.id
		end
		return ref_direction_list
	end
	
	def load_ref_direction_list()
		test = RefDirection::new("-1", "test in DatabaseInterface")
		return load_ref_object_list(
			RefDirection, 
			@sql[:select][:refdirectionlist],
			@stat_select_ref_direction_list
		)
	end
	
	#BUSINESS
	def load_job(id)
		job = Job::new
		result_set = execute_select_w_one_result(
			@sql[:select][:job], 
			@stat_select_job, 
			:id => id)
		job.id = id
		job.start_time = result_set["start_time"]
		job.loading_end_time = result_set["loading_end_time"]
		job.crawling_end_time = result_set["crawling_end_time"]
		job.computing_end_time = result_set["computing_end_time"]
		return job
	end
	
end
