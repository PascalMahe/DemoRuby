require './validation-core.rb'

def validate_joint_R4_C5_N2(runner_to_check)
	@logger.info("Validating joint_R4_C5_N2")
	
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
						is_non_runner: false,
						is_substitute: false,
						load_handicap: 60.0,
						load_ride: 0.0,
						number: 2,
						places: 14,
						# race: race_to_test,
						races_run: 23,
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
						
	validate_joint_runner(expected_runner, runner_to_check, "R4_C5_N2 (10th, with dist)")
end

def validate_joint_R4_C5_N4(runner_to_check)
	@logger.info("Validating joint_R4_C5_N4")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 59.0,
					load_ride: 0.0,
					number: 4,
					places: 5,
					# race: race_to_test,
					races_run: 12,
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

def validate_joint_R4_C5_N5(runner_to_check)
	@logger.info("Validating joint_R4_C5_N5")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 58.0,
					load_ride: 0.0,
					number: 5,
					places: 15,
					# race: race_to_test,
					races_run: 43,
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
	
	validate_joint_runner(expected_runner, runner_to_check, "R4_C5_N5 (10th, with dist)")
end

def validate_joint_R4_C5_N17(runner_to_check)
	@logger.info("Validating joint_R4_C5_N17")
	
	blinder = @ref_list_hash[:ref_blinder_list][""]
	shoes = @ref_list_hash[:ref_shoes_list][""]
	breed = @ref_list_hash[:ref_breed_list]["PUR-SANG"]
	coat = @ref_list_hash[:ref_coat_list][""]
	
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
						name: "Lizzy Grey")
						
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
					is_non_runner: true,
					is_substitute: false,
					load_handicap: 0.0,
					load_ride: 0.0,
					number: 17,
					places: 8,
					# race: race_to_test,
					races_run: 16,
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

def validate_joint_R1_C1_N4(runner_to_check)
	@logger.info("Validating joint_R1_C1_N4")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 67.0,
					load_ride: 0.0,
					number: 4,
					places: 8,
					# race: race_to_test,
					races_run: 23,
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

def validate_joint_R1_C1_N5(runner_to_check)
	@logger.info("Validating joint_R1_C1_N5")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 67.0,
					load_ride: 0.0,
					number: 5,
					places: 6,
					# race: race_to_test,
					races_run: 16,
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

def validate_joint_R1_C1_N9(runner_to_check)
	@logger.info("Validating joint_R1_C1_N9")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 67.0,
					load_ride: 0.0,
					number: 9,
					places: 11,
					# race: race_to_test,
					races_run: 28,
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

def validate_joint_R2_C7_N1(runner_to_check)
	@logger.info("Validating joint_R2_C7_N1")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 72.0,
					load_ride: 68.0,
					number: 1,
					places: 3,
					# race: race_to_test,
					races_run: 9,
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

def validate_joint_R2_C7_N4(runner_to_check)
	@logger.info("Validating joint_R2_C7_N4")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 68.0,
					load_ride: 0.0,
					number: 4,
					places: 4,
					# race: race_to_test,
					races_run: 13,
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

def validate_joint_R2_C7_N11(runner_to_check)
	@logger.info("Validating joint_R2_C7_N11")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 64.0,
					load_ride: 61.0,
					number: 11,
					places: 6,
					# race: race_to_test,
					races_run: 19,
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

def validate_joint_R2_C7_N12(runner_to_check)
	@logger.info("Validating joint_R2_C7_N12")
	
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
					is_non_runner: false,
					is_substitute: true,
					load_handicap: 64.0,
					load_ride: 65.0,
					number: 12,
					places: 4,
					# race: race_to_test,
					races_run: 13,
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

def validate_joint_R1_C7_N1(runner_to_check)
	@logger.info("Validating joint_R1_C7_N1")
	
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 0.0,
					load_ride: 0.0,
					number: 1,
					places: 0,
					# race: race_to_test,
					races_run: 0,
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

def validate_joint_R1_C7_N3(runner_to_check)
	@logger.info("Validating joint_R1_C7_N3")
	
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 0.0,
					load_ride: 0.0,
					number: 3,
					places: 0,
					# race: race_to_test,
					races_run: 0,
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

def validate_joint_R1_C7_N11(runner_to_check)
	@logger.info("Validating joint_R1_C7_N11")
	
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
					is_non_runner: false,
					is_substitute: false,
					load_handicap: 0.0,
					load_ride: 0.0,
					number: 11,
					places: 1,
					# race: race_to_test,
					races_run: 2,
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
