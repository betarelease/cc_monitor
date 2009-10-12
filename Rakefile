#cc rb example   http://cruisecontrol/XmlStatusReport.aspx
#cc java example http://cruisecontrol:8080/dashboard/cctray.xml
PROJECTS = "http://cruisecontrolrb.engineering.rackspace.com/XmlStatusReport.aspx"
AUTH = true
USERNAME = "thoughtworks"
PASSWORD = "th0ughtw0rks"
# PROJECTS = "http://localhost:8080/dashboard/cctray.xml"

# PROJECTS = "http://localhost:3000/simple"

TITLE    = "BLACKBOX BUILD MONITOR"

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
  task :start do
    require 'start'
    start
  end
  
  task :clean => ['db:migrate:reset']  
end