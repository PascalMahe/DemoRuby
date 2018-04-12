require_relative './TestSuite.rb'
require_relative '../ref.rb'
require_relative '../Crawler.rb'
require_relative './validation-meeting.rb'
require_relative './validation-race.rb'
require_relative './validation-runner-joint.rb'
require_relative './validation-runner-list.rb'
require_relative './validation-runner-result.rb'

class TestCrawler < TestSuite

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
	def test_fetch_meetings

		@logger.imp("Testing fetch meetings")
		begin
			job = Job::new
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

			# Checking the meetings
			# in order to not spend an eternity writing validation functions
			# for every race and runner, the meetings are "crippled" before
			# validation
			# R1
			r1 = meeting_list[0]

			r1_c7 = r1.race_list[6]
			validate_race_R1_C7(r1_c7, result_insertion_time_before)

			r1.race_list = nil
			validate_R1(r1, job)

			# R2
			r2 = meeting_list[1]

			r2_c7 = r2.race_list[6]
			validate_race_R2_C7(r2_c7, result_insertion_time_before)

			r2.race_list = nil
			validate_R2(r2, job)

			# R3
			r3 = meeting_list[2]

			r3_c1 = r3.race_list[0]
			validate_race_R3_C1(r3_c1, result_insertion_time_before)

			r3.race_list = nil
			validate_R3(r3, job)

			# R4
			r4 = meeting_list[3]

			r4_c3 = r4.race_list[1] # bug: R4_C1 isn't fetched (file doesn't
									# exist ?) so C3 is actually 2nd in the
									# list
			validate_race_R4_C3(r4_c3, result_insertion_time_before)

			r4.race_list = nil
			validate_R4(r4, job)

			# R5
			r5 = meeting_list[4]

			r5_c5 = r5.race_list[4]
			validate_race_R5_C5(r5_c5, result_insertion_time_before)

			r5.race_list = nil
			validate_R5(r5, job)

		rescue Exception => err
			log_flunking_test(err)
		end
		@logger.ok("Tests for fetch_meetings OK.")
	end

end
