class Meeting
	attr_accessor :country
	attr_accessor :date
	attr_accessor :id
	attr_accessor :job
	attr_accessor :number
	attr_accessor :racetrack
	attr_accessor :race_list # in Race table
	attr_accessor :track_condition
	attr_accessor :urls_of_races_array # transient
	attr_accessor :weather

	def initialize(country: nil,
					date: nil,
					id: nil,
					job: nil,
					number: nil,
					racetrack: nil,
					race_list: nil,
					urls_of_races_array: nil,
					track_condition: nil,
					weather: nil)
		@country = country
		@date = date
		@id = id
		@job = job
		@number = number
		@racetrack = racetrack
		@race_list = race_list
		@urls_of_races_array = urls_of_races_array
		@track_condition = track_condition
		@weather = weather
	end


	def biz_id()
		format = $globalState.config[:gen][:default_date_format]
		return "" + date.strftime(format) + "M" + nil_safe_to_s(@number)
	end

	def to_s()
		return "Meeting[id = " + nil_safe_to_s(@id) +
		", country = " + nil_safe_to_s(@country) +
		", date = " + nil_safe_to_s(@date) +
		", job = " + nil_safe_to_s(@job) +
		", number = " + nil_safe_to_s(@number) +
		", racetrack = " + nil_safe_to_s(@racetrack) +
		", track_condition = " + nil_safe_to_s(@track_condition) +
		", urls_of_races_array = " + nil_safe_to_s(@urls_of_races_array) +
		", weather = " + nil_safe_to_s(@weather) +
		", race_list = " + nil_safe_to_s(@race_list) +
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
	attr_accessor :general_conditions
	attr_accessor :name
	attr_accessor :number
	attr_accessor :race_type
	attr_accessor :result
	attr_accessor :result_insertion_time
	attr_accessor :rope
	attr_accessor :runner_list # in Runner table
	attr_accessor :sex_rule
	attr_accessor :time
	attr_accessor :url
	attr_accessor :value

	def initialize(	bets: nil,
					detailed_conditions: nil,
					distance: nil,
					id: nil,
					general_conditions: nil,
					name: nil,
					number: nil,
					race_type: nil,
					result: nil,
					result_insertion_time: nil,
					rope: nil,
					runner_list: nil,
					time: nil,
					sex_rule: nil,
					url: nil,
					value: nil
					)
		@bets = bets
		@detailed_conditions = detailed_conditions
		@distance = distance
		@id = id
		@general_conditions = general_conditions
		@name = name
		@number = number
		@race_type = race_type
		@result = result
		@result_insertion_time = result_insertion_time
		@rope = rope
		@runner_list = runner_list
		@sex_rule = sex_rule
		@time = time
		@url = url
		@value = value
	end

	def biz_id()
		return @number.to_s
	end

	def is_finished?()

	end

	def to_s()
		return "Race[id = " + nil_safe_to_s(@id) +
		", bets = " + nil_safe_to_s(@bets) +
		", detailed_conditions = " + nil_safe_to_s(@detailed_conditions) +
		", distance = " + nil_safe_to_s(@distance) +
		", general_conditions = " + nil_safe_to_s(@general_conditions) +
		", name = " + nil_safe_to_s(@name) +
		", number = " + nil_safe_to_s(@number) +
		", race_type = " + nil_safe_to_s(@race_type) +
		", result = " + nil_safe_to_s(@result) +
		", result_insertion_time = " + nil_safe_to_s(@result_insertion_time) +
		", rope = " + nil_safe_to_s(@rope) +
		", sex_rule = " + nil_safe_to_s(@sex_rule) +
		", time = " + nil_safe_to_s(@time) +
		", url = " + nil_safe_to_s(@url) +
		", value = " + nil_safe_to_s(@value) +
		", runner_list = " + nil_safe_to_s(@runner_list) +
		"]"
	end

	def ==(other_object)
		if not other_object.is_a? Race then
			return false
		end
		if other_object.id == self.id and
		other_object.bets == self.bets and
		other_object.detailed_conditions == self.detailed_conditions and
		other_object.distance == self.distance and
		other_object.general_conditions == self.general_conditions and
		other_object.name == self.name and
		other_object.number == self.number and
		other_object.race_type == self.race_type and
		other_object.result == self.result and
		other_object.result_insertion_time == self.result_insertion_time and
		other_object.rope == self.rope and
		other_object.sex_rule == self.sex_rule and
		other_object.time == self.time and
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

	def initialize(id: nil, insolation: nil, temperature: nil, wind_direction: nil, wind_speed: nil)
		@id = id
		@insolation = insolation
		@temperature = temperature
		@wind_direction = wind_direction
		@wind_speed = wind_speed
	end

	def initialize(jsonWeather)
		@id = id
		@insolation = jsonWeather["nebulositeLibelleCourt"]
		@temperature = jsonWeather["temperature"]
		@wind_direction = jsonWeather["directionVent"]
		@wind_speed = jsonWeather["forceVent"]
	end

	def to_s()
		return "Weather[id = " + nil_safe_to_s(@id) +
		", insolation = " + nil_safe_to_s(@insolation) +
		", temperature = " + nil_safe_to_s(@temperature) +
		", wind_direction = " + nil_safe_to_s(@wind_direction) +
		", wind_speed = " + nil_safe_to_s(@wind_speed) +
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
