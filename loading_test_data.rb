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
	$logger = SimpleHtmlLogger::new('./', SimpleHtmlLogger::DEBUG)
	
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

	base_adress = $config[:gen][:base_adress_test_fetching]
	# base_adress = $config[:gen][:base_adress_test]
	
	# Getting main page
	$driver.get(base_adress)
	date = Date::new(2014,02,20)
	
	#Fetching meetings
	html_meeting_list = $driver.find_elements(:xpath, '//div[@id="timeline-view"]/div[@class="course-line"]')
	
	page_list = Hash::new
	html_meeting_list.each do |html_meeting|
		link_list = html_meeting.find_elements(:xpath, 'a')
		link_list.each do |link|
			url = link.attribute("href")
			meeting_and_race_start_index = url.index(/R[1-9].C[1-9]/)
			meeting_and_race_numbers = url.slice(meeting_and_race_start_index, 5) # getting the RX_CX part of the filename
			meeting_and_race_numbers.gsub!('/', '_')
			page_list[meeting_and_race_numbers] = url
		end
	end
	$logger.debug(page_list.inspect)
	page_list.each_pair do |link_key, link|
		$logger.imp("Getting page : " + link_key)
		$driver.get(link)
		
		$logger.info("Saving race conditions page")
		button = $driver.find_element(:xpath, '//div[@id="conditions"]/a')
		button.click
		filename = "./Test-HTML/" + link_key + "_conditions.htm"
		#creating file to save the new HTML
		temp_file = File.new(filename, "w")
		temp_file.puts($driver.page_source)
		temp_file.close
		$logger.debug("Saving page : " + filename)
		
		$logger.info("Saving runners' table page")
		button = $driver.find_element(:xpath, '//div[@id="participants-view"]/div[2]/a[2]')
		button.click
		filename = "./Test-HTML/" + link_key + "_runners.htm"
		temp_file = File.new(filename, "w")
		temp_file.puts($driver.page_source)
		temp_file.close
		$logger.debug("Saving page : " + filename)
		
		$logger.info("Saving runners' details pages")
		# $driver.find_elements(:xpath, '//*[contains(concat(" ", normalize-space(@class), " "), " foo ")]') #see http://stackoverflow.com/a/9133579/2112089
		runner_first = $driver.find_elements(:xpath, '//tr[@class="ligne-participant favorite odd"]')
		runner_list_odd = $driver.find_elements(:xpath, '//tr[@class="ligne-participant odd"]')
		runner_list_even = $driver.find_elements(:xpath, '//tr[@class="ligne-participant even"]')
		runner_list_odd_non = $driver.find_elements(:xpath, '//tr[@class="ligne-participant non-partant odd"]')
		runner_list_even_non = $driver.find_elements(:xpath, '//tr[@class="ligne-participant non-partant even"]')
		runner_list = runner_first.concat(runner_list_odd.concat(runner_list_even.concat(runner_list_odd_non.concat(runner_list_even_non))))
	
		runner_list.each do |runner|
			runner_link = runner.find_element(:xpath, 'td/span[@class="name unit"]')
			$logger.debug(runner_link.attribute("innerHTML"))
			runner_name = runner_link.attribute("title")
			runner_name.gsub!(' ', '_')
			runner_link.click
			filename = "./Test-HTML/" + link_key + "_runner_" + runner_name + ".htm"
			temp_file = File.new(filename, "w")
			temp_file.puts($driver.page_source)
			temp_file.close
			$logger.debug("Saving page : " + filename)
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


