
class Job
	attr_accessor :id
	attr_accessor :start_time
	attr_accessor :loading_end_time
	attr_accessor :crawling_end_time
	attr_accessor :computing_end_time
end

class Forecast
	attr_accessor :id
	attr_accessor :race
	attr_accessor :origin
	attr_accessor :expected_result
	attr_accessor :result_match_rate
	attr_accessor :normalised_result_match_rate
	attr_accessor :origin_score
end

class Weight
	attr_accessor :id
	attr_accessor :forecast
	attr_accessor :name
	attr_accessor :value
end

class Origin
	attr_accessor :id
	attr_accessor :name
	attr_accessor :column_order
	attr_accessor :url
end

