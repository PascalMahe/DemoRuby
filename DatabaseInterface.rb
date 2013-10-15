require 'sqlite3'

class DatabaseInterface
	
	def initialize(logger, database_name, sql_hash)
		@logger = logger
		@db = SQLite3::Database.new (database_name)
		@sql = sql_hash
	end
	
	def execute_query(query)
		begin
			@logger.info("Executing query : '" + query + "'")
			@db.execute(query)
		rescue SQLite3::Exception => e 
			@logger.error "Exception occured"
			@logger.error e
		end
	end
	
	def insert_job(job)
		if @stat_insert_job == nil then
			@stat_insert_job = @db.prepare(@sql["insert"]["job"])
		end
		@stat_insert_job.execute(
			"start_time" => job.start_time, 
			"loading_end_time" => job.loading_end_time,
			"crawling_end_time" => job.crawling_end_time,
			"computing_end_time" => job.computing_end_time,
		)
		job.id = @db.last_insert_row_id()
		@logger.info("Inserted Job, id = " + job.id)
	end
	
end

