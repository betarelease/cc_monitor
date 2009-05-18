require File.join(File.expand_path(File.dirname(__FILE__)), "../vendor/activerecord-2.1.1/lib/activerecord")
require "rexml/document"
require 'net/http'
require 'uri'
require 'ostruct'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'db.sqlite'
class Project < ActiveRecord::Base
  set_table_name 'projects'
  
  def self.fetch(address)
    feed = fetch_xml address
    projects = []
    CcTray.new.parse(feed) do |element|
      if element.attributes['name'].include? "Could not connect"
        project = OpenStruct.new(element.attributes)
      else
        project = find_or_create(element)
        project.last_successful_build = difference(project.last_successful_build)
        project.last_failed_build = difference(project.last_failed_build)
      end
      projects << project
    end
    projects
  end
  
  def self.fetch_xml(address)
    url = URI.parse(address)
    begin 
      Net::HTTP.start(url.host, url.port) do |http|
        req = Net::HTTP::Get.new(url.path)
        response = http.request(req)
        case response
          when Net::HTTPSuccess     then response.body
          when Net::HTTPRedirection then fetch_xml(response['location'])
          else response.error!
        end
      end
    rescue
      error = error_xml
    end
  end

  def self.error_xml
    error = <<EOF
<Projects>
<Project name="Could not connect to #{address}" activity="Error" 
lastBuildStatus="Error" lastBuildLabel="unknown" lastBuildTime="unknown" webUrl="#{address}"/>
</Projects>
EOF
  end

  def self.difference(recorded_time)
    seconds = (Time.now - recorded_time.to_i).to_i
    minutes = seconds/60
    hours = minutes/60
  end

  def self.find_or_create(element)
    values = {}
    element.attributes.each do |name, value|
      values.merge!(name.underscore.to_sym => value.to_s)
    end
    project = Project.find_or_create_by_name(values[:name])
    unless project.last_build_time == Time.parse(element.attributes['lastBuildTime'])
      populate_project(project, element)
    end
    project.save! 
    project
  end
  
  def self.populate_project(project, element)
    project.last_build_time = element.attributes['lastBuildTime']
    project.last_build_status = element.attributes['lastBuildStatus']
    project.last_build_label =element.attributes['lastBuildLabel']
    project.activity = element.attributes['activity']
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