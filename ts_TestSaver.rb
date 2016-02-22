require './TestSuite.rb'
require './ref.rb'
require './Saver.rb'
require './validation.rb'
require 'json'

class TestSaver < TestSuite
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi_insert = $globalState.dbi_insert
		@dbi_select_tech = $globalState.dbi_select_by_tech_id
		@dbi_select_biz = $globalState.dbi_select_by_business_id
		@ref_list_hash = @dbi_select_tech.load_all_refs
		
		@logger.level = SimpleHtmlLogger::DEBUG
		
		@test_start_time = Time.now()
	end
	
	def teardown
		test_end_time = Time.now()
		
		test_duration_in_s = test_end_time - @test_start_time
		@logger.ok("(Test took " + 
			format_time_diff(test_duration_in_s) + 
			".)")
	
		@logger.debug("Teardown")
		@logger.level = SimpleHtmlLogger::INFO
	end
	
	############################
	# Tests for simple objects #
	############################
	
	def test_save_breeder
		
		@logger.imp("Testing save breeder")
		begin
			# Counting number of Breeders before test
			old_breeder_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:breeder])
					
			# Getting last ID currently in Breeder
			old_last_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:breeder])
			
			# Creating a Breeder without id
			# (Adding the date & time to the name so that's it unique
			# even if the test is launched multiple times and the DB
			# is not cleaned in between.)
			name = "LYNN LODGE STUD" + 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			breeder_to_save = Breeder::new(name: name)
			
			# Saving it
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_breeder(breeder_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, breeder_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_id + 1, breeder_to_save.id)
			
			# Check that the number of Breeders in the DB incremented
			breeder_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:breeder])
			assert_equal(old_breeder_num + 1, 
						breeder_num_after_first_save,
						"Wrong number of Breeders in DB after first " + 
							"attempt to save")
			
			# Check that if a Breeder is retrieved just on that ID,
			# it's the same as the first
			verification_breeder = @dbi_select_tech.
				load_breeder_by_id(breeder_to_save.id)
			validate_breeder(breeder_to_save, 
							verification_breeder, 
							"breeder to save")
			
			# Check that if a create the same Breeder (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Breeder isn't incremented again)
			breeder_to_fail_to_save = Breeder::new(name: name)
			saver.save_breeder(breeder_to_fail_to_save)
			
			assert_equal(breeder_to_save,
						breeder_to_fail_to_save,
						"Wrong ID after attempt to fail to save")
			
			breeder_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:breeder])
			assert_equal(breeder_num_after_first_save, 
						breeder_num_after_second_save,
						"Wrong number of Breeders in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save breeder OK.")
	end
	
	
end