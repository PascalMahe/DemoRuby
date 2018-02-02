class RefObject
	attr_accessor :id
	attr_accessor :text	
	
	def initialize(id = nil, text)
		@id = id
		@text = text
	end
	
	def to_s(ref_class)
		return ref_class + "#" + @id.to_s +
		": " + @text.to_s + ""
	end
	
	def ==(other_object)
		if not other_object.instance_of? self.class then
			return false
		end
		if other_object.id == self.id and
		other_object.text == self.text then
			return true
		else 
			return false
		end
	end
end

class RefObjectContainer < Hash
	
	attr_accessor :ref_class
	attr_accessor :dbi_insert
	attr_accessor :local_log
	
	def initialize(class_to_instanciate, dbi_insert)
		@ref_class = class_to_instanciate
		@dbi_insert = dbi_insert
	end
	
	def load_table()
		raw_query = $globalState.config[:sql][:gen][:load_table]
		query = raw_query.gsub(':table', @ref_class.to_s)
		stat_select_all = nil
		# $globalState.logger.debug("load_table - query: " + query)
		table_content = $globalState.dbi_select_by_tech_id.
							load_ref_object_list(
								@ref_class, 
								query,
								stat_select_all)
		return table_content
	end
	
	def to_s()
		str = "" + @ref_class.to_s + "["
		first = true
		self.keys.each do |key|
			value = self.fetch(key) # fetch because [] is overriden (see below)
			if not first then
				str = str + ", "
			end
			str = str + key + " => " + value.to_s
			first = false
		end
		str = str + "]"
	end
	
	def write_to_local_log(msg)
		if @local_log == nil then
			@local_log = ""
		end
		@local_log = local_log + msg + "\n"
	end
	
	# fetches from text
	def [](text)
		logger = $globalState.logger
		
	
		# logger.debug("lookup - prep done in " + @ref_class.to_s)
		keys_before = self.keys
		# logger.debug("lookup - got keys in " + @ref_class.to_s)
		
		# Counting duplicates (before)
		duplicate_IDs_before = @dbi_insert.detect_duplicates(@ref_class)
		
		table_content_before = load_table
		# logger.debug("lookup - testing if text in keys in " + @ref_class.to_s)	
		if not self.has_key?(text) then
			ref_to_add = @ref_class.new(text)
			ref_to_add.id = @dbi_insert.insert_ref_object(@ref_class, ref_to_add)
			
			# logger.debug("lookup - ref_to_add after insertion " + ref_to_add.to_s)
			self.store(text, ref_to_add) # using store to avoid using []
			ref_to_add_str = ref_to_add.to_s
			debug_answer = "lookup - Nope, added #" + 
									ref_to_add.id.to_s + "."
		else
			# logger.debug("lookup - totes text in keys in " + @ref_class.to_s)
			ref_to_add = self.fetch(text)
			# logger.debug("lookup - fetched ref in " + @ref_class.to_s)
			debug_answer = "lookup - Yep: returning #" + 
									ref_to_add.id.to_s + "."
		end
		
		# Counting duplicates (after)
		duplicate_IDs = @dbi_insert.detect_duplicates(@ref_class)
		if duplicate_IDs_before != duplicate_IDs then
			table_content_after = load_table
			keys_after = self.keys
			
			logger.error("lookup - Duplicate came from this call: " + 
							duplicate_IDs_before.size.to_s + " before, " + 
							duplicate_IDs.size.to_s + " after.")
			
			logger.error("lookup - Keys before duplicates : " + 
							keys_before.to_s)
			
			logger.error("lookup - Keys after duplicates : " + 
							keys_after.to_s)
			
			logger.error("lookup - Table before duplicates : " + 
							table_content_before.to_s)
			
			logger.error("lookup - Table after duplicates : " + 
							table_content_after.to_s)
			
			level_before = logger.level
			logger.level = SimpleHtmlLogger::DEBUG
			
			logger.level = level_before
		end
		return ref_to_add
	end
	
	# fetches from id
	def get(key)
		# Select gets the element such as value.id == key
		# and returns a hash containing that element.
		# cf. http://www.ruby-doc.org/core-2.0.0/Hash.html#method-i-select
		new_hash = self.select{|k,v| v.id == key}
		
		# $globalState.logger.debug("get - Looking for id = %s in :" % key)
		# $globalState.logger.debug("get - " + self.to_s)
		
		ref_with_right_ID = new_hash.shift()
		if ref_with_right_ID == nil then
			value_to_return = nil
		else
			# We only want the first element (the id)
			value_to_return = ref_with_right_ID[1]
			$globalState.logger.debug("get - Found" + value_to_return.to_s)
		end
		return value_to_return
	end
end

class RefBlinder < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefBlinder")
	end
end

class RefBreed < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefBreed")
	end
end

class RefCoat < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefCoat")
	end
end

class RefColumn < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefColumn")
	end
end

class RefDirection < RefObject
	
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefDirection")
	end
end

class RefRaceType < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefRaceType")
	end
end

class RefRope < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefRope")
	end
end

class RefShoes < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefShoes")
	end
end

class RefSex < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefSex")
	end
end

class RefSexRule < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefSexRule")
	end
end

class RefTrackCondition < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefTrackCondition")
	end
end

