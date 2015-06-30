require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require './DatabaseInterface.rb'
require './SimpleHtmlLogger.rb'

class GlobalState
	attr_accessor :config
	attr_accessor :logger
	attr_accessor :dbi
	attr_accessor :is_test

	def load_config()
		
		# Read config file
		config = []
		config = YAML.load_file("config.yml") # From file (cf. http://strugglingwithruby.blogspot.fr/2008/10/yaml.html)

		#SQL
		sql_create = YAML.load_file(config[:gen][:sql_create])
		sql_delete = YAML.load_file(config[:gen][:sql_delete])
		sql_insert = YAML.load_file(config[:gen][:sql_insert])
		sql_select = YAML.load_file(config[:gen][:sql_select])
		sql_update = YAML.load_file(config[:gen][:sql_update])
		sql_gen = YAML.load_file(config[:gen][:sql_gen])
		sql = sql_create.merge!(sql_delete.merge!(sql_insert.merge!(sql_select.merge!(sql_update.merge!(sql_gen)))))
		
		config[:sql] = sql
		return config
	end
	
	def initialize(is_test, log_level, path_to_log)
		@config = load_config()
		@logger = SimpleHtmlLogger::new(path_to_log, log_level)
		@is_test = is_test
		@dbi = DatabaseInterface::new(@config, is_test, @logger)
	end
	
end

