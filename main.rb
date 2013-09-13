require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require './SimpleHtmlLogger.rb'

start_time = Time.now

logger = SimpleHtmlLogger::new(SimpleHtmlLogger::Debug)
logger.info("START TIME: " + start_time.strftime("%d/%m/%Y %H:%M:%S.%L"))
logger.log(SimpleHtmlLogger::Important, "IMPORTANT")
logger.log(SimpleHtmlLogger::Error, "ERROR")
logger.log(SimpleHtmlLogger::Info, "INFO")
logger.log(SimpleHtmlLogger::Debug, "DEBUG")
logger.end_log