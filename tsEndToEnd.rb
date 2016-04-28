require './TestSuite.rb'
require './validation-core.rb'
require './ref.rb'
require './Crawler.rb'
require './Saver.rb'

class TestEndToEnd < TestSuite
	
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
	
	def test_end_to_end
		
		@logger.imp("Testing Crawler and Saver COMBINED!")
		begin
			
			
			@logger.imp("Scrubbing database! (Too late to save...) ")
			@logger.debug(@config[:sql][:clean].keys)
			@config[:sql][:clean].keys.each do |table|
				@logger.info("Scrubbing values from " + table.to_s)
				current_query = @config[:sql][:clean][table]
				dummy_statement = nil
				@dbi_select_tech.execute_query(current_query, dummy_statement, nil, true)
			end

		
			job = Job::new(start_time: Time.now)
			date = Date::new(2013,11,15)
			@crawler.driver.get("file:///D:/Dev/workspace/RPP/Test-HTML/accueil.htm")
			html_meeting_list = @crawler.driver.find_element(:xpath, "//div[@id='reunions-view']")
			
			if html_meeting_list == nil then
				flunk("html_meeting_list is nil.")
			end
			
			result_insertion_time_before = Time.now
			
			meeting_list = @crawler.fetch_meetings(html_meeting_list, job)
			
			# Checking the list has meetings in it and that those meetings
			# have races
			assert_equal(5, meeting_list.size)
			assert_equal(9, meeting_list[0].race_list.size)
			assert_equal(8, meeting_list[1].race_list.size)
			assert_equal(8, meeting_list[2].race_list.size)
			assert_equal(4, meeting_list[3].race_list.size) # should be 5, according to the files 
															# but the main page only has 2 to 5
			assert_equal(6, meeting_list[4].race_list.size)
			
			# Counting number of Meetings before test
			old_meeting_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:meeting])
			
			# Counting number of Jobs before test
			old_job_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:job])
			
			# Counting number of Races before test
			old_races_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:race])
			
			# Saving the meeting_list
			saver = Saver::new(@dbi_insert, 
								@dbi_select_tech, 
								@dbi_select_biz)
			
			saver.save_meeting_list(meeting_list)
			
			
			# Counting number of Meetings after test
			new_meeting_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:meeting])
			
			# Counting number of Jobs after test
			new_job_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:job])
			
			# Counting number of Races after test
			new_races_num = @dbi_select_tech.
				select_count_from_table(
					@config[:gen][:table_names][:race])
			
			
			assert_equal(old_meeting_num + 5, 
						new_meeting_num,
						"Wrong number of Meetings in DB after second " + 
							"attempt to save")
							
			
			assert_equal(old_job_num + 1, 
						new_job_num,
						"Wrong number of Jobs in DB after second " + 
							"attempt to save")
			
			
			assert_equal(old_races_num + 35, 
						new_races_num,
						"Wrong number of Races in DB after second " + 
							"attempt to save")
			
		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for combination of Crawler and Saver OK.")
	end
	
	
end