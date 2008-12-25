require 'active_record'
require "rexml/document"
require 'net/http'
require 'uri'
require 'ostruct'


ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'db.sqlite'
class Project < ActiveRecord::Base
  set_table_name 'projects'
  
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
      raise "No Projects"
    end
  end

  def self.fetch(address)
    projects = []
    xml_text = fetch_xml address
    doc = REXML::Document.new xml_text
    doc.elements.each('Projects/Project') do |element|
      project = Project.find_or_create_by_name(element.attributes['name']) 
      project.activity = element.attributes['activity']
      project.last_build_status = element.attributes['lastBuildStatus']
      project.last_build_time = element.attributes['lastBuildTime']
      project.web_url = element.attributes['webUrl']

      unless project.last_build_label == element.attributes['lastBuildLabel']
        project.last_build_label = element.attributes['lastBuildLabel']
        project.build_count +=1
        if project.last_build_status.include? "Success"
          project.success_count += 1 
          project.last_successful_build = project.last_build_time
        end
        if project.last_build_status.include? "Failure"
          project.failure_count += 1
          project.last_failed_build = project.last_build_time
        end
      end
      project.save!           
      projects << project
    end
    projects
  end
  
end

