
class Weather
	attr_accessor :id
	attr_accessor :wind_direction
	attr_accessor :temperature
	attr_accessor :wind_speed
	attr_accessor :insolation
	
	def to_s()
		return "Weather : id = " + id.to_s +
		", wind_direction = " + wind_direction.to_s + 
		", temperature = " + temperature.to_s +
		", wind_speed = " + wind_speed.to_s +
		", insolation = " + insolation.to_s
	end
end

class Meeting
	attr_accessor :id
	attr_accessor :track_condition
	attr_accessor :job
	attr_accessor :date
	attr_accessor :racetrack
	attr_accessor :number
	attr_accessor :url
	attr_accessor :race_list
	
	def to_s()
		return "Meeting : id = " + id.to_s +
		", track_condition = " + track_condition.to_s + 
		", job = " + job.to_s +
		", date = " + date.to_s +
		", racetrack = " + racetrack.to_s +
		", number = " + number.to_s +
		", url = " + url.to_s
	end
end

class Race
	attr_accessor :id
	attr_accessor :meeting
	attr_accessor :racetype
	attr_accessor :time
	attr_accessor :number
	attr_accessor :name
	attr_accessor :country
	attr_accessor :result
	attr_accessor :result_insertion_time
	attr_accessor :distance
	attr_accessor :detailed_conditions
	attr_accessor :bets
	attr_accessor :url
	attr_accessor :value
	attr_accessor :runner_list
	
	def to_s()
		return "Race : id = " + id.to_s +
		", meeting = " + meeting.to_s + 
		", racetype = " + racetype.to_s +
		", time = " + time.to_s +
		", number = " + number.to_s +
		", name = " + name.to_s +
		", country = " + country.to_s + 
		", result = " + result.to_s +
		", result_insertion_time = " + result_insertion_time.to_s +
		", distance = " + distance.to_s +
		", detailed_conditions = " + detailed_conditions.to_s +
		", bets = " + bets.to_s + 
		", url = " + url.to_s +
		", value = " + value.to_s +
		", runner_list = " + runner_list.to_s
	end
end