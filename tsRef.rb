require './TestSuite.rb'
require './ref.rb'
require './validation-core.rb'

class TestRef < TestSuite
	
	i_suck_and_my_tests_are_order_dependent!()
	
	def setup
		needs_crawler = true
		testSetup(needs_crawler)
	end
	
	def teardown
		testTearDown()
	end
	
	##################
	#      Tests     #
	##################
	def test_load_all_refs
	
		@logger.imp("Testing loading all reference objects")
		begin
			ref_list = @dbi_select_tech.load_all_refs
			
			assert_equal(9, ref_list.size, "Wrong number of refObjectContainer loaded")
			
			@logger.debug("test_load_all_refs - list_blinder.size = " + 
							ref_list[:ref_blinder_list].to_s)
			expected_ref_blinder_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_blinder])
			
			assert_equal(expected_ref_blinder_list_size, 
						ref_list[:ref_blinder_list].size,
						"Wrong number of RefBlinder loaded by load_all_refs")
			
			expected_ref_breed_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_breed])
			assert_equal(expected_ref_breed_list_size, 
						ref_list[:ref_breed_list].size,
						"Wrong number of RefBreed loaded by load_all_refs")
			
			expected_ref_coat_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_coat])
			assert_equal(expected_ref_coat_list_size, 
						ref_list[:ref_coat_list].size,
						"Wrong number of RefCoat loaded by load_all_refs")
			
			expected_ref_column_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_column])
			assert_equal(expected_ref_column_list_size, 
						ref_list[:ref_column_list].size,
						"Wrong number of RefColumn loaded by load_all_refs")
			
			expected_ref_direction_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_direction])
			assert_equal(expected_ref_direction_list_size, 
						ref_list[:ref_direction_list].size,
						"Wrong number of RefDirection loaded by load_all_refs")
			
			expected_ref_race_type_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_race_type])
			assert_equal(expected_ref_race_type_list_size, 
						ref_list[:ref_race_type_list].size,
						"Wrong number of RefRaceType loaded by load_all_refs")
			
			expected_ref_sex_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_sex])
			assert_equal(expected_ref_sex_list_size, 
						ref_list[:ref_sex_list].size,
						"Wrong number of RefSex loaded by load_all_refs")
			
			expected_ref_shoes_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_shoes])
			assert_equal(expected_ref_shoes_list_size, 
						ref_list[:ref_shoes_list].size,
						"Wrong number of RefShoes loaded by load_all_refs")
			
			expected_ref_track_condition_list_size = 
				@dbi_select_tech.select_count_from_table(
					@config[:gen][:table_names][:ref_track_condition])
			assert_equal(expected_ref_track_condition_list_size, 
						ref_list[:ref_track_condition_list].size,
						"Wrong number of RefTrackCondition loaded " + 
						 "by load_all_refs")
			
			@logger.ok("Tests for loading all reference objects OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_get
		@logger.imp("Testing get of RefContainerObject")
		begin
			# Getting the number of blinders beforehand
			first_nb_of_blinder = @dbi_select_tech.select_count_from_table(
									@config[:gen][:table_names][:ref_blinder])
		
			ref_blinder_list = @dbi_select_tech.load_ref_blinder_list()
			
			test_blinder = ref_blinder_list.get(-1)
			
			expected_blinder = RefBlinder::new(-1, "Test Blinder")
			
			validate_blinder(expected_blinder, test_blinder, " from testing " + 
								"of get of RefContainerObject")
			
			# Getting the number of blinders after the first try
			second_nb_of_blinder = @dbi_select_tech.select_count_from_table(
									@config[:gen][:table_names][:ref_blinder])
			
			# Checking that the number hasn't changed
			assert_equal(first_nb_of_blinder, 
						second_nb_of_blinder,
						"Wrong number of blinders after get")
			
			expected_nil = ref_blinder_list.get(-1000)
			
			assert_equal(nil, 
						expected_nil,
						"Wrong blinder after second try: should be nil")
			
			# Getting the number of blinders after the second (failed) try
			third_nb_of_blinder = @dbi_select_tech.select_count_from_table(
									@config[:gen][:table_names][:ref_blinder])
			
			# Checking that the number hasn't changed
			assert_equal(second_nb_of_blinder, 
						third_nb_of_blinder,
						"Wrong number of blinders after failed get")
			
			@logger.ok("Tests for get of RefContainerObject OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_look_up
		@logger.imp("Testing look up of RefContainerObject")
		begin
			# Getting the number of blinders beforehand
			first_nb_of_blinder = @dbi_select_tech.select_count_from_table(
									@config[:gen][:table_names][:ref_blinder])
			
			# Getting last ID
			old_last_blinder_id = @dbi_select_tech.select_last_id_from_table(
									@config[:gen][:table_names][:ref_blinder])
			
			ref_blinder_list = @dbi_select_tech.load_ref_blinder_list()
			
			diferentiator = 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			test_blinder = ref_blinder_list["Testing look up" + 
													diferentiator]
			
			expected_blinder = RefBlinder::new(old_last_blinder_id + 1, 
												"Testing look up" + 
													diferentiator)
			
			validate_blinder(expected_blinder, test_blinder, " from testing " + 
								"of get of RefContainerObject")
			
			# Getting the number of blinders after the first try
			second_nb_of_blinder = @dbi_select_tech.select_count_from_table(
									@config[:gen][:table_names][:ref_blinder])
			
			# Checking that the number hasn't changed
			assert_equal(first_nb_of_blinder + 1, 
						second_nb_of_blinder,
						"Wrong number of blinders after look up")
			
			# Retry on the same to check that it doesn't insert again
			retry_blinder = ref_blinder_list["Testing look up" + 
													diferentiator]
			
			validate_blinder(expected_blinder, test_blinder, " from testing " + 
								"of get of RefContainerObject")
			
			# Getting the number of blinders after the second (failed) try
			third_nb_of_blinder = @dbi_select_tech.select_count_from_table(
									@config[:gen][:table_names][:ref_blinder])
			
			# Checking that the number hasn't changed
			assert_equal(second_nb_of_blinder, 
						third_nb_of_blinder,
						"Wrong number of blinders after failed look up")
			
			# Tests with special characters: _,ç...
			special_blinder = ref_blinder_list["PUR-SA_çàè&NG" + 
												diferentiator]
			@logger.debug("test_look_up - blinder w/ special " +
							"chars (after ins): " + 
							special_blinder.to_s)
			
			expected_special_blinder = RefBlinder::new(expected_blinder.id + 1,
													"PUR-SA_çàè&NG" + 
														diferentiator)
			
			# Getting the number of blinders after the third try
			fourth_nb_of_blinder = @dbi_select_tech.select_count_from_table(
									@config[:gen][:table_names][:ref_blinder])
			
			# Checking that the number has incremented
			assert_equal(third_nb_of_blinder + 1, 
						fourth_nb_of_blinder,
						"Wrong number of blinders after lookup with " + 
						"special chars.")
			
			validate_blinder(expected_special_blinder, 
							special_blinder,
							"Wrong Blinder after look up with special chars.")
			
			# Retry to check it isn't added a second time
			retry_special_blinder = ref_blinder_list["PUR-SA_çàè&NG" + 
													diferentiator]
													
			
			validate_blinder(expected_special_blinder, 
							retry_special_blinder,
							"Wrong Blinder after second look up with " + 
							"special chars.")
			
			# Getting the number of blinders after the fourth (failed) try
			fifth_nb_of_blinder = @dbi_select_tech.select_count_from_table(
									@config[:gen][:table_names][:ref_blinder])
			
			# Checking that the number hasn't incremented
			assert_equal(fourth_nb_of_blinder, 
						fifth_nb_of_blinder,
						"Wrong number of blinders after lookup with " + 
						"special chars.")
			
			
			@logger.ok("Tests for look up of RefContainerObject OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	def test_has_key()
		@logger.imp("Testing has_key of RefContainerObject")
		begin
			refOC = RefObjectContainer::new(RefBlinder, @dbi_insert)
			
			key_to_search = "keykey"
			
			assert_equal(true, 
						refOC.empty?, 
						"refOC should be empty.")
							
			assert_equal(false, 
						refOC.has_key?(key_to_search), 
						"Wrong key in refOC: " + key_to_search + 
							" shouldn't be in it.")
							
			refOC[key_to_search] = key_to_search
			
			assert_equal(false, 
						refOC.empty?, 
						"refOC shouldn't be empty.")
							
			assert_equal(true, 
						refOC.has_key?(key_to_search), 
						"Wrong key in refOC: " + key_to_search + 
							" should be in it.")
			
			@logger.debug("test_has_key - refOC : " + refOC.to_s)
			
			text1 = "kiki"
			text2 = "totoro"
			text3 = "porco rosso"
			text4 = "ponyo!"
			
			refBlinder1 = RefBlinder::new(text1)
			refBlinder2 = RefBlinder::new(text2)
			refBlinder3 = RefBlinder::new(text3)
			refBlinder4 = RefBlinder::new(text4)
			trip_up_ref = RefBlinder::new(text4)
			
			refOC[text1] = refBlinder1
			refOC[text2] = refBlinder2
			refOC[text3] = refBlinder3
			refOC[text4] = refBlinder4
			keys_array = refOC.keys
			
			@logger.debug("test_has_key - " + keys_array.to_s)
			
			ref_trip_check = refOC[text4]
			assert_equal(refBlinder4.id, ref_trip_check.id)
			assert_equal(refBlinder4.text, ref_trip_check.text)
			
			
			@logger.ok("Tests for has_key of RefContainerObject OK.")
		rescue Exception => err
			log_flunking_test(err)
		end
	end
	
	
	def test_no_ref_duplication_part_a()
		@logger.imp("Testing no duplication of Ref - Part A")
	end
	
	
	def test_no_ref_duplication_part_b
		@logger.imp("Testing no duplication of Ref - Part B")
		test_start_time = Time.now()
		begin
			
			# modifying the race type list in the crawler
			expected_race_list = @crawler.getTraCon
			
			# @logger.level = SimpleHtmlLogger::DEBUG
			@logger.debug(expected_race_list)
			
			# showing the one in the test
			
			@logger.debug("test_part_b - ")
			@logger.debug(@ref_list_hash[:ref_race_type_list])
			
			# @logger.level = SimpleHtmlLogger::INFO
			
			# modifying the race type list in the test
			verif_race_type = @ref_list_hash[:ref_race_type_list]["Attelé"]
			
			# @logger.level = SimpleHtmlLogger::DEBUG
			@logger.debug("test_part_b - ")
			@logger.debug(@ref_list_hash[:ref_race_type_list])
			assert_equal(expected_race_list, 
							verif_race_type, 
							"Wrong race_type")
	
			# validate_race_R1_C7(fetched_race)
			
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for no duplication of Ref OK.")
	end
end