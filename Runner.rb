
class Runner
	attr_accessor :id
	attr_accessor :race
	attr_accessor :horse
	attr_accessor :jockey
	attr_accessor :trainer
	attr_accessor :owner
	attr_accessor :breeder
	attr_accessor :blinder
	attr_accessor :shoes
	attr_accessor :number
	attr_accessor :draw
	attr_accessor :single_rating
	attr_accessor :final_place
	attr_accessor :non_runner
	attr_accessor :races_run
	attr_accessor :victories
	attr_accessor :places
	attr_accessor :earnings_career
	attr_accessor :earnings_current_year
	attr_accessor :earnings_last_year
	attr_accessor :earnings_victory
	attr_accessor :description
	attr_accessor :distance
	attr_accessor :load
	attr_accessor :history
	attr_accessor :url
	attr_accessor :score_horse
	attr_accessor :score_jockey
	attr_accessor :score_owner
	attr_accessor :score_trainer
	attr_accessor :score_breeder

	def to_s()
		return "Runner[id = " + id.to_s +
		", race = " + race.to_s +
		", jockey = " + jockey.to_s +
		", trainer = " + trainer.to_s +
		", owner = " + owner.to_s +
		", breeder = " + breeder.to_s +
		", blinder = " + blinder.to_s +
		", number = " + number.to_s +
		", draw = " + draw.to_s +
		", single_rating = " + single_rating.to_s +
		", final_place = " + final_place.to_s +
		", non_runner = " + non_runner.to_s +
		", races_run = " + races_run.to_s +
		", victories = " + victories.to_s +
		", places = " + places.to_s +
		", earnings_career = " + earnings_career.to_s +
		", earnings_current_year = " + earnings_current_year.to_s +
		", earnings_last_year = " + earnings_last_year.to_s +
		", earnings_victory = " + earnings_victory.to_s +
		", description = " + description.to_s +
		", distance = " + distance.to_s +
		", load = " + load.to_s +
		", history = " + history.to_s +
		", url = " + url.to_s +
		", score_horse = " + score_horse.to_s +
		", score_jockey = " + score_jockey.to_s +
		", score_owner = " + score_owner.to_s +
		", score_trainer = " + score_trainer.to_s +
		", score_breeder = " + score_breeder.to_s + 
		"]"
	end
end

