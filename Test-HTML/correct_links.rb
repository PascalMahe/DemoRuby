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

	
	# $logger.info("START TIME: " + start_time.strftime($config[:gen][:default_date_time_format]))
	# $logger.debug("Config : " + $config.to_s)

	loading_end_time = Time.now

	# magic numbers !
	max_meeting_number = 5
	max_race_number = 9
	total_file_count = 0
	
	# first loop : conditions
	for i in 1..max_meeting_number do
		for j in 1..max_race_number do
			filename = "R#{i}_C#{j}_test.htm"
			if File.exist?(filename) then
				$logger.info("Opening file : " + filename)
				text = File.read(filename)
				# We're looking for 3 lines, looking like this :
				# some_spaces <span class="name unit" title="horse_name_in_all_caps_with_spaces">
				# some_spaces horse_name_with_spaces
				# some_spaces </span>
				
				# the regex looks like this :
				# '\<span class="name unit" title="([^\r\n]+)">' => (ignoring the first spaces) the span and a group capturing the name (exluding any line jumps)
				#([\s^\r\n]+) 	=> the spaces at the beginning of the 2nd line (capture in a group to put them back when replacing the characters)
				#([^\r\n]+) 	=> the horse's name
				#([\s^\r\n]+) 	=> again, capturing the spaces, for the 3rd line this time
				# <\/span>/ 	=> the final </span> tag
				regex = /\<span class="name unit" title="([^\r\n]+)">([\s^\r\n]+)([^\r\n]+)([\s^\r\n]+)<\/span>/
				group_captured = text.scan(regex)
				
				$logger.debug("Text : ")
				$logger.debug(text)
				
				if group_captured[0] != nil then
				
					$logger.debug("Captured groups : ")
					$logger.debug(group_captured)
					original_title = group_captured[0][0]

					
					
					#$logger.debug("After replacement : ")
					new_file_content = text.gsub(regex, "<span class=\"name unit\" title=\"\\1\"><a href=\"file:///D:/Dev/workspace/RPP/Test-HTML/R#{i}_C#{j}_\\1.htm\">\\2\\3\\4</a></span>")
					
					#$logger.debug(new_file_content)
					File.open(filename, "w") {|file| file.puts new_file_content}
					
				else 
					$logger.debug("No match found.")
				end
				$logger.info("Closing file : " + filename)
				
				total_file_count = total_file_count + 1
			end
			
		end
	end
	
	
rescue Exception => err
	$logger.error(err.inspect)
	$logger.error(err.backtrace)
end

$logger.imp("Done !")
$logger.info("Files : #{total_file_count}")

end_time = Time.now
total_time = (end_time - start_time).round(3)
$logger.info("Start time : " + start_time.strftime($config[:gen][:default_date_time_format]))
$logger.info("End time : " + end_time.strftime($config[:gen][:default_date_time_format]))
$logger.info("Total time (s) : #{total_time}")

$logger.end_log


