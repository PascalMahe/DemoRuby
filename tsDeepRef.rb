require './TestSuite.rb'
require './ref.rb'
require './validation-core.rb'
require './validation-race.rb'

class TestDeepRef < TestSuite
	
	@@crawler = nil
	@@ref_list_hash = nil
	
	i_suck_and_my_tests_are_order_dependent!()
	
	def setup
		testSetup()
	end
	
	
	def teardown
		testTearDown()
		
	end
	
	##################
	#      Tests     #
	##################
	
	def test_part_a()
		@logger.imp("Part A")
	end
	
	
	def test_part_b
		@logger.imp("Part B")
		test_start_time = Time.now()
		begin
			
			# modifying the race type list in the crawler
			expected_race_list = @crawler.getTraCon
			
			@logger.level = SimpleHtmlLogger::DEBUG
			@logger.debug(expected_race_list)
			
			# showing the one in the test
			
			@logger.debug("test_part_b - ")
			@logger.debug(@ref_list_hash[:ref_race_type_list])
			
			@logger.level = SimpleHtmlLogger::INFO
			
			# modifying the race type list in the test
			verif_race_type = @ref_list_hash[:ref_race_type_list]["Attelé"]
			
			@logger.level = SimpleHtmlLogger::DEBUG
			@logger.debug("test_part_b - ")
			@logger.debug(@ref_list_hash[:ref_race_type_list])
			assert_equal(expected_race_list, 
							verif_race_type, 
							"Wrong race_type")
	
			# validate_race_R1_C7(fetched_race)
			
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_race OK.")
	end
	
end