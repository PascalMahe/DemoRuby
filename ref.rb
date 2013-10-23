class RefObject
	attr_accessor :id
	attr_accessor :text	
	
	def initialize(id, text)
		@id = id
		@text = text
	end
	
	def to_s(ref_class)
		return ref_class + " : id = " + id.to_s +
		", text = " + text.to_s
	end
end

class RefDirection < RefObject
	def to_s()
		return to_s("RefDirection")
	end
end

class RefTrackCondition < RefObject
	def to_s()
		return to_s("RefTrackCondition")
	end
end

class RefRaceType < RefObject
	def to_s()
		return to_s("RefRaceType")
	end
end

class RefColumn < RefObject
	def to_s()
		return to_s("RefColumn")
	end
end

class RefBreed < RefObject
	def to_s()
		return to_s("RefBreed")
	end
end

class RefCoat < RefObject
	def to_s()
		return to_s("RefCoat")
	end
end

class RefBlinder < RefObject
	def to_s()
		return to_s("RefBlinder")
	end
end

class RefShoes < RefObject
	def to_s()
		return to_s("RefShoes")
	end
end

