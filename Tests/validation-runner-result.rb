require_relative './validation-core.rb'

def validate_result_R1_C1_N4(runner_from_result_list)
	@logger.info("Validating R1_C1_N4")

	expected_runner = Runner::new(
				commentary: "Vite en troisième position, a donné un bon coup de reins dans les 100 derniers mètres sans pouvoir remonter totalement Virgious du Maza (5).",
				disqualified: false,
				distance: "",
				final_place: 2,
				is_favorite: true,
				is_non_runner: false,
				is_substitute: nil,
				number: 9,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALROY.htm",
				single_rating_after_race: 2.5,
				time: "1'13\"80")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C1_N4(favorite)")
end

def validate_result_R1_C1_N5(runner_from_result_list)
	@logger.info("Validating R1_C1_N5")

	expected_runner = Runner::new(
				commentary: "Installé au commandement en bas de la descente, a repoussé jusqu'au bout la bonne attaque de Valroy (9).",
				disqualified: false,
				distance: "",
				final_place: 1,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 5,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VIRGIOUS_DU_MAZA.htm",
				single_rating_after_race: 8.4,
				time: "1'13\"80")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C1_N5(1st)")
end

def validate_result_R1_C1_N9(runner_from_result_list)
	@logger.info("Validating R1_C1_N9")

	expected_runner = Runner::new(
				commentary: "Vite en tête, puis relayé par Virgious du Maza (5) en bas de la descente, venait visiblement dominer son rival lorsqu'il s'est montré fautif à mi-ligne droite.",
				disqualified: true,
				distance: "",
				final_place: 0,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 4,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1_runner_VALDEZ_TURGOT.htm",
				single_rating_after_race: 4.2,
				time: "0'00\"00")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C1_N9(disqualified)")
end

def validate_result_R4_C5_N2(runner_from_result_list)
	@logger.info("Validating R4_C5_N2")

	expected_runner = Runner::new(
			commentary: "",
			distance: "",
			disqualified: false,
			final_place: 1,
			is_favorite: true,
			is_non_runner: false,
			is_substitute: nil,
			number: 2,
			url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_NEGEV.htm",
			single_rating_after_race: 2.9,
			time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R4_C5_N2(1st, is_favorite)")
end

def validate_result_R4_C5_N4(runner_from_result_list)
	@logger.info("Validating R4_C5_N4")

	expected_runner = Runner::new(
				commentary: "",
				disqualified: false,
				distance: "",
				final_place: 0,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 4,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_CAT'S_GAME.htm",
				single_rating_after_race: 13.9,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R4_C5_N4(no place, no dist)")
end

def validate_result_R4_C5_N5(runner_from_result_list)
	@logger.info("Validating R4_C5_N5")

	expected_runner = Runner::new(
				commentary: "",
				disqualified: false,
				distance: "3/4 De Longueur",
				final_place: 10,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 5,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_AIM_OF_THE_GAME.htm",
				single_rating_after_race: 9.6,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R4_C5_N5 (10th, with dist)")
end

def validate_result_R4_C5_N17(runner_from_result_list)
	@logger.info("Validating R4_C5_N17")

	expected_runner = Runner::new(
				commentary: "",
				disqualified: false,
				distance: "",
				final_place: 0,
				is_favorite: false,
				is_non_runner: true,
				is_substitute: nil,
				number: 17,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5_runner_LIZZY_GREY.htm",
				single_rating_after_race: 0.0,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R4_C5_N17(non runner)")
end

def validate_result_R2_C7_N1(runner_from_result_list)
	@logger.info("Validating R2_C7_N1")

	expected_runner = Runner::new(
				commentary: "Vite en tête, n'a été dominé que dans les derniers mètres.",
				disqualified: false,
				distance: "1 Tête",
				final_place: 3,
				is_favorite: true,
				is_non_runner: false,
				is_substitute: nil,
				number: 1,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_FRANZ_QUERCUS.htm",
				single_rating_after_race: 2.6,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R2_C7_N1(favorite)")
end

def validate_result_R2_C7_N4(runner_from_result_list)
	@logger.info("Validating R2_C7_N4")

	expected_runner = Runner::new(
				commentary: "Rapproché à la sortie du tournant final, faisant alors illusion pour la troisième ou quatrième place, a marqué le pas sur le plat.",
				disqualified: false,
				distance: "4 Longueurs",
				final_place: 12,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 4,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_GRYPAS.htm",
				single_rating_after_race: 17.6,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R2_C7_N4(12th)")
end

def validate_result_R2_C7_N11(runner_from_result_list)
	@logger.info("Validating R2_C7_N11")

	expected_runner = Runner::new(
				commentary: "Après avoir patienté en quatrième ou cinquième position, s'est rapprochée entre les deux dernières haies, puis a bien accéléré sur le plat, créant la décision aux abords du poteau.",
				disqualified: false,
				distance: "",
				final_place: 1,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 11,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_VIVA_VOCE_SIVOLA.htm",
				single_rating_after_race: 93.6,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R2_C7_N11(1st)")
end

def validate_result_R2_C7_N12(runner_from_result_list)
	@logger.info("Validating R2_C7_N12")

	expected_runner = Runner::new(
				commentary: "Venue de l'arrière-garde, a progressé entre les deux dernières haies et a conclu correctement.",
				disqualified: false,
				distance: "1 Longueur 1/2",
				final_place: 6,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 12,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7_runner_TWEETY_KASH.htm",
				single_rating_after_race: 22.3,
				time: "")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R2_C7_N12(substitute)")
end

def validate_result_R1_C7_N1(runner_from_result_list)
	@logger.info("Validating R1_C7_N1")

	expected_runner = Runner::new(
				commentary: "Longtemps en dehors de l'animateur Juni Kongen (7), a conservé la quatrième place en léger retrait.",
				disqualified: false,
				distance: "",
				final_place: 3,
				is_favorite: true,
				is_non_runner: false,
				is_substitute: nil,
				number: 1,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_NORHEIM_JAERV.htm",
				single_rating_after_race: 3.5,
				time: "1'25\"30")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C7_N1(is favorite)")
end

def validate_result_R1_C7_N3(runner_from_result_list)
	@logger.info("Validating R1_C7_N3")

	expected_runner = Runner::new(
				commentary: "Patient sur une troisième ligne, a débordé Närby Kalabalik (8) sur le fil.",
				disqualified: false,
				distance: "",
				final_place: 1,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 3,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_DOKTOR_JAROS.htm",
				single_rating_after_race: 11.6,
				time: "1'24\"70")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C7_N3(1st)")
end

def validate_result_R1_C7_N11(runner_from_result_list)
	@logger.info("Validating R1_C7_N11")

	expected_runner = Runner::new(
				commentary: "S'est montré fautif peu après le départ.",
				disqualified: true,
				distance: "",
				final_place: 0,
				is_favorite: false,
				is_non_runner: false,
				is_substitute: nil,
				number: 11,
				url: "file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7_runner_METKUTUS.htm",
				single_rating_after_race: 32.6,
				time: "0'00\"00")
	validate_runner_from_result_list(expected_runner, runner_from_result_list, "R1_C7_N11(disqualified)")
end
