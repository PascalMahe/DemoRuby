
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
	attr_accessor :jockey
	attr_accessor :load_handicap
	attr_accessor :load_ride
	attr_accessor :non_runner	
	attr_accessor :number
	attr_accessor :owner
	attr_accessor :places
	attr_accessor :race
	attr_accessor :races_run
	attr_accessor :score_horse
	attr_accessor :score_jockey
	attr_accessor :score_owner
	attr_accessor :score_trainer
	attr_accessor :score_breeder
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
			jockey: nil,
			load_handicap: nil,
			load_ride: nil,
			non_runner: nil,
			number: nil,
			owner: nil,
			places: nil,
			race: nil,
			races_run: nil,
			score_horse: nil,
			score_jockey: nil,
			score_owner: nil,
			score_trainer: nil,
			score_breeder: nil,
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
		@jockey = jockey
		@load_handicap = load_handicap
		@load_ride = load_ride
		@non_runner = non_runner
		@number = number
		@owner = owner
		@places = places
		@race = race
		@races_run = races_run
		@score_breeder = score_breeder
		@score_horse = score_horse
		@score_jockey = score_jockey
		@score_owner = score_owner
		@score_trainer = score_trainer
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
		if @age == nil then 
			@age = other_runner.age
		end
		if @blinder == nil then 
			@blinder = other_runner.blinder 
		end
		if @breeder == nil then 
			@breeder = other_runner.breeder 
		end
		if @commentary == nil then 
			@commentary = other_runner.commentary 
		end
		if @description == nil then 
			@description = other_runner.description 
		end
		if @disqualified == nil then 
			@disqualified = other_runner.disqualified 
		end
		if @distance == nil then 
			@distance = other_runner.distance 
		end
		if @draw == nil then 
			@draw = other_runner.draw 
		end
		if @earnings_career == nil then 
			@earnings_career = other_runner.earnings_career 
		end
		if @earnings_current_year == nil then 
			@earnings_current_year = other_runner.earnings_current_year 
		end
		if @earnings_last_year == nil then 
			@earnings_last_year = other_runner.earnings_last_year 
		end
		if @earnings_victory == nil then 
			@earnings_victory = other_runner.earnings_victory 
		end
		if @final_place == nil then 
			@final_place = other_runner.final_place 
		end
		if @history == nil then 
			@history = other_runner.history 
		end
		if @horse == nil then 
			@horse = other_runner.horse 
		end
		if @id == nil then 
			@id = other_runner.id 
		end
		if @is_favorite == nil then 
			@is_favorite = other_runner.is_favorite 
		end
		
		if @jockey == nil then 
			@jockey = other_runner.jockey 
		end
		if @load_handicap == nil then 
			@load_handicap = other_runner.load_handicap 
		end
		if @load_ride == nil then 
			@load_ride = other_runner.load_ride 
		end
		if @non_runner == nil then 
			@non_runner = other_runner.non_runner 
		end
		if @number == nil then 
			@number = other_runner.number 
		end
		if @owner == nil then 
			@owner = other_runner.owner 
		end
		if @places == nil then 
			@places = other_runner.places 
		end
		if @race == nil then 
			@race = other_runner.race 
		end
		if @races_run == nil then 
			@races_run = other_runner.races_run 
		end
		if @score_breeder == nil then 
			@score_breeder = other_runner.score_breeder 
		end
		if @score_horse == nil then 
			@score_horse = other_runner.score_horse 
		end
		if @score_jockey == nil then 
			@score_jockey = other_runner.score_jockey 
		end
		if @score_owner == nil then 
			@score_owner = other_runner.score_owner 
		end
		if @score_trainer == nil then 
			@score_trainer = other_runner.score_trainer 
		end
		if @shoes == nil then 
			@shoes = other_runner.shoes 
		end
		# $globalState.logger.debug("Runner.join - horse.name = " + @horse.name + ", is_favorite (before): " + pretty(@single_rating) + " other_runner.single_rating: " + pretty(other_runner.single_rating))
		if @single_rating_after_race == nil then 
			@single_rating_after_race = other_runner.single_rating_after_race 
		end
		if @single_rating_before_race == nil then 
			@single_rating_before_race = other_runner.single_rating_before_race 
		end
		# $globalState.logger.debug("Runner.join - single_rating (after): " + pretty(@single_rating))
		
		if @time == nil then 
			@time = other_runner.time 
		end
		if @trainer == nil then 
			@trainer = other_runner.trainer 
		end
		if @url == nil then 
			@url = other_runner.url 
		end
		if @victories == nil then 
			@victories = other_runner.victories 
		end
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
		", history = " + nil_safe_to_s(history) +
		", jockey = " + nil_safe_to_s(jockey) +
		", load_handicap = " + nil_safe_to_s(load_handicap) +
		", load_ride = " + nil_safe_to_s(load_ride) +
		", non_runner = " + nil_safe_to_s(non_runner) +
		", number = " + nil_safe_to_s(number) +
		", owner = " + nil_safe_to_s(owner) +
		", places = " + nil_safe_to_s(places) +
		", race = " + nil_safe_to_s(race) +
		", races_run = " + nil_safe_to_s(races_run) +
		", score_breeder = " + nil_safe_to_s(score_breeder) + 
		", score_horse = " + nil_safe_to_s(score_horse) +
		", score_jockey = " + nil_safe_to_s(score_jockey) +
		", score_owner = " + nil_safe_to_s(score_owner) +
		", score_trainer = " + nil_safe_to_s(score_trainer) +
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

