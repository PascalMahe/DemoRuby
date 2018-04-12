require 'minitest'

def log_flunking_test(err)
	@logger.error(err.inspect)
	@logger.error(err.backtrace)
	
	interesting_backtrace = []  # in the workspace, 
								# the rest is ignored
	for bkt in err.backtrace do 
		if bkt.include?("workspace") then
			interesting_backtrace.push(bkt)
		end
	end
	
	final_message = err.inspect + " in: \n"
	
	for bkt in interesting_backtrace do
		final_message = final_message + bkt + "\n"
	end
 	flunk(final_message)
end

def validate_blinder(expected_blinder, actual_blinder, str_blinder_identifier)
	validate_ref(expected_blinder, actual_blinder, "Blinder " + str_blinder_identifier)
end

def validate_breeder(expected_breeder, actual_breeder, str_breeder_identifier)
	assert_equal(expected_breeder.id, 	actual_breeder.id,		"Wrong id for " + str_breeder_identifier)
	assert_equal(expected_breeder.name,	actual_breeder.name,	"Wrong name for " + str_breeder_identifier)
end	

def validate_horse(expected_horse, actual_horse, str_horse_identifier)

	if expected_horse != nil and actual_horse != nil then
		assert_equal(expected_horse.breed, 	actual_horse.breed, "Wrong breed for " + str_horse_identifier)
		assert_equal(expected_horse.coat, 	actual_horse.coat, 	"Wrong coat for " + str_horse_identifier)
		assert_equal(expected_horse.name, 	actual_horse.name, 	"Wrong name for " + str_horse_identifier)
		assert_equal(expected_horse.sex, 	actual_horse.sex, 	"Wrong sex for " + str_horse_identifier)
		
		validate_horse(expected_horse.father, actual_horse.father, "father from " + str_horse_identifier)
		validate_horse(expected_horse.mother, actual_horse.mother, "mother from " + str_horse_identifier)
	elsif expected_horse == nil and actual_horse != nil then
		flunk("expected_horse is nil, actual_horse is not.")
	elsif expected_horse != nil and actual_horse == nil then
		flunk("actual_horse is nil, expected_horse is not.")
	end
	@logger.ok("Tests for " + str_horse_identifier + " OK.")
end

def validate_job(expected_job, actual_job, str_job_identifier)
	
	if expected_job != nil and actual_job != nil then
		# both not nil
		validate_time(expected_job.start_time, actual_job.start_time, "start_time", str_job_identifier)
		validate_time(expected_job.loading_end_time, actual_job.loading_end_time, "loading_end_time", str_job_identifier)
		validate_time(expected_job.crawling_end_time, actual_job.crawling_end_time, "crawling_end_time", str_job_identifier)
		validate_time(expected_job.computing_end_time, actual_job.computing_end_time, "computing_end_time", str_job_identifier)
	else
		assert_equal(expected_job, nil, "Wrong expected_job for " + str_job_identifier + " (should not be nil)")
		assert_equal(actual_job, nil, "Wrong actual_job for " + str_job_identifier + " (should not be nil)")
	end
	@logger.ok("Tests for " + str_job_identifier + " OK.")
end

def validate_jockey(expected_jockey, actual_jockey, str_jockey_identifier)
	assert_equal(expected_jockey.id, 		actual_jockey.id,		"Wrong id for " + str_jockey_identifier)
	assert_equal(expected_jockey.name,		actual_jockey.name,		"Wrong name for " + str_jockey_identifier)
	assert_equal(expected_jockey.jacket,	actual_jockey.jacket,	"Wrong jacket for " + str_jockey_identifier)
end

def validate_meeting(expected_meeting, actual_meeting, str_meeting_identifier)
	# simple values
	# @logger.debug("validate_meeting - expected_meeting : " + expected_meeting)
	# @logger.debug("validate_meeting - actual_meeting : " + actual_meeting)
	# @logger.debug("validate_meeting - str_meeting_identifier : " + str_meeting_identifier)
	assert_equal(expected_meeting.date,					actual_meeting.date, 				"Wrong date for " + str_meeting_identifier)
	assert_equal(expected_meeting.country, 				actual_meeting.country, 			"Wrong country for " + str_meeting_identifier)
	
	assert_equal(expected_meeting.number, 				actual_meeting.number, 				"Wrong number for " + str_meeting_identifier)
	assert_equal(expected_meeting.racetrack, 			actual_meeting.racetrack, 			"Wrong racetrack for " + str_meeting_identifier)
	
	assert_equal(expected_meeting.track_condition,		actual_meeting.track_condition, 	"Wrong track_condition for " + str_meeting_identifier)
	assert_equal(expected_meeting.urls_of_races_array,	actual_meeting.urls_of_races_array,	"Wrong urls_of_races_array for " + str_meeting_identifier)

	validate_job(expected_meeting.job, actual_meeting.job, "job from " + str_meeting_identifier)
	validate_weather(expected_meeting.weather, actual_meeting.weather, "weather from " + str_meeting_identifier)
	
	if expected_meeting.race_list != nil and 
		actual_meeting.race_list != nil then
		
		assert_equal(expected_meeting.race_list.size, actual_meeting.race_list.size, "Wrong race_list.size for " + str_meeting_identifier)
		@logger.debug("validate_meeting - race_list.size = " + expected_meeting.race_list.size.to_s)
		for i in 0..expected_meeting.race_list.size do
			expected_race = expected_meeting.race_list[i]
			actual_race = actual_meeting.race_list[i]
			if expected_race != nil then
				assert_operator(actual_race, :!=, nil, "Wrong race (num: " + i.to_s + ") in actual_meeting.race_list for " + str_meeting_identifier + " (should not be nil)")
				validate_race(expected_race, 
							actual_race, 
							"race from " + str_meeting_identifier)
			else
				assert_equal(actual_race, nil, "Wrong race (num: " + i.to_s + ") in actual_meeting.race_list for " + str_meeting_identifier + " (should be nil)")
			end
			
		end
	else 
		assert_equal(nil, expected_meeting.race_list, "Wrong expected_meeting.race_list for " + str_meeting_identifier + " (should be nil)")
		assert_equal(nil, actual_meeting.race_list, "Wrong actual_meeting.race_list for " + str_meeting_identifier + " (should be nil)")
	end
	@logger.ok("Tests for " + str_meeting_identifier + " OK.")
end

def validate_owner(expected_owner, actual_owner, str_owner_identifier)
	assert_equal(expected_owner.id, 	actual_owner.id,	"Wrong id for " + str_owner_identifier)
	assert_equal(expected_owner.name,	actual_owner.name,	"Wrong name for " + str_owner_identifier)
end

def validate_race(expected_race, 
					actual_race, 
					str_race_identifier,
					result_insertion_time_before = nil)
	assert_equal(expected_race.bets, 					actual_race.bets, 					"Wrong bets for " + str_race_identifier)
	assert_equal(expected_race.detailed_conditions, 	actual_race.detailed_conditions, 	"Wrong detailed_conditions for " + str_race_identifier)
	assert_equal(expected_race.distance, 				actual_race.distance, 				"Wrong distance for " + str_race_identifier)  
	assert_equal(expected_race.general_conditions, 		actual_race.general_conditions, 	"Wrong general_conditions for " + str_race_identifier)
	assert_equal(expected_race.name, 					actual_race.name, 					"Wrong name for " + str_race_identifier) 
	assert_equal(expected_race.number, 					actual_race.number, 				"Wrong number for " + str_race_identifier) 
	assert_equal(expected_race.race_type, 				actual_race.race_type, 				"Wrong race_type for " + str_race_identifier) 
	assert_equal(expected_race.rope, 					actual_race.rope, 					"Wrong rope for " + str_race_identifier)
	assert_equal(expected_race.result, 					actual_race.result, 				"Wrong result for " + str_race_identifier)
	assert_equal(expected_race.time, 					actual_race.time, 					"Wrong time for " + str_race_identifier)
	assert_equal(expected_race.url, 					actual_race.url, 					"Wrong url for " + str_race_identifier)  
	assert_equal(expected_race.value, 					actual_race.value, 					"Wrong value for " + str_race_identifier)  
	assert_equal(expected_race.sex_rule, 				actual_race.sex_rule, 				"Wrong sex_rule for " + str_race_identifier)  
	# @logger.debug("validate_race - expected_race.result_insertion_time = " + 
		# expected_race.result_insertion_time.to_s)
		
	if result_insertion_time_before == nil then
		@logger.debug("validate_race - ritb is nil -> checking race.rit with validate_time")
		# if result_insertion_time_before is nil, we're testing the recovery 
		# from the database and the result must be exact (or very very close)
		validate_time(expected_race.result_insertion_time, 	
						actual_race.result_insertion_time,  
						"result_insertion_time", 
						str_race_identifier)
	else 
		# if result_insertion_time_before is not nil, we're testing the 
		# values from crawling and we can't know precisely when they'll
		# be crawled 
		# so we check the value is between result_insertion_time_before,
		# which should be armed before calling the crawling function, and
		# the expected_race's result_insertion_time, which represents then
		# later barrier (in the before <= time <= after)
		@logger.debug("validate_race - ritb is not nil -> checking ritb < race.rit < actual.rit")
		
		ritb_as_str = result_insertion_time_before.
					strftime(@config[:gen][:default_date_time_format])
		actual_rit_as_str = actual_race.result_insertion_time.
					strftime(@config[:gen][:default_date_time_format])
		expected_rit_as_str = actual_race.result_insertion_time.
					strftime(@config[:gen][:default_date_time_format])
		
		@logger.debug("validate_race - ritb : " + ritb_as_str)
		@logger.debug("validate_race - race.rit : " + actual_rit_as_str)
		@logger.debug("validate_race - actual.rit : " + expected_rit_as_str)
		
		rit_is_between = actual_race.result_insertion_time.between?(
							result_insertion_time_before, 
							expected_race.result_insertion_time)
		
		assert_equal(true, 
						rit_is_between, 
						"Wrong result_insertion_time for " + 
						str_race_identifier + ", " + 
						actual_rit_as_str + " isn't between " + 
						ritb_as_str + " and " + 
						expected_rit_as_str)
		
	end
	
	# Checking runner_list's value would be too costly (in term of tests' development) so,
	# we just check its length
	if expected_race.runner_list != nil then
		assert_operator(actual_race.runner_list, 
						:!=, 
						nil, 
						"Wrong runner_list for " + 
							str_race_identifier + 
							" (should not be nil)")
		assert_equal(expected_race.runner_list.length,
						actual_race.runner_list.length, 
						"Wrong runner_list.length for " + str_race_identifier)
	else
		assert_equal(nil, 
					actual_race.runner_list, 
					"Wrong runner_list for " + 
						str_race_identifier + 
						" (should be nil)")
	end
	
	@logger.ok("Tests for " + str_race_identifier + " OK.")
end

def validate_ref(expected_ref, actual_ref, str_ref_identifier)	
	assert_equal(expected_ref.id, 	actual_ref.id,		"Wrong id for " + str_ref_identifier)
	assert_equal(expected_ref.text,	actual_ref.text,	"Wrong text for " + str_ref_identifier)
end

def validate_time(expected_time, actual_time, str_time_identifier, str_test_identifier)
	if expected_time != nil then
		assert_operator(actual_time, :!=, nil, "Wrong " + str_time_identifier + " for " + str_test_identifier + " (should not be nil)")
		# making sure expected_time and actual_time
		# are, in fact, times
		if not expected_time.is_a? Numeric then
			expected_time_as_time = expected_time.to_time
		else
			expected_time_as_time = expected_time
		end
		if not actual_time.is_a? Numeric then
			actual_time_as_time = actual_time.to_time
		else
			actual_time_as_time = actual_time
		end
		
		# actual test
		abs_diff_between_start_times = (expected_time_as_time - actual_time_as_time).abs
		assert_operator(60.00, :>=, abs_diff_between_start_times, 	"Wrong " + str_time_identifier + " for " + str_test_identifier)
	else
		assert_equal(nil, actual_time, 	"Wrong " + str_time_identifier + " for " + str_test_identifier + " (should be nil)")		
	end
end

def validate_trainer(expected_trainer, actual_trainer, str_trainer_identifier)
	assert_equal(expected_trainer.id, 	actual_trainer.id,		"Wrong id for " + str_trainer_identifier)
	assert_equal(expected_trainer.name,	actual_trainer.name,	"Wrong name for " + str_trainer_identifier)
end

def validate_weather(expected_weather, actual_weather, str_weather_identifier)
	if expected_weather != nil and actual_weather != nil then
		# both not nil
		assert_equal(expected_weather.wind_direction,	actual_weather.wind_direction,	"Wrong wind_direction for " + str_weather_identifier)
		assert_equal(expected_weather.temperature,		actual_weather.temperature,	"Wrong temperature for " + str_weather_identifier)
		assert_equal(expected_weather.wind_speed,		actual_weather.wind_speed,	"Wrong wind_speed for " + str_weather_identifier)
		assert_equal(expected_weather.insolation,		actual_weather.insolation,	"Wrong insolation for " + str_weather_identifier)
	else
		assert_equal(expected_weather, nil, "Wrong expected_weather for " + str_weather_identifier + " (should not be nil)")
		assert_equal(actual_weather, nil, "Wrong actual_weather for " + str_weather_identifier + " (should not be nil)")
	end
	@logger.ok("Tests for " + str_weather_identifier + " OK.")
end

def validate_runner(expected_runner, actual_runner, str_runner_identifier)
	validate_horse(expected_runner.horse, actual_runner.horse, "horse from " + str_runner_identifier)
	
	assert_equal(expected_runner.breeder.name, 				actual_runner.breeder.name, 			"Wrong breeder.name for " + str_runner_identifier)
	assert_equal(expected_runner.description, 				actual_runner.description, 				"Wrong description for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_career, 			actual_runner.earnings_career, 			"Wrong earnings_career for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_current_year, 	actual_runner.earnings_current_year,	"Wrong earnings_current_year for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_last_year, 		actual_runner.earnings_last_year, 		"Wrong earnings_last_year for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_victory, 			actual_runner.earnings_victory, 		"Wrong earnings_victory for " + str_runner_identifier)
	assert_equal(expected_runner.places, 					actual_runner.places, 					"Wrong places for " + str_runner_identifier)
	assert_equal(expected_runner.races_run, 				actual_runner.races_run, 				"Wrong races_run for " + str_runner_identifier)
	assert_equal(expected_runner.trainer.name, 				actual_runner.trainer.name, 			"Wrong trainer.name for " + str_runner_identifier)
	assert_equal(expected_runner.victories, 				actual_runner.victories, 				"Wrong victories for " + str_runner_identifier)
	
	validate_owner(expected_runner.owner, actual_runner.owner, 		"owner from " + str_runner_identifier)
		
	@logger.ok("Tests for " + str_runner_identifier + " OK.")
end

def validate_runner_shallow(expected_runner, actual_runner, str_runner_identifier)

	assert_equal(expected_runner.age, 						actual_runner.age, 							"Wrong age for " + str_runner_identifier)
	assert_equal(expected_runner.blinder, 					actual_runner.blinder, 						"Wrong blinder for " + str_runner_identifier)
	assert_equal(expected_runner.distance, 					actual_runner.distance, 					"Wrong distance for " + str_runner_identifier)
	assert_equal(expected_runner.draw, 						actual_runner.draw, 						"Wrong draw for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_career, 			actual_runner.earnings_career, 				"Wrong earnings_career for " + str_runner_identifier)
	assert_equal(expected_runner.history, 					actual_runner.history, 						"Wrong history for " + str_runner_identifier)
	assert_equal(expected_runner.is_non_runner, 			actual_runner.is_non_runner, 				"Wrong is_favorite for " + str_runner_identifier)
	assert_equal(expected_runner.is_substitute, 			actual_runner.is_substitute, 				"Wrong is_substitute for " + str_runner_identifier)
	assert_equal(expected_runner.load_handicap, 			actual_runner.load_handicap, 				"Wrong load_handicap for " + str_runner_identifier)
	assert_equal(expected_runner.load_ride, 				actual_runner.load_ride, 					"Wrong load_ride for " + str_runner_identifier)
	assert_equal(expected_runner.horse.name, 				actual_runner.horse.name, 					"Wrong horse.name for " + str_runner_identifier)
	assert_equal(expected_runner.number, 					actual_runner.number, 						"Wrong number for " + str_runner_identifier)
	# assert_equal(expected_runner.race, 						actual_runner.race, 						"Wrong race for " + str_runner_identifier)
	assert_equal(expected_runner.shoes, 					actual_runner.shoes, 						"Wrong shoes for " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_before_race, actual_runner.single_rating_before_race, 	"Wrong single_rating for " + str_runner_identifier)
	assert_equal(expected_runner.horse.sex, 				actual_runner.horse.sex, 					"Wrong horse.sex for " + str_runner_identifier)
	assert_equal(expected_runner.url, 						actual_runner.url, 							"Wrong url for " + str_runner_identifier)
	
	validate_jockey(expected_runner.jockey, actual_runner.jockey, 	"jockey from " + str_runner_identifier)
	
	@logger.ok("Tests (shallow) for runner " + str_runner_identifier + " OK.")
end

def validate_runner_from_runner_list(expected_runner, actual_runner, str_runner_identifier)
	# not nil values
	assert_equal(expected_runner.age, 					actual_runner.age, 					"Wrong age for " + str_runner_identifier)
	assert_equal(expected_runner.blinder, 				actual_runner.blinder, 				"Wrong blinder for " + str_runner_identifier)
	assert_equal(expected_runner.commentary, 			actual_runner.commentary, 			"Wrong commentary for " + str_runner_identifier)
	assert_equal(expected_runner.description, 			actual_runner.description, 			"Wrong description for " + str_runner_identifier)
	assert_equal(expected_runner.disqualified, 			actual_runner.disqualified, 		"Wrong disqualified for " + str_runner_identifier)
	assert_equal(expected_runner.distance, 				actual_runner.distance, 			"Wrong distance for " + str_runner_identifier)
	assert_equal(expected_runner.draw, 					actual_runner.draw, 				"Wrong draw for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_career, 		actual_runner.earnings_career, 		"Wrong earnings_career for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_current_year,	actual_runner.earnings_current_year,"Wrong earnings_current_year for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_last_year, 	actual_runner.earnings_last_year, 	"Wrong earnings_last_year for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_victory, 		actual_runner.earnings_victory, 	"Wrong earnings_victory for " + str_runner_identifier)
	assert_equal(expected_runner.final_place, 			actual_runner.final_place, 			"Wrong final_place for " + str_runner_identifier)
	assert_equal(expected_runner.history, 				actual_runner.history, 				"Wrong history for " + str_runner_identifier)
	assert_equal(expected_runner.is_favorite, 			actual_runner.is_favorite, 			"Wrong is_favorite for " + str_runner_identifier)
	assert_equal(expected_runner.is_non_runner, 		actual_runner.is_non_runner, 		"Wrong is_non_runner for " + str_runner_identifier)
	assert_equal(expected_runner.is_pregnant, 			actual_runner.is_pregnant, 			"Wrong is_pregnant for " + str_runner_identifier)
	assert_equal(expected_runner.is_substitute, 		actual_runner.is_substitute, 		"Wrong is_substitute for " + str_runner_identifier)
	assert_equal(expected_runner.load_handicap, 		actual_runner.load_handicap, 		"Wrong load_handicap for " + str_runner_identifier)
	assert_equal(expected_runner.load_ride, 			actual_runner.load_ride, 			"Wrong load_ride for " + str_runner_identifier)
	assert_equal(expected_runner.number, 				actual_runner.number, 				"Wrong number for " + str_runner_identifier)
	assert_equal(expected_runner.places, 				actual_runner.places, 				"Wrong places for " + str_runner_identifier)
	# assert_equal(expected_runner.race, 					actual_runner.race, 				"Wrong race for " + str_runner_identifier)
	assert_equal(expected_runner.races_run, 			actual_runner.races_run, 			"Wrong races_run for " + str_runner_identifier)
	assert_equal(expected_runner.shoes, 				actual_runner.shoes, 				"Wrong shoes for " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_before_race, 			
				actual_runner.single_rating_before_race,
				"Wrong single_rating_before_race for " + str_runner_identifier)
	assert_equal(expected_runner.time, 					actual_runner.time, 				"Wrong time for " + str_runner_identifier)
	assert_equal(expected_runner.url, 					actual_runner.url, 					"Wrong url for " + str_runner_identifier)
	# FIXME If real website does have a URL per runner
	# assert_equal(expected_runner.disqualified, 		actual_runner.url, 					"Wrong url for " + str_runner_identifier)
	assert_equal(expected_runner.victories, 			actual_runner.victories, 			"Wrong victories for " + str_runner_identifier)
	assert_equal(expected_runner.breeder.name, 			actual_runner.breeder.name, 		"Wrong breeder.name for " + str_runner_identifier)
	assert_equal(expected_runner.horse.breed, 			actual_runner.horse.breed, 			"Wrong horse.breed for " + str_runner_identifier)
	assert_equal(expected_runner.horse.coat, 			actual_runner.horse.coat, 			"Wrong horse.coat for " + str_runner_identifier)
	assert_equal(expected_runner.horse.father, 			actual_runner.horse.father, 		"Wrong horse.father for " + str_runner_identifier)
	assert_equal(expected_runner.horse.mother, 			actual_runner.horse.mother, 		"Wrong horse.mother for " + str_runner_identifier)
	assert_equal(expected_runner.horse.mother.father, 	actual_runner.horse.mother.father, 	"Wrong horse.mother.father for " + str_runner_identifier)
	assert_equal(expected_runner.horse.name, 			actual_runner.horse.name, 			"Wrong horse.name for " + str_runner_identifier)
	assert_equal(expected_runner.horse.sex, 			actual_runner.horse.sex, 			"Wrong horse.sex for " + str_runner_identifier)
	assert_equal(expected_runner.trainer.name,			actual_runner.trainer.name, 		"Wrong trainer.name for " + str_runner_identifier)
	
	validate_jockey(expected_runner.jockey, actual_runner.jockey, 	"jockey from " + str_runner_identifier)
	validate_owner(expected_runner.owner, actual_runner.owner, 		"owner from " + str_runner_identifier)
	
	# nil values
	assert_equal(nil, actual_runner.id, 						"Id not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.single_rating_after_race,	"Single_rating_after_race not nil for " + str_runner_identifier)
	
	@logger.ok("Tests (from: results) for runner " + str_runner_identifier + " OK.")
end

def validate_runner_from_result_list(expected_runner, actual_runner, str_runner_identifier)
	# not nil values
	assert_equal(expected_runner.commentary,	actual_runner.commentary, 		"Wrong commentary for " + str_runner_identifier)
	assert_equal(expected_runner.disqualified, 	actual_runner.disqualified, 	"Wrong disqualified for " + str_runner_identifier)
	assert_equal(expected_runner.distance, 		actual_runner.distance, 		"Wrong distance for " + str_runner_identifier)
	assert_equal(expected_runner.final_place, 	actual_runner.final_place, 		"Wrong final_place for " + str_runner_identifier)
	assert_equal(expected_runner.is_favorite, 	actual_runner.is_favorite, 		"Wrong is_favorite for " + str_runner_identifier)
	assert_equal(expected_runner.is_non_runner, actual_runner.is_non_runner, 	"Wrong is_non_runner for " + str_runner_identifier)
	assert_equal(expected_runner.is_pregnant, 	actual_runner.is_pregnant, 		"Wrong is_pregnant for " + str_runner_identifier)
	assert_equal(expected_runner.is_substitute, actual_runner.is_substitute,	"Wrong is_substitute for " + str_runner_identifier)
	assert_equal(expected_runner.number, 		actual_runner.number, 			"Wrong number for " + str_runner_identifier)
	assert_equal(expected_runner.url, 			actual_runner.url, 				"Wrong url for " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_after_race, 
				actual_runner.single_rating_after_race, 						"Wrong single_rating_after_race for " + str_runner_identifier)
	assert_equal(expected_runner.time, 			actual_runner.time, 			"Wrong time for " + str_runner_identifier)
	
	# nil values
	assert_equal(nil, actual_runner.age, 						"Age not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.blinder, 					"Blinder not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.breeder, 					"Breeder not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.description, 				"Description not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.draw, 						"Draw not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.earnings_career, 			"Earnings_career not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.earnings_current_year, 		"Earnings_current_year not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.earnings_last_year, 		"Earnings_last_year not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.earnings_victory, 			"Earnings_victory not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.history, 					"History not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.horse, 						"Horse not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.id, 						"Id not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.jockey, 					"Jockey not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.load_handicap, 				"Load_handicap not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.load_ride, 					"Load_ride not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.owner, 						"Owner not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.places, 					"Places not nil for " + str_runner_identifier)
	# assert_equal(nil, actual_runner.race, 						"Race not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.races_run, 					"Races_run not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.shoes, 						"Shoes not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.single_rating_before_race,	"Single_rating_before_race not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.trainer, 					"Trainer not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.victories, 					"Victories not nil for " + str_runner_identifier)
	
	@logger.ok("Tests (from: runner) for runner " + str_runner_identifier + " OK.")
end

def validate_joint_runner(expected_runner, actual_runner, str_runner_identifier)
	assert_equal(expected_runner.age, 						actual_runner.age, 							"Wrong age for " + str_runner_identifier)
	assert_equal(expected_runner.blinder, 					actual_runner.blinder, 						"Wrong blinder for " + str_runner_identifier)
	assert_equal(expected_runner.commentary, 				actual_runner.commentary, 					"Wrong commentary for " + str_runner_identifier)		
	assert_equal(expected_runner.description, 				actual_runner.description, 					"Wrong description for " + str_runner_identifier)
	assert_equal(expected_runner.disqualified, 				actual_runner.disqualified, 				"Wrong disqualified for " + str_runner_identifier)
	assert_equal(expected_runner.distance, 					actual_runner.distance, 					"Wrong distance for " + str_runner_identifier)
	assert_equal(expected_runner.draw, 						actual_runner.draw, 						"Wrong draw for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_career,			actual_runner.earnings_career, 				"Wrong earnings_career for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_current_year,		actual_runner.earnings_current_year,		"Wrong earnings_current_year for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_last_year, 		actual_runner.earnings_last_year, 			"Wrong earnings_last_year for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_victory, 			actual_runner.earnings_victory, 			"Wrong earnings_victory for " + str_runner_identifier)
	assert_equal(expected_runner.final_place, 				actual_runner.final_place, 					"Wrong final_place for " + str_runner_identifier)
	assert_equal(expected_runner.history, 					actual_runner.history, 						"Wrong history for " + str_runner_identifier)
	assert_equal(expected_runner.is_favorite, 				actual_runner.is_favorite, 					"Wrong is_favorite for " + str_runner_identifier)
	assert_equal(expected_runner.is_non_runner, 			actual_runner.is_non_runner, 				"Wrong is_non_runner for " + str_runner_identifier)
	assert_equal(expected_runner.is_pregnant, 				actual_runner.is_pregnant, 					"Wrong is_pregnant for " + str_runner_identifier)
	assert_equal(expected_runner.is_substitute, 			actual_runner.is_substitute, 				"Wrong is_substitute for " + str_runner_identifier)
	assert_equal(expected_runner.load_handicap, 			actual_runner.load_handicap, 				"Wrong load_handicap for " + str_runner_identifier)
	assert_equal(expected_runner.load_ride, 				actual_runner.load_ride, 					"Wrong load_ride for " + str_runner_identifier)
	assert_equal(expected_runner.number, 					actual_runner.number, 						"Wrong number for " + str_runner_identifier)
	assert_equal(expected_runner.places, 					actual_runner.places, 						"Wrong places for " + str_runner_identifier)
	
	assert_equal(expected_runner.races_run, 				actual_runner.races_run, 					"Wrong races_run for " + str_runner_identifier)
	assert_equal(expected_runner.shoes, 					actual_runner.shoes, 						"Wrong shoes for " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_after_race,	actual_runner.single_rating_after_race, 	"Wrong single_rating for " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_before_race,	actual_runner.single_rating_before_race,	"Wrong single_rating for " + str_runner_identifier)
	assert_equal(expected_runner.time, 						actual_runner.time, 						"Wrong time for " + str_runner_identifier)
	# FIXME If real website does have a URL per runner
	assert_equal(expected_runner.url, 						actual_runner.url, 							"Wrong url for " + str_runner_identifier)
	assert_equal(expected_runner.victories, 				actual_runner.victories, 					"Wrong victories for " + str_runner_identifier)
	assert_equal(expected_runner.breeder.name, 				actual_runner.breeder.name, 				"Wrong breeder.name for " + str_runner_identifier)
	assert_equal(expected_runner.horse.sex, 				actual_runner.horse.sex, 					"Wrong horse.sex for " + str_runner_identifier)
	assert_equal(expected_runner.trainer.name, 				actual_runner.trainer.name, 				"Wrong trainer.name for " + str_runner_identifier)
	
	
	# assert_equal(expected_runner.race, 						actual_runner.race, 						"Wrong race for " + str_runner_identifier)
	# validate_race(expected_runner.race, 	actual_runner.race, 	"race from " + str_runner_identifier)
	validate_horse(expected_runner.horse, 	actual_runner.horse, 	"horse from " + str_runner_identifier)
	validate_jockey(expected_runner.jockey, actual_runner.jockey, 	"jockey from " + str_runner_identifier)
	validate_owner(expected_runner.owner, actual_runner.owner, 		"owner from " + str_runner_identifier)
	
	@logger.ok("Tests (after joining) for " + str_runner_identifier + " OK.")
end