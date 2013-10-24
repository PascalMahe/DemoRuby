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

logger = SimpleHtmlLogger::new(SimpleHtmlLogger::Debug)
logger.info("START TIME: " + start_time.strftime("%d/%m/%Y %H:%M:%S.%L"))

# Read config file
config = []
config = YAML.load_file("config.yml") # From file (cf. http://strugglingwithruby.blogspot.fr/2008/10/yaml.html)
logger.debug("Config : " + config.to_s)
sql_create = YAML.load_file("sql.table_creation.yml")
sql_delete = YAML.load_file("sql.table_deletion.yml")
sql_insert = YAML.load_file("sql.insert.yml")
sql_select = YAML.load_file("sql.select.yml")
logger.debug("sql_select : " + sql_select.to_s)
sql = sql_create.merge!(sql_delete.merge!(sql_insert.merge!(sql_select)))
config[:sql] = sql

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

job = Job::new
job.start_time = start_time.strftime("%d/%m/%Y %H:%M:%S.%L")
job.loading_end_time = Time.now.strftime("%d/%m/%Y %H:%M:%S.%L")
job.crawling_end_time = Time.now.strftime("%d/%m/%Y %H:%M:%S.%L")
job.computing_end_time = Time.now.strftime("%d/%m/%Y %H:%M:%S.%L")


dbi.insert_job(job)

selected_job = dbi.load_job(job.id)
logger.debug(selected_job.to_s)

#TODO : test other objects
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


logger.info("RefDirection : ")
ref_dir_list = dbi.load_ref_direction_list()
logger.debug(ref_dir_list.to_s)

logger.info("RefTrackCondition : ")
ref_track_condition_list = dbi.load_ref_track_condition_list()
logger.debug(ref_track_condition_list)

logger.info("RefRaceType : ")
ref_race_type_list = dbi.load_ref_race_type_list()
logger.debug(ref_race_type_list)

logger.info("RefColumn : ")
ref_column_list = dbi.load_ref_column_list()
logger.debug(ref_column_list)

logger.info("RefSex : ")
ref_sex_list = dbi.load_ref_sex_list()
logger.debug(ref_sex_list)

logger.info("RefBreed : ")
ref_breed_list = dbi.load_ref_breed_list()
logger.debug(ref_breed_list)

logger.info("RefCoat : ")
ref_coat_list = dbi.load_ref_coat_list()
logger.debug(ref_coat_list)

logger.info("RefBlinder : ")
ref_blinder_list = dbi.load_ref_blinder_list()
logger.debug(ref_blinder_list)

logger.info("RefShoes : ")
ref_shoes_list = dbi.load_ref_shoes_list()
logger.debug(ref_shoes_list)

# Creating test interface with database
logger.imp("END TESTS")
logger.imp("REAL STUFF")
dbi = DatabaseInterface::new(logger, config[:gen][:database_name], config[:sql])

logger.end_log