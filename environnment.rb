class Meeting
	attr_accessor :date
	attr_accessor :country
	attr_accessor :id
	attr_accessor :job
	attr_accessor :number
	attr_accessor :racetrack
	attr_accessor :race_list
	attr_accessor :track_condition
	attr_accessor :urls_of_races_array
	attr_accessor :weather
	
	def initialize(country: nil, date: nil, job: nil, number: nil, racetrack: nil, urls_of_races_array: nil, track_condition: nil, weather: nil)
		@date = date
		@country = country
		@job = job
		@number = number
		@racetrack = racetrack
		@urls_of_races_array = urls_of_races_array
		@track_condition = track_condition
		@weather = weather
		@race_list = []
	end
	
	def to_s()
		return "Meeting[id = " + @id.to_s +
		", country = " + @country.to_s +
		", date = " + @date.to_s +
		", job = " + @job.to_s +
		", number = " + @number.to_s +
		", racetrack = " + @racetrack.to_s +
		", track_condition = " + @track_condition.to_s + 
		", urls_of_races_array = " + @urls_of_races_array.to_s + 
		", weather = " + @weather.to_s + 
		", race_list = " + @race_list.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Meeting then
			return false
		end
		if other_object.id == self.id and
		other_object.country == self.country and
		other_object.track_condition == self.track_condition and
		other_object.job == self.job and
		other_object.date == self.date and
		other_object.racetrack == self.racetrack and
		other_object.number == self.number and
		other_object.urls_of_races_array == self.urls_of_races_array and
		other_object.weather == self.weather and
		other_object.race_list == self.race_list then
			return true
		else 
			return false
		end
	end
end

class Race
	attr_accessor :bets
	attr_accessor :detailed_conditions
	attr_accessor :distance
	attr_accessor :id
	attr_accessor :meeting
	attr_accessor :general_conditions
	attr_accessor :name
	attr_accessor :number
	attr_accessor :race_type
	attr_accessor :result
	attr_accessor :result_insertion_time
	attr_accessor :runner_list
	attr_accessor :time
	attr_accessor :url
	attr_accessor :value
		
	def initialize(	bets: nil,
					detailed_conditions: nil,
					distance: nil, 
					id: nil, 
					general_conditions: nil,
					meeting: nil, 
					name: nil, 
					number: nil, 
					race_type: nil,
					result: nil,
					result_insertion_time: nil,
					runner_list: nil,
					time: nil,
					url: nil,  
					value: nil
					)
		@bets = bets
		@detailed_conditions = detailed_conditions
		@distance = distance
		@id = id
		@general_conditions = general_conditions
		@meeting = meeting
		@name = name
		@number = number
		@race_type = race_type
		@result = result
		@result_insertion_time = result_insertion_time
		@runner_list = runner_list
		@time = time
		@url = url
		@value = value
	end
	
	def to_s()
		return "Race[id = " + @id.to_s +
		", meeting = " + @meeting.to_s + 
		", race_type = " + @race_type.to_s +
		", time = " + @time.to_s +
		", number = " + @number.to_s +
		", name = " + @name.to_s +
		", general_conditions = " + @general_conditions + 
		", result = " + @result.to_s +
		", result_insertion_time = " + @result_insertion_time.to_s +
		", distance = " + @distance.to_s +
		", detailed_conditions = " + @detailed_conditions.to_s +
		", bets = " + @bets.to_s + 
		", url = " + @url.to_s +
		", value = " + @value.to_s +
		", runner_list = " + @runner_list.to_s + 
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Race then
			return false
		end
		if other_object.id == self.id and
		other_object.meeting == self.meeting and
		other_object.race_type == self.race_type and
		other_object.time == self.time and
		other_object.number == self.number and
		other_object.name == self.name and
		other_object.general_conditions == self.general_conditions and
		other_object.result == self.result and
		other_object.result_insertion_time == self.result_insertion_time and
		other_object.distance == self.distance and
		other_object.detailed_conditions == self.detailed_conditions and
		other_object.bets == self.bets and
		other_object.url == self.url and
		other_object.value == self.value then
			return true
		else 
			return false
		end
	end
end

class Weather
	attr_accessor :id
	attr_accessor :wind_direction
	attr_accessor :temperature
	attr_accessor :wind_speed
	attr_accessor :insolation
	
	def initialize(insolation: nil, temperature: nil, wind_direction: nil, wind_speed: nil)
		@insolation = insolation
		@temperature = temperature
		@wind_direction = wind_direction
		@wind_speed = wind_speed
	end
	
	def to_s()
		return "Weather[id = " + id.to_s +
		", insolation = " + insolation.to_s + 
		", temperature = " + temperature.to_s +
		", wind_direction = " + wind_direction.to_s + 
		", wind_speed = " + wind_speed.to_s +
		"]"
	end
	
	def ==(other_object)
		if not other_object.is_a? Weather then
			return false
		end
		if other_object.id == self.id and
		other_object.wind_direction == self.wind_direction and
		other_object.temperature == self.temperature and
		other_object.wind_speed == self.wind_speed and
		other_object.insolation == self.insolation then
			return true
		else 
			return false
		end
	end
end
