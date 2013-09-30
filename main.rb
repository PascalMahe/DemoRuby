require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require 'sqlite3'
require './SimpleHtmlLogger.rb'

start_time = Time.now

logger = SimpleHtmlLogger::new(SimpleHtmlLogger::Debug)
logger.info("START TIME: " + start_time.strftime("%d/%m/%Y %H:%M:%S.%L"))

# Check whether database exists (ie. if all tables exist) 
#Cf. http://stackoverflow.com/a/1604121/2112089
db = SQLite3::Database.new ("test.db")
config = YAML.load_file("config.yml") # From file (cf. http://strugglingwithruby.blogspot.fr/2008/10/yaml.html)


# Read file (cf. http://stackoverflow.com/a/7157219/2112089)
str_database_creation = ''
begin
    file = File.open("table_creation.sql", "r")
    while (line = file.gets)
        str_database_creation = str_database_creation + line
    end
    file.close
rescue => err
	logger.error("Exception: #{err}")
end


logger.imp("CREATING DATABASE")
begin    
	db.execute_batch(str_database_creation)
rescue SQLite3::Exception => e 
    logger.error "Exception occured"
    logger.error e
ensure
    db.close if db
end
logger.imp("DATABASE CREATED")

logger.end_log