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
sql_create = YAML.load_file("table_creation.sql.yml")
sql_delete = YAML.load_file("table_deletion.sql.yml")
sql_insert = YAML.load_file("insert.sql.yml")
sql = sql_create.merge!(sql_delete.merge!(sql_insert))
config["sql"] = sql
#logger.debug("Config : " + config.to_s)

# Creating interface with database
dbi = DatabaseInterface::new(logger, config["gen"]["database_name"], config["sql"])

logger.imp("CREATING DATABASE")

logger.imp("TESTING OBJECTS")

job = Job.new
job.start_time = start_time
job.loading_end_time = start_time = Time.now
job.crawling_end_time = start_time = Time.now
job.computing_end_time = start_time = Time.now

dbi.insert_job(job)

logger.end_log