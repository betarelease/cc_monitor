#cc rb example   http://cruisecontrol/XmlStatusReport.aspx
#cc java example http://cruisecontrol:8080/dashboard/cctray.xml
require 'config'

namespace :db do
  desc "Setup environment"
  task :environment do
    load 'environment.rb'
  end
  
  task :create => [:environment] do
    
  end
  
  desc "Migrate the database"
  task :migrate => [:environment] do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('migrations', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end    
end

desc "Run all specs"
task :spec do
  Dir.glob("spec/model/").each do |spec_name|
    spec spec_name
  end
end

namespace :monitor do
  desc "Start monitor"
  task :start do
    require 'start'
    start
  end

  desc "Start monitor under test mode"
  task :test do
    require 'start'
    start  
  end
  
  desc "Start test publisher for the monitor"
  task :test_publisher do
    require 'test_publisher'
    PUBLISHER_PORT = 3000
    server = WEBrick::HTTPServer.new(:Port => PUBLISHER_PORT)
    server.mount "/test_publisher", TestPublisher
    trap("INT"){ server.shutdown }

    puts "Starting Test Publisher on port: #{PUBLISHER_PORT}"
    server.start    
  end
end