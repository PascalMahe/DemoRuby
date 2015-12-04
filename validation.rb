require 'minitest'

def validate_race(expected_race, actual_race, str_race_identifier)
	# @logger.debug("validate_race_R1_C7 - actual_race: " + actual_race.to_s)
	@logger.debug("validate_race_R1_C7 - actual_race.runner_list is nil: " + (actual_race.runner_list == nil).to_s)
	@logger.debug("validate_race_R1_C7 - expected_race.runner_list is nil: " + (expected_race.runner_list == nil).to_s)
	assert_equal(expected_race.detailed_conditions, 	actual_race.detailed_conditions, 	"Wrong detailed_conditions for " + str_race_identifier)
	assert_equal(expected_race.distance, 				actual_race.distance, 				"Wrong distance for " + str_race_identifier)  
	assert_equal(expected_race.general_conditions, 		actual_race.general_conditions, 	"Wrong general_conditions for " + str_race_identifier)
	assert_equal(expected_race.name, 					actual_race.name, 					"Wrong name for " + str_race_identifier) 
	assert_equal(expected_race.number, 					actual_race.number, 				"Wrong number for " + str_race_identifier) 
	assert_equal(expected_race.race_type, 				actual_race.race_type, 				"Wrong race_type for " + str_race_identifier)
	assert_equal(expected_race.result, 					actual_race.result, 				"Wrong result for " + str_race_identifier)
	# assert_equal(expected_race.result_insertion_time, 	actual_race.result_insertion_time, 	"Wrong result_insertion_time for " + str_race_identifier)
	# assert_equal(expected_race.runner_list, 			actual_race.runner_list, 			"Wrong runner_list for " + str_race_identifier)
	
	# Checking runner_list's value would be too costly (in term of development) so,
	# we just check its length
	assert_equal(expected_race.runner_list.length, 		actual_race.runner_list.length, 	"Wrong runner_list.length for " + str_race_identifier)
	assert_equal(expected_race.time, 					actual_race.time, 					"Wrong time for " + str_race_identifier)
	assert_equal(expected_race.url, 					actual_race.url, 					"Wrong url for " + str_race_identifier)  
	assert_equal(expected_race.value, 					actual_race.value, 					"Wrong value for " + str_race_identifier)  
	
	assert_operator(5, :<=, (expected_race.result_insertion_time - actual_race.result_insertion_time) * 60 * 1000 , 	"Wrong result_insertion_time for " + str_race_identifier)
	
	validate_meeting(expected_race.meeting, 				actual_race.meeting, 			"meeting from " + str_race_identifier) 

	@logger.ok("Tests for race " + str_race_identifier + " OK.")
end

def validate_race_R1_C7(fetched_race, meeting)
	# @logger.debug("validate_race_R1_C7 - fetched_race: " + fetched_race.to_s)
	verif_bets = 166715.00
	verif_detailed_conditions = "PRIX DES TROTTEURS \"SANG-FROID\" Course 7 Course Internationale Départ à l'Autostart 20.000. - Attelé. - 2.100 mètres (G. P.) 9.000, 5.000, 2.800, 1.600, 1.000, 400, 200. Course spéciale sur invitation réservée à 12 trotteurs \"Sang-Froid\" sélectio nés par les Fédérations de Finlande, Norvège et Suède. 3 chevaux seront menés par des jockeys français désignés p r la SECF."
	verif_distance = 2100
	verif_general_conditions = "Internationale - Autostart Corde à gauche"
	verif_meeting = meeting
	verif_name = "PRIX DES TROTTEURS \"SANG-FROID\""
	verif_number = 7
	verif_race_type = @ref_list_hash[:ref_race_type_list]["Attelé"]
	verif_result = "3 - 7 - 1 - 10 - 6 - 2 - 12"
	verif_result_insertion_time = Time::new
	verif_runner_list = []
	for i in 0..11 do
		verif_runner_list[i] = Runner::new
	end
	# @logger.debug("validate_race_R1_C7 - verif_runner_list: " + verif_runner_list.to_s)
	verif_time =  Time::new(1, 1, 1, 16, 30)
	verif_url = "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7.htm"
	verif_value =  20000
	
	verif_race = Race::new(
		bets: verif_bets,
		detailed_conditions: verif_detailed_conditions,
		distance: verif_distance,  
		general_conditions: verif_general_conditions,
		meeting: verif_meeting, 
		name: verif_name, 
		number: verif_number, 
		race_type: verif_race_type,
		result: verif_result,
		result_insertion_time: verif_result_insertion_time,
		runner_list: verif_runner_list,
		time: verif_time,
		url: verif_url,  
		value: verif_value
	)
	validate_race(verif_race, fetched_race, "R1 C7")
end

def validate_weather(expected_weather, actual_weather, str_weather_identifier)
	assert_equal(expected_weather.wind_direction,	actual_weather.wind_direction,	"Wrong wind_direction for " + str_weather_identifier)
	assert_equal(expected_weather.temperature,	actual_weather.temperature,	"Wrong temperature for " + str_weather_identifier)
	assert_equal(expected_weather.wind_speed,	actual_weather.wind_speed,	"Wrong wind_speed for " + str_weather_identifier)
	assert_equal(expected_weather.insolation,	actual_weather.insolation,	"Wrong insolation for " + str_weather_identifier)
	
	@logger.ok("Tests for weather " + str_weather_identifier + " OK.")
end

def  validate_job(expected_job, actual_job, str_job_identifier)
	assert_equal(expected_job.start_time,			actual_job.start_time,			"Wrong start_time for " + str_job_identifier)
	assert_equal(expected_job.loading_end_time,		actual_job.loading_end_time,	"Wrong loading_end_time for " + str_job_identifier)
	assert_equal(expected_job.crawling_end_time,	actual_job.crawling_end_time,	"Wrong crawling_end_time for " + str_job_identifier)
	assert_equal(expected_job.computing_end_time,	actual_job.computing_end_time,	"Wrong computing_end_time for " + str_job_identifier)
	
	@logger.ok("Tests for job " + str_job_identifier + " OK.")
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
	assert_equal(expected_meeting.race_list, 			actual_meeting.race_list,			"Wrong race_list for " + str_meeting_identifier)
	assert_equal(expected_meeting.track_condition,		actual_meeting.track_condition, 	"Wrong track_condition for " + str_meeting_identifier)
	assert_equal(expected_meeting.urls_of_races_array,	actual_meeting.urls_of_races_array,	"Wrong urls_of_races_array for " + str_meeting_identifier)

	validate_job(expected_meeting.job, actual_meeting.job, "job from " + str_meeting_identifier)
	validate_weather(expected_meeting.weather, actual_meeting.weather, "weather from " + str_meeting_identifier)
	
	@logger.ok("Tests for meeting " + str_meeting_identifier + " OK.")
end

def validate_runner_shallow(expected_runner, actual_runner, str_runner_identifier)

	assert_equal(expected_runner.age, 						actual_runner.age, 				"Wrong age for " + str_runner_identifier)
	assert_equal(expected_runner.blinder, 					actual_runner.blinder, 			"Wrong blinder for " + str_runner_identifier)
	assert_equal(expected_runner.distance, 					actual_runner.distance, 		"Wrong distance for " + str_runner_identifier)
	assert_equal(expected_runner.draw, 						actual_runner.draw, 			"Wrong draw for " + str_runner_identifier)
	assert_equal(expected_runner.earnings_career, 			actual_runner.earnings_career, 	"Wrong earnings_career for " + str_runner_identifier)
	assert_equal(expected_runner.history, 					actual_runner.history, 			"Wrong history for " + str_runner_identifier)
	assert_equal(expected_runner.is_substitute, 			actual_runner.is_substitute, 	"Wrong is_substitute for " + str_runner_identifier)
	assert_equal(expected_runner.jockey.name, 				actual_runner.jockey.name, 		"Wrong jockey.name for " + str_runner_identifier)
	assert_equal(expected_runner.load_handicap, 			actual_runner.load_handicap, 	"Wrong load_handicap for " + str_runner_identifier)
	assert_equal(expected_runner.load_ride, 				actual_runner.load_ride, 		"Wrong load_ride for " + str_runner_identifier)
	assert_equal(expected_runner.horse.name, 				actual_runner.horse.name, 		"Wrong horse.name for " + str_runner_identifier)
	assert_equal(expected_runner.non_runner, 				actual_runner.non_runner, 		"Wrong is_favorite for " + str_runner_identifier)
	assert_equal(expected_runner.number, 					actual_runner.number, 			"Wrong number for " + str_runner_identifier)
	assert_equal(expected_runner.race, 						actual_runner.race, 			"Wrong race for " + str_runner_identifier)
	assert_equal(expected_runner.shoes, 					actual_runner.shoes, 			"Wrong shoes for " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_before_race, actual_runner.single_rating_before_race, 	"Wrong single_rating for " + str_runner_identifier)
	assert_equal(expected_runner.horse.sex, 				actual_runner.horse.sex, 		"Wrong horse.sex for " + str_runner_identifier)
	assert_equal(expected_runner.url, 						actual_runner.url, 				"Wrong url for " + str_runner_identifier)
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
	assert_equal(expected_runner.is_substitute, 		actual_runner.is_substitute, 		"Wrong is_substitute for " + str_runner_identifier)
	assert_equal(expected_runner.load_handicap, 		actual_runner.load_handicap, 		"Wrong load_handicap for " + str_runner_identifier)
	assert_equal(expected_runner.load_ride, 			actual_runner.load_ride, 			"Wrong load_ride for " + str_runner_identifier)
	assert_equal(expected_runner.non_runner, 			actual_runner.non_runner, 			"Wrong non_runner for " + str_runner_identifier)
	assert_equal(expected_runner.number, 				actual_runner.number, 				"Wrong number for " + str_runner_identifier)
	assert_equal(expected_runner.places, 				actual_runner.places, 				"Wrong places for " + str_runner_identifier)
	assert_equal(expected_runner.race, 					actual_runner.race, 				"Wrong race for " + str_runner_identifier)
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
	assert_equal(expected_runner.jockey.name, 			actual_runner.jockey.name, 			"Wrong jockey.name for " + str_runner_identifier)
	assert_equal(expected_runner.horse.breed, 			actual_runner.horse.breed, 			"Wrong horse.breed for " + str_runner_identifier)
	assert_equal(expected_runner.horse.coat, 			actual_runner.horse.coat, 			"Wrong horse.coat for " + str_runner_identifier)
	assert_equal(expected_runner.horse.father, 			actual_runner.horse.father, 		"Wrong horse.father for " + str_runner_identifier)
	assert_equal(expected_runner.horse.mother, 			actual_runner.horse.mother, 		"Wrong horse.mother for " + str_runner_identifier)
	assert_equal(expected_runner.horse.mother.father, 	actual_runner.horse.mother.father, 	"Wrong horse.mother.father for " + str_runner_identifier)
	assert_equal(expected_runner.horse.name, 			actual_runner.horse.name, 			"Wrong horse.name for " + str_runner_identifier)
	assert_equal(expected_runner.horse.sex, 			actual_runner.horse.sex, 			"Wrong horse.sex for " + str_runner_identifier)
	assert_equal(expected_runner.owner.name, 			actual_runner.owner.name, 			"Wrong owner.name for " + str_runner_identifier)
	assert_equal(expected_runner.trainer.name,			actual_runner.trainer.name, 		"Wrong trainer.name for " + str_runner_identifier)
	
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
	assert_equal(expected_runner.is_substitute, actual_runner.is_substitute,	"Wrong is_substitute for " + str_runner_identifier)
	assert_equal(expected_runner.non_runner, 	actual_runner.non_runner, 		"Wrong non_runner for " + str_runner_identifier)
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
	assert_equal(nil, actual_runner.race, 						"Race not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.races_run, 					"Races_run not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.score_horse, 				"Score_horse not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.score_jockey, 				"Score_jockey not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.score_owner, 				"Score_owner not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.score_trainer, 				"Score_trainer not nil for " + str_runner_identifier)
	assert_equal(nil, actual_runner.score_breeder, 				"Score_breeder not nil for " + str_runner_identifier)
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
	assert_equal(expected_runner.is_substitute, 			actual_runner.is_substitute, 				"Wrong is_substitute for " + str_runner_identifier)
	assert_equal(expected_runner.load_handicap, 			actual_runner.load_handicap, 				"Wrong load_handicap for " + str_runner_identifier)
	assert_equal(expected_runner.load_ride, 				actual_runner.load_ride, 					"Wrong load_ride for " + str_runner_identifier)
	assert_equal(expected_runner.non_runner, 				actual_runner.non_runner, 					"Wrong non_runner for " + str_runner_identifier)
	assert_equal(expected_runner.number, 					actual_runner.number, 						"Wrong number for " + str_runner_identifier)
	assert_equal(expected_runner.places, 					actual_runner.places, 						"Wrong places for " + str_runner_identifier)
	assert_equal(expected_runner.race, 						actual_runner.race, 						"Wrong race for " + str_runner_identifier)
	assert_equal(expected_runner.races_run, 				actual_runner.races_run, 					"Wrong races_run for " + str_runner_identifier)
	assert_equal(expected_runner.score_horse, 				actual_runner.score_horse, 					"Wrong score_horse for " + str_runner_identifier)
	assert_equal(expected_runner.score_jockey, 				actual_runner.score_jockey, 				"Wrong score_jockey for " + str_runner_identifier)
	assert_equal(expected_runner.score_owner, 				actual_runner.score_owner, 					"Wrong score_owner for " + str_runner_identifier)
	assert_equal(expected_runner.score_trainer, 			actual_runner.score_trainer, 				"Wrong score_trainer for " + str_runner_identifier)
	assert_equal(expected_runner.score_breeder, 			actual_runner.score_breeder, 				"Wrong score_breeder for " + str_runner_identifier)
	assert_equal(expected_runner.shoes, 					actual_runner.shoes, 						"Wrong shoes for " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_after_race,	actual_runner.single_rating_after_race, 	"Wrong single_rating for " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_before_race,	actual_runner.single_rating_before_race,	"Wrong single_rating for " + str_runner_identifier)
	assert_equal(expected_runner.time, 						actual_runner.time, 						"Wrong time for " + str_runner_identifier)
	# FIXME If real website does have a URL per runner
	assert_equal(expected_runner.url, 						actual_runner.url, 							"Wrong url for " + str_runner_identifier)
	assert_equal(expected_runner.victories, 				actual_runner.victories, 					"Wrong victories for " + str_runner_identifier)
	assert_equal(expected_runner.breeder.name, 				actual_runner.breeder.name, 				"Wrong breeder.name for " + str_runner_identifier)
	assert_equal(expected_runner.jockey.name, 				actual_runner.jockey.name, 					"Wrong jockey.name for " + str_runner_identifier)
	assert_equal(expected_runner.horse.breed, 				actual_runner.horse.breed, 					"Wrong horse.breed for " + str_runner_identifier)
	assert_equal(expected_runner.horse.coat, 				actual_runner.horse.coat, 					"Wrong horse.coat for " + str_runner_identifier)
	assert_equal(expected_runner.horse.father, 				actual_runner.horse.father, 				"Wrong horse.father for " + str_runner_identifier)
	assert_equal(expected_runner.horse.mother, 				actual_runner.horse.mother, 				"Wrong horse.mother for " + str_runner_identifier)
	assert_equal(expected_runner.horse.mother.father, 		actual_runner.horse.mother.father, 			"Wrong horse.mother.father for " + str_runner_identifier)
	assert_equal(expected_runner.horse.name, 				actual_runner.horse.name, 					"Wrong horse.name for " + str_runner_identifier)
	assert_equal(expected_runner.horse.sex, 				actual_runner.horse.sex, 					"Wrong horse.sex for " + str_runner_identifier)
	assert_equal(expected_runner.owner.name, 				actual_runner.owner.name, 					"Wrong owner.name for " + str_runner_identifier)
	assert_equal(expected_runner.trainer.name, 				actual_runner.trainer.name, 				"Wrong trainer.name for " + str_runner_identifier)
	
	@logger.ok("Tests (after joining) for " + str_runner_identifier + " OK.")
end

def validate_runner_R4_C5_N2(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "stronghold")
	grand_father = Horse::new(name: "doyoun")
	mother = Horse::new(name: "haifaa", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "P Strydom")
	trainer = Trainer::new(name: "L W GOOSEN")
	owner = Owner::new(name: "MESSRS C M COMAROFF & B K PARKER")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Negev",
						sex: sex)
	expected_runner = Runner::new(
		age: 5,
		blinder: blinder,
		breeder: breeder,
		commentary: nil,
		description: "",
		disqualified: nil,
		distance: nil,
		draw: 11,
		earnings_career: 54359.00,
		earnings_current_year: 3527.00,
		earnings_last_year: 8944.00,
		earnings_victory: 7098.00,
		final_place: nil,
		history: "2p2p3p6p",
		horse: horse,
		is_favorite: nil,
		is_substitute: false,
		jockey: jockey,
		load_handicap: 60.0,
		load_ride: 0.0,
		non_runner: false,
		number: 2,
		owner: owner,
		places: 14,
		race: race_to_test,
		races_run: 23,
		shoes: shoes,
		single_rating_before_race: 0.0,
		time: nil,
		trainer: trainer,
		url: "",
		victories: 2)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R4_C5_N2 (first, is_favorite)")
end

def validate_runner_R4_C5_N4(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "black minnaloushe")
	grand_father = Horse::new(name: "cordoba")
	mother = Horse::new(name: "light fandango", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "M V'rensburg")
	trainer = Trainer::new(name: "S M FERREIRA")
	owner = Owner::new(name: "MRS L C A BOUWER")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Cat's Game",
						sex: sex)
	expected_runner = Runner::new(
				age: 5,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: nil,
				description: "",
				draw: 8,
				earnings_career: 11334.00,
				earnings_current_year: 0.00,
				earnings_last_year: 5117.00,
				earnings_victory: 6921.00,
				final_place: nil,
				history: "5p8p2p6p",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 59.0,
				load_ride: 0.0,
				non_runner: false,
				number: 4,
				places: 5,
				race: race_to_test,
				races_run: 12,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_CAT'S_GAME.htm"
				victories: 2,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R4_C5_N4(no place, no dist)")
end

def validate_runner_R4_C5_N5(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "eyeofthetiger")
	grand_father = Horse::new(name: "argosy")
	mother = Horse::new(name: "missdefied", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "S Brown")
	trainer = Trainer::new(name: "L J ERASMUS")
	owner = Owner::new(name: "MR L J & MRS M J ERASMUS")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Aim Of The Game",
						sex: sex)
	expected_runner = Runner::new(
				age: 6,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: nil,
				description: "",
				draw: 3,
				earnings_career: 24095.00,
				earnings_current_year: 4408.00,
				earnings_last_year: 12601.00,
				earnings_victory: 15898.00,
				final_place: nil,
				history: "1p7p(13)9p8p",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 58.0,
				load_ride: 0.0,
				non_runner: false,
				number: 5,
				places: 15,
				race: race_to_test,
				races_run: 43,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_AIM_OF_THE_GAME.htm"
				victories: 5,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R4_C5_N5(10th, with dist)")
end

def validate_runner_R4_C5_N17(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	sex = @ref_list_hash[:ref_sex_list][""]
	
	father = Horse::new(name: "windrush")
	grand_father = Horse::new(name: "northern guest")
	mother = Horse::new(name: "arctic game", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "")
	trainer = Trainer::new(name: "G H VAN ZYL")
	owner = Owner::new(name: "MR A D C A FERNANDES")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Lizzy Grey",
						sex: sex)
	expected_runner = Runner::new(
				age: 0,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: nil,
				description: "",
				draw: 0,
				earnings_career: 7845.00,
				earnings_current_year: 1190.00,			
				earnings_last_year: 1491.00,
				earnings_victory: 2753.00,
				final_place: nil,
				history: "",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 0.0,
				load_ride: 0.0,
				non_runner: true,
				number: 17,
				places: 8,
				race: race_to_test,
				races_run: 16,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_LIZZY_GREY.htm"
				victories: 1,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R4_C5_N17 (non runner)")
end

def validate_runner_R1_C1_N4(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["M"]
	
	father = Horse::new(name: "first de retz")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "leda d'occagnes", father: grand_father)
	
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "A. Abrivard")
	trainer = Trainer::new(name: "J.M. BAZIRE")
	owner = Owner::new(name: "Ecurie des CHARMES")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Valroy",
						sex: sex)
	expected_runner = Runner::new(
				age: 5,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: 2700,
				description: "",
				draw: 0,
				earnings_career: 105130.00,
				earnings_current_year: 9520.00,			
				earnings_last_year: 53550.00,
				earnings_victory: 37500.00,
				final_place: nil,
				history: "3m(13)2mDm",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 67.0,
				load_ride: 0.0,
				non_runner: false,
				number: 9,
				places: 11,
				race: race_to_test,
				races_run: 28,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALROY.htm"
				victories: 4,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R1_C1_N4(favorite)")
end

def validate_runner_R1_C1_N5(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_POSTERIEURS"]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["H"]
	
	father = Horse::new(name: "prodigious")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "pocket edition", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "")
	trainer = Trainer::new(name: "G H VAN ZYL")
	owner = Owner::new(name: "MR A D C A FERNANDES")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Lizzy Grey",
						sex: sex)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "D. Bonne")
	trainer = Trainer::new(name: "S. ERNAULT")
	owner = Owner::new(name: "Ecurie du MAZA")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Virgious Du Maza",
						sex: sex)
	expected_runner = Runner::new(
				age: 5,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: 2700,
				description: "",
				draw: 0,
				earnings_career: 85060.00,
				earnings_current_year: 0.00,			
				earnings_last_year: 69400.00,
				earnings_victory: 67600.00,
				final_place: nil,
				history: "DmDa(13)1m",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 67.0,
				load_ride: 0.0,
				non_runner: false,
				number: 5,
				places: 6,
				race: race_to_test,
				races_run: 16,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VIRGIOUS_DU_MAZA.htm"
				victories: 5,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R1_C1_N5(1st)")
end

def validate_runner_R1_C1_N9(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["H"]
	
	father = Horse::new(name: "nijinski blue")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "nectarine turgot", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "M. Abrivard")
	trainer = Trainer::new(name: "P. COIGNARD")
	owner = Owner::new(name: "P. COIGNARD")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Valdez Turgot",
						sex: sex)
	expected_runner = Runner::new(
				age: 5,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: 2700,
				description: "",
				draw: 0,
				earnings_career: 84980.00,
				earnings_current_year: 27900.00,			
				earnings_last_year: 54060.00,
				earnings_victory: 72900.00,
				final_place: nil,
				history: "1m3m(13)1m",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 67.0,
				load_ride: 0.0,
				non_runner: false,
				number: 4,
				places: 8,
				race: race_to_test,
				races_run: 23,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALDEZ_TURGOT.htm"
				victories: 6,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R1_C1_N9(disqualified)")
end

def validate_runner_R2_C7_N1(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["H"]
	
	father = Horse::new(name: "martaline")
	grand_father = Horse::new(name: "sanglamore")
	mother = Horse::new(name: "la haie blanche", father: grand_father)
	
	breeder = Breeder::new(name: "MR DANIEL CHASSAGNEUX")
	jockey = Jockey::new(name: "J.rougier")
	trainer = Trainer::new(name: "MACAIRE (S)")
	owner = Owner::new(name: "JD.COTTON")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Franz Quercus",
						sex: sex)
	expected_runner = Runner::new(
				age: 7,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: nil,
				description: "",
				draw: 0,
				earnings_career: 60330.00,
				earnings_current_year: 0.00,			
				earnings_last_year: 0.00,
				earnings_victory: 48960.00,
				final_place: nil,
				history: "1s1h3h(11)1s",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 72.0,
				load_ride: 68.0,
				non_runner: false,
				number: 1,
				places: 3,
				race: race_to_test,
				races_run: 9,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_FRANZ_QUERCUS.htm"
				victories: 5,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R2_C7_N1(favorite)")
end

def validate_runner_R2_C7_N4(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list]["ALEZAN"]
	sex = @ref_list_hash[:ref_sex_list]["H"]
	
	father = Horse::new(name: "medicean")
	grand_father = Horse::new(name: "trempolino")
	mother = Horse::new(name: "vivacity", father: grand_father)
	
	breeder = Breeder::new(name: "STILVI COMPANIA FINANCIERA S.A.")
	jockey = Jockey::new(name: "A.lecordier")
	trainer = Trainer::new(name: "C.SCANDELLA")
	owner = Owner::new(name: "A.CANAVERO")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Grypas",
						sex: sex)
	expected_runner = Runner::new(
				age: 7,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: nil,
				description: "",
				draw: 0,
				earnings_career: 21175.00,
				earnings_current_year: 0.00,			
				earnings_last_year: 21175.00,
				earnings_victory: 14400.00,
				final_place: nil,
				history: "9hAh1h4h5h5h",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 68.0,
				load_ride: 0.0,
				non_runner: false,
				number: 4,
				places: 4,
				race: race_to_test,
				races_run: 13,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm"
				victories: 2,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R2_C7_N4(12th)")
end

def validate_runner_R2_C7_N11(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "assessor")
	grand_father = Horse::new(name: "garde royale")
	mother = Horse::new(name: "notting hill", father: grand_father)
	
	breeder = Breeder::new(name: "MR GILLES TRAPENARD")
	jockey = Jockey::new(name: "C.abou")
	trainer = Trainer::new(name: "MME F.GIMMI PELLEGRINO")
	owner = Owner::new(name: "MME F.GIMMI PELLEGRINO")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Viva Voce Sivola",
						sex: sex)
	expected_runner = Runner::new(
				age: 5,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: nil,
				description: "",
				draw: 0,
				earnings_career: 9970.00,
				earnings_current_year: 0.00,			
				earnings_last_year: 3825.00,
				earnings_victory: 0.00,
				final_place: nil,
				history: "3aThAh5s5s3h",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 64.0,
				load_ride: 61.0,
				non_runner: false,
				number: 11,
				places: 6,
				race: race_to_test,
				races_run: 19,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_VIVA_VOCE_SIVOLA.htm"
				victories: 0,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R2_C7_N11(1st)")
end

def validate_runner_R2_C7_N12(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_AUSTRALIENNES"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "bonbon rose")
	grand_father = Horse::new(name: "saint preuil")
	mother = Horse::new(name: "sainte kash", father: grand_father)
	
	breeder = Breeder::new(name: "MR ARNAUD CHAILLE-CHAILLE")
	jockey = Jockey::new(name: "B.lestrade")
	trainer = Trainer::new(name: "M.SEROR")
	owner = Owner::new(name: "S.HOFFMEISTER")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Tweety Kash",
						sex: sex)
	expected_runner = Runner::new(
				age: 5,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: nil,
				description: "",
				draw: 0,
				earnings_career: 17775.00,
				earnings_current_year: 0.00,			
				earnings_last_year: 17775.00,
				earnings_victory: 10560.00,
				final_place: nil,
				history: "AhAsTs6h(13)",
				is_favorite: nil,
				is_substitute: true,
				load_handicap: 64.0,
				load_ride: 65.0,
				non_runner: false,
				number: 12,
				places: 4,
				race: race_to_test,
				races_run: 13,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_TWEETY_KASH.htm"
				victories: 2,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R2_C7_N12(substitute)")
end

def validate_runner_R1_C7_N1(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
	coat = @ref_list_hash[:ref_coat_list]["BAI FONCE"]
	sex = @ref_list_hash[:ref_sex_list]["M"]
	
	father = Horse::new(name: "jarvsofaks")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "norheim elle", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "T.e. Solberg")
	trainer = Trainer::new(name: "Georg William SVERDRUP")
	owner = Owner::new(name: "Georg William SVERDRUP (NOR)")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Norheim Jaerv",
						sex: sex)
	expected_runner = Runner::new(
				age: 6,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: 2100,
				description: "",
				draw: 0,
				earnings_career: 120946.00,
				earnings_current_year: 0.00,			
				earnings_last_year: 0.00,
				earnings_victory: 0.00,
				final_place: nil,
				history: "6a1a(13)3a",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 0.0,
				load_ride: 0.0,
				non_runner: false,
				number: 1,
				places: 0,
				race: race_to_test,
				races_run: 0,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_NORHEIM_JAERV.htm"
				victories: 0,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R1_C7_N1(favorite)")
end

def validate_runner_R1_C7_N3(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS"]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
	coat = @ref_list_hash[:ref_coat_list]["NOIR"]
	sex = @ref_list_hash[:ref_sex_list]["M"]
	
	father = Horse::new(name: "mortvedt jerkeld")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "faks perla", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "G. Gudmestad")
	trainer = Trainer::new(name: "G. GUDMESTAD")
	owner = Owner::new(name: "Ecurie JAROS (NOR)")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Doktor Jaros",
						sex: sex)
	expected_runner = Runner::new(
				age: 7,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: 2100,
				description: "",
				draw: 0,
				earnings_career: 87843.00,
				earnings_current_year: 0.00,			
				earnings_last_year: 0.00,
				earnings_victory: 0.00,
				final_place: nil,
				history: "0a2a1a1a(1",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 0.0,
				load_ride: 0.0,
				non_runner: false,
				number: 3,
				places: 0,
				race: race_to_test,
				races_run: 0,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm"
				victories: 0,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R1_C7_N3(1st)")
end

def validate_runner_R1_C7_N11(runner_from_list_runners, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
	coat = @ref_list_hash[:ref_coat_list]["ALEZAN BRULE"]
	sex = @ref_list_hash[:ref_sex_list]["M"]
	
	father = Horse::new(name: "liptus")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "mikun metka", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "J.m. Paavola")
	trainer = Trainer::new(name: "J.M. PAAVOLA")
	owner = Owner::new(name: "J.M. PAAVOLA (FIN)")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Metkutus",
						sex: sex)
	expected_runner = Runner::new(
				age: 10,
				blinder: blinder,
				commentary: nil,
				disqualified: nil,
				distance: 2100,
				description: "",
				draw: 0,
				earnings_career: 86140.00,
				earnings_current_year: 0.00,			
				earnings_last_year: 200.00,
				earnings_victory: 0.00,
				final_place: nil,
				history: "4a0a6a5a(1",
				is_favorite: nil,
				is_substitute: false,
				load_handicap: 0.0,
				load_ride: 0.0,
				non_runner: false,
				number: 11,
				places: 1,
				race: race_to_test,
				races_run: 2,
				shoes: shoes,
				single_rating_before_race: 0.0,
				time: nil,
				url: "",
				# FIXME If real website does have a URL per runner
				# "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_METKUTUS.htm"
				victories: 0,
				breeder: breeder,
				horse: horse,
				jockey: jockey,
				owner: owner,
				trainer: trainer)
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "R1_C7_N11(disqualified)")
end

def validate_result_R1_C1_N4(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Vite en troisième position, a donné un bon coup de reins dans les 100 derniers mètres sans pouvoir remonter totalement Virgious du Maza (5).",
				disqualified: false,
				distance: "",
				final_place: 2,
				is_favorite: true,
				is_substitute: nil,
				non_runner: false,
				number: 9,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALROY.htm",
				single_rating_after_race: 2.5,
				time: "1'13\"80")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C1_N4(favorite)")
end

def validate_result_R1_C1_N5(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Installé au commandement en bas de la descente, a repoussé jusqu'au bout la bonne attaque de Valroy (9).",
				disqualified: false,
				distance: "",
				final_place: 1,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 5,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VIRGIOUS_DU_MAZA.htm",
				single_rating_after_race: 8.4,
				time: "1'13\"80")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C1_N5(1st)")
end

def validate_result_R1_C1_N9(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Vite en tête, puis relayé par Virgious du Maza (5) en bas de la descente, venait visiblement dominer son rival lorsqu'il s'est montré fautif à mi-ligne droite.",
				disqualified: true,
				distance: "",
				final_place: 0,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 4,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALDEZ_TURGOT.htm",
				single_rating_after_race: 4.2,
				time: "0'00\"00")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C1_N9(disqualified)")
end

def validate_result_R4_C5_N2(runner_from_result_list)
	expected_runner = Runner::new(
			commentary: "",
			distance: "",
			disqualified: false,
			final_place: 1,
			is_favorite: true,
			is_substitute: nil,
			non_runner: false,
			number: 2,
			url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm",
			single_rating_after_race: 2.9,
			time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R4_C5_N2(1st, is_favorite)")
end

def validate_result_R4_C5_N4(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "",
				disqualified: false,
				distance: "",
				final_place: 0,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 4,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_CAT'S_GAME.htm",
				single_rating_after_race: 13.9,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R4_C5_N4(no place, no dist)")
end

def validate_result_R4_C5_N5(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "",
				disqualified: false,
				distance: "3/4 De Longueur",
				final_place: 10,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 5,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_AIM_OF_THE_GAME.htm",
				single_rating_after_race: 9.6,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R4_C5_N5(10th, with dist)")
end

def validate_result_R4_C5_N17(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "",
				disqualified: false,
				distance: "",
				final_place: 0,
				is_favorite: false,
				is_substitute: nil,
				non_runner: true,
				number: 17,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_LIZZY_GREY.htm",
				single_rating_after_race: 0.0,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R4_C5_N17(non runner)")
end

def validate_result_R2_C7_N1(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Vite en tête, n'a été dominé que dans les derniers mètres.",
				disqualified: false,
				distance: "1 Tête",
				final_place: 3,
				is_favorite: true,
				is_substitute: nil,
				non_runner: false,
				number: 1,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_FRANZ_QUERCUS.htm",
				single_rating_after_race: 2.6,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R2_C7_N1(favorite)")
end

def validate_result_R2_C7_N4(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Rapproché à la sortie du tournant final, faisant alors illusion pour la troisième ou quatrième place, a marqué le pas sur le plat.",
				disqualified: false,
				distance: "4 Longueurs",
				final_place: 12,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 4,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm",
				single_rating_after_race: 17.6,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R2_C7_N4(12th)")
end

def validate_result_R2_C7_N11(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Après avoir patienté en quatrième ou cinquième position, s'est rapprochée entre les deux dernières haies, puis a bien accéléré sur le plat, créant la décision aux abords du poteau.",
				disqualified: false,
				distance: "",
				final_place: 1,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 11,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_VIVA_VOCE_SIVOLA.htm",
				single_rating_after_race: 93.6,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R2_C7_N11(1st)")		
end

def validate_result_R2_C7_N12(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Venue de l'arrière-garde, a progressé entre les deux dernières haies et a conclu correctement.",
				disqualified: false,
				distance: "1 Longueur 1/2",
				final_place: 6,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 12,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_TWEETY_KASH.htm",
				single_rating_after_race: 22.3,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R2_C7_N12(substitute)")
end

def validate_result_R1_C7_N1(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Longtemps en dehors de l'animateur Juni Kongen (7), a conservé la quatrième place en léger retrait.",
				disqualified: false,
				distance: "",
				final_place: 3,
				is_favorite: true,
				is_substitute: nil,
				non_runner: false,
				number: 1,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_NORHEIM_JAERV.htm",
				single_rating_after_race: 3.5,
				time: "1'25\"30")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C7_N1(is favorite)")
end

def validate_result_R1_C7_N3(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "Patient sur une troisième ligne, a débordé Närby Kalabalik (8) sur le fil.",
				disqualified: false,
				distance: "",
				final_place: 1,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 3,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_DOKTOR_JAROS.htm",
				single_rating_after_race: 11.6,
				time: "1'24\"70")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C7_N3(1st)")
end

def validate_result_R1_C7_N11(runner_from_result_list)
	expected_runner = Runner::new(
				commentary: "S'est montré fautif peu après le départ.",
				disqualified: true,
				distance: "",
				final_place: 0,
				is_favorite: false,
				is_substitute: nil,
				non_runner: false,
				number: 11,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_METKUTUS.htm",
				single_rating_after_race: 32.6,
				time: "0'00\"00")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C7_N11(disqualified)")
end

def validate_joint_R4_C5_N2(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	
	father = Horse::new(name: "stronghold")
	grand_father = Horse::new(name: "doyoun")
	mother = Horse::new(name: "haifaa", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "P Strydom")
	trainer = Trainer::new(name: "L W GOOSEN")
	owner = Owner::new(name: "MESSRS C M COMAROFF & B K PARKER")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Negev",
						sex: sex)
	# is_favorite
	expected_runner = Runner::new(
						age: 5,
						blinder: blinder,
						commentary: "",		
						description: "",
						disqualified: false,
						distance: "",
						draw: 11,
						earnings_career: 54359.00,
						earnings_current_year: 3527.00,
						earnings_last_year: 8944.00,
						earnings_victory: 7098.00,
						final_place: 1,
						history: "2p2p3p6p",
						is_favorite: true,
						is_substitute: false,
						load_handicap: 60.0,
						load_ride: 0.0,
						non_runner: false,
						number: 2,
						places: 14,
						race: race_to_test,
						races_run: 23,
						score_horse: nil,
						score_jockey: nil,
						score_owner: nil,
						score_trainer: nil,
						score_breeder: nil,
						shoes: shoes,
						single_rating_after_race: 2.9,
						single_rating_before_race: 0.0,
						time: "",
						# FIXME If real website does have a URL per runner
						url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm", 
						victories: 2,
						breeder: breeder,
						horse: horse,
						jockey: jockey,
						owner: owner,
						trainer: trainer)
						
	validate_joint_runner(expected_runner, runner_to_check, "R4_C5_N2(10th, with dist)")
end

def validate_joint_R4_C5_N4(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "black minnaloushe")
	grand_father = Horse::new(name: "cordoba")
	mother = Horse::new(name: "light fandango", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "M V'rensburg")
	trainer = Trainer::new(name: "S M FERREIRA")
	owner = Owner::new(name: "MRS L C A BOUWER")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Cat's Game",
						sex: sex)
	expected_runner = Runner::new(						
					age: 5,
					blinder: blinder,
					commentary: "",		
					description: "",
					disqualified: false,
					distance: "",
					draw: 8,
					earnings_career: 11334.00,
					earnings_current_year: 0.00,
					earnings_last_year: 5117.00,
					earnings_victory: 6921.00,
					final_place: 0,
					history: "5p8p2p6p",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 59.0,
					load_ride: 0.0,
					non_runner: false,
					number: 4,
					places: 5,
					race: race_to_test,
					races_run: 12,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 13.9,
					single_rating_before_race: 0.0,
					time: "",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_CAT'S_GAME.htm",
					victories: 2,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	
	validate_joint_runner(expected_runner, runner_to_check, "R4_C5_N4(no place, no dist)")
end

def validate_joint_R4_C5_N5(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "eyeofthetiger")
	grand_father = Horse::new(name: "argosy")
	mother = Horse::new(name: "missdefied", father: grand_father)

	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "S Brown")
	trainer = Trainer::new(name: "L J ERASMUS")
	owner = Owner::new(name: "MR L J & MRS M J ERASMUS")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Aim Of The Game",
						sex: sex)
	
	expected_runner = Runner::new(
					age: 6,
					blinder: blinder,
					commentary: "",		
					description: "",
					disqualified: false,
					distance: "3/4 De Longueur",
					draw: 3,
					earnings_career: 24095.00,
					earnings_current_year: 4408.00,
					earnings_last_year: 12601.00,
					earnings_victory: 15898.00,
					final_place: 10,
					history: "1p7p(13)9p8p",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 58.0,
					load_ride: 0.0,
					non_runner: false,
					number: 5,
					places: 15,
					race: race_to_test,
					races_run: 43,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 9.6,
					single_rating_before_race: 0.0,
					time: "",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_AIM_OF_THE_GAME.htm",
					victories: 5,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	
	validate_joint_runner(expected_runner, runner_to_check, "R4_C5_N5(10th, with dist)")
end

def validate_joint_R4_C5_N17(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	sex = @ref_list_hash[:ref_sex_list][""]
	
	father = Horse::new(name: "windrush")
	grand_father = Horse::new(name: "northern guest")
	mother = Horse::new(name: "arctic game", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "")
	trainer = Trainer::new(name: "G H VAN ZYL")
	owner = Owner::new(name: "MR A D C A FERNANDES")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Lizzy Grey",
						sex: sex)
	expected_runner = Runner::new(			
					age: 0,
					blinder: blinder,
					commentary: "",		
					description: "",
					disqualified: false,
					distance: "",
					draw: 0,
					earnings_career: 7845.00,
					earnings_current_year: 1190.00,
					earnings_last_year: 1491.00,
					earnings_victory: 2753.00,
					final_place: 0,
					history: "",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 0.0,
					load_ride: 0.0,
					non_runner: true,
					number: 17,
					places: 8,
					race: race_to_test,
					races_run: 16,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 0.0,
					single_rating_before_race: 0.0,
					time: "",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_LIZZY_GREY.htm",
					victories: 1,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	
	validate_joint_runner(expected_runner, runner_to_check, "R4_C5_N17(non runner)")
end

def validate_joint_R1_C1_N4(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["H"]
	
	father = Horse::new(name: "nijinski blue")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "nectarine turgot", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "M. Abrivard")
	trainer = Trainer::new(name: "P. COIGNARD")
	owner = Owner::new(name: "P. COIGNARD")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Valdez Turgot",
						sex: sex)
	expected_runner = Runner::new(
					age: 5,
					blinder: blinder,
					commentary: "Vite en tête, puis relayé par Virgious du Maza (5) en bas de la descente, venait visiblement dominer son rival lorsqu'il s'est montré fautif à mi-ligne droite.",		
					description: "",
					disqualified: true,
					distance: 2700,
					draw: 0,
					earnings_career: 84980.00,
					earnings_current_year: 27900.00,
					earnings_last_year: 54060.00,
					earnings_victory: 72900.00,
					final_place: 0,
					history: "1m3m(13)1m",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 67.0,
					load_ride: 0.0,
					non_runner: false,
					number: 4,
					places: 8,
					race: race_to_test,
					races_run: 23,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 4.2,
					single_rating_before_race: 0.0,
					time: "0'00\"00",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALDEZ_TURGOT.htm",
					victories: 6,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	
	validate_joint_runner(expected_runner, runner_to_check, "R1_C1_N4(disqualified)")
end

def validate_joint_R1_C1_N5(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_POSTERIEURS"]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["H"]
	
	father = Horse::new(name: "prodigious")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "pocket edition", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "D. Bonne")
	trainer = Trainer::new(name: "S. ERNAULT")
	owner = Owner::new(name: "Ecurie du MAZA")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Virgious Du Maza",
						sex: sex)
	expected_runner = Runner::new(
					age: 5,
					blinder: blinder,
					commentary: "Installé au commandement en bas de la descente, a repoussé jusqu'au bout la bonne attaque de Valroy (9).",		
					description: "",
					disqualified: false,
					distance: 2700,
					draw: 0,
					earnings_career: 85060.00,
					earnings_current_year: 0.00,
					earnings_last_year: 69400.00,
					earnings_victory: 67600.00,
					final_place: 1,
					history: "DmDa(13)1m",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 67.0,
					load_ride: 0.0,
					non_runner: false,
					number: 5,
					places: 6,
					race: race_to_test,
					races_run: 16,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 8.4,
					single_rating_before_race: 0.0,
					time: "1'13\"80",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VIRGIOUS_DU_MAZA.htm",
					victories: 5,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	
	validate_joint_runner(expected_runner, runner_to_check, "R1_C1_N5(1st)")
end

def validate_joint_R1_C1_N9(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR FRANCAIS"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["M"]
	
	father = Horse::new(name: "first de retz")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "leda d'occagnes", father: grand_father)

	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "A. Abrivard")
	trainer = Trainer::new(name: "J.M. BAZIRE")
	owner = Owner::new(name: "Ecurie des CHARMES")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Valroy",
						sex: sex)
	expected_runner = Runner::new(
					age: 5,
					blinder: blinder,
					commentary: "Vite en troisième position, a donné un bon coup de reins dans les 100 derniers mètres sans pouvoir remonter totalement Virgious du Maza (5).",
					description: "",
					disqualified: false,
					distance: 2700,
					draw: 0,
					earnings_career: 105130.00,
					earnings_current_year: 9520.00,
					earnings_last_year: 53550.00,
					earnings_victory: 37500.00,
					final_place: 2,
					history: "3m(13)2mDm",
					is_favorite: true,
					is_substitute: false,
					load_handicap: 67.0,
					load_ride: 0.0,
					non_runner: false,
					number: 9,
					places: 11,
					race: race_to_test,
					races_run: 28,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 2.5,
					single_rating_before_race: 0.0,
					time: "1'13\"80",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALROY.htm",
					victories: 4,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	validate_joint_runner(expected_runner, runner_to_check, "R1_C1_N9(favorite)")
end

def validate_joint_R2_C7_N1(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["H"]
	
	father = Horse::new(name: "martaline")
	grand_father = Horse::new(name: "sanglamore")
	mother = Horse::new(name: "la haie blanche", father: grand_father)
	
	breeder = Breeder::new(name: "MR DANIEL CHASSAGNEUX")
	jockey = Jockey::new(name: "J.rougier")
	trainer = Trainer::new(name: "MACAIRE (S)")
	owner = Owner::new(name: "JD.COTTON")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Franz Quercus",
						sex: sex)
	expected_runner = Runner::new(
					age: 7,
					blinder: blinder,
					commentary: "Vite en tête, n'a été dominé que dans les derniers mètres.",		
					description: "",
					disqualified: false,
					distance: "1 Tête",
					draw: 0,
					earnings_career: 60330.00,
					earnings_current_year: 0.00,
					earnings_last_year: 0.00,
					earnings_victory: 48960.00,
					final_place: 3,
					history: "1s1h3h(11)1s",
					is_favorite: true,
					is_substitute: false,
					load_handicap: 72.0,
					load_ride: 68.0,
					non_runner: false,
					number: 1,
					places: 3,
					race: race_to_test,
					races_run: 9,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 2.6,
					single_rating_before_race: 0.0,
					time: "",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_FRANZ_QUERCUS.htm",
					victories: 5,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	validate_joint_runner(expected_runner, runner_to_check, "R2_C7_N1(favorite)")
end

def validate_joint_R2_C7_N4(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_CLASSIQUE"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list]["ALEZAN"]
	sex = @ref_list_hash[:ref_sex_list]["H"]
	
	father = Horse::new(name: "medicean")
	grand_father = Horse::new(name: "trempolino")
	mother = Horse::new(name: "vivacity", father: grand_father)
	
	breeder = Breeder::new(name: "STILVI COMPANIA FINANCIERA S.A.")
	jockey = Jockey::new(name: "A.lecordier")
	trainer = Trainer::new(name: "C.SCANDELLA")
	owner = Owner::new(name: "A.CANAVERO")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Grypas",
						sex: sex)
	expected_runner = Runner::new(
					age: 7,
					blinder: blinder,
					commentary: "Rapproché à la sortie du tournant final, faisant alors illusion pour la troisième ou quatrième place, a marqué le pas sur le plat.",		
					description: "",
					disqualified: false,
					distance: "4 Longueurs",
					draw: 0,
					earnings_career: 21175.00,
					earnings_current_year: 0.00,
					earnings_last_year: 21175.00,
					earnings_victory: 14400.00,
					final_place: 12,
					history: "9hAh1h4h5h5h",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 68.0,
					load_ride: 0.0,
					non_runner: false,
					number: 4,
					places: 4,
					race: race_to_test,
					races_run: 13,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 17.6,
					single_rating_before_race: 0.0,
					time: "",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm",
					victories: 2,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	validate_joint_runner(expected_runner, runner_to_check, "R2_C7_N4(12th)")
end

def validate_joint_R2_C7_N11(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["SANS_OEILLERES"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "assessor")
	grand_father = Horse::new(name: "garde royale")
	mother = Horse::new(name: "notting hill", father: grand_father)
	
	breeder = Breeder::new(name: "MR GILLES TRAPENARD")
	jockey = Jockey::new(name: "C.abou")
	trainer = Trainer::new(name: "MME F.GIMMI PELLEGRINO")
	owner = Owner::new(name: "MME F.GIMMI PELLEGRINO")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Viva Voce Sivola",
						sex: sex)
	expected_runner = Runner::new(
					age: 5,
					blinder: blinder,
					commentary: "Après avoir patienté en quatrième ou cinquième position, s'est rapprochée entre les deux dernières haies, puis a bien accéléré sur le plat, créant la décision aux abords du poteau.",		
					description: "",
					disqualified: false,
					distance: "",
					draw: 0,
					earnings_career: 9970.00,
					earnings_current_year: 0.00,
					earnings_last_year: 3825.00,
					earnings_victory: 0.00,
					final_place: 1,
					history: "3aThAh5s5s3h",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 64.0,
					load_ride: 61.0,
					non_runner: false,
					number: 11,
					places: 6,
					race: race_to_test,
					races_run: 19,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 93.6,
					single_rating_before_race: 0.0,
					time: "",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_VIVA_VOCE_SIVOLA.htm",
					victories: 0,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	validate_joint_runner(expected_runner, runner_to_check, "R2_C7_N11(1st)")
end

def validate_joint_R2_C7_N12(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list]["OEILLERES_AUSTRALIENNES"]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list]["BAI"]
	sex = @ref_list_hash[:ref_sex_list]["F"]
	
	father = Horse::new(name: "bonbon rose")
	grand_father = Horse::new(name: "saint preuil")
	mother = Horse::new(name: "sainte kash", father: grand_father)
	
	breeder = Breeder::new(name: "MR ARNAUD CHAILLE-CHAILLE")
	jockey = Jockey::new(name: "B.lestrade")
	trainer = Trainer::new(name: "M.SEROR")
	owner = Owner::new(name: "S.HOFFMEISTER")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Tweety Kash",
						sex: sex)
	expected_runner = Runner::new(
					age: 5,
					blinder: blinder,
					commentary: "Venue de l'arrière-garde, a progressé entre les deux dernières haies et a conclu correctement.",		
					description: "",
					disqualified: false,
					distance: "1 Longueur 1/2",
					draw: 0,
					earnings_career: 17775.00,
					earnings_current_year: 0.00,
					earnings_last_year: 17775.00,
					earnings_victory: 10560.00,
					final_place: 6,
					history: "AhAsTs6h(13)",
					is_favorite: false,
					is_substitute: true,
					load_handicap: 64.0,
					load_ride: 65.0,
					non_runner: false,
					number: 12,
					places: 4,
					race: race_to_test,
					races_run: 13,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 22.3,
					single_rating_before_race: 0.0,
					time: "",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_TWEETY_KASH.htm",
					victories: 2,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	validate_joint_runner(expected_runner, runner_to_check, "R2_C7_N12(favorite)")
end

def validate_joint_R1_C7_N1(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
	coat = @ref_list_hash[:ref_coat_list]["BAI FONCE"]
	sex = @ref_list_hash[:ref_sex_list]["M"]
	
	father = Horse::new(name: "jarvsofaks")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "norheim elle", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "T.e. Solberg")
	trainer = Trainer::new(name: "Georg William SVERDRUP")
	owner = Owner::new(name: "Georg William SVERDRUP (NOR)")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Norheim Jaerv",
						sex: sex)
	expected_runner = Runner::new(
					age: 6,
					blinder: blinder,
					commentary: "Longtemps en dehors de l'animateur Juni Kongen (7), a conservé la quatrième place en léger retrait.",		
					description: "",
					disqualified: false,
					distance: 2100,
					draw: 0,
					earnings_career: 120946.00,
					earnings_current_year: 0.00,
					earnings_last_year: 0.00,
					earnings_victory: 0.00,
					final_place: 3,
					history: "6a1a(13)3a",
					is_favorite: true,
					is_substitute: false,
					load_handicap: 0.0,
					load_ride: 0.0,
					non_runner: false,
					number: 1,
					places: 0,
					race: race_to_test,
					races_run: 0,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 3.5,
					single_rating_before_race: 0.0,
					time: "1'25\"30",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_NORHEIM_JAERV.htm",
					victories: 0,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	
	validate_joint_runner(expected_runner, runner_to_check, "R1_C7_N1(favorite)")
end

def validate_joint_R1_C7_N3(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS"]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
	coat = @ref_list_hash[:ref_coat_list]["NOIR"]
	sex = @ref_list_hash[:ref_sex_list]["M"]
	
	father = Horse::new(name: "mortvedt jerkeld")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "faks perla", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "G. Gudmestad")
	trainer = Trainer::new(name: "G. GUDMESTAD")
	owner = Owner::new(name: "Ecurie JAROS (NOR)")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Doktor Jaros",
						sex: sex)
	expected_runner = Runner::new(
					age: 7,
					blinder: blinder,
					commentary: "Patient sur une troisième ligne, a débordé Närby Kalabalik (8) sur le fil.",		
					description: "",
					disqualified: false,
					distance: 2100,
					draw: 0,
					earnings_career: 87843.00,
					earnings_current_year: 0.00,
					earnings_last_year: 0.00,
					earnings_victory: 0.00,
					final_place: 1,
					history: "0a2a1a1a(1",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 0.0,
					load_ride: 0.0,
					non_runner: false,
					number: 3,
					places: 0,
					race: race_to_test,
					races_run: 0,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 11.6,
					single_rating_before_race: 0.0,
					time: "1'24\"70",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_DOKTOR_JAROS.htm",
					victories: 0,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	
	validate_joint_runner(expected_runner, runner_to_check, "R1_C7_N3(1st)")
end

def validate_joint_R1_C7_N11(runner_to_check, race_to_test)
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list]["DEFERRE_ANTERIEURS_POSTERIEURS"]
	breed = @ref_list_hash[:ref_breed_list]["TROTTEUR ETRANGER"]
	coat = @ref_list_hash[:ref_coat_list]["ALEZAN BRULE"]
	sex = @ref_list_hash[:ref_sex_list]["M"]
	
	father = Horse::new(name: "liptus")
	grand_father = Horse::new(name: "-")
	mother = Horse::new(name: "mikun metka", father: grand_father)
	
	breeder = Breeder::new(name: "")
	jockey = Jockey::new(name: "J.m. Paavola")
	trainer = Trainer::new(name: "J.M. PAAVOLA")
	owner = Owner::new(name: "J.M. PAAVOLA (FIN)")
	horse = Horse::new(breed: breed,
						coat: coat,
						father: father,
						mother: mother,
						name: "Metkutus",
						sex: sex)
	expected_runner = Runner::new(
					age: 10,
					blinder: blinder,
					commentary: "S'est montré fautif peu après le départ.",		
					description: "",
					disqualified: true,
					distance: 2100,
					draw: 0,
					earnings_career: 86140.00,
					earnings_current_year: 0.00,
					earnings_last_year: 200.00,
					earnings_victory: 0.00,
					final_place: 0,
					history: "4a0a6a5a(1",
					is_favorite: false,
					is_substitute: false,
					load_handicap: 0.0,
					load_ride: 0.0,
					non_runner: false,
					number: 11,
					places: 1,
					race: race_to_test,
					races_run: 2,
					score_horse: nil,
					score_jockey: nil,
					score_owner: nil,
					score_trainer: nil,
					score_breeder: nil,
					shoes: shoes,
					single_rating_after_race: 32.6,
					single_rating_before_race: 0.0,
					time: "0'00\"00",
					# FIXME If real website does have a URL per runner
					url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_METKUTUS.htm",
					victories: 0,
					breeder: breeder,
					horse: horse,
					jockey: jockey,
					owner: owner,
					trainer: trainer)
	
	validate_joint_runner(expected_runner, runner_to_check, "R1_C7_N11(disqualified)")
end
