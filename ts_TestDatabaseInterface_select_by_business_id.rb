require './TestSuite.rb'
require './validation.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'

class TestDatabaseInterfaceSelect < TestSuite
	
	def setup
		@logger = $globalState.logger
		@config = $globalState.config
		@dbi_select_tech = $globalState.dbi_select_by_tech_id
		@dbi_select = $globalState.dbi_select_by_business_id
		if(@ref_list_hash == nil) then 
			@ref_list_hash = @dbi_select_tech.load_all_refs
		end
	end
	
	def teardown
		
	end
	
	##################
	#      Tests     #
	##################
	def test_load_breeder_id
		@logger.imp("Testing selection of Breeder ID")
		begin
			test_name = "Test Breeder 2 Name"
			breeder = Breeder::new(name: test_name)
			selected_id = @dbi_select.load_breeder_id(breeder)
			
			# Checking value
			assert_equal(selected_id, -2)
			
			@logger.ok("Tests selection of Breeder ID OK.")
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			
		end
	end
	
	
end