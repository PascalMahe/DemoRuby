﻿require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'selenium-webdriver'
require './common.rb'
require './SimpleHtmlLogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
require './DatabaseInterface.rb'
require './JSONCrawler.rb'
require './Saver.rb'


###########################################################################################
#################################                        ##################################
#################################    MAIN SCRIPT HERE    ##################################
#################################                        ##################################
###########################################################################################

start_time = Time.now

begin #general exception catching block

	# Initializing globalState (which contains the logger, the config file and whether we are in test or prod)

	path_to_log = ""
	log_level = SimpleHtmlLogger::DEBUG
	is_test = false
	$globalState = GlobalState::new(is_test, log_level, path_to_log)

	logger = $globalState.logger
	is_test = $globalState.is_test
	dbi = $globalState.dbi

	logger.info("Loading config")
	config = $globalState.config
	logger.info("START TIME: " + start_time.strftime(config[:gen][:default_date_time_format]))
	# logger.debug("Config : " + config.to_s)

	loading_end_time = Time.now

	# Creating job
	current_job = Job::new
	current_job.start_time = start_time
	current_job.loading_end_time = loading_end_time

	# Creating test interface with database
	if is_test then
		logger.imp("TESTS")
	end

	# logger.imp("Dropping all tables, 'cause, you know, reasons...")
	# dbi.drop_tables()
	# logger.info("Tables dropped")

	logger.imp("Checking Database Existence")
	table_nb = dbi.get_table_number()
	if(table_nb < 22) then
		logger.info("Creating tables")
		dbi.create_tables()
		logger.info("Tables created")
	else
		logger.info("Tables already exist")
	end

	# logger.info("Cleansing all tables, 'cause, you know, heretics...")
	# dbi.clean_tables()
	# logger.info("Tables cleansed")

	if is_test then
		logger.imp("END TESTS")

		logger.imp("REAL STUFF")
	end

	logger.info("Loading reference values")
	dbi_select_by_tech_id = $globalState.dbi_select_by_tech_id
	ref_list_hash = dbi_select_by_tech_id.load_all_refs

	logger.imp("CRAWLING TIME")

	logger.info("Starting to crawl")

	# crawler = Crawler::new(logger, ref_list_hash, config, is_test)

	crawler = JSONCrawler::new(logger, ref_list_hash, config, is_test)
	meeting_list = crawler.crawl(current_job)

	logger.info("Ending crawl")
	crawling_end_time = Time.now
	current_job.crawling_end_time = crawling_end_time

	logger.imp("SAVING TIME")

	logger.info("Starting saves")
	# Saving the meeting_list
	saver = Saver::new($globalState.dbi_insert,
						$globalState.dbi_select_by_tech_id,
						$globalState.dbi_select_by_business_id)

	saver.save_meeting_list(meeting_list)
	logger.info("Ending saves")

	logger.info("Starting computations")
	logger.info("Ending computations")
	computing_end_time = Time.now

	logger.debug(current_job)
	logger.imp("END REAL STUFF")

rescue Exception => err

	if logger != nil then
		logger.error("Caught general error: " + err.inspect)
		logger.error(err.backtrace)
	else
		puts err.backtrace
	end
	
	# only works fro chromedriver...
	# if crawler != nil then
		# crawler.close_driver
	# end
end

end_time = Time.now
total_duration = end_time - start_time

logStr = "TOTAL TIME: " +	format_time_diff(total_duration)
logger.imp(logStr)

logger.end_log
