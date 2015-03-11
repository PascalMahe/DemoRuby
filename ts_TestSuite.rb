﻿require 'minitest'
require 'minitest/autorun'

require './common.rb'
require './SimpleHtmlLogger.rb'
 
class TestSuite < MiniTest::Test
	attr_accessor :sql_test
	attr_accessor :ref_list_hash
	
	##########################
	# Setup before any tests #
	##########################
	path_to_log = ""
	# Starting in debug to erase old test file
	log_level = SimpleHtmlLogger::Debug
	is_test = true
	$globalState = GlobalState::new(is_test, log_level, path_to_log)
	
	# LEGACY
	# Starting in debug to erase old test file
	#logger = SimpleHtmlLogger::new("", SimpleHtmlLogger::Debug)
	# Loggin at INFO level to avoid unnecesary logging about test data insertion
	#logger.level = SimpleHtmlLogger::Info
	#logger.imp("TEST SUITE")
	#logger.info("First setup")
	#@config = load_config()
	#@dbi = DatabaseInterface::new(@config, true)
	
	logger = $globalState.logger
	config = $globalState.config
	dbi = $globalState.dbi
	# Loggin at INFO level to avoid unnecesary logging about test data insertion
	logger.level = SimpleHtmlLogger::Info
	logger.imp("TEST SUITE")
	logger.info("First setup")
	
	begin # try
		@ref_list_hash = dbi.load_all_refs
	rescue Exception => sqle
		logger.error(sqle.inspect)
		logger.info("Database tables might not exist, trying to create them.")
		dbi.create_tables()
		@ref_list_hash = dbi.load_all_refs
	end
	
	# getting the SQL for the setup and teardown
	@sql_test = []
	@sql_test = YAML.load_file(config[:gen][:sql_test])

	#setting up the test values
	@sql_test[:test][:insert].keys.each do |table|
		logger.info("Inserting test values into " + table.to_s)
		current_query = @sql_test[:test][:insert][table]
		dummy_statement = nil
		dbi.execute_query(current_query, dummy_statement, nil, true)
	end
	logger.info("End of setup")
	logger.level = SimpleHtmlLogger::Debug
	##########################
	#      End of setup      #
	##########################
	
	############################
	# Teardown after all tests #
	############################
	Minitest.after_run {
		# Loggin at INFO level to avoid unnecesary logging about test data deletion
		logger.level = SimpleHtmlLogger::Info
		logger.info("Teardown")
		# deleting values in database
		logger.debug(@sql_test[:test][:delete].keys)
		@sql_test[:test][:delete].keys.each do |table|
			logger.info("Deleting test values from " + table.to_s)
			current_query = @sql_test[:test][:delete][table]
			dummy_statement = nil
			dbi.execute_query(current_query, dummy_statement, nil, true)
		end
		logger.info("End of teardown")
		logger.imp("END TEST SUITE")
	}
	############################
	#      End of teardown     #
	############################
end