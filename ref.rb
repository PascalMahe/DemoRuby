class RefObject
	attr_accessor :id
	attr_accessor :text	
	
	def initialize(id = nil, text)
		@id = id
		@text = text
	end
	
	def to_s(ref_class)
		return ref_class + "[id = " + id.to_s +
		", text = " + text.to_s + "]"
	end
end

class RefObjectContainer < Hash
	
	attr_accessor :class
	attr_accessor :database_interface

	def initialize(class_to_instanciate, database_interface)
		@class = class_to_instanciate
		@database_interface = database_interface
	end
	
	#fetches from text
	def [](text, logger = nil)
		if not self.has_key?(text) then
			if logger != nil then 
				logger.debug("Looking for %s in :" % text)
				logger.debug(self)
			end
			ref_to_add = @class.new(text)
			ref_to_add.id = @database_interface.insert_ref_object(@class, ref_to_add)
			self[text] = ref_to_add
		else
			ref_to_add = self.fetch(text)
		end
		return ref_to_add
	end
	
	#fetches from id
	def get(key)
		# Select gets the element such as value.id == key
		# and returns a hash containing that element.
		# cf. http://www.ruby-doc.org/core-2.0.0/Hash.html#method-i-select
		new_hash = self.select{|k,v| v.id == key}
		# We only want the first element
		return new_hash.shift()[1]
	end
end

class RefDirection < RefObject
	
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefDirection")
	end
end

class RefTrackCondition < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefTrackCondition")
	end
end

class RefRaceType < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return to_s("RefRaceType")
	end
end

class RefSex < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return to_s("RefSex")
	end
end

class RefColumn < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return to_s("RefColumn")
	end
end

class RefBreed < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return to_s("RefBreed")
	end
end

class RefCoat < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return to_s("RefCoat")
	end
end

class RefBlinder < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return to_s("RefBlinder")
	end
end

class RefShoes < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return to_s("RefShoes")
	end
end

