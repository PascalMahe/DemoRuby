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
		@logger.debug("Executing query : " + query + ", with values : " + values_hash.to_s)
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
		@logger.debug("Executing query : " + query + ", with values : " + values_hash.to_s)
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
		@logger.debug("Executing query : " + query + ", with values : " + values_hash.to_s)
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
	
	def insert_job(job)
		values_hash = {
			:start_time => job.start_time, 
			:loading_end_time => job.loading_end_time,
			:crawling_end_time => job.crawling_end_time,
			:computing_end_time => job.computing_end_time
		}
		job.id = execute_query(@sql[:insert][:job], @stat_insert_job, values_hash, true)
	end
	
	def load_job(id)
		job = Job::new
		result_set = execute_select_w_one_result(@sql[:select][:job], @stat_select_job, :id => id)
		job.id = id
		job.start_time = result_set["start_time"]
		job.loading_end_time = result_set["loading_end_time"]
		job.crawling_end_time = result_set["crawling_end_time"]
		job.computing_end_time = result_set["computing_end_time"]
		return job
	end
	
end

