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
	$logger = SimpleHtmlLogger::new('./../', SimpleHtmlLogger::DEBUG)
	
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
	
	for i in 1..max_meeting_number do
		for j in 1..max_race_number do
			filename = "R#{i}_C#{j}.htm"
			if File.exist?(filename) then
				$logger.info("Opening file : " + filename)
				text = File.read(filename)
				# We're looking for 3 lines, looking like this :
				# some_spaces <span class="name unit" title="horse_name_in_all_caps_with_spaces">
				# some_spaces horse_name_with_spaces
				# some_spaces </span>
				
				# the regex looks like this :
				# '\<span class="name unit" title="([^\r\n]+)">' => (ignoring the first spaces) the span and a group capturing the name (exluding any line jumps)
				#([\s^\r\n]+) 	=> the spaces at the beginning of the 2nd line (captured in a group to put them back when replacing the characters)
				#([^\r\n]+) 	=> the horse's name
				#([\s^\r\n]+) 	=> again, capturing the spaces, for the 3rd line this time
				# <\/span>/ 	=> the final </span> tag
				runner_link_regex = /\<span class="name unit" title="([^\r\n]+)">([\s^\r\n]+)([^\r\n]+)([\s^\r\n]+)<\/span>/
				group_captured = text.scan(runner_link_regex)
				
				#TEMP : correcting an earlier mistake: forgetting the "_runner_" characters
				#<a href="file:///D:/Dev/workspace/RPP/Test-HTML/R4_C2_ISPHAN.htm">
				#runner_link_regex = /\<a href="file:\/\/\/D:\/Dev\/workspace\/RPP\/Test-HTML\/R(\d)_C(\d)_(.+).htm">/
				#group_captured = text.scan(runner_link_regex)
				
				#$logger.debug("Text : ")
				#$logger.debug(text)
				
				if group_captured[0] != nil then
				
					$logger.debug("Captured groups : ")
					$logger.debug(group_captured)
					original_title = group_captured[0][0]

					# First pass : adding the links to the runners with spaces
					new_file_content = text.gsub(runner_link_regex, "<span class=\"name unit\" title=\"\\1\"><a href=\"file:///D:/Dev/workspace/RPP/Test-HTML/R#{i}_C#{j}_runner_\\1.htm\">\\2\\3\\4</a></span>")
					#TEMP : new_file_content = text.gsub(runner_link_regex, "<a href=\"file:///D:/Dev/workspace/RPP/Test-HTML/R\\1_C\\2_runner_\\3.htm\">")
					
					#Second pass : correcting those links by removing spaces
					# REGEX : 	R\d_ 		-> R followed by a digit (0-9) followed by _
					# 			C\d_ 		-> C followed by a digit (0-9) followed by _
					#			(.+ +.+)+ 	-> at least one caracter (any car.) 
					#							followed by one or more spaces ' ' 
					#							followed by at least one caracter (any car.)
					#							and this whole group happens at least once
					#			\.htm		-> a dot followed by htm
					space_regex = /R\d_C\d_(.+ .+)+\.htm/
					space_group_captured = new_file_content.scan(space_regex)
					
					if space_group_captured[0] != nil then
				
						$logger.debug("Captured space groups : ")
						$logger.debug(space_group_captured)
					end
					
					# loop on the existence of "space in a filename"
					while (regex_index = new_file_content.index(space_regex)) != nil do
						# getting the string to modify : the filename
						string_to_mod = new_file_content.slice(space_regex)
						# editing the string : replacing spaces with underscores
						modded_string = string_to_mod.gsub(" ", "_")
						$logger.debug("#{string_to_mod} => #{modded_string}")
						
						# cutting out the string
						new_file_content.slice!(space_regex)
						
						# sewing it all back together
						new_file_content.insert(regex_index, modded_string)
					end
					$logger.info("Replaced links to individual runners")
					
					# Third pass : runners links
					runners_table_regex = /<a class="btn( btn-selected)?">Tableau des partants/
					new_file_content = new_file_content.gsub(runners_table_regex, "<a class=\"btn\\1\" href=\"file:///D:/Dev/workspace/RPP/Test-HTML/R#{i}_C#{j}_runners.htm\">Tableau des partants")
					$logger.info("Replaced runners link")
					
					# Fourth pass : conditions links
					conditions_regex = /<a class="btn conditions-show">/
					new_file_content = new_file_content.gsub(conditions_regex, "<a class=\"btn conditions-show\" href=\"file:///D:/Dev/workspace/RPP/Test-HTML/R#{i}_C#{j}_conditions.htm\">")
					$logger.info("Replaced conditions link")
					
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


