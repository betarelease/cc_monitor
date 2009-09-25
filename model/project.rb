require File.join(File.expand_path(File.dirname(__FILE__)), "../vendor/activerecord-2.1.1/lib/activerecord")

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'db.sqlite'

class Project < ActiveRecord::Base
  set_table_name 'projects'
  
  def self.find_or_create(element)
    values = {}
    element.attributes.each do |name, value|
      values.merge!(name.underscore.to_sym => value.to_s)
    end
    project = Project.find_or_create_by_name(values[:name])
    unless project.last_build_time == Time.parse(element.attributes['lastBuildTime'])
      project = populate_project(project, element)
    end
    Graph.new.plot(project)
    project.save! 
    project
  end
  
  def self.populate_project(project, element)
    project.last_build_time = element.attributes['lastBuildTime']
    project.last_build_status = element.attributes['lastBuildStatus']
    project.last_build_label =element.attributes['lastBuildLabel']
    project.activity = element.attributes['activity']
    project.web_url = element.attributes['webUrl']
    project.build_count +=1
    if project.last_build_status.include? "Success"
      project.success_count += 1 
      project.last_successful_build = project.last_build_time
    end
    if project.last_build_status.include? "Failure"
      project.failure_count += 1
      project.last_failed_build = project.last_build_time
    end
    project
  end
  
end