require './validation-core.rb'

def validate_R1(actual_r1, job)
	expected_r1 = Meeting::new(
		country: "France",
		date: Date::new(2015, 06, 12),
		job: job, 
		number: 1, 
		racetrack: "HIPPODROME DE PARIS-VINCENNES", 
		urls_of_races_array: [
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C1.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C2.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C3.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C4.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C5.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C6.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C7.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C8.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R1_C9.htm"
					], 
		track_condition: @ref_list_hash[:ref_track_condition_list][""], 
		weather: Weather::new(
					insolation: "P8", 
					temperature: 11, 
					wind_speed: 27)
	)
	validate_meeting(expected_r1, actual_r1, "R1")
end

def validate_R2(actual_r2, job)
	expected_r2 = Meeting::new(
		country: "France",
		date: Date::new(2015, 06, 12),
		job: job, 
		number: 2, 
		racetrack: "HIPPODROME DE MARSEILLE BORELY", 
		urls_of_races_array: [
					"file:///D:/Dev/workspace/RPP/Test-HTML/R2_C1.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R2_C2.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R2_C3.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R2_C4.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R2_C5.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R2_C6.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R2_C7.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R2_C8.htm"
					], 
		track_condition: @ref_list_hash[:ref_track_condition_list]["Terrain souple"], 
		weather: Weather::new(
					insolation: "P1", 
					temperature: 12, # 12
					wind_speed: 16)  # 16
	)
	validate_meeting(expected_r2, actual_r2, "R2")
end

def validate_R3(actual_r3, job)
	expected_r3 = Meeting::new(
		country: "France",
		date: Date::new(2015, 06, 12),
		job: job, 
		number: 3, 
		racetrack: "HIPPODROME DE SAINT GALMIER", 
		urls_of_races_array: [
					"file:///D:/Dev/workspace/RPP/Test-HTML/R3_C1.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R3_C2.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R3_C3.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R3_C4.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R3_C5.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R3_C6.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R3_C7.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R3_C8.htm"
					], 
		track_condition: @ref_list_hash[:ref_track_condition_list]["Terrain bon"], 
		weather: Weather::new(
					insolation: "P8c", 
					temperature: 14, # 14
					wind_speed: 5)  #  5
	)
	validate_meeting(expected_r3, actual_r3, "R3")
end

def validate_R4(actual_r4, job)
	expected_r4 = Meeting::new(
		country: "Af Sud",
		date: Date::new(2015, 06, 12),
		job: job, 
		number: 4, 
		racetrack: "HIPPODROME DE VAAL", 
		urls_of_races_array: [
					"file:///D:/Dev/workspace/RPP/Test-HTML/R4_C2.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R4_C3.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R4_C4.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R4_C5.htm",
					], 
		track_condition: @ref_list_hash[:ref_track_condition_list][""], 
		weather: Weather::new(
					insolation: "P4", 
					temperature: 31, # 31
					wind_speed: 9)  #  9
	)
	validate_meeting(expected_r4, actual_r4, "R4")
end

def validate_R5(actual_r5, job)
	expected_r5 = Meeting::new(
		country: "E.A.U",
		date: Date::new(2015, 06, 12),
		job: job, 
		number: 5, 
		racetrack: "HIPPODROME MEYDAN", 
		urls_of_races_array: [
					"file:///D:/Dev/workspace/RPP/Test-HTML/R5_C1.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R5_C2.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R5_C3.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R5_C4.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R5_C5.htm",
					"file:///D:/Dev/workspace/RPP/Test-HTML/R5_C6.htm"
					], 
		track_condition: @ref_list_hash[:ref_track_condition_list][""], 
		weather: Weather::new(
					insolation: "P1", 
					temperature: 24, # 24
					wind_speed: 18)  # 18
	)
	validate_meeting(expected_r5, actual_r5, "R5")
end
