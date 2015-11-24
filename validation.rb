require 'minitest'

def validate_runner_from_runner_list(expected_runner, actual_runner, str_runner_identifier)
	# not nil values
	assert_equal(expected_runner.age, 					actual_runner.age, 					"Wrong age while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.blinder, 				actual_runner.blinder, 				"Wrong blinder while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.commentary, 			actual_runner.commentary, 			"Wrong commentary while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.description, 			actual_runner.description, 			"Wrong description while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.disqualified, 			actual_runner.disqualified, 		"Wrong disqualified while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.distance, 				actual_runner.distance, 			"Wrong distance while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.draw, 					actual_runner.draw, 				"Wrong draw while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.earnings_career, 		actual_runner.earnings_career, 		"Wrong earnings_career while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.earnings_current_year,	actual_runner.earnings_current_year,"Wrong earnings_current_year while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.earnings_last_year, 	actual_runner.earnings_last_year, 	"Wrong earnings_last_year while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.earnings_victory, 		actual_runner.earnings_victory, 	"Wrong earnings_victory while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.final_place, 			actual_runner.final_place, 			"Wrong final_place while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.history, 				actual_runner.history, 				"Wrong history while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.is_favorite, 			actual_runner.is_favorite, 			"Wrong is_favorite while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.is_substitute, 		actual_runner.is_substitute, 		"Wrong is_substitute while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.load_handicap, 		actual_runner.load_handicap, 		"Wrong load_handicap while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.load_ride, 			actual_runner.load_ride, 			"Wrong load_ride while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.non_runner, 			actual_runner.non_runner, 			"Wrong non_runner while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.number, 				actual_runner.number, 				"Wrong number while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.places, 				actual_runner.places, 				"Wrong places while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.race, 					actual_runner.race, 				"Wrong race while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.races_run, 			actual_runner.races_run, 			"Wrong races_run while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.shoes, 				actual_runner.shoes, 				"Wrong shoes while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.single_rating_before_race, 			
				actual_runner.single_rating_before_race,
				"Wrong single_rating_before_race while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.time, 					actual_runner.time, 				"Wrong time while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.url, 					actual_runner.url, 					"Wrong url while checking " + str_runner_identifier + ".")
	# FIXME If real website does have a URL per runner
	# assert_equal(expected_runner.disqualified, 		actual_runner.url, 					"Wrong url while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.victories, 			actual_runner.victories, 			"Wrong victories while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.breeder.name, 			actual_runner.breeder.name, 		"Wrong breeder.name while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.jockey.name, 			actual_runner.jockey.name, 			"Wrong jockey.name while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.horse.breed, 			actual_runner.horse.breed, 			"Wrong horse.breed while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.horse.coat, 			actual_runner.horse.coat, 			"Wrong horse.coat while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.horse.father, 			actual_runner.horse.father, 		"Wrong horse.father while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.horse.mother, 			actual_runner.horse.mother, 		"Wrong horse.mother while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.horse.mother.father, 	actual_runner.horse.mother.father, 	"Wrong horse.mother.father while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.horse.name, 			actual_runner.horse.name, 			"Wrong horse.name while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.horse.sex, 			actual_runner.horse.sex, 			"Wrong horse.sex while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.owner.name, 			actual_runner.owner.name, 			"Wrong owner.name while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.trainer.name,			actual_runner.trainer.name, 			"Wrong trainer.name while checking " + str_runner_identifier + ".")
	
	# nil values
	assert_equal(nil, actual_runner.id, 						"Id not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.single_rating_after_race,	"Single_rating_after_race not nil while checking " + str_runner_identifier + ".")
	
	@logger.info("Tests (from: results) for runner " + str_runner_identifier + " OK.")
end


def validate_runner_from_result_list(expected_runner, actual_runner, str_runner_identifier)
	# not nil values
	assert_equal(expected_runner.commentary,	actual_runner.commentary, 		"Wrong commentary while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.disqualified, 	actual_runner.disqualified, 	"Wrong disqualified while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.distance, 		actual_runner.distance, 		"Wrong distance while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.final_place, 	actual_runner.final_place, 		"Wrong final_place while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.is_favorite, 	actual_runner.is_favorite, 		"Wrong is_favorite while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.is_substitute, actual_runner.is_substitute,	"Wrong is_substitute while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.non_runner, 	actual_runner.non_runner, 		"Wrong non_runner while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.number, 		actual_runner.number, 			"Wrong number while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.url, 			actual_runner.url, 				"Wrong url while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.single_rating_after_race, 
				actual_runner.single_rating_after_race, 						"Wrong single_rating_after_race while checking " + str_runner_identifier + ".")
	assert_equal(expected_runner.time, 			actual_runner.time, 			"Wrong time while checking " + str_runner_identifier + ".")
	
	# nil values
	assert_equal(nil, actual_runner.age, 						"Age not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.blinder, 					"Blinder not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.breeder, 					"Breeder not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.description, 				"Description not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.draw, 						"Draw not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.earnings_career, 			"Earnings_career not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.earnings_current_year, 		"Earnings_current_year not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.earnings_last_year, 		"Earnings_last_year not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.earnings_victory, 			"Earnings_victory not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.history, 					"History not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.horse, 						"Horse not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.id, 						"Id not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.jockey, 					"Jockey not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.load_handicap, 				"Load_handicap not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.load_ride, 					"Load_ride not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.owner, 						"Owner not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.places, 					"Places not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.race, 						"Race not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.races_run, 					"Races_run not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.score_horse, 				"Score_horse not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.score_jockey, 				"Score_jockey not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.score_owner, 				"Score_owner not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.score_trainer, 				"Score_trainer not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.score_breeder, 				"Score_breeder not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.shoes, 						"Shoes not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.single_rating_before_race,	"Single_rating_before_race not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.trainer, 					"Trainer not nil while checking " + str_runner_identifier + ".")
	assert_equal(nil, actual_runner.victories, 					"Victories not nil while checking " + str_runner_identifier + ".")
	
	@logger.info("Tests (from: runner) for runner " + str_runner_identifier + " OK.")
end

def validate_joint_runner(expected_runner, actual_runner, str_runner_identifier)
	assert_equal(expected_runner.age, 						actual_runner.age, 							"Wrong age while checking " + str_runner_identifier)
	assert_equal(expected_runner.blinder, 					actual_runner.blinder, 						"Wrong blinder while checking " + str_runner_identifier)
	assert_equal(expected_runner.commentary, 				actual_runner.commentary, 					"Wrong commentary while checking " + str_runner_identifier)		
	assert_equal(expected_runner.description, 				actual_runner.description, 					"Wrong description while checking " + str_runner_identifier)
	assert_equal(expected_runner.disqualified, 				actual_runner.disqualified, 				"Wrong disqualified while checking " + str_runner_identifier)
	assert_equal(expected_runner.distance, 					actual_runner.distance, 					"Wrong distance while checking " + str_runner_identifier)
	assert_equal(expected_runner.draw, 						actual_runner.draw, 						"Wrong draw while checking " + str_runner_identifier)
	assert_equal(expected_runner.earnings_career,			actual_runner.earnings_career, 				"Wrong earnings_career while checking " + str_runner_identifier)
	assert_equal(expected_runner.earnings_current_year,		actual_runner.earnings_current_year,		"Wrong earnings_current_year while checking " + str_runner_identifier)
	assert_equal(expected_runner.earnings_last_year, 		actual_runner.earnings_last_year, 			"Wrong earnings_last_year while checking " + str_runner_identifier)
	assert_equal(expected_runner.earnings_victory, 			actual_runner.earnings_victory, 			"Wrong earnings_victory while checking " + str_runner_identifier)
	assert_equal(expected_runner.final_place, 				actual_runner.final_place, 					"Wrong final_place while checking " + str_runner_identifier)
	assert_equal(expected_runner.history, 					actual_runner.history, 						"Wrong history while checking " + str_runner_identifier)
	assert_equal(expected_runner.is_favorite, 				actual_runner.is_favorite, 					"Wrong is_favorite while checking " + str_runner_identifier)
	assert_equal(expected_runner.is_substitute, 			actual_runner.is_substitute, 				"Wrong is_substitute while checking " + str_runner_identifier)
	assert_equal(expected_runner.load_handicap, 			actual_runner.load_handicap, 				"Wrong load_handicap while checking " + str_runner_identifier)
	assert_equal(expected_runner.load_ride, 				actual_runner.load_ride, 					"Wrong load_ride while checking " + str_runner_identifier)
	assert_equal(expected_runner.non_runner, 				actual_runner.non_runner, 					"Wrong non_runner while checking " + str_runner_identifier)
	assert_equal(expected_runner.number, 					actual_runner.number, 						"Wrong number while checking " + str_runner_identifier)
	assert_equal(expected_runner.places, 					actual_runner.places, 						"Wrong places while checking " + str_runner_identifier)
	assert_equal(expected_runner.race, 						actual_runner.race, 						"Wrong race while checking " + str_runner_identifier)
	assert_equal(expected_runner.races_run, 				actual_runner.races_run, 					"Wrong races_run while checking " + str_runner_identifier)
	assert_equal(expected_runner.score_horse, 				actual_runner.score_horse, 					"Wrong score_horse while checking " + str_runner_identifier)
	assert_equal(expected_runner.score_jockey, 				actual_runner.score_jockey, 				"Wrong score_jockey while checking " + str_runner_identifier)
	assert_equal(expected_runner.score_owner, 				actual_runner.score_owner, 					"Wrong score_owner while checking " + str_runner_identifier)
	assert_equal(expected_runner.score_trainer, 			actual_runner.score_trainer, 				"Wrong score_trainer while checking " + str_runner_identifier)
	assert_equal(expected_runner.score_breeder, 			actual_runner.score_breeder, 				"Wrong score_breeder while checking " + str_runner_identifier)
	assert_equal(expected_runner.shoes, 					actual_runner.shoes, 						"Wrong shoes while checking " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_after_race,	actual_runner.single_rating_after_race, 	"Wrong single_rating while checking " + str_runner_identifier)
	assert_equal(expected_runner.single_rating_before_race,	actual_runner.single_rating_before_race,	"Wrong single_rating while checking " + str_runner_identifier)
	assert_equal(expected_runner.time, 						actual_runner.time, 						"Wrong time while checking " + str_runner_identifier)
	# FIXME If real website does have a URL per runner
	assert_equal(expected_runner.url, 						actual_runner.url, 							"Wrong url while checking " + str_runner_identifier)
	assert_equal(expected_runner.victories, 				actual_runner.victories, 					"Wrong victories while checking " + str_runner_identifier)
	assert_equal(expected_runner.breeder.name, 				actual_runner.breeder.name, 				"Wrong breeder.name while checking " + str_runner_identifier)
	assert_equal(expected_runner.jockey.name, 				actual_runner.jockey.name, 					"Wrong jockey.name while checking " + str_runner_identifier)
	assert_equal(expected_runner.horse.breed, 				actual_runner.horse.breed, 					"Wrong horse.breed while checking " + str_runner_identifier)
	assert_equal(expected_runner.horse.coat, 				actual_runner.horse.coat, 					"Wrong horse.coat while checking " + str_runner_identifier)
	assert_equal(expected_runner.horse.father, 				actual_runner.horse.father, 				"Wrong horse.father while checking " + str_runner_identifier)
	assert_equal(expected_runner.horse.mother, 				actual_runner.horse.mother, 				"Wrong horse.mother while checking " + str_runner_identifier)
	assert_equal(expected_runner.horse.mother.father, 		actual_runner.horse.mother.father, 			"Wrong horse.mother.father while checking " + str_runner_identifier)
	assert_equal(expected_runner.horse.name, 				actual_runner.horse.name, 					"Wrong horse.name while checking " + str_runner_identifier)
	assert_equal(expected_runner.horse.sex, 				actual_runner.horse.sex, 					"Wrong horse.sex while checking " + str_runner_identifier)
	assert_equal(expected_runner.owner.name, 				actual_runner.owner.name, 					"Wrong owner.name while checking " + str_runner_identifier)
	assert_equal(expected_runner.trainer.name, 				actual_runner.trainer.name, 				"Wrong trainer.name while checking " + str_runner_identifier)
	
	@logger.info("Tests (after joining) for " + str_runner_identifier + " OK.")
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
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "first place is_favorite")
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
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "runner no place no dist")
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
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "runner 10th place with dist")
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
	validate_runner_from_runner_list(expected_runner, runner_from_list_runners, "non runner")
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
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "first place is_favorite")
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
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "no place and no dist")
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
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "10th place with dist")
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
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "non runner")
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
						
	validate_joint_runner(expected_runner, runner_to_check, "runner 10th place with dist")
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
	
	validate_joint_runner(expected_runner, runner_to_check, "runner no place and no dist")
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
	
	validate_joint_runner(expected_runner, runner_to_check, "runner 10th place with dist")
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
	
	validate_joint_runner(expected_runner, runner_to_check, "for non runner")
end
