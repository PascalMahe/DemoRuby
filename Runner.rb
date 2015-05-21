
class Runner
	attr_accessor :blinder
	attr_accessor :breeder
	attr_accessor :description
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
	attr_accessor :jockey
	attr_accessor :load
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
	attr_accessor :trainer
	attr_accessor :url
	attr_accessor :victories

	def initialize(
			blinder: nil,
			breeder: nil,
			description: nil,
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
			jockey: nil,
			load: nil,
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
			trainer: nil,
			url: nil,
			victories: nil
			)
		@blinder = blinder
		@breeder = breeder
		@description = description
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
		@jockey = jockey
		@load = load
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
		@trainer = trainer
		@url = url
		@victories = victories

	end
	
	def to_s()
		return "Runner[id = " + id.to_s +
		", blinder = " + blinder.to_s +
		", breeder = " + breeder.to_s +
		", description = " + description.to_s +
		", distance = " + distance.to_s +
		", draw = " + draw.to_s +
		", earnings_career = " + earnings_career.to_s +
		", earnings_current_year = " + earnings_current_year.to_s +
		", earnings_last_year = " + earnings_last_year.to_s +
		", earnings_victory = " + earnings_victory.to_s +
		", final_place = " + final_place.to_s +
		", history = " + history.to_s +
		", jockey = " + jockey.to_s +
		", load = " + load.to_s +
		", non_runner = " + non_runner.to_s +
		", number = " + number.to_s +
		", owner = " + owner.to_s +
		", places = " + places.to_s +
		", race = " + race.to_s +
		", races_run = " + races_run.to_s +
		", score_breeder = " + score_breeder.to_s + 
		", score_horse = " + score_horse.to_s +
		", score_jockey = " + score_jockey.to_s +
		", score_owner = " + score_owner.to_s +
		", score_trainer = " + score_trainer.to_s +
		", single_rating = " + single_rating.to_s +
		", trainer = " + trainer.to_s +
		", url = " + url.to_s +
		", victories = " + victories.to_s +
		"]"
	end
end

