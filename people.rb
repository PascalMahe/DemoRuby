
class Breeder
	attr_accessor :id
	attr_accessor :name
	
	def initialize(
			id: nil,
			name: nil
		)
		@id = id
		@name = name
	end
	
	def to_s()
		return "Breeder[id = " + id.to_s +
		", name = " + name.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Breeder then
			return false
		end
		if other_object.id == self.id and
		other_object.name == self.name then
			return true
		else 
			return false
		end
	end
end

class Horse
	attr_accessor :id
	attr_accessor :breed
	attr_accessor :coat
	attr_accessor :father
	attr_accessor :mother
	attr_accessor :name
	attr_accessor :sex

	def initialize(
			breed: nil,
			coat: nil,
			father: nil,
			id: nil,
			mother: nil,
			name: nil,
			sex: nil
		)
		@id = id
		@breed = breed
		@coat = coat
		@father = father
		@mother = mother
		@name = name
		@sex = sex
	end
	
	def to_s()
		return "Horse[id = " + id.to_s +
		", breed = " + breed.to_s + 
		", coat = " + coat.to_s + 
		", father = " + father.to_s + 
		", mother = " + mother.to_s + 
		", name = " + name.to_s + 
		", sex = " + sex.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Horse then
			return false
		end
		if other_object.id == self.id and
		other_object.breed == self.breed and
		other_object.coat == self.coat and
		other_object.father == self.father and
		other_object.mother == self.mother and
		other_object.name == self.name and
		other_object.sex == self.sex then
			return true
		else 
			return false
		end
	end
end

class Jockey
	attr_accessor :id
	attr_accessor :name
	attr_accessor :jacket
	
	def initialize(
			id: nil,
			jacket: nil,
			name: nil
		)
		@id = id
		@jacket = jacket
		@name = name
	end
	
	def to_s()
		return "Jockey[id = " + id.to_s +
		", name = " + name.to_s + 
		"]"
	end
	
	def to_long_s()
		return "Jockey[id = " + id.to_s +
		", name = " + name.to_s + 
		", jacket = " + jacket.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Jockey then
			return false
		end
		if other_object.id == self.id and
		other_object.name == self.name and
		other_object.jacket == self.jacket then
			return true
		else 
			return false
		end
	end
end

class Owner
	attr_accessor :id
	attr_accessor :name
	
	def initialize(
			id: nil,
			name: nil
		)
		@id = id
		@name = name
	end
	
	def to_s()
		return "Owner[id = " + id.to_s +
		", name = " + name.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Owner then
			return false
		end
		if other_object.id == self.id and
		other_object.name == self.name then
			return true
		else 
			return false
		end
	end
end

class Trainer
	attr_accessor :id
	attr_accessor :name
	
	def initialize(
			id: nil,
			name: nil
		)
		@id = id
		@name = name
	end
	
	def to_s()
		return "Trainer[id = " + id.to_s +
		", name = " + name.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Trainer then
			return false
		end
		if other_object.id == self.id and
		other_object.name == self.name then
			return true
		else 
			return false
		end
	end
end

