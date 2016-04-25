require 'sqlite3'
require 'date'
require './ref.rb'

class DatabaseInterface
	
	def initialize(config, is_test, logger)
		
		if is_test then
			db_name = config[:gen][:test_database_name]
		else 
			db_name = config[:gen][:database_name]
		end
		@db = SQLite3::Database.new (db_name)
		# cf. http://sqlite-ruby.rubyforge.org/sqlite3/faq.html#538670696
		@db.type_translation = true
		# cf. http://sqlite-ruby.rubyforge.org/sqlite3/faq.html#538670736
		@db.results_as_hash = true
		
		@sql = config[:sql]
		@config = config
		@logger = logger
	end
	
	def log_nicely(message_header, query, values_hash = nil)
		log_message = message_header + query
		if values_hash != nil and not values_hash.empty? then
			log_message = log_message + "; with values : " + values_hash.to_s
		end
		@logger.debug(log_message)
	end
	
	def transaction_active?
		return @db.transaction_active?
	end
	
	# To avoid RuntimeError: can't prepare FalseClass (or TrueClass)
	# in execute_query
	def boolean_cleanup(values_hash)
		if values_hash != nil then
			values_hash.each do |key, value|
				if value == true then
					values_hash[key] = 1
				end
				if value == false then
					values_hash[key] = 0
				end
			end
		end
	end
	
	def boolean_load(non_boolean_value)
		boolean_return = nil
		if non_boolean_value != nil then
			boolean_return = false
			if non_boolean_value == 1 then
				boolean_return = true
			end
		end
		return boolean_return
	end
	
	# To avoid problems with timezones
	# -> put everything in UTC before interacting
	# with Sqlite
	def date_cleanup(values_hash)
		if values_hash != nil then
			values_hash.each do |key, value|
				if value.respond_to? :to_time then
					# @logger.debug("date_cleanup - timey value : " + value.strftime(@config[:gen][:database_date_time_format]))
					utc_time_value_as_str = value.to_time.utc.strftime(@config[:gen][:database_date_time_format])
					# @logger.debug("date_cleanup - UTC time value : " + utc_time_value_as_str)
					# if the value has the to_time method
					values_hash[key] = utc_time_value_as_str
				end
			end
		end
	end
	
	#For INSERT, UPDATE or DELETE
	def execute_query(query, statement = nil, values_hash = nil, is_insertion = nil)
		# Cleanups
		boolean_cleanup(values_hash)
		date_cleanup(values_hash)
		
		log_nicely("execute_query - Executing query: ", query, values_hash)
		
		if statement == nil then
			statement = @db.prepare(query)
		end
		begin
			if values_hash != nil then
				statement.bind_params(values_hash)
			end
			statement.execute() 
			if is_insertion then
				id = @db.last_insert_row_id()
				@logger.debug("Insertion Ok; got ID : " + id.to_s)
				return id
			end
		rescue SQLite3::BusyException => e 
			@logger.error "BusyException occured in DatabaseInterface.execute_query"
			@logger.error e.to_s
		rescue SQLite3::LockedException => e 
			@logger.error "LockedException occured in DatabaseInterface.execute_query"
			@logger.error e.to_s
		end
	end
	
	#For SELECT
	def execute_select(query, statement, values_hash)
		if statement == nil then
			statement = @db.prepare(query)
		end
		
		# log_nicely("execute_select - Executing query: ", query, values_hash)
		
		begin
			statement.bind_params(values_hash)
			return statement.execute()			
		rescue SQLite3::Exception => e 
			@logger.error "Exception occured in DatabaseInterface.execute_select"
			@logger.error e
		end
	end
	
	#For SELECT with one result
	def execute_select_w_one_result(query, statement, values_hash)
		
		# Cleanups
		date_cleanup(values_hash)
		
		log_nicely("execute_select_w_one_result - Fetching first result of query : ", query, values_hash)
			
		if statement == nil then
			statement = @db.prepare(query)			
		end
		
		begin
			if values_hash != nil then
				statement.bind_params(values_hash)
			end
			result_set = statement.execute
			
			row = result_set.next
			
			result_set.close
			
			return row
		rescue SQLite3::Exception => e 
			@logger.error "Exception occured in DatabaseInterface.execute_select_w_one_result"
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
	
	def drop_tables()
		@sql[:drop].each do |query_array|
			execute_query(query_array[1])
		end
	end
	
	def clean_tables()
		@sql[:clean].each do |query_array|
			execute_query(query_array[1])
		end
	end
	
	# GENERAL QUERIES
	
	# Select count(*) from one table
	def select_count_from_table(table)
		
		query = @sql[:gen][:count_all]
		
		@logger.debug("select_count_from_table - Counting rows in: " + table.to_s)
		
		# Replace :table parameter in query with table
		# For security reasons, checking if table is in the table list
		if @config[:gen][:table_names].has_value?(table) then
			query = query.gsub(':table', table)
			
			# Note : the statement is not a attribute of the DatabaseInterface object
			# (not @) because the query can change (query for RefSex, Breeder...)
			stat_select_count = @db.prepare(query)
					
			row = execute_select_w_one_result(
				query, 
				stat_select_count, 
				nil
			)
			count = row["COUNT (*)"]
		else
			@logger.info("select_count_from_table - " + table.to_s + " is not in the table list. " + 
						"Returning 0.")
			count = 0
		end
		
		@logger.debug("select_count_from_table - Found " + count.to_s)
		return count
	end
	
	# Detect duplicate texts in RefTables
	def detect_duplicates(refTable)
		
		query = @sql[:gen][:duplicate_detection]
		
		# @logger.debug("detect_duplicates - Getting IDs that are duplicates in: " + refTable.to_s)
		id_list = []
		
		query = query.gsub(':table', refTable.to_s)
			
		# Note : the statement is not a attribute of the DatabaseInterface object
		# (not @) because the query can change (query for RefSex, Breeder...)
		stat_duplicates = @db.prepare(query)
				
		result_set = execute_select(
			query, 
			stat_duplicates, 
			{}
		)
		
		row = result_set.next
		while row != nil do
			id = row["ID"]
			id_list.push(id)
			row = result_set.next
		end
		result_set.close
		
		
		plural = ""
		if id_list.size > 1 then
			plural = "s"
		end
		# @logger.debug("detect_duplicates - Found " + id_list.size.to_s + " duplicate"  + 
		#				 plural + " in " + refTable.to_s + ".")
		return id_list
	end
end
