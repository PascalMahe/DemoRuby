require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require './../SimpleHtmlLogger.rb'


###########################################################################################
#################################                        ##################################
#################################    MAIN SCRIPT HERE    ##################################
#################################                        ##################################
###########################################################################################


begin #general exception catching block

	start_time = Time.now
	
	# Initializing logger
	$logger = SimpleHtmlLogger::new('./../', SimpleHtmlLogger::Debug)
	
	$logger.info("Loading config")
	$config = []
	$config = YAML.load_file("./../config.yml") # From file (cf. http://strugglingwithruby.blogspot.fr/2008/10/yaml.html)

				
	#TEMP : correcting an earlier mistake: forgetting the "_runner_" characters
	#<a href="file:///D:/Dev/workspace/RPP/Test-HTML/R4_C2_ISPHAN.htm">
	text = "<a href=\"file:///D:/Dev/workspace/RPP/Test-HTML/R4_C2_ISPHAN.htm\">"
	runner_link_regex = /\<a href="file:\/\/\/D:\/Dev\/workspace\/RPP\/Test-HTML\/R(\d)_C(\d)_(.+).htm">/
	group_captured = text.scan(runner_link_regex)
	
	if group_captured[0] != nil then
	
		$logger.debug("Captured groups : ")
		$logger.debug(group_captured)
		
	else 
		$logger.debug("No match found.")
	end
				
	
rescue Exception => err
	$logger.error(err.inspect)
	$logger.error(err.backtrace)
end

$logger.imp("Done !")

end_time = Time.now
total_time = (end_time - start_time).round(3)
$logger.info("Start time : " + start_time.strftime($config[:gen][:default_date_time_format]))
$logger.info("End time : " + end_time.strftime($config[:gen][:default_date_time_format]))
$logger.info("Total time (s) : #{total_time}")

$logger.end_log


