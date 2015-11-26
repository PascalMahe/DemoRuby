class SimpleHtmlLogger

	IMPORTANT = "IMP"
	ERROR = "ERR"
	INFO = "INF"
	DEBUG = "DBG"
	OK = "OK"
	
	File_prefix = "RPP_job-"
	File_ext = ".html"
	
	attr_accessor :file
	attr_accessor :path
	attr_accessor :level
	
	def initialize(path, level = :info)
		@level = level
		@path = path
		@mutex = Mutex.new 	# Mutex to synchronize the logging : 
							# otherwise, the tests scramble the logs
		
		#creating the HTML file where the logs are copied
		filename = get_filename()	
		
		@file = File.new(filename, "w")
		copy_html_to_log_file(@path + "log_html_header.htm")
	end
	
	def get_filename()
		# Stem filename = RPP_job-20130211 
		# where 20130211 is today's date formatted YYYYMMDD
		timestamp = Time.now
		str_today = timestamp.strftime("%Y%m%d")
		filename = File_prefix + str_today + File_ext
		puts @level
		
		if @level != DEBUG
			padding_number = 0
			# check if files already exist
			if File::exist?(filename) or File::exist?(build_filename(str_today, padding_number))
				puts "file named " + filename + " already exists"
				
				#if filename does, rename it to filename-00.hmtl
				if File::exist?(filename)
					File.rename(filename, build_filename(str_today, padding_number))
					puts "renamed it to : " + build_filename(str_today, padding_number)
				end
				
				while File::exist?(build_filename(str_today, padding_number))
					#if the 00 file exists, compute the new number
					padding_number = padding_number + 1
				end
				filename = build_filename(str_today, padding_number)
				puts "filenames up to " + (padding_number - 1).to_s + " taken" 
				
			end
		
		end
		puts "final filename :  " + filename
		return filename
	end
	
	def build_filename(str_today, padding_number)
		return File_prefix + str_today + "-" + padding_number.to_s.rjust(2, '0') + File_ext
	end
	
	def end_log()
		copy_html_to_log_file(@path + "log_html_footer.htm")
		@file.close
	end
	
	def log(level, message)
		@mutex.synchronize do
			if can_write_level?(level) then
				timestamp = Time.now
				#For time and formatting examples, cf. http://www.tutorialspoint.com/ruby/ruby_date_time.htm
				# for doc : http://ruby-doc.org/stdlib-2.0.0/libdoc/date/rdoc/Date.html
				str_now = timestamp.strftime("%H:%M:%S.%L")
				color_code = get_color_code_from_level(level)
				complete_log = terminal_pretty(message.to_s)
				complete_log = colorize(str_now + " - " + level + " - " + complete_log, color_code)
				puts(complete_log)
				html_message = html_escape(message.to_s)
				html_message = html_pretty(html_message)
				#puts html_message
				@file.puts('<tr class="' + level + '"><td>' + str_now + '</td><td>' + level + '</td><td class="' + level + '-main">' + html_message + '</td>')
			end
		end
 	end
	
	def get_color_code_from_level(level)
		if level == IMPORTANT then 
			color_code = 36
		elsif level == ERROR then 
			color_code = 31
		elsif level == DEBUG then 
			color_code = 35
		elsif level == OK then 
			color_code = 32
		else 
			color_code = 37
		end
		return color_code
	end
	
	def can_write_level?(level_to_check)
		level_as_number = convert_level_to_number(@level)
		level_to_check_as_number = convert_level_to_number(level_to_check)
		
		# @level | level_to_check || returns
		#	ERR	4		ERR	4			T
		#	ERR	4		IMP	3			F
		#	ERR	4		OK	2			F
		#	ERR	4		INF	1			F
		#	ERR	4		DBG	0			F
		#
		#	IMP	3		ERR	3			T
		#	IMP	3		IMP	2			T
		#	IMP	3		OK	2			F
		#	IMP	3		INF	1			F
		#	IMP	3		DBG	0			F
		#
		#	OK	2		ERR	4			T
		#	OK	2		IMP	3			T
		#	OK	2		OK	2			T
		#	OK	2		INF	1			F
		#	OK	2		DBG	0			F
		#
		#	INF	1		ERR	4			T
		#	INF	1		IMP	3			T
		#	INF	1		OK	2			T
		#	INF	1		INF	1			T
		#	INF	1		DBG	0			F
		#
		#	DBG	0		ERR	4			T
		#	DGB	0		IMP	3			T
		#	DGB	0		OK	2			T
		#	DBG	0		INF	1			T
		#	DBG	0		DBG	0			T
		# => returns true if @level is less or equal to level_to_check
		
		return level_as_number <= level_to_check_as_number
	end
	
	def convert_level_to_number(level)
		# ERROR = 4
		# IMPORTANT = 3
		# OK = 2
		# INFO = 1
		# DEBUG = 0
		level_as_number = 4 #ERROR
		if level == IMPORTANT then
			level_as_number = 3
		elsif level == OK
			level_as_number = 2
		elsif level == INFO
			level_as_number = 1
		elsif level == DEBUG
			level_as_number = 0
		end
		return level_as_number
	end
	
	# For discovery of color space (really ANSI code space)
	def test_colors()
		for i in 0..50 do
			puts(colorize("Test of color code " + i.to_s + "\n", i))
		end
	end
	
	
	# see http://stackoverflow.com/a/2070405/2112089
	def colorize(text, color_code)
	  "\e[#{color_code}m#{text}\e[0m"
	end
	
	def ok(message)
		log(OK, message)
	end
	
	def info(message)
		log(INFO, message)
	end
	
	def debug(message)
		log(DEBUG, message)
	end
	
	def error(message)
		log(ERROR, message)
	end
	
	def imp(message)
		log(IMPORTANT, message)
	end
	
	def copy_html_to_log_file(html_filename)
		File.open(html_filename, "r").each_line do |line|
			@file.write(line)
		end
	end
	
	def html_escape(string)
		html_escaped_string = string.gsub("<", "&lt;")
		html_escaped_string = html_escaped_string.gsub(">", "&gt;")
		return html_escaped_string
	end
	
	def pretty(string, new_line_string, tab_string)
		# regex : ',' not between parentheses (see http://stackoverflow.com/a/9030062/2112089)
		#','		=> Match a comma
		#'(?!'		=> only if it's not followed by...
		#'[^(]*'	=> any number of characters except opening parens
		#'\)'		=> followed by a closing parens
		#')'		=> End of lookahead
		#
		#pretty_string = string.gsub(/(,(?![^(]*\)))/, "," + new_line_string)
		
		# regex : '[' not followed by ']'
		opening_square_regex = /(\[)([^\]])/
		
		# regex : ']' when not preceded by '['
		closing_square_regex = /([^\[])(\])/		
		
		# regex : '{' not followed by '}'
		closing_curly_regex = /({)([^}])/
		
		# regex : '}' when not preceded by '{'
		closing_curly_regex = /([^{])(})/
		
		#pretty_string = pretty_string.gsub(opening_square_regex, '\1' + new_line_string + '\2')
		#pretty_string = pretty_string.gsub(closing_square_regex, '\1' + new_line_string + '\2')
		#pretty_string = pretty_string.gsub(closing_curly_regex, '\1' + new_line_string + '\2')
		#pretty_string = pretty_string.gsub(closing_curly_regex, '\1' + new_line_string + '\2')
		
		# new lines and tabs are inserted only if there is a list (array...)
		# we check that by checking if there are multiple (more than one) commas or brackets (and if the brackets are in pairs)
		number_of_commas = string.scan(",").length
		number_of_opening_brackets = string.scan("(").length
		number_of_closing_brackets = string.scan(")").length
		number_of_opening_square_brackets = string.scan("[").length
		number_of_closing_square_brackets = string.scan("]").length
		
		is_a_list_or_array = number_of_commas > 1 or 
							(number_of_opening_brackets == number_of_closing_brackets and 
								number_of_opening_brackets > 1) or
							(number_of_opening_brackets == number_of_closing_brackets and 
								number_of_opening_brackets > 1)
		if is_a_list_or_array then
			
			# at each bracket (opening or closing), a new_line_string is inserted, followed by a number of tab_strings
			# the number of tabs is incremented after each opening bracket and decremented after each closing bracket
			i = 0
			tab_nb = 0
			opened_paren = 0
			while (i < string.length() - 1) do

				if string[i].eql?("[") and not (string[i + 1].eql?("]")) then
					tab_nb = tab_nb + 1
					nb_char_inserted = insert_new_line_and_tabs(string, i, tab_nb, tab_string, new_line_string, false)
					i = i + nb_char_inserted
				end

				if string[i].eql?("{") and not (string[i + 1].eql?("}")) then
					tab_nb = tab_nb + 1
					nb_char_inserted = insert_new_line_and_tabs(string, i, tab_nb, tab_string, new_line_string, false)
					i = i + nb_char_inserted
				end

				if string[i].eql?("]") 
					if i - 1 > 0 then 
						if not (string[i - 1].eql?("[")) then
							tab_nb = tab_nb - 1
							nb_char_inserted = insert_new_line_and_tabs(string, i, tab_nb, tab_string, new_line_string, true)
							i = i + nb_char_inserted
						end #end if
					end #end if
				end #end if
				
				if string[i].eql?("}") 
					if i - 1 > 0 then 
						if not (string[i - 1].eql?("{")) then
							tab_nb = tab_nb - 1
							nb_char_inserted = insert_new_line_and_tabs(string, i, tab_nb, tab_string, new_line_string, true)
							i = i + nb_char_inserted
						end #end if 
					end #end if
				end #end if
				
				if string[i].eql?("(") then
					opened_paren = opened_paren + 1
				end
				if string[i].eql?(")") then
					opened_paren = opened_paren - 1
				end
				if string[i].eql?(",") and opened_paren == 0 then
					nb_char_inserted = insert_new_line_and_tabs(string, i, tab_nb, tab_string, new_line_string, true)
					i = i + nb_char_inserted
				end
				
				i = i + 1
			end #end while
			
		end # end if on number of commas and brackets 
		
		
		return string
	end
	
	def insert_new_line_and_tabs(string, insertion_index, tab_nb, tab_string, new_line_string, insert_after)
		# inserts into the string (at the specified index) the new_line_string and Xtab_nb times the tab_string
		# returns the number of char inserted
		i = 0
		str_tab = ""
		while i < tab_nb do
			str_tab = str_tab + tab_string
			i = i + 1
		end
		insertion_string = new_line_string + str_tab
		offset = 0
		if insert_after then 
			offset = 1
		end
		string.insert(insertion_index + offset, insertion_string)
		return insertion_string.length + offset
	end
	
	def html_pretty(string)	
		prettified = pretty(string, '<br/>', '&nbsp;&nbsp;&nbsp;')
		#puts prettified
		return prettified
	end
	
	def terminal_pretty(string)
		return pretty(string, "\n", "\t")
	end
end

