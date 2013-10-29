
class Jockey
	attr_accessor :id
	attr_accessor :name
	attr_accessor :jacket
	
	def to_s()
		return "Jockey[id = " + id.to_s +
		", name = " + name.to_s + 
		", jacket = " + jacket.to_s + 
		"]"
	end
end

class Trainer
	attr_accessor :id
	attr_accessor :name
	
	def to_s()
		return "Trainer[id = " + id.to_s +
		", name = " + name.to_s + 
		"]"
	end
end

class Owner
	attr_accessor :id
	attr_accessor :name
	
	def to_s()
		return "Owner[id = " + id.to_s +
		", name = " + name.to_s + 
		"]"
	end
end

class Breeder
	attr_accessor :id
	attr_accessor :name
	
	def to_s()
		return "Breeder[id = " + id.to_s +
		", name = " + name.to_s + 
		"]"
	end
end

class Horse
	attr_accessor :id
	attr_accessor :name
	attr_accessor :sex
	attr_accessor :breed
	attr_accessor :coat
	
	def to_s()
		return "Horse[id = " + id.to_s +
		", name = " + name.to_s + 
		", sex = " + sex.to_s + 
		", breed = " + breed.to_s + 
		", coat = " + coat.to_s + 
		"]"
	end
end

