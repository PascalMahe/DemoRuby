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
			:name => ref_direction.name, 
			true
		)
	end
	
	def insert_ref_track_condition(track_condition)
		track_condition.id = execute_query(
			@sql[:insert][:reftrackcondition], 
			@stat_insert_reftrackcondition, 
			:name => track_condition.name, 
			true
		)
	end
	
	def insert_ref_race_type(ref_race_type)
		ref_race_type.id = execute_query(
			@sql[:insert][:refracetype], 
			@stat_insert_refracetype, 
			:name => ref_race_type.name, 
			true
		)
	end
	
	def insert_ref_column(ref_column)
		ref_column.id = execute_query(
			@sql[:insert][:refcolumn], 
			@stat_insert_refcolumn, 
			:name => ref_column.name, 
			true
		)
	end
	
	def insert_ref_sex(ref_sex)
		ref_sex.id = execute_query(
			@sql[:insert][:refsex], 
			@stat_insert_refsex, 
			:name => ref_sex.name, 
			true
		)
	end
	
	def insert_ref_breed(ref_breed)
		ref_breed.id = execute_query(
			@sql[:insert][:refbreed], 
			@stat_insert_refbreed, 
			:name => ref_breed.name, 
			true
		)
	end
	
	def insert_ref_coat(ref_coat)
		ref_coat.id = execute_query(
			@sql[:insert][:refcoat], 
			@stat_insert_refcoat, 
			:name => ref_coat.name, 
			true
		)
	end
	
	def insert_ref_blinder(ref_blinder)
		ref_blinder.id = execute_query(
			@sql[:insert][:refblinder], 
			@stat_insert_refblinder, 
			:name => ref_blinder.name, 
			true
		)
	end
	
	def insert_ref_shoes(ref_shoes)
		ref_shoes.id = execute_query(
			@sql[:insert][:shoes], 
			@stat_insert_shoes, 
			:name => ref_shoes.name, 
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
	
	#TODO
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
	
	#LOADING QUERIES
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

