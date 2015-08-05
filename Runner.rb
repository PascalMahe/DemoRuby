
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
	attr_accessor :single_rating
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
			single_rating: nil,
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
		@is_favorite = (is_favorite == true)
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
		@single_rating = single_rating
		@time = time
		@trainer = trainer
		@url = url
		@victories = victories

	end
	
	def to_s()
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
		", single_rating = " + nil_safe_to_s(single_rating) +
		", shoes = " + nil_safe_to_s(shoes) +
		", time = " + nil_safe_to_s(time) +
		", trainer = " + nil_safe_to_s(trainer) +
		", url = " + nil_safe_to_s(url) +
		", victories = " + nil_safe_to_s(victories) +
		"]"
		return runner_string
	end
end

