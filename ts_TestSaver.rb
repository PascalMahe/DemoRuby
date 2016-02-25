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
	
	def test_save_horse
		
		@logger.imp("Testing save horse")
		begin
			# Counting number of Horse before test
			old_horse_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:horse])
					
			# Getting last ID currently in Horse
			old_last_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:horse])
			
			@logger.debug("test_save_horse - " +
				"old_horse_num = " + old_horse_num.to_s)
			@logger.debug("test_save_horse - " +
				"old_last_id = " + old_last_id.to_s)
			
			# Creating a Horse without id
			# (Adding the date & time to the name so that's it unique
			# even if the test is launched multiple times and the DB
			# is not cleaned in between.)
			father = @dbi_select_tech.load_horse_by_id(-5)
			mother = @dbi_select_tech.load_horse_by_id(-6)
			name = "SILVER TREASURE" + 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			horse_to_save = Horse::new(	father: father, 
										mother: mother, 
										name: name)
			
			# Saving it
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_horse(horse_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, horse_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_id + 1, horse_to_save.id)
			
			# Check that the number of Horses in the DB incremented
			horse_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:horse])
			assert_equal(old_horse_num + 1, 
						horse_num_after_first_save,
						"Wrong number of Horses in DB after first " + 
							"attempt to save")
			
			# Check that if a Horse is retrieved just on that ID,
			# it's the same as the first
			verification_horse = @dbi_select_tech.
				load_horse_by_id(horse_to_save.id)
			validate_horse(horse_to_save, 
							verification_horse, 
							"horse to save")
			
			# Check that if a create the same Horse (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Horse isn't incremented again)
			horse_to_fail_to_save = Horse::new(	father: father, 
												mother: mother, 
												name: name)
			saver.save_horse(horse_to_fail_to_save)
			
			assert_equal(horse_to_save,
						horse_to_fail_to_save,
						"Wrong ID after attempt to fail to save")
			
			horse_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:horse])
			assert_equal(horse_num_after_first_save, 
						horse_num_after_second_save,
						"Wrong number of Horses in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save horse OK.")
	end
	
	
	def test_save_job
		
		@logger.imp("Testing save job")
		begin
			
			# Counting number of Jobs before test
			old_job_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:job])
					
			# Getting last ID currently in Job
			old_last_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:job])
			
			# Creating a Job without id
			start_time = DateTime.now
			job_to_save = Job::new(start_time: start_time)
			@logger.debug("test_save_job - job_to_save = " + job_to_save.to_s)
			
			# Saving it
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_job(job_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, job_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_id + 1, job_to_save.id)
			
			# Check that the number of Jobs in the DB incremented
			job_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:job])
			assert_equal(old_job_num + 1, 
						job_num_after_first_save,
						"Wrong number of Jobs in DB after first " + 
							"attempt to save")
			
			# Check that if a Job is retrieved just on that ID,
			# it's the same as the first
			verification_job = @dbi_select_tech.
				load_job_by_id(job_to_save.id)
			@logger.debug("test_save_job - verification_job = " + 
				verification_job.to_s)
			validate_job(job_to_save, 
							verification_job, 
							"job to save")
			
			# Check that if a create the same Job (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Job isn't incremented again)
			job_to_fail_to_save = Job::new(start_time: start_time)
			saver.save_job(job_to_fail_to_save)
			
			assert_equal(job_to_save,
						job_to_fail_to_save,
						"Wrong ID after attempt to fail to save")
			
			job_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:job])
			assert_equal(job_num_after_first_save, 
						job_num_after_second_save,
						"Wrong number of Jobs in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save job OK.")
	end
	
	def test_save_jockey
		@logger.imp("Testing save jockey")
		begin
			# Counting number of Jockeys before test
			old_jockey_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:jockey])
					
			# Getting last ID currently in Jockey
			old_last_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:jockey])
			
			# Creating a Jockey without id
			# (Adding the date & time to the name so that's it unique
			# even if the test is launched multiple times and the DB
			# is not cleaned in between.)
			name = "J.m. Paavola" + 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			jockey_to_save = Jockey::new(name: name)
			
			# Saving it
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_jockey(jockey_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, jockey_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_id + 1, jockey_to_save.id)
			
			# Check that the number of Jockeys in the DB incremented
			jockey_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:jockey])
			assert_equal(old_jockey_num + 1, 
						jockey_num_after_first_save,
						"Wrong number of Jockeys in DB after first " + 
							"attempt to save")
			
			# Check that if a Jockey is retrieved just on that ID,
			# it's the same as the first
			verification_jockey = @dbi_select_tech.
				load_jockey_by_id(jockey_to_save.id)
			validate_jockey(jockey_to_save, 
							verification_jockey, 
							"jockey to save")
			
			# Check that if a create the same Jockey (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Jockey isn't incremented again)
			jockey_to_fail_to_save = Jockey::new(name: name)
			saver.save_jockey(jockey_to_fail_to_save)
			
			assert_equal(jockey_to_save,
						jockey_to_fail_to_save,
						"Wrong ID after attempt to fail to save")
			
			jockey_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:jockey])
			assert_equal(jockey_num_after_first_save, 
						jockey_num_after_second_save,
						"Wrong number of Jockeys in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save jockey OK.")
	end
	
	def test_save_meeting()
		# TODO later 'cause it's hard (needs thinking and all...)
	end
	
	def test_save_meeting_list()
		# TODO later 'cause it's hard (needs thinking and all...)
	end
	
	def test_save_owner
		@logger.imp("Testing save owner")
		begin
			# Counting number of Owners before test
			old_owner_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:owner])
					
			# Getting last ID currently in Owner
			old_last_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:owner])
			
			# Creating a Owner without id
			# (Adding the date & time to the name so that's it unique
			# even if the test is launched multiple times and the DB
			# is not cleaned in between.)
			name = "J.m. Paavola" + 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			owner_to_save = Owner::new(name: name)
			
			# Saving it
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_owner(owner_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, owner_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_id + 1, owner_to_save.id)
			
			# Check that the number of Owners in the DB incremented
			owner_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:owner])
			assert_equal(old_owner_num + 1, 
						owner_num_after_first_save,
						"Wrong number of Owners in DB after first " + 
							"attempt to save")
			
			# Check that if a Owner is retrieved just on that ID,
			# it's the same as the first
			verification_owner = @dbi_select_tech.
				load_owner_by_id(owner_to_save.id)
			validate_owner(owner_to_save, 
							verification_owner, 
							"owner to save")
			
			# Check that if a create the same Owner (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Owner isn't incremented again)
			owner_to_fail_to_save = Owner::new(name: name)
			saver.save_owner(owner_to_fail_to_save)
			
			assert_equal(owner_to_save,
						owner_to_fail_to_save,
						"Wrong ID after attempt to fail to save")
			
			owner_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:owner])
			assert_equal(owner_num_after_first_save, 
						owner_num_after_second_save,
						"Wrong number of Owners in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save owner OK.")
	end
	
	def test_save_race()
		@logger.imp("Testing save race")
		begin
			# Counting number of Races before test
			old_race_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:race])
					
			# Getting last ID currently in Race
			old_last_race_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:race])
			
			# Counting number of Runners before test
			old_runner_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:runner])
					
			# Getting last ID currently in Runner
			old_last_runner_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:runner])
			
			# Creating a Race without id
			# We need a meeting WITH an ID 
			# so we create and save it in one go
			# (Adding the date & time to the racetrack so that's it unique
			# even if the test is launched multiple times and the DB
			# is not cleaned in between.)
			
			# Creating meeting
			test_date = Date::new(2016, 02, 17)
			test_racetrack = "Test Meeting for saving race" + 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			meeting = Meeting::new(	date: test_date,
									racetrack: test_racetrack)
			
			@dbi_insert.insert_meeting(meeting)
			assert_operator(meeting.id, :!=, nil)
			
			# Creating runner_list
			test_runner_list = []
			for i in 0..4 do
				format = @config[:gen][:default_date_time_format]
				differentiator = DateTime.now.strftime(format)
				
				breeder = Breeder::new(name: "Breeder" + differentiator)
				
				# all horses from this test are siblings...
				father = @dbi_select_tech.load_horse_by_id(-5)
				mother = @dbi_select_tech.load_horse_by_id(-6)
				name = "Breeder" + differentiator
				horse = Horse::new(father: father, 
									mother: mother, 
									name: name)
									
				jockey = Jockey::new(name: "Jockey" + differentiator)
				owner = Owner::new(name: "Owner" + differentiator)
				trainer = Trainer::new(name: "Trainer" + differentiator)
				runner = Runner::new(breeder: breeder,
									horse: horse,
									jockey: jockey,
									number: i,
									owner: owner,
									trainer: trainer)
				test_runner_list[i] = runner
			end
			
			# Creating race
			test_number = -3
			race_to_save = Race::new(meeting: meeting, 
									number: test_number, 
									runner_list: test_runner_list)
			
			# Saving the Race
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_race(race_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, race_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_race_id + 1, race_to_save.id)
			
			# Do the same for the runners
			for runner in race_to_save.runner_list
				# ID existence check
				assert_operator(0, :<=, runner.id)
				# ID bigger-than-previous-last check
				assert_equal(old_last_runner_id + runner.number + 1, runner.id)
			end
			
			# Check that the number of Races in the DB incremented
			race_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:race])
					
			assert_equal(old_race_num + 1, 
						race_num_after_first_save,
						"Wrong number of Races in DB after first " + 
							"attempt to save")
			
			# Check that the number of Runners in the DB incremented
			runner_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:runner])
					
			assert_equal(old_runner_num + test_runner_list.size, 
						runner_num_after_first_save,
						"Wrong number of Runners in DB after first " + 
							"attempt to save")
			
			# Check that if a Race is retrieved just on that ID,
			# it's the same as the first
			verification_race = @dbi_select_tech.
				load_race_by_id(race_to_save.id)
			validate_race(race_to_save, 
							verification_race, 
							"race to save")
			
			# Do the same for the runners
			for runner in race_to_save.runner_list
				verification_runner = @dbi_select_tech.
					load_runner_by_id(runner.id)
				validate_runner(runner, 
							verification_runner, 
							"runner loaded with race loaded from ID")
			end
			
			# Check that if a create the same Race (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Race isn't incremented again)
			# and that it does the same to the runners
			race_to_fail_to_save = Race::new(meeting: meeting, 
											number: test_number, 
											runner_list: test_runner_list)
			saver.save_race(race_to_fail_to_save)
			
			assert_equal(race_to_save.id,
						race_to_fail_to_save.id,
						"Wrong ID after attempt to fail to save")
			
			for i in 0..4 do
				original_runner = race_to_save.runner_list[i]
				should_be_same_runner = race_to_fail_to_save.runner_list[i]
				
				validate_runner(original_runner,
								should_be_same_runner,
								"runner after attempt to fail to save")
			end
			
			# Check that nnumber of Races hasn't incremented
			race_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:race])
			assert_equal(race_num_after_first_save, 
						race_num_after_second_save,
						"Wrong number of Races in DB after first " + 
							"attempt to save")
			
			# Same for Runners
			runner_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:runner])
			assert_equal(runner_num_after_first_save, 
						runner_num_after_second_save,
						"Wrong number of Runners in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save race OK.")
	end
	
	def test_save_runner()
		@logger.imp("Testing save runner")
		begin
			@logger.level = SimpleHtmlLogger::DEBUG
			# Counting number of Runners before test
			old_runner_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:runner])
					
			# Getting last ID currently in Runner
			old_last_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:runner])
			
			# Creating a Runner without ID
			# for that we need a race WITH ID
			# and for that we need a meeting WITH ID
			# (Adding the date & time to the names so that they're unique
			# even if the test is launched multiple times and the DB
			# is not cleaned in between.)
			
			# Creating and inserting meeting
			test_date = Date::new(2016, 02, 17)
			test_racetrack = "Test Meeting for saving race" + 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			meeting = Meeting::new(	date: test_date,
									racetrack: test_racetrack)
			
			@dbi_insert.insert_meeting(meeting)
			assert_operator(meeting.id, :!=, nil)
			
			# Creating and inserting race
			test_number = -3
			race = Race::new(meeting: meeting, 
							number: test_number)
			@dbi_insert.insert_race_with_result(race)
			assert_operator(race.id, :!=, nil)
			
			# Creating runner
			format = @config[:gen][:default_date_time_format]
			differentiator = DateTime.now.strftime(format)
			
			breeder = Breeder::new(name: "Breeder" + differentiator)
			
			# still siblings...
			father = @dbi_select_tech.load_horse_by_id(-5)
			mother = @dbi_select_tech.load_horse_by_id(-6)
			name = "Breeder" + differentiator
			horse = Horse::new(father: father, 
								mother: mother, 
								name: name)
								
			jockey = Jockey::new(name: "Jockey" + differentiator)
			owner = Owner::new(name: "Owner" + differentiator)
			trainer = Trainer::new(name: "Trainer" + differentiator)
			runner_to_save = Runner::new(breeder: breeder,
								horse: horse,
								jockey: jockey,
								number: 1,
								owner: owner,
								race: race,
								trainer: trainer)
			
			# Saving it
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_runner(runner_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, runner_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_id + 1, runner_to_save.id)
			
			# Check that the number of Runners in the DB incremented
			runner_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:runner])
			assert_equal(old_runner_num + 1, 
						runner_num_after_first_save,
						"Wrong number of Runners in DB after first " + 
							"attempt to save")
			
			# Check that if a Runner is retrieved just on that ID,
			# it's the same as the first
			verification_runner = @dbi_select_tech.
				load_runner_by_id(runner_to_save.id)
			validate_runner(runner_to_save, 
							verification_runner, 
							"runner to save")
			
			# Check that if we create the same Runner (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Runner isn't incremented again)
			runner_to_fail_to_save = Runner::new(breeder: breeder,
								horse: horse,
								jockey: jockey,
								number: 1,
								owner: owner,
								race: race,
								trainer: trainer)
			saver.save_runner(runner_to_fail_to_save)
			
			validate_runner(runner_to_save,
						runner_to_fail_to_save,
						"Wrong ID after attempt to fail to save")
			
			runner_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:runner])
			assert_equal(runner_num_after_first_save, 
						runner_num_after_second_save,
						"Wrong number of Runners in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save runner OK.")
	end
	
	def test_save_trainer
		@logger.imp("Testing save trainer")
		begin
			# Counting number of Trainers before test
			old_trainer_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:trainer])
					
			# Getting last ID currently in Trainer
			old_last_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:trainer])
			
			# Creating a Trainer without id
			# (Adding the date & time to the name so that's it unique
			# even if the test is launched multiple times and the DB
			# is not cleaned in between.)
			name = "J.m. Paavola" + 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			trainer_to_save = Trainer::new(name: name)
			
			# Saving it
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_trainer(trainer_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, trainer_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_id + 1, trainer_to_save.id)
			
			# Check that the number of Trainers in the DB incremented
			trainer_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:trainer])
			assert_equal(old_trainer_num + 1, 
						trainer_num_after_first_save,
						"Wrong number of Trainers in DB after first " + 
							"attempt to save")
			
			# Check that if a Trainer is retrieved just on that ID,
			# it's the same as the first
			verification_trainer = @dbi_select_tech.
				load_trainer_by_id(trainer_to_save.id)
			validate_trainer(trainer_to_save, 
							verification_trainer, 
							"trainer to save")
			
			# Check that if a create the same Trainer (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Trainer isn't incremented again)
			trainer_to_fail_to_save = Trainer::new(name: name)
			saver.save_trainer(trainer_to_fail_to_save)
			
			assert_equal(trainer_to_save,
						trainer_to_fail_to_save,
						"Wrong ID after attempt to fail to save")
			
			trainer_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:trainer])
			assert_equal(trainer_num_after_first_save, 
						trainer_num_after_second_save,
						"Wrong number of Trainers in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save trainer OK.")
	end
	
	def test_save_weather
		@logger.imp("Testing save weather")
		begin
			# Counting number of Weathers before test
			old_weather_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:weather])
					
			# Getting last ID currently in Weather
			old_last_id = @dbi_select_tech.
				select_last_id_from_table(
					@config[:gen][:table_names][:weather])
			
			# Creating a Weather without id
			# (Adding the date & time to the insolation so that's it unique
			# even if the test is launched multiple times and the DB
			# is not cleaned in between.)
			test_insolation = "P5.png"+ 
				DateTime.now.strftime(@config[:gen][:default_date_time_format])
			test_temperature = -2
			test_wind_direction = 
				@ref_list_hash[:ref_direction_list]["Test Direction"]
			test_wind_speed = -2
			weather_to_save = Weather::new(
									insolation: test_insolation,
									temperature: test_temperature,
									wind_direction: test_wind_direction,
									wind_speed: test_wind_speed)
			
			# Saving it
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			saver.save_weather(weather_to_save)
			
			# Check that it has an ID
			assert_operator(0, :<=, weather_to_save.id)
			# Check that its ID is one bigger than the old last one
			assert_equal(old_last_id + 1, weather_to_save.id)
			
			# Check that the number of Weathers in the DB incremented
			weather_num_after_first_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:weather])
			assert_equal(old_weather_num + 1, 
						weather_num_after_first_save,
						"Wrong number of Weathers in DB after first " + 
							"attempt to save")
			
			# Check that if a Weather is retrieved just on that ID,
			# it's the same as the first
			verification_weather = @dbi_select_tech.
				load_weather_by_id(weather_to_save.id)
			validate_weather(weather_to_save, 
							verification_weather, 
							"weather to save")
			
			# Check that if a create the same Weather (without ID)
			# and try to save it, it retrieves the ID but doesn't save
			# it (number of Weather isn't incremented again)
			weather_to_fail_to_save = Weather::new(
										insolation: test_insolation,
										temperature: test_temperature,
										wind_direction: test_wind_direction,
										wind_speed: test_wind_speed)
										
			saver.save_weather(weather_to_fail_to_save)
			
			assert_equal(weather_to_save,
						weather_to_fail_to_save,
						"Wrong ID after attempt to fail to save")
			
			weather_num_after_second_save = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:weather])
			assert_equal(weather_num_after_first_save, 
						weather_num_after_second_save,
						"Wrong number of Weathers in DB after first " + 
							"attempt to save")
			
		rescue Exception => err
			@logger.error(err.inspect)
			@logger.error(err.backtrace)
			flunk(err.inspect)
		end
		@logger.ok("Tests for save weather OK.")
	end
	
end