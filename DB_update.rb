require 'sqlite3'
# require 'activerecord-jdbcsqlite3-adapter'
require 'date'
require './ref.rb'
require './DatabaseInterface.rb'

class DatabaseInterfaceUpdate < DatabaseInterface
	
	#UPDATE
	#forecast : result_match_rate & normalised_result_match_rate
	def update_forecast_with_match_rate(forecast)
		values_hash = {
			:result_match_rate => forecast.result_match_rate,
			:normalised_result_match_rate => forecast.normalised_result_match_rate,
			:id => forecast.id
		}
		execute_query(
			@sql[:update][:forecast], 
			@stat_update_forecast, 
			values_hash, 
			false
		)
	end
	
	#race : update result & result_insertion_time
	def update_race_with_result(race)
		race.result_insertion_time.strftime(@config[:gen][:default_date_time_format])
		values_hash = {
			:result => race.result,
			# NB: calling the SQLite function datetime directly in the request fails
			# so we have to trust the race object to have the right times -> no date
			# in the SQL
			# :result_insertion_time => "datetime('now', 'localtime')",
			:result_insertion_time => race.result_insertion_time,
			:id => race.id
		}
		execute_query(
			@sql[:update][:race], 
			@stat_update_race, 
			values_hash, 
			false
		)
	end
	
	#runner :final_place, disqualified, single_rating_after_race
	def update_runner_after_race(runner)
		values_hash = {
			:disqualified => runner.disqualified,
			:final_place => runner.final_place,
			:single_rating_after_race => runner.single_rating_after_race,
			:id => runner.id
		}
		execute_query(
			@sql[:update][:runner], 
			@stat_update_runner, 
			values_hash, 
			false
		)
	end
	
end
