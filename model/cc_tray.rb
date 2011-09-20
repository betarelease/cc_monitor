require "rexml/document"
require 'net/https'
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
        project.record!(element)
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
      http = Net::HTTP::new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      
      http.start do |http|
        req = Net::HTTP::Get.new(url.path)
        req.basic_auth USERNAME, PASSWORD if AUTH
        response = http.request(req)
        case response
          when Net::HTTPSuccess     then response.body
          when Net::HTTPRedirection then fetch_xml(response['location'])
          else response.error!
        end
      end
    rescue => e
      puts "Exception was #{e.message}"
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
end