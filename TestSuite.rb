require 'minitest'
require 'minitest/autorun'

require './common.rb'
require './SimpleHtmlLogger.rb'
require './Crawler.rb'
 
class TestSuite < MiniTest::Test
	attr_accessor :sql_test
	attr_accessor :ref_list_hash
	attr_accessor :state
	
	##########################
	# Setup before any tests #
	##########################
	
	path_to_log = ""
	# Starting in debug to erase old test file
	log_level = SimpleHtmlLogger::DEBUG
	is_test = true
	$globalState = GlobalState::new(is_test, log_level, path_to_log)
	
	# LEGACY
	# Starting in debug to erase old test file
	#logger = SimpleHtmlLogger::new("", SimpleHtmlLogger::DEBUG)
	# Loggin at INFO level to avoid unnecesary logging about test data insertion
	#logger.level = SimpleHtmlLogger::INFO
	#logger.imp("TEST SUITE")
	#logger.info("First setup")
	#@config = load_config()
	#@dbi = DatabaseInterface::new(@config, true)
	
	logger = $globalState.logger
	config = $globalState.config
	dbi = $globalState.dbi
	dbi_select_by_tech_id = $globalState.dbi_select_by_tech_id
	
	##########################
	# Before anything else:  #
	# saving the work dir    #
	##########################
	logger.imp("Saving work dir")
	save_dir_name = "../RPP_Save"
	if not Dir.exist?(save_dir_name) then
		logger.debug("Creating " + save_dir_name)
		Dir.mkdir(save_dir_name)
		logger.debug("Saving all files and directories")
		FileUtils.copy_entry(".", "./Save")
	else
		save_dir = Dir.new(save_dir_name)
		array_of_files = Dir.entries(".")
		copied_files = 0
		array_of_files.each do |file_name| 
			# to avoid the directories . && ..
			if File.file?(file_name) then
				local_file = File::new(file_name)
				needs_copying = false
				distant_file_name = save_dir_name + "/" + file_name
				if not File.file?(distant_file_name) then
					needs_copying = true
				else
					distant_file = File::new(distant_file_name)
					# if the local file has been modified after the distant one,
					# it's saved
					if local_file.mtime >= distant_file.mtime && local_file.size > 0 then
						needs_copying = true
					end
				end
				# if the local file has been modified after the distant one,
				# it's saved
				if needs_copying then
					logger.debug("Saving " + file_name)
					copied_files = copied_files + 1
					FileUtils.copy(file_name, save_dir_name, {verbose: false})
				end
			end
		end
		plural = ""
		if not copied_files == 1
			plural = "s"
		end
		logger.info("Saved " + copied_files.to_s + " file" + plural + " from work dir.")
	end
	
	
	# Loggin at INFO level to avoid unnecesary logging about test data insertion
	logger.level = SimpleHtmlLogger::INFO
	logger.imp("TEST SUITE")
	logger.info("First setup")
	
	begin # try
		@ref_list_hash = dbi_select_by_tech_id.load_all_refs
	rescue Exception => sqle
		logger.error(sqle.inspect)
		logger.info("Database tables might not exist, trying to create them.")
		dbi.create_tables()
		@ref_list_hash = dbi_select_by_tech_id.load_all_refs
	end
	
	# getting the SQL for the setup and teardown
	@sql_test = []
	@sql_test = YAML.load_file(config[:gen][:sql_test])

	# cleaning database, just in case a test failed before it could do it itself
	logger.debug(@sql_test[:delete].keys)
	@sql_test[:delete].keys.each do |table|
		logger.info("Deleting test values from " + table.to_s)
		current_query = @sql_test[:delete][table]
		dummy_statement = nil
		dbi.execute_query(current_query, dummy_statement, nil, true)
	end
	
	#setting up the test values for select by tech ID
	@sql_test[:tech_id].keys.each do |table|
		logger.info("Inserting STech test data into " + table.to_s + ".")
		current_query = @sql_test[:tech_id][table]
		dummy_statement = nil
		dbi.execute_query(current_query, dummy_statement, nil, true)
	end
	
	#setting up the test values for update
	@sql_test[:update].keys.each do |table|
		logger.info("Inserting U test data into " + table.to_s + ".")
		current_query = @sql_test[:update][table]
		dummy_statement = nil
		dbi.execute_query(current_query, dummy_statement, nil, true)
	end
	
	#setting up the test values for select by business ID
	@sql_test[:business_id].keys.each do |table|
		logger.info("Inserting SBusiness test data into " + table.to_s + ".")
		current_query = @sql_test[:business_id][table]
		dummy_statement = nil
		dbi.execute_query(current_query, dummy_statement, nil, true)
	end
	
	@@crawler = nil
	@suite_start_time = Time.now
	logger.info("End of setup")
	
	##########################
	#      End of setup      #
	##########################
	
	############################
	# Teardown after all tests #
	############################
	Minitest.after_run {
		# Loggin at INFO level to avoid unnecesary logging about test data deletion
		logger.level = SimpleHtmlLogger::INFO
		
		if @@crawler != nil
			logger.debug("Found a crawler. Shutting it down.")
			@@crawler.close_driver()
		end
		
		logger.info("Teardown")
		
		# Data deletion went here until it was moved to before the data insertion
		
		logger.info("End of teardown")
		
		suite_end_time = Time.now
		test_suite_duration = suite_end_time - @suite_start_time
		logger.info("Test suite took: " + 
			format_time_diff(test_suite_duration))
		
		logger.imp("END TEST SUITE")
	}
	############################
	#      End of teardown     #
	############################

	
end