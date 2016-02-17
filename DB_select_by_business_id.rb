require 'sqlite3'
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
		return row["id_breeder"]
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
		return row["id_horse"]
	end
	
	def load_job_id(job)
		values_hash = {
			:start_time => job.start_time
		}
		row = execute_select_w_one_result(
			@sql[:select][:job_id], 
			@stat_select_job_id, 
			values_hash)
		return row["id_job"]
	end
	
	def load_jockey_id(jockey)
		values_hash = {
			:name => breeder.name
		}
		row = execute_select_w_one_result(
			@sql[:select][:jockey_id], 
			@stat_select_jockey_id, 
			values_hash)
		return row["id_jockey"]
	end
	
	def load_meeting_id(meeting)
		values_hash = {
			:date => meeting.date,
			:racetrack => meeting.racetrack
		}
		row = execute_select_w_one_result(
			@sql[:select][:meeting_id], 
			@stat_select_meeting_id, 
			values_hash)
		return row["id_meeting"]
	end
	
	def load_owner_id(owner)
		values_hash = {
			:name => owner.name
		}
		row = execute_select_w_one_result(
			@sql[:select][:owner_id], 
			@stat_select_owner_id, 
			values_hash)
		return row["id_owner"]
	end
	
	def load_race_id(race)
		values_hash = {
			:id_meeting => race.id_meeting.id,
			:number => race.number
		}
		row = execute_select_w_one_result(
			@sql[:select][:race_id], 
			@stat_select_race_id, 
			values_hash)
		return row["id_race"]
	end
	
	def load_runner_id(runner)
		values_hash = {
			:id_race => runner.race.id,
			:number => runner.number
		}
		row = execute_select_w_one_result(
			@sql[:select][:runner_id], 
			@stat_select_runner_id, 
			values_hash)
		return row["id_runner"]
	end
	
	def load_trainer_id(trainer)
		values_hash = {
			:name => trainer.name
		}
		row = execute_select_w_one_result(
			@sql[:select][:trainer_id], 
			@stat_select_trainer_id, 
			values_hash)
		return row["id_trainer"]
	end
	
	def load_weather_id(weather)
		values_hash = {
			:insolation => weather.insolation,
			:wind_speed => weather.wind_speed,
			:temperature => weather.temperature,
			:wind_direction => weather.wind_direction
		}
		row = execute_select_w_one_result(
			@sql[:select][:weather_id], 
			@stat_select_weather_id, 
			values_hash)
		return row["id_weather"]
	end
	
end
