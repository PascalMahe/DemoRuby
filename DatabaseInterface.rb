require 'sqlite3'

class DatabaseInterface
	
	def initialize(logger, database_name, sql_hash)
		@logger = logger
		@db = SQLite3::Database.new (database_name)
		@db.type_translation = true
		@sql = sql_hash
	end
	
	def execute_query(query)
		begin
			@logger.info("Executing query : '" + query.to_s + "'")
			@db.execute(query)
		rescue SQLite3::Exception => e 
			@logger.error "Exception occured"
			@logger.error e
		end
	end
	
	def insert_job(job)
		if @stat_insert_job == nil then
			@stat_insert_job = @db.prepare(@sql[:insert][:job])
		end
		values_hash = {
			"start_time" => job.start_time, 
			"loading_end_time" => job.loading_end_time,
			"crawling_end_time" => job.crawling_end_time,
			"computing_end_time" => job.computing_end_time
		}
		@logger.debug("Executing job insertion query : " + @sql[:insert][:job] + ", with values : " + values_hash.to_s)
		@stat_insert_job.bind_params(values_hash)
		@stat_insert_job.execute()
		job.id = @db.last_insert_row_id()
		@logger.info("Inserted Job, id = " + job.id.to_s)
	end
	
	def get_table_number()
		return @db.get_first_value(@sql[:select][:master])
	end
	
	def create_tables()
		@sql[:create].each do |query_array|
			execute_query(query_array[1])
		end
	end
	
end

