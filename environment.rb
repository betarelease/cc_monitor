RUBY_ROOT =
  File.expand_path( File.join( File.dirname(__FILE__), "." ) ) unless defined? RUBY_ROOT

require "rubygems"


require 'rack'
require 'ramaze'
require 'active_record'
require 'sqlite3'

require File.join(File.expand_path(File.dirname(__FILE__)), "config")

database_file = File.join(File.expand_path(File.dirname(__FILE__)), "database.yml")
ActiveRecord::Base.establish_connection(YAML::load(File.open(database_file)))

ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))

$LOAD_PATH.unshift( "#{RUBY_ROOT}")
$LOAD_PATH.unshift( "#{RUBY_ROOT}/start")

require "#{RUBY_ROOT}/model/cc_tray"
require "#{RUBY_ROOT}/model/project"
require "#{RUBY_ROOT}/model/statistic"
require "#{RUBY_ROOT}/controller/main"
