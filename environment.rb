require File.join(File.expand_path(File.dirname(__FILE__)), "/vendor/activerecord-2.1.1/lib/activerecord")

ActiveRecord::Base.establish_connection(YAML::load(File.open('database.yml')))
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
