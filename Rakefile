#cc rb example   http://cruisecontrol/XmlStatusReport.aspx
#cc java example http://cruisecontrol:8080/dashboard/cctray.xml
require 'config'

namespace :db do
  namespace :migrate do
    task :reset do
      require 'migrations/project'
      Project.down
      Project.up
    end
  end
end

task :spec do
  Dir.glob("spec/model/").each do |spec_name|
    spec spec_name
  end
end

namespace :monitor do
  task :clean => ['db:migrate:reset']  

  task :start do
    require 'start'
    start
  end

  task :test do
    require 'start'
    start  
  end
  
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