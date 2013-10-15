
class Weather
	attr_accessor :id
	attr_accessor :wind_direction
	attr_accessor :temperature
	attr_accessor :wind_speed
	attr_accessor :insolation
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
end
