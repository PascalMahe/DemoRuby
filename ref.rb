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
	
	attr_accessor :class
	attr_accessor :dbi_insert
	
	def initialize(class_to_instanciate, dbi_insert)
		@class = class_to_instanciate
		@dbi_insert = dbi_insert
	end
	
	# fetches from text
	def [](text)
		if not self.has_key?(text) then
			
			$globalState.logger.debug("Looking for text = %s in :" % text)
			$globalState.logger.debug(self)
			
			ref_to_add = @class.new(text)
			ref_to_add.id = @dbi_insert.insert_ref_object(@class, ref_to_add)
			self[text] = ref_to_add
			
			
			$globalState.logger.debug("Added ref with text = %s in :" % text)
			$globalState.logger.debug(self)
			
		else
			ref_to_add = self.fetch(text)
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

class RefTrackCondition < RefObject
		
	alias :super_to_s :to_s

	def to_s()
		return super_to_s("RefTrackCondition")
	end
end

