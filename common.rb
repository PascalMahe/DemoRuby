require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require_relative './DatabaseInterface.rb'
require_relative './DB_insert.rb'
require_relative './DB_select_by_tech_id.rb'
require_relative './DB_select_by_business_id.rb'
require_relative './DB_update.rb'
require_relative './SimpleHtmlLogger.rb'


def nil_safe_to_s(attr)
	if attr == nil
		attr_as_string = "nil"
	else
		attr_as_string = attr.to_s
	end
	return attr_as_string
end

def format_time_diff(sec_with_frac)
	tDif = Time.at(sec_with_frac)
	if sec_with_frac > 3600 then
		format =  $globalState.config[:gen][:default_time_format]
		suffix = "h"
	elsif sec_with_frac > 60 then
		format =  $globalState.config[:gen][:minute_time_format]
		suffix = "m"
	else
		format =  $globalState.config[:gen][:second_time_format]
		suffix = "s"
	end
	return tDif.strftime(format) + " " + suffix
end

def log_object_and_ref(obj)
	logger = $globalState.logger
	level_before = logger.level
	logger.level = SimpleHtmlLogger::DEBUG

	logger.debug("Currently inside a : " + obj.class.to_s)
	logger.debug("Current @ref_list_hash : " + obj.ref_list_hash.to_s)

	logger.level = level_before
end

class GlobalState
	attr_accessor :config
	attr_accessor :logger
	attr_accessor :dbi
	attr_accessor :dbi_insert
	attr_accessor :dbi_select_by_tech_id
	attr_accessor :dbi_select_by_business_id
	attr_accessor :dbi_update
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
		@dbi_insert = DatabaseInterfaceInsert::new(@config, is_test, @logger)
		@dbi_select_by_tech_id = DatabaseInterfaceSelectByTechId::new(@config, is_test, @logger)
		@dbi_select_by_business_id = DatabaseInterfaceSelectByBusinessId::new(@config, is_test, @logger)
		@dbi_update = DatabaseInterfaceUpdate::new(@config, is_test, @logger)
	end

end
