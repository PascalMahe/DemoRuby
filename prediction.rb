class Forecast
	attr_accessor :id
	attr_accessor :race
	attr_accessor :origin
	attr_accessor :expected_result
	attr_accessor :result_match_rate
	attr_accessor :normalised_result_match_rate
	attr_accessor :origin_score
	
	def to_s()
		return "Forecast[id = " + id.to_s +
		", race = " + race.to_s + 
		", origin = " + origin.to_s +
		", expected_result = " + expected_result.to_s +
		", result_match_rate = " + result_match_rate.to_s +
		", normalised_result_match_rate = " + normalised_result_match_rate.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Forecast then
			return false
		end
		if other_object.id == self.id and
			other_object.race == self.race and
			other_object.origin == self.origin and
			other_object.expected_result == self.expected_result and
			other_object.result_match_rate == self.result_match_rate and
			other_object.normalised_result_match_rate == self.normalised_result_match_rate and
			other_object.origin_score == self.origin_score then
			return true
		else 
			return false
		end
	end
end

class Job
	attr_accessor :id
	attr_accessor :start_time
	attr_accessor :loading_end_time
	attr_accessor :crawling_end_time
	attr_accessor :computing_end_time
	
	def to_s()
		return "Job[id = " + id.to_s +
		", start_time = " + start_time.to_s + 
		", loading_end_time = " + loading_end_time.to_s +
		", crawling_end_time = " + crawling_end_time.to_s +
		", computing_end_time = " + computing_end_time.to_s + "]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Job then
			return false
		end
		if other_object.id == self.id and
			other_object.start_time == self.start_time and
			other_object.loading_end_time == self.loading_end_time and
			other_object.crawling_end_time == self.crawling_end_time and
			other_object.computing_end_time == self.computing_end_time then
			return true
		else 
			return false
		end
	end
end

class Origin
	attr_accessor :id
	attr_accessor :name
	attr_accessor :column_order
	attr_accessor :url
	
	def to_s()
		return "Origin[id = " + id.to_s +
		", name = " + name + 
		", column_order = " + column_order.to_s + 
		", url = " + url.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Origin then
			return false
		end
		if other_object.id == self.id and
			other_object.name == self.name and
			other_object.column_order == self.column_order and
			other_object.url == self.url then
			return true
		else 
			return false
		end
	end
end

class Weight
	attr_accessor :id
	attr_accessor :forecast
	attr_accessor :name
	attr_accessor :value
	
	def to_s()
		return "Weight[id = " + id.to_s +
		", forecast = " + forecast.to_s + 
		", name = " + name.to_s +
		", value = " + value.to_s + 
		"]"
	end
end
