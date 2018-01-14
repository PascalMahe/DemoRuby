require 'sqlite3'
# require 'activerecord-jdbcsqlite3-adapter'
require 'date'
require './ref.rb'
require './DatabaseInterface.rb'

class DatabaseInterfaceSelectByBusinessId < DatabaseInterface
	
	#LOADING QUERIES
	
	
	#BUSINESS
	def load_breeder_id(breeder)
		values_hash = {
			:name => breeder.name
		}
		row = execute_select_w_one_result(
			@sql[:select][:breeder_id], 
			@stat_select_breeder_id, 
			values_hash)
		
		if row != nil then
			tech_id = row["id_breeder"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_horse_id(horse)
		values_hash = {
			:name => horse.name,
			:id_father => horse.father.id,
			:id_mother => horse.mother.id
		}
		row = execute_select_w_one_result(
			@sql[:select][:horse_id], 
			@stat_select_horse_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_horse"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_job_id(job)
		values_hash = {
			:start_time => job.start_time.
				strftime(@config[:gen][:database_date_time_format])
		}
		row = execute_select_w_one_result(
			@sql[:select][:job_id], 
			@stat_select_job_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_job"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_jockey_id(jockey)
		values_hash = {
			:name => jockey.name
		}
		row = execute_select_w_one_result(
			@sql[:select][:jockey_id], 
			@stat_select_jockey_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_jockey"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_meeting_id(meeting)
		values_hash = {
			:date => meeting.date.
				strftime(@config[:gen][:default_date_format]),
			:racetrack => meeting.racetrack
		}
		row = execute_select_w_one_result(
			@sql[:select][:meeting_id], 
			@stat_select_meeting_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_meeting"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_owner_id(owner)
		values_hash = {
			:name => owner.name
		}
		row = execute_select_w_one_result(
			@sql[:select][:owner_id], 
			@stat_select_owner_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_owner"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_race_id(race, id_meeting)
		values_hash = {
			:id_meeting => id_meeting,
			:number => race.number
		}
		row = execute_select_w_one_result(
			@sql[:select][:race_id], 
			@stat_select_race_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_race"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_runner_id(runner, id_race)
		values_hash = {
			:id_race => id_race,
			:number => runner.number
		}
		row = execute_select_w_one_result(
			@sql[:select][:runner_id], 
			@stat_select_runner_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_runner"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_trainer_id(trainer)
		values_hash = {
			:name => trainer.name
		}
		row = execute_select_w_one_result(
			@sql[:select][:trainer_id], 
			@stat_select_trainer_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_trainer"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
	def load_weather_id(weather)
		if weather.wind_direction != nil then
			id_wind_direction = weather.wind_direction.id
		end
		values_hash = {
			:insolation => weather.insolation,
			:temperature => weather.temperature,
			:id_wind_direction => id_wind_direction,
			:wind_speed => weather.wind_speed
		}
		row = execute_select_w_one_result(
			@sql[:select][:weather_id], 
			@stat_select_weather_id, 
			values_hash)
		if row != nil then
			tech_id = row["id_weather"]
		else
			tech_id = nil
		end
		return tech_id
	end
	
end
