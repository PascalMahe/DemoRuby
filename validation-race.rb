require './validation-core.rb'

def validate_race_R1_C7(fetched_race)
	# @logger.debug("validate_race_R1_C7 - fetched_race: " + fetched_race.to_s)
	verif_bets = 166715.00
	verif_detailed_conditions = "PRIX DES TROTTEURS \"SANG-FROID\" Course 7 Course Internationale Départ à l'Autostart 20.000. - Attelé. - 2.100 mètres (G. P.) 9.000, 5.000, 2.800, 1.600, 1.000, 400, 200. Course spéciale sur invitation réservée à 12 trotteurs \"Sang-Froid\" sélectio nés par les Fédérations de Finlande, Norvège et Suède. 3 chevaux seront menés par des jockeys français désignés p r la SECF."
	verif_distance = 2100
	verif_general_conditions = "Internationale - Autostart Corde à gauche"
	# verif_meeting = meeting
	verif_name = "PRIX DES TROTTEURS \"SANG-FROID\""
	verif_number = 7
	verif_race_type = @ref_list_hash[:ref_race_type_list]["Attelé"]
	verif_result = "3 - 7 - 1 - 10 - 6 - 2 - 12"
	verif_result_insertion_time = Time::new
	@logger.debug("validate_race_R1_C7 - verif_result_insertion_time : " + 
		verif_result_insertion_time.
			strftime(@config[:gen][:default_date_time_format])
	)
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
		# meeting: verif_meeting, 
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

def validate_race_R2_C7(fetched_race)
	verif_bets = 136823.00
	verif_detailed_conditions = "Pour tous chevaux de 5 ans et au-dess us, n'ayant pas reçu, en course de ha ies, une alloc ation de 8.000 (à récl amer excepté), depuis le 1er septembr e 2013 inclus, et mis à réclamer au m inimum pour 9.000, avec prix de récl amation supérieur de 2.000 en 2.000. Poids : 5 ans, 66 k. ; 6 ans et au-de ssus, 68 k. Surcharges accumulées : 1 k. par 2.000 pour les pr ix de récla mation supérieurs à 9.000. En outre, tout cheval ayant, depuis le 1 er déc embre 2013 inclus, en courses de haie s, reçu une allocation de 7.500 porte ra 2 k. Les Jockeys n'ayant pas gagné quarante courses recevront 4 k . "
	verif_distance = 3800
	verif_general_conditions = "Terrain souple  - A réclamer"
	# verif_meeting = meeting
	verif_name = "PRIX DE LA PLANCHE"
	verif_number = 7
	verif_race_type = @ref_list_hash[:ref_race_type_list]["Haies"]
	verif_result = "11 - 2 - 1 - 3 - 6 - 12 - 7 - 9 - 8 - 5 - 10 - 4"
	verif_result_insertion_time = Time::new
	verif_runner_list = []
	for i in 0..11 do
		verif_runner_list[i] = Runner::new
	end
	# @logger.debug("validate_race_R1_C7 - verif_runner_list: " + verif_runner_list.to_s)
	verif_time =  Time::new(1, 1, 1, 15, 35)
	verif_url = "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_conditions.htm"
	verif_value =  18000
	
	verif_race = Race::new(
		bets: verif_bets,
		detailed_conditions: verif_detailed_conditions,
		distance: verif_distance,  
		general_conditions: verif_general_conditions,
		# meeting: verif_meeting, 
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
	validate_race(verif_race, fetched_race, "R2 C7")
end

def validate_race_R3_C1(fetched_race)
	verif_bets = 127877.00
	verif_detailed_conditions = "PRIX DE FEURS Course 1 Course E Course Européenne APPRENTIS - LADS-JOCKEYS 22.000. - Monté. - 2.700 mètres. 9.900, 5.500, 3.080, 1.760, 1.100, 440, 220.- alloués par la S.E.C.F. Pour 6 à 10 ans inclus (Q à U), n'ayant pas gagné 161.000. - Avance de 25 m. aux chevaux montés par des Apprentis ou Lads-Jockeys n'ayant pas gagné quinze courses. Sont seuls admis à participer à cette épreuve les chevaux n'ayant pas, dans es 12 mois précédant la course, été classés, au trot monté ou au trot attelé, 1er, 2ème ou 3ème d'une épreuve d Groupe I. Poids minimum (voir Conditions Générales)."
	verif_distance = 2700
	verif_general_conditions = "Terrain bon  - Apprentis - Lads Jockeys - Européenne  - Corde à droite"
	# verif_meeting = meeting
	verif_name = "PRIX DE FEURS"
	verif_number = 1
	verif_race_type = @ref_list_hash[:ref_race_type_list]["Monté"]
	verif_result = "5 - 7 - 13 - 4 - 9 - 1 - 12 - 3 - 8 - 11"
	verif_result_insertion_time = Time::new
	verif_runner_list = []
	for i in 0..13 do
		verif_runner_list[i] = Runner::new
	end
	# @logger.debug("validate_race_R1_C7 - verif_runner_list: " + verif_runner_list.to_s)
	verif_time =  Time::new(1, 1, 1, 17, 20)
	verif_url = "file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1_conditions.htm"
	verif_value =  22000
	
	verif_race = Race::new(
		bets: verif_bets,
		detailed_conditions: verif_detailed_conditions,
		distance: verif_distance,  
		general_conditions: verif_general_conditions,
		# meeting: verif_meeting, 
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
	validate_race(verif_race, fetched_race, "R3 C1")
end

def validate_race_R4_C3(fetched_race)
	verif_bets = 29235.00
	verif_detailed_conditions = "Pour pur sang femelle de trois ans et plus (Allocations distribuées aux 5 pr iers). "
	verif_distance = 1200
	verif_general_conditions = "Handicap  - Corde à droite"
	# verif_meeting = meeting
	verif_name = "JOBURG'S PRAWN FEST HANDICAP"
	verif_number = 3
	verif_race_type = @ref_list_hash[:ref_race_type_list]["Plat"]
	verif_result = "7 - 1 - 6 - 3 - 4 - 5 - 2"
	verif_result_insertion_time = Time::new
	verif_runner_list = []
	for i in 0..7 do
		verif_runner_list[i] = Runner::new
	end
	# @logger.debug("validate_race_R1_C7 - verif_runner_list: " + verif_runner_list.to_s)
	verif_time =  Time::new(1, 1, 1, 12, 15)
	verif_url = "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C3.htm"
	verif_value =  7759
	
	verif_race = Race::new(
		bets: verif_bets,
		detailed_conditions: verif_detailed_conditions,
		distance: verif_distance,  
		general_conditions: verif_general_conditions,
		# meeting: verif_meeting, 
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
	validate_race(verif_race, fetched_race, "R4 C3")
end

def validate_race_R5_C5(fetched_race)
	verif_bets = 77856.00
	verif_detailed_conditions = "Pour pur sang femelle de 4 ans et plus (Allocations distribuées aux 6 premie ). "
	verif_distance = 1800
	verif_general_conditions = "Groupe II  - Corde à gauche"
	# verif_meeting = meeting
	verif_name = "MEYDAN (E.A.U) - BALANCHINE"
	verif_number = 7
	verif_race_type = @ref_list_hash[:ref_race_type_list]["Plat"]
	verif_result = "3 - 4 - 1 - 2 - 5 - 6"
	verif_result_insertion_time = Time::new
	verif_runner_list = []
	for i in 0..5 do
		verif_runner_list[i] = Runner::new
	end
	# @logger.debug("validate_race_R1_C7 - verif_runner_list: " + verif_runner_list.to_s)
	verif_time =  Time::new(1, 1, 1, 18, 35)
	verif_url = "file:///D:/Dev/workspace/RPP/Test-HTML/R5_C5.htm"
	verif_value =  145364
	
	verif_race = Race::new(
		bets: verif_bets,
		detailed_conditions: verif_detailed_conditions,
		distance: verif_distance,  
		general_conditions: verif_general_conditions,
		# meeting: verif_meeting, 
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
	validate_race(verif_race, fetched_race, "R5 C5")
end