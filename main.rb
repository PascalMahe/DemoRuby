require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require './SimpleHtmlLogger.rb'
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


# Creating interface with database
dbi = DatabaseInterface::new(logger, config[:gen][:database_name], config[:sql])

logger.imp("CHECKING DATABASE EXISTENCE")
table_nb = dbi.get_table_number()
created = false
if(table_nb < 22) then
	logger.info("Creating tables")
	dbi.create_tables()
	logger.info("Tables created")
else 
	logger.info("Tables already exist")
end
	


logger.imp("TESTING OBJECTS")

job = Job.new
job.start_time = start_time.strftime("%d/%m/%Y %H:%M:%S.%L")
# job.loading_end_time = Time.now
# job.crawling_end_time = Time.now
# job.computing_end_time = Time.now

dbi.insert_job(job)

logger.end_log