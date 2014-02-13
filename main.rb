﻿require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'test/unit'
require 'selenium-webdriver'
require './common.rb'
require './SimpleHtmlLogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
require './DatabaseInterface.rb'

begin #general exception catching block

	start_time = Time.now
	config = load_config()
	is_test = true
	logger = config[:logger]
	logger.info("START TIME: " + start_time.strftime(config[:gen][:default_date_time_format]))
	logger.debug("Config : " + config.to_s)

	loading_end_time = Time.now

	# Creating job 
	current_job = Job::new
	current_job.start_time = start_time
	current_job.loading_end_time = loading_end_time

	# Creating test interface with database
	logger.imp("TESTS")
	dbi = DatabaseInterface::new(config, is_test)

	#logger.imp("Dropping all tables, 'cause, you know, reasons...")
	#dbi.drop_tables()
	#logger.info("Tables dropped")

	logger.imp("Checking Database Existence")
	table_nb = dbi.get_table_number()
	if(table_nb < 22) then
		logger.info("Creating tables")
		dbi.create_tables()
		logger.info("Tables created")
	else 
		logger.info("Tables already exist")
	end


	#create a new empty TestSuite, giving it a name
	#db_tests = Test::Unit::TestSuite.new("Database Interfacing Tests")
	#db_tests << TestDatabaseInterface.new('test_insert_breeder')#calls TestDatabaseInterface#test_insert_breeder
	#run the suite
	#Test::Unit::UI::Console::TestRunner.run(db_tests)


	logger.imp("END TESTS")

	logger.imp("REAL STUFF")
	# Creating real interface with database
	dbi = DatabaseInterface::new(config, false)
	logger.info("Loading reference values")
	ref_list_hash = dbi.load_all_refs()

	logger.info("Preparing browser")
	# preparing FF : adding Firebug 
	profile = Selenium::WebDriver::Firefox::Profile.new
	profile.add_extension("./Install/firebug-1.11.4-fx.xpi")

	PROXY = 'proxy-internet.societe.mma.fr:8080'
	profile.proxy = Selenium::WebDriver::Proxy.new(
	  :http     => PROXY,
	  :ftp      => PROXY,
	  :ssl      => PROXY
	)
	#Loading browser
	driver = Selenium::WebDriver.for(:firefox)
	driver.manage.timeouts.implicit_wait = 15 # seconds

	logger.info("Starting to crawl")
	if is_test
		base_adress = config[:gen][:base_adress]
	else
		base_adress = config[:gen][:base_adress_test]
	end

	driver.get(base_adress)


#rescue ArgumentError, NameError => err
#	logger.error(err)
#	puts err
rescue Exception => err
	logger.error(err)
	logger.error(err.backtrace)
end

logger.end_log





















