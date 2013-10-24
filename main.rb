require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require './SimpleHtmlLogger.rb'
require './ref.rb'
require './environnment.rb'
require './prediction.rb'
require './people.rb'
require './Runner.rb'
require './DatabaseInterface.rb'

start_time = Time.now

# Initializing logger
logger = SimpleHtmlLogger::new(SimpleHtmlLogger::Debug)

# Read config file
config = []
config = YAML.load_file("config.yml") # From file (cf. http://strugglingwithruby.blogspot.fr/2008/10/yaml.html)
logger.info("START TIME: " + start_time.strftime(config[:gen][:default_date_time_format]))

logger.debug("Config : " + config.to_s)
sql_create = YAML.load_file("sql.table_creation.yml")
sql_delete = YAML.load_file("sql.table_deletion.yml")
sql_insert = YAML.load_file("sql.insert.yml")
sql_select = YAML.load_file("sql.select.yml")
logger.debug("sql_select : " + sql_select.to_s)
sql = sql_create.merge!(sql_delete.merge!(sql_insert.merge!(sql_select)))
config[:sql] = sql
loading_end_time = Time.now

# Creating job 
current_job = Job::new
current_job.start_time = start_time
current_job.loading_end_time = loading_end_time

# Creating test interface with database
logger.imp("TESTS")
dbi = DatabaseInterface::new(logger, config[:gen][:test_database_name], config[:sql])

logger.imp("Checcking Database Existence")
table_nb = dbi.get_table_number()
created = false
if(table_nb < 22) then
	logger.info("Creating tables")
	dbi.create_tables()
	logger.info("Tables created")
else 
	logger.info("Tables already exist")
end

logger.imp("Testing Objects")

logger.info("Testing loading of RefObjects")
#dbi.insert_ref_direction(RefDirection::new("", "test1"))
#dbi.insert_ref_track_condition(RefTrackCondition::new("", "test1"))
#dbi.insert_ref_race_type(RefRaceType::new("", "test1"))
#dbi.insert_ref_column(RefColumn::new("", "test1"))
#dbi.insert_ref_sex(RefSex::new("", "test1"))
#dbi.insert_ref_breed(RefBreed::new("", "test1"))
#dbi.insert_ref_coat(RefCoat::new("", "test1"))
#dbi.insert_ref_blinder(RefBlinder::new("", "test1"))
#dbi.insert_ref_shoes(RefShoes::new("", "test1"))

ref_list_hash = dbi.load_all_refs()

logger.info("Testing creation of Business Objects")

logger.info("Testing Job")
job = Job::new
job.start_time = start_time.strftime(config[:gen][:default_date_time_format])
job.loading_end_time = Time.now.strftime(config[:gen][:default_date_time_format])
job.crawling_end_time = Time.now.strftime(config[:gen][:default_date_time_format])
job.computing_end_time = Time.now.strftime(config[:gen][:default_date_time_format])

dbi.insert_job(job)

selected_job = dbi.load_job_by_id(job.id, config[:gen][:default_date_time_format])
logger.debug(selected_job.to_s)

logger.info("Testing Weather")
weather = Weather::new
weather.wind_direction = ref_list_hash[:ref_direction_list]["S"]
weather.temperature = 19
weather.wind_speed = 11
weather.insolation = "P6.png"

dbi.insert_weather(weather)

selected_weather = dbi.load_weather_by_id(weather.id)
logger.debug(selected_weather.to_s)

logger.info("Testing Meeting")
meeting = Meeting::new
meeting.job = selected_job
meeting.track_condition = ref_list_hash[:ref_trackcondition_list]["Terrain bon", logger]
meeting.date = Time.now.strftime(config[:gen][:default_date_format])
meeting.racetrack = "Auteuil"
meeting.number = 11
meeting.url = "http://www.test.com"

dbi.insert_meeting(meeting)

selected_meeting = dbi.load_meeting_by_id(meeting.id)
logger.debug(selected_meeting.to_s)

logger.imp("END TESTS")

logger.imp("REAL STUFF")
# Creating real interface with database
dbi = DatabaseInterface::new(logger, config[:gen][:database_name], config[:sql])

logger.end_log