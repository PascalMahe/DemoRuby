
class Runner
	attr_accessor :age
	attr_accessor :blinder
	attr_accessor :breeder
	attr_accessor :commentary
	attr_accessor :description
	attr_accessor :disqualified
	attr_accessor :distance
	attr_accessor :draw
	attr_accessor :earnings_career
	attr_accessor :earnings_current_year
	attr_accessor :earnings_last_year
	attr_accessor :earnings_victory
	attr_accessor :final_place
	attr_accessor :history
	attr_accessor :horse
	attr_accessor :id
	attr_accessor :is_favorite
	attr_accessor :is_non_runner
	attr_accessor :is_substitute
	attr_accessor :jockey
	attr_accessor :load_handicap
	attr_accessor :load_ride
	attr_accessor :number
	attr_accessor :owner
	attr_accessor :places
	attr_accessor :race
	attr_accessor :races_run
	attr_accessor :shoes
	attr_accessor :single_rating_after_race
	attr_accessor :single_rating_before_race
	attr_accessor :time
	attr_accessor :trainer
	attr_accessor :url
	attr_accessor :victories

	def initialize(
			age: nil,
			blinder: nil,
			breeder: nil,
			commentary: nil,
			description: nil,
			disqualified: nil,
			distance: nil,
			draw: nil,
			earnings_career: nil,
			earnings_current_year: nil,
			earnings_last_year: nil,
			earnings_victory: nil,
			final_place: nil,
			history: nil,
			horse: nil,
			id: nil,
			is_favorite: nil,
			is_non_runner: nil,
			is_substitute: nil,
			jockey: nil,
			load_handicap: nil,
			load_ride: nil,
			number: nil,
			owner: nil,
			places: nil,
			race: nil,
			races_run: nil,
			shoes: nil,
			single_rating_after_race: nil,
			single_rating_before_race: nil,
			time: nil,
			trainer: nil,
			url: nil,
			victories: nil
			)
		@blinder = blinder
		@age = age
		@breeder = breeder
		@commentary = commentary
		@description = description
		@disqualified = disqualified
		@distance = distance
		@draw = draw
		@earnings_career = earnings_career
		@earnings_current_year = earnings_current_year
		@earnings_last_year = earnings_last_year
		@earnings_victory = earnings_victory
		@final_place = final_place
		@history = history
		@horse = horse
		@id = id
		@is_favorite = is_favorite
		@is_non_runner = is_non_runner
		@is_substitute = is_substitute
		@jockey = jockey
		@load_handicap = load_handicap
		@load_ride = load_ride
		@number = number
		@owner = owner
		@places = places
		@race = race
		@races_run = races_run
		@shoes = shoes
		@single_rating_after_race = single_rating_after_race
		@single_rating_before_race = single_rating_before_race
		@time = time
		@trainer = trainer
		@url = url
		@victories = victories

	end
	
	def pretty(var)
		str_age = "nil"
		if var != nil
			str_age = var.to_s
		end
		return str_age
	end
	
	def join!(other_runner)
		# int
		@age = choose_good_int(@age, other_runner.age)
		# object
		if @blinder == nil then 
			@blinder = other_runner.blinder 
		end
		# object
		if @breeder == nil then 
			@breeder = other_runner.breeder 
		end
		# string
		@commentary = choose_good_string(@commentary, other_runner.commentary)
		# string
		@description = choose_good_string(@description, other_runner.description)
		# boolean
		if @disqualified == nil then 
			@disqualified = other_runner.disqualified 
		end
		# string
		@distance = choose_good_string(@distance, other_runner.distance)
		# int
		@draw = choose_good_int(@draw, other_runner.draw)
		# float
		@earnings_career = choose_good_float(@earnings_career, other_runner.earnings_career)
		@earnings_current_year = choose_good_float(@earnings_current_year, other_runner.earnings_current_year)
		@earnings_last_year = choose_good_float(@earnings_last_year, other_runner.earnings_last_year)
		@earnings_victory = choose_good_float(@earnings_victory, other_runner.earnings_victory)
		# int
		@final_place = choose_good_int(@final_place, other_runner.final_place)
		# string
		@history = choose_good_string(@history, other_runner.history)
		# object
		if @horse == nil then 
			@horse = other_runner.horse 
		end
		# string
		@id = choose_good_string(@id, other_runner.id)
		
		# boolean
		if @is_favorite == nil then 
			@is_favorite = other_runner.is_favorite 
		end
		if @is_non_runner == nil then 
			@is_non_runner = other_runner.is_non_runner 
		end
		if @is_substitute == nil then 
			@is_substitute = other_runner.is_substitute 
		end
		
		# object
		if @jockey == nil then 
			@jockey = other_runner.jockey 
		end
		# float
		@load_handicap = choose_good_float(@load_handicap, other_runner.load_handicap)
		@load_ride = choose_good_float(@load_ride, other_runner.load_ride)
		
		# int
		@number = choose_good_int(@number, other_runner.number)
		# object
		if @owner == nil then 
			@owner = other_runner.owner 
		end
		# int
		@places = choose_good_int(@places, other_runner.places)
		# object
		if @race == nil then 
			@race = other_runner.race 
		end
		# int
		@races_run = choose_good_int(@races_run, other_runner.races_run)
		
		# object
		if @shoes == nil then 
			@shoes = other_runner.shoes 
		end
		# float
		@single_rating_after_race = choose_good_float(@single_rating_after_race, other_runner.single_rating_after_race)
		@single_rating_before_race = choose_good_float(@single_rating_before_race, other_runner.single_rating_before_race)
		# string
		@time = choose_good_string(@time, other_runner.time)
		# object
		if @trainer == nil then 
			@trainer = other_runner.trainer 
		end
		# string
		# $globalState.logger.debug("Runner.join! - horse.name = " + @horse.name + ", url (before): " + pretty(@url) + " other_runner.url: " + pretty(other_runner.url))
		@url = choose_good_string(@url, other_runner.url)
		# $globalState.logger.debug("Runner.join! - url (after): " + pretty(@url))
		# int
		@victories = choose_good_int(@victories, other_runner.victories)
	end
	
	def choose_good_int(first_int, other_int)
		int_to_return = first_int
		if (first_int == nil and other_int != nil) or 
			(first_int == 0 and (other_int != nil and other_int > 0)) then
			int_to_return = other_int
		end
		return int_to_return
	end
	
	def choose_good_float(first_float, other_float)
		float_to_return = first_float
		if (first_float == nil and other_float != nil) or 
			(first_float == 0.0 and (other_float != nil and other_float > 0.0)) then
			float_to_return = other_float
		end
		return float_to_return
	end
	
	def choose_good_string(first_string, other_string)
		string_to_return = first_string
		if (first_string == nil and other_string != nil) or 
			(first_string == "" and 
				(other_string != nil and other_string != "")) then
			string_to_return = other_string
		end
		return string_to_return
	end
	
	def to_s()
		runner_string = "Runner[id = " + nil_safe_to_s(id) +
		", jockey = " + nil_safe_to_s(jockey) +
		", horse = " + nil_safe_to_s(horse.name) +
		"]"
		return runner_string
	end
	
	
	def to_long_s()
		runner_string = "Runner[id = " + nil_safe_to_s(id) +
		", age = " + nil_safe_to_s(age) +
		", blinder = " + nil_safe_to_s(blinder) +
		", breeder = " + nil_safe_to_s(breeder) +
		", commentary = " + nil_safe_to_s(commentary) +
		", description = " + nil_safe_to_s(description) +
		", disqualified = " + nil_safe_to_s(disqualified) +
		", distance = " + nil_safe_to_s(distance) +
		", draw = " + nil_safe_to_s(draw) +
		", earnings_career = " + nil_safe_to_s(earnings_career) +
		", earnings_current_year = " + nil_safe_to_s(earnings_current_year) +
		", earnings_last_year = " + nil_safe_to_s(earnings_last_year) +
		", earnings_victory = " + nil_safe_to_s(earnings_victory) +
		", final_place = " + nil_safe_to_s(final_place) +
		", is_favorite = " + nil_safe_to_s(is_favorite) +
		", is_non_runner = " + nil_safe_to_s(is_non_runner) +
		", is_substitute = " + nil_safe_to_s(is_substitute) +
		", history = " + nil_safe_to_s(history) +
		", jockey = " + nil_safe_to_s(jockey) +
		", load_handicap = " + nil_safe_to_s(load_handicap) +
		", load_ride = " + nil_safe_to_s(load_ride) +
		", number = " + nil_safe_to_s(number) +
		", owner = " + nil_safe_to_s(owner) +
		", places = " + nil_safe_to_s(places) +
		", race = " + nil_safe_to_s(race) +
		", races_run = " + nil_safe_to_s(races_run) +
		", single_rating_after_race = " + nil_safe_to_s(single_rating_after_race) +
		", single_rating_before_race = " + nil_safe_to_s(single_rating_before_race) +
		", shoes = " + nil_safe_to_s(shoes) +
		", time = " + nil_safe_to_s(time) +
		", trainer = " + nil_safe_to_s(trainer) +
		", url = " + nil_safe_to_s(url) +
		", victories = " + nil_safe_to_s(victories) +
		"]"
		return runner_string
	end
end

