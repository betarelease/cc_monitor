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
      error = <<EOF
<Projects>
<Project name="Could not connect to #{address}" activity="Error" lastBuildStatus="Error" lastBuildLabel="unknown" lastBuildTime="unknown" webUrl="#{address}"/>
</Projects>'
EOF
    end
  end

  def self.fetch_rss(address)
    xml_text = fetch_xml address
    doc = REXML::Document.new xml_text
    projects = []
    doc.elements.each('rss/channel/item') do |element|
      title = element.elements["title"].get_text.to_s.split(" ")[0]
      status = element.elements["description"].get_text
      last_build_time = element.elements["pubDate"].get_text
      web_url = element.elements["link"].get_text
      project = Project.find_or_create_by_name({:name => title, 
                                                :last_build_status => status,
                                                :last_build_time => last_build_time, 
                                                :last_build_label => 1})
      projects << project
    end
    projects
  end

  def self.fetch(address)
    xml_text = fetch_xml address
    doc = REXML::Document.new xml_text
    projects = []
    doc.elements.each('Projects/Project') do |element|
      if element.attributes['name'].include? "Could not connect"
        project = OpenStruct.new(element.attributes)
      else
        project =  find_or_create(element)
        project.last_successful_build = difference(project.last_successful_build)
        project.last_failed_build = difference(project.last_failed_build)
      end
      projects << project
    end
    projects
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
    project = Project.find_or_create_by_name(values)
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
    project
  end
end