
class Saver
	attr_accessor :dbi_insert
	attr_accessor :dbi_select_tech
	attr_accessor :dbi_select_biz

	def initialize(dbi_insert, dbi_select_tech, dbi_select_by_biz)
		@dbi_insert = dbi_insert
		@dbi_select_by_tech = dbi_select_tech
		@dbi_select_biz = dbi_select_by_biz
		
		@logger = $globalState.logger
	end
	
	def save_breeder(breeder)
		if breeder.id == nil then
			@logger.debug("save_breeder - no ID")
			tech_id = @dbi_select_biz.load_breeder_id(breeder)
			
			if tech_id == nil then
				@logger.debug("save_breeder - no tech ID retrieved, " +
					"inserting breeder")
				@dbi_insert.insert_breeder(breeder)
				@logger.debug("save_breeder - breeder inserted")
			else
				breeder.id = tech_id
			end
			
			@logger.debug("save_breeder - tech ID retrieved: " + breeder.id.to_s)
		else
			@logger.debug("save_breeder - breeder#" + breeder.id.to_s)
		end
	end
	
	def save_horse(horse)
		if horse.id == nil then
			@logger.debug("save_horse - no ID")
			tech_id = @dbi_select_biz.load_horse_id(horse)
			
			if tech_id == nil then
				@logger.debug("save_horse - no tech ID retrieved, " +
					"inserting horse")
				@dbi_insert.insert_horse(horse)
				@logger.debug("save_horse - horse inserted")
			else
				horse.id = tech_id
			end
			
			@logger.debug("save_horse - tech ID retrieved: " + horse.id.to_s)
		else
			@logger.debug("save_horse - horse#" + horse.id.to_s)
		end
	end
	
	def save_job(job)
		if job.id == nil then
			@logger.debug("save_job - no ID")
			tech_id = @dbi_select_biz.load_job_id(job)
			
			if tech_id == nil then
				@logger.debug("save_job - no tech ID retrieved, " +
					"inserting job")
				@dbi_insert.insert_job(job)
				@logger.debug("save_job - job inserted")
			else
				job.id = tech_id
			end
			
			@logger.debug("save_job - tech ID retrieved: " + job.id.to_s)
		else
			@logger.debug("save_job - job#" + job.id.to_s)
		end
	end
	
	def save_jockey(jockey)
		if jockey.id == nil then
			@logger.debug("save_jockey - no ID")
			tech_id = @dbi_select_biz.load_jockey_id(jockey)
			
			if tech_id == nil then
				@logger.debug("save_jockey - no tech ID retrieved, " +
					"inserting jockey")
				@dbi_insert.insert_jockey(jockey)
				@logger.debug("save_jockey - jockey inserted")
			else
				jockey.id = tech_id
			end
			
			@logger.debug("save_jockey - tech ID retrieved: " + jockey.id.to_s)
		else
			@logger.debug("save_jockey - jockey#" + jockey.id.to_s)
		end
	end
	
	def save_meeting(meeting)
		# job.id is required to insert meeting.id
		if meeting.job.id == nil then
			@logger.debug("save_meeting - saving job")
			save_job(meeting.job)
			@logger.debug("save_meeting - job#" + meeting.job.id.to_s)
		end
		
		# weather
		@logger.debug("save_meeting - saving weather")
		save_weather(meeting.weather)
		@logger.debug("save_meeting - weather#" + meeting.weather.id.to_s)
		
		# if the ID is unknown 
		# => if the meeting exists in the DB, its ID is loaded
		# => if the meeting isn't in the DB, it's inserted
		if meeting.id == nil then
			@logger.debug("save_meeting - no ID")
			tech_id = @dbi_select_biz.load_meeting_id(meeting)
			
			if tech_id == nil then
				@logger.debug("save_meeting - no tech ID retrieved, " +
					"inserting meeting")
				@dbi_insert.insert_meeting(meeting)
				@logger.debug("save_meeting - meeting inserted")
			else
				meeting.id = tech_id
			end
			@logger.debug("save_meeting - tech ID retrieved: " + meeting.id.to_s)
		end
		
		# saving the races
		@logger.debug("save_meeting - saving races")
		meeting.race_list.each do |race|
			save_race(race, meeting.id)
		end
	end
	
	def save_meeting_list(meeting_list)
		meeting_list.each do |meeting|
			save_meeting(meeting)
		end
	end
	
	def save_owner(owner)
		if owner.id == nil then
			@logger.debug("save_owner - no ID")
			tech_id = @dbi_select_biz.load_owner_id(owner)
			
			if tech_id == nil then
				@logger.debug("save_owner - no tech ID retrieved, " +
					"inserting owner")
				@dbi_insert.insert_owner(owner)
				@logger.debug("save_owner - owner inserted")
			else
				owner.id = tech_id
			end
			
			@logger.debug("save_owner - tech ID retrieved: " + owner.id.to_s)
		else
			@logger.debug("save_owner - owner#" + owner.id.to_s)
		end
	end
	
	def save_race(race, id_meeting)
		if race.id == nil then
			@logger.debug("save_race - no ID")
			tech_id = @dbi_select_biz.load_race_id(race, id_meeting)
			if tech_id == nil then
				@logger.debug("save_race - no tech ID retrieved, " +
					"inserting race")
				@dbi_insert.insert_race_with_result(race, id_meeting)
				@logger.debug("save_race - race inserted")
			else
				race.id = tech_id
			end
			@logger.debug("save_race - tech ID retrieved: " + race.id.to_s)
		else
			@logger.debug("save_race - race#" + race.id.to_s)
		end
		
		# saving the runners, if necessary
		if race.runner_list != nil then
			@logger.debug("save_race - saving runners")
			race.runner_list.each do |runner|
				save_runner(runner, race.id)
			end
		else
			@logger.debug("save_race - no runners to save")
		end
	end
	
	def save_runner(runner, id_race)
		
		# objects that have already been saved
		# blinder (ref)
		# race
		# shoes (ref)
		
		# objects (check and save)
		# breeder
		# horse
		# jockey
		# owner
		# trainer
		
		# attributes (saved at insert)
		# age
		# commentary
		# description
		# disqualified
		# distance
		# draw
		# earnings_career
		# earnings_currunt_year
		# earnings_last_year
		# earnings_victory
		# final_place
		# history
		# is_favorite
		# is_non_runner
		# is_substitute
		# load_handicap
		# load_ride
		# number
		# places
		# races_run
		# single_rating_after_race
		# single_rating_before_race
		# time
		# url
		# victories
		
		# other 
		# id: retrieved when saved
		
		# objects to check:
		# breeder
		@logger.debug("save_runner - saving breeder")
		save_breeder(runner.breeder)
		@logger.debug("save_runner - breeder#" + runner.breeder.id.to_s)
		
		# horse
		@logger.debug("save_runner - saving horse")
		save_horse(runner.horse)
		@logger.debug("save_runner - horse#" + runner.horse.id.to_s)
		
		# jockey
		@logger.debug("save_runner - saving jockey")
		save_jockey(runner.jockey)
		@logger.debug("save_runner - jockey#" + runner.jockey.id.to_s)
		
		# owner
		@logger.debug("save_runner - saving owner")
		save_owner(runner.owner)
		@logger.debug("save_runner - owner#" + runner.owner.id.to_s)
		
		# trainer
		@logger.debug("save_runner - saving trainer")
		save_trainer(runner.trainer)
		@logger.debug("save_runner - trainer#" + runner.trainer.id.to_s)
		
		if runner.id == nil then
			@logger.debug("save_runner - no ID")
			tech_id = @dbi_select_biz.load_runner_id(runner, id_race)
			
			if tech_id == nil then
				@logger.debug("save_runner - no tech ID retrieved, " +
					"inserting runner")
				@dbi_insert.insert_runner_after_race(runner, id_race)
				@logger.debug("save_runner - runner inserted")
			else
				runner.id = tech_id
			end
			
			@logger.debug("save_trainer - tech ID retrieved: " + runner.id.to_s)
		else
			@logger.debug("save_trainer - runner#" + runner.id.to_s)
		end
	end
	
	def save_trainer(trainer)
		if trainer.id == nil then
			@logger.debug("save_trainer - no ID")
			tech_id = @dbi_select_biz.load_trainer_id(trainer)
			
			if tech_id == nil then
				@logger.debug("save_trainer - no tech ID retrieved, " +
					"inserting trainer")
				@dbi_insert.insert_trainer(trainer)
				@logger.debug("save_trainer - trainer inserted")
			else
				trainer.id = tech_id
			end
			
			@logger.debug("save_trainer - tech ID retrieved: " + trainer.id.to_s)
		else
			@logger.debug("save_trainer - trainer#" + trainer.id.to_s)
		end
	end

	def save_weather(weather)
		if weather.id == nil then
			@logger.debug("save_weather - no ID")
			tech_id = @dbi_select_biz.load_weather_id(weather)
			
			if tech_id == nil then
				@logger.debug("save_weather - no tech ID retrieved, " +
					"inserting weather")
				@dbi_insert.insert_weather(weather)
				@logger.debug("save_weather - weather inserted")
			else
				weather.id = tech_id
			end
			
			@logger.debug("save_weather - tech ID retrieved: " + weather.id.to_s)
		else
			@logger.debug("save_weather - weather#" + weather.id.to_s)
		end
	end
	
end

