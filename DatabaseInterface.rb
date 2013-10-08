class DatabaseInterface
	
	def initialize(logger, database)
		@logger = logger
		@db = database
	end
	
	def execute_query(query)
		begin
			@logger.info("Executing query : '" + query + "'")
			db.execute(query)
		rescue SQLite3::Exception => e 
			@logger.error "Exception occured"
			@logger.error e
		end
	end
end

