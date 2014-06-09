require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'test/unit'
require 'selenium-webdriver'
require './common.rb'
require './SimpleHtmllogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
require './DatabaseInterface.rb'

###########################################################################################
#################################                        ##################################
#################################    MAIN SCRIPT HERE    ##################################
#################################                        ##################################
###########################################################################################


begin #general exception catching block

	start_time = Time.now
	
	# Initializing logger
	$logger = SimpleHtmlLogger::new('./', SimpleHtmlLogger::Debug)
	
	$logger.info("Loading config")
	
	$config = load_config()
	$is_test = true
	
	$logger.info("START TIME: " + start_time.strftime($config[:gen][:default_date_time_format]))
	
	loading_end_time = Time.now

	# Creating job 
	current_job = Job::new
	current_job.start_time = start_time
	current_job.loading_end_time = loading_end_time

	$logger.info("Preparing browser")
	
	# Proxy problem : see http://tech.danbarrese.com/2013/04/08/solved-use-watir-webdriver-behind-proxy/
	# and http://code.google.com/p/selenium/issues/detail?id=4300
	 ENV['no_proxy'] = '127.0.0.1'
	
	# preparing FF : adding Firebug 
	# see this page for version : https://getfirebug.com/downloads/
	profile = Selenium::WebDriver::Firefox::Profile.new
	# PROXY = 'proxy-internet.societe.mma.fr:8080'
	# profile.proxy = Selenium::WebDriver::Proxy.new(
	  # :http     => PROXY,
	  # :ftp      => PROXY,
	  # :ssl      => PROXY
	# )
	profile.add_extension("./Install/firebug-1.12.6.xpi")
	#Loading browser
	$driver = Selenium::WebDriver.for(:firefox, :profile => profile)
	$driver.manage.timeouts.implicit_wait = 15 # seconds

	$logger.info("Starting to crawl")

	# Load images location file
	filename = "images_locations.txt"
	if File.exist?(filename) then
		# loop on lines
		File.open(filename, 'r') do |file|
			$logger.info("File opened")
			file.each_line do |line|
				$logger.info("Line : #{line}")
				# Getting image
				$driver.get(line)
			end
			
			file.close
			$logger.info("File closed")
		end
	end
	
	$logger.info("Ending crawl")
	current_job.crawling_end_time = Time.now
	current_job.computing_end_time = Time.now
	
	$logger.debug(current_job)
	$logger.imp("END REAL STUFF")
	
	
rescue Exception => err
	$logger.error(err.inspect)
	$logger.error(err.backtrace)
end

$logger.end_log


