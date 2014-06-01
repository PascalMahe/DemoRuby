require 'psych' #see why at http://www.opinionatedprogrammer.com/2011/04/parsing-yaml-1-1-with-ruby/
require 'yaml'
require './DatabaseInterface.rb'

def load_config()
	
	# Read config file
	config = []
	config = YAML.load_file("config.yml") # From file (cf. http://strugglingwithruby.blogspot.fr/2008/10/yaml.html)

	#SQL
	sql_create = YAML.load_file(config[:gen][:sql_create])
	sql_delete = YAML.load_file(config[:gen][:sql_delete])
	sql_insert = YAML.load_file(config[:gen][:sql_insert])
	sql_select = YAML.load_file(config[:gen][:sql_select])
	sql = sql_create.merge!(sql_delete.merge!(sql_insert.merge!(sql_select)))
	
	config[:sql] = sql
	return config
end
