%w( vendor/rack-0.4.0/lib/rack 
    vendor/ramaze-2008.11/lib/ramaze 
    vendor/activerecord-2.1.1/lib/activerecord ).each do |gem|
  require File.join(File.expand_path(File.dirname(__FILE__)), ".", gem)
end

ActiveRecord::Base.establish_connection(YAML::load(File.open('database.yml')))
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
