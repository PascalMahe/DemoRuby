require 'sqlite3'
require 'date'
require './ref.rb'
require './DatabaseInterface.rb'

class DatabaseInterfaceInsert < DatabaseInterface
	#INSERTION QUERIES
	#REF
	def insert_ref_object(ref_class, ref_object)
		query = @sql[:insert][:ref_object] % ref_class
		# Note : the statement is not a attribute of the DatabaseInterface 
		# object (not @) because the query can change (query for RefSex, 
		# RefBreed...)
		stat_insert_ref_object = @db.prepare(query)
		ref_object.id = execute_query(
			query, 
			stat_insert_ref_object, 
			{:text => ref_object.text}, 
			true
		)
	end

	def insert_ref_blinder(ref_blinder)
		ref_blinder.id = execute_query(
			@sql[:insert][:ref_blinder], 
			@stat_insert_refblinder, 
			{:text => ref_blinder.text}, 
			true
		)
	end

	def insert_ref_breed(ref_breed)
		ref_breed.id = execute_query(
			@sql[:insert][:ref_breed], 
			@stat_insert_refbreed, 
			{:text => ref_breed.text}, 
			true
		)
	end

	def insert_ref_coat(ref_coat)
		ref_coat.id = execute_query(
			@sql[:insert][:ref_coat], 
			@stat_insert_refcoat, 
			{:text => ref_coat.text}, 
			true
		)
	end

	def insert_ref_column(ref_column)
		ref_column.id = execute_query(
			@sql[:insert][:ref_column], 
			@stat_insert_refcolumn, 
			{:text => ref_column.text}, 
			true
		)
	end

	def insert_ref_direction(ref_direction)
		ref_direction.id = execute_query(
			@sql[:insert][:ref_direction], 
			@stat_insert_refdirection, 
			{:text => ref_direction.text}, 
			true
		)
	end

	def insert_ref_race_type(ref_race_type)
		ref_race_type.id = execute_query(
			@sql[:insert][:ref_race_type], 
			@stat_insert_refrace_type, 
			{:text => ref_race_type.text}, 
			true
		)
	end

	def insert_ref_sex(ref_sex)
		ref_sex.id = execute_query(
			@sql[:insert][:ref_sex], 
			@stat_insert_refsex, 
			{:text => ref_sex.text}, 
			true
		)
	end
		
	def insert_ref_shoes(ref_shoes)
		ref_shoes.id = execute_query(
			@sql[:insert][:ref_shoes], 
			@stat_insert_shoes, 
			{:text => ref_shoes.text}, 
			true
		)
	end
	def insert_ref_track_condition(ref_track_condition)
		ref_track_condition.id = execute_query(
			@sql[:insert][:ref_track_condition], 
			@stat_insert_ref_track_condition, 
			{:text => ref_track_condition.text}, 
			true
		)
	end

	#BUSINESS
	def insert_breeder(breeder)
		values_hash = {
			:name => breeder.name
		}
		breeder.id = execute_query(
			@sql[:insert][:breeder], 
			@stat_insert_breeder, 
			values_hash, 
			true
		)
	end

	def insert_forecast_with_matchrate(forecast)
		values_hash = {
			:origin => forecast.origin.id,
			:race => forecast.race.id, 
			:expected_result => forecast.expected_result,
			:result_match_rate => forecast.result_match_rate,
			:normalised_result_match_rate => 
				forecast.normalised_result_match_rate
		}
		forecast.id = execute_query(
			@sql[:insert][:forecast_with_matchrate], 
			@stat_insert_forecast, 
			values_hash, 
			true
		)
	end

	def insert_forecast_without_matchrate(forecast)
		values_hash = {
			:race => forecast.race.id, 
			:origin => forecast.origin.id,
			:expected_result => forecast.expected_result
		}
		forecast.id = execute_query(
			@sql[:insert][:forecast_without_matchrate], 
			@stat_insert_forecast, 
			values_hash, 
			true
		)
	end

	def insert_horse(horse)
		# optional parameters are assigned if not nil
		if horse.breed != nil then
			breed = horse.breed.id
		end
		if horse.coat != nil then
			coat = horse.coat.id
		end
		if horse.sex != nil then
			sex = horse.sex.id
		end
		values_hash = {
			:breed => breed,
			:coat => coat,
			:father => horse.father.id, 
			:mother => horse.mother.id, 
			:sex => sex, 
			:name => horse.name
		}
		horse.id = execute_query(
			@sql[:insert][:horse], 
			@stat_insert_horse, 
			values_hash, 
			true
		)
	end

	def insert_job(job)
		format = @config[:gen][:database_date_time_format]
		
		start_time = job.start_time.strftime(format)
		
		loading_end_time = nil
		if job.loading_end_time != nil then
			loading_end_time = job.loading_end_time.strftime(format)
		end
		
		crawling_end_time = nil
		if job.crawling_end_time != nil then
			crawling_end_time = job.crawling_end_time.strftime(format)
		end
		
		computing_end_time = nil
		if job.computing_end_time != nil then
			computing_end_time = job.computing_end_time.strftime(format)
		end
		
		values_hash = {
			:start_time => 			start_time, 
			:loading_end_time => 	loading_end_time,
			:crawling_end_time => 	crawling_end_time,
			:computing_end_time => 	computing_end_time
		}
		job.id = execute_query(
			@sql[:insert][:job], 
			@stat_insert_job, 
			values_hash, 
			true
		)
	end

	def insert_jockey(jockey)
		values_hash = {
			:name => jockey.name, 
			:jacket => jockey.jacket
		}
		jockey.id = execute_query(
			@sql[:insert][:jockey], 
			@stat_insert_jockey, 
			values_hash, 
			true
		)
	end

	def insert_meeting(meeting)
		@logger.debug("Seeking to insert meeting : " + meeting.to_s)
		
		if meeting.job != nil then
			job_id = meeting.job.id
		end
		
		if meeting.track_condition != nil then
			track_condition_id = meeting.track_condition.id
		end
		
		if meeting.weather != nil then
			weather_id = meeting.weather.id
		end
		
		values_hash = {
			:country => meeting.country,
			:date => meeting.date.
				strftime(@config[:gen][:default_date_format]),
			:job => job_id,
			:number => meeting.number,
			:racetrack => meeting.racetrack,
			:track_condition => track_condition_id,
			:weather => weather_id
		}
		meeting.id = execute_query(
			@sql[:insert][:meeting], 
			@stat_insert_meeting, 
			values_hash, 
			true
		)
	end

	def insert_origin(origin)
		values_hash = {
			:name => origin.name, 
			:column_order => origin.column_order,
			:url => origin.url
		}
		origin.id = execute_query(
			@sql[:insert][:origin], 
			@stat_insert_origin, 
			values_hash, 
			true
		)
	end

	def insert_owner(owner)
		values_hash = {
			:name => owner.name
		}
		owner.id = execute_query(
			@sql[:insert][:owner], 
			@stat_insert_owner, 
			values_hash, 
			true
		)
	end

	def insert_race_with_result(race, id_meeting)
		
		if race.race_type != nil then
			race_type_id = race.race_type.id
		end
	
		values_hash = {
			:meeting => id_meeting, 
			:race_type => race_type_id,
			:bets => race.bets,
			:detailed_conditions => race.detailed_conditions,
			:distance => race.distance,
			:general_conditions => race.general_conditions,
			:name => race.name,
			:number => race.number, 
			:result => race.result, 
			:result_insertion_time => race.result_insertion_time,
			:time => race.time,
			:url => race.url,
			:value => race.value
		}
		race.id = execute_query(
			@sql[:insert][:race_with_result], 
			@stat_insert_race_with_result, 
			values_hash, 
			true
		)
	end

	def insert_race_without_result(race, id_meeting)
		values_hash = {
			:meeting => id_meeting, 
			:race_type => race.race_type.id,
			:bets => race.bets,
			:detailed_conditions => race.detailed_conditions,
			:distance => race.distance,
			:general_conditions => race.general_conditions,
			:name => race.name,
			:number => race.number, 
			:time => race.time,
			:url => race.url,
			:value => race.value
		}
		race.id = execute_query(
			@sql[:insert][:race_without_result], 
			@stat_insert_race_without_result, 
			values_hash, 
			true
		)
	end

	def insert_runner_after_race(runner, id_race)
		
		# optional parameters that are objects
		if runner.blinder != nil then
			blinder_id = runner.blinder.id
		end
		if runner.shoes != nil then
			shoes_id = runner.shoes.id
		end
		
		values_hash = {
			:blinder => blinder_id, 
			:breeder => runner.breeder.id,
			:horse => runner.horse.id,
			:jockey => runner.jockey.id,
			:owner => runner.owner.id,
			:race => id_race, 
			:shoes => shoes_id,
			:trainer => runner.trainer.id, 
			:age => runner.age,
			:commentary => runner.commentary,
			:description => runner.description,
			:disqualified => runner.disqualified,
			:distance => runner.distance,
			:draw => runner.draw, 
			:earnings_career => runner.earnings_career, 
			:earnings_current_year => runner.earnings_current_year,
			:earnings_last_year => runner.earnings_last_year,
			:earnings_victory => runner.earnings_victory, 
			:final_place => runner.final_place,
			:history => runner.history,
			:is_favorite => runner.is_favorite,
			:is_non_runner => runner.is_non_runner,
			:is_substitute => runner.is_substitute,
			:load_handicap => runner.load_handicap, 
			:load_ride => runner.load_ride, 
			:number => runner.number,
			:places => runner.places,
			:races_run => runner.races_run, 
			:single_rating_after_race => runner.single_rating_after_race,
			:single_rating_before_race => runner.single_rating_before_race,
			:time => runner.time,
			:url => runner.url,
			:victories => runner.victories
		}
		runner.id = execute_query(
			@sql[:insert][:runner_after_race], 
			@stat_insert_runner, 
			values_hash, 
			true
		)
	end

	def insert_runner_before_race(runner, id_race)
	# no final_place, disqualified or single_rating_after_race
		values_hash = {
			:blinder => runner.blinder.id, 
			:breeder => runner.breeder.id,
			:jockey => runner.jockey.id,
			:horse => runner.horse.id,
			:owner => runner.owner.id,
			:race => id_race, 
			:shoes => runner.shoes.id,
			:trainer => runner.trainer.id, 
			:age => runner.age,
			:commentary => runner.commentary,
			:description => runner.description,
			:distance => runner.distance,
			:draw => runner.draw, 
			:earnings_career => runner.earnings_career, 
			:earnings_current_year => runner.earnings_current_year,
			:earnings_last_year => runner.earnings_last_year,
			:earnings_victory => runner.earnings_victory,
			:history => runner.history,
			:is_favorite => runner.is_favorite,
			:is_non_runner => runner.is_non_runner,
			:is_substitute => runner.is_substitute,
			:load_handicap => runner.load_handicap, 
			:load_ride => runner.load_ride, 
			:number => runner.number,
			:places => runner.places,
			:races_run => runner.races_run,
			:single_rating_before_race => runner.single_rating_before_race,
			:time => runner.time,
			:url => runner.url,
			:victories => runner.victories
		}
		runner.id = execute_query(
			@sql[:insert][:runner_before_race], 
			@stat_insert_runner, 
			values_hash, 
			true
		)
	end

	def insert_trainer(trainer)
		values_hash = {
			:name => trainer.name
		}
		trainer.id = execute_query(
			@sql[:insert][:trainer], 
			@stat_insert_trainer, 
			values_hash, 
			true
		)
	end

	def insert_weather(weather)
		values_hash = {
			:wind_direction => weather.wind_direction.id, 
			:insolation => weather.insolation,
			:temperature => weather.temperature,
			:wind_speed => weather.wind_speed
		}
		weather.id = execute_query(
			@sql[:insert][:weather], 
			@stat_insert_weather, 
			values_hash, 
			true
		)
	end

	def insert_weight(weight)
		values_hash = {
			:forecast => weight.forecast.id, 
			:name => weight.name,
			:value => weight.value
		}
		weight.id = execute_query(
			@sql[:insert][:weight], 
			@stat_insert_weight, 
			values_hash, 
			true
		)
	end
end
