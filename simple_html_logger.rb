Class SimpleHtmlLogger

	:important = "IMP"
	:error = "ERR"
	:info = "INF"
	:debug = "DBG"
	
	:file_prefix = "RPP_job-"
	:file_ext = ".html"
	
	attr_accessor :file
	attr_accessor :level
	
	def initialize(level = :info)
		@level = level
		
		#creating the HTML file where the logs are copied
		filename = get_filename() 
		#if there already are files for today, a new filename is computed
		
		
		file = File.open(filename, "o")
	end
	
	def get_filename()
		# Stem filename = RPP_job-20130211 
		# where 20130211 is today's date formatted YYYYMMDD
		time_today = Time.now
		str_today = time_today.year + time_today.month + time_today.day
		filename = :file_prefix+str_today+:file_ext
		
		if @level != debug
			# check if file already exists
			if exist?(filename)
				#if it does, rename it to filename-00.hmtl
				File.rename(filename, :file_prefix+str_today+"00"+:file_ext)
			end
			if exist?(:file_prefix+str_today+"00"+:file_ext)
				#if the 00 file exists, compute the new number
				
			end
		end
		return filename
	end

	def log(level, message)
	
	end

end

