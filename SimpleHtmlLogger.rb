class SimpleHtmlLogger

	Important = "IMP"
	Error = "ERR"
	Info = "INF"
	Debug = "DBG"
	
	File_prefix = "RPP_job-"
	File_ext = ".html"
	
	attr_accessor :file
	attr_accessor :level
	
	def initialize(level = :info)
		@level = level
		
		#creating the HTML file where the logs are copied
		filename = get_filename()	
		
		@file = File.new(filename, "w")
		copy_html_to_log_file("log_html_header.htm")
	end
	
	def get_filename()
		# Stem filename = RPP_job-20130211 
		# where 20130211 is today's date formatted YYYYMMDD
		timestamp = Time.now
		str_today = timestamp.strftime("%Y%m%d")
		filename = File_prefix + str_today + File_ext
		puts @level
		
		if @level != Debug
			puts "level != debug"
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
		copy_html_to_log_file("log_html_footer.htm")
		@file.close
	end

	
	def log(level, message)
		timestamp = Time.now
		#For time and formatting examples, cf. http://www.tutorialspoint.com/ruby/ruby_date_time.htm
		# for doc : http://ruby-doc.org/stdlib-2.0.0/libdoc/date/rdoc/Date.html
		str_now = timestamp.strftime("%d/%m/%Y %H:%M:%S.%L")
		complete_log = str_now + " - " + level + " - " + message.to_s
		puts(complete_log)
		@file.puts('<tr class="' + level + '"><td>' + str_now + '</td><td>' + level + '</td><td class="' + level + '-main">' + message.to_s + '</td>')
 	end
	
	def info(message)
		log(Info, message)
	end
	
	def debug(message)
		log(Debug, message)
	end
	
	def error(message)
		log(Error, message)
	end
	
	def imp(message)
		log(Important, message)
	end
	
	def copy_html_to_log_file(html_filename)
		File.open(html_filename, "r").each_line do |line|
			@file.write(line)
		end
	end
end

