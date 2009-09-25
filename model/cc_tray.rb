require "rexml/document"
require 'net/http'
require 'uri'
require 'ostruct'

class CCTray
  def fetch(address)
    feed = fetch_xml address
    projects = []
    parse(feed) do |element|
      if element.attributes['name'].include? "Could not connect"
        project = OpenStruct.new(element.attributes)
      else
        project = Project.find_or_create(element)
        project.last_successful_build = difference(project.last_successful_build)
        project.last_failed_build = difference(project.last_failed_build)
      end
      projects << project
    end
    projects
  end
  
private
  
  def fetch_xml(address)
    return "" unless address
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
      error_xml(address)
    end
  end

  def error_xml(address)
    error = <<EOF
<Projects>
<Project name="Could not connect to #{address}" activity="Error" 
lastBuildStatus="Error" lastBuildLabel="unknown" lastBuildTime="unknown" webUrl="#{address}"/>
</Projects>
EOF
  end
  
  def parse(feed)
    doc = REXML::Document.new feed
    projects = []
    doc.elements.each('Projects/Project') do |element|
      yield element
    end
  end
  
  
  def difference(recorded_time)
    seconds = (Time.now - recorded_time.to_i).to_i
    minutes = seconds/60
    hours = minutes/60
  end
  
end