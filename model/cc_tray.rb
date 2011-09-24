require "rexml/document"
require 'net/https'
require 'uri'
require 'ostruct'

class CCTray
  def projects(feed)
    xml = fetch_feed feed    
    projects = []
    parse(xml) do |element|
      if element.attributes['name'].include? "Could not connect"
        project = OpenStruct.new(element.attributes)
      else
        project = Project.find_or_create(element)
        project.record!(element)
      end
      if ONLY_BROKEN_BUILDS
        projects << project if project.last_build_status != "Success"
      else
        projects << project
      end
    end
    projects
  end

  def pipelines(feed)
    projects = projects feed
    sorted_projects = projects.sort_by(&:name)
    grouped_by_pipeline = sorted_projects.group_by do |project|
      project.name.split("::").first
    end
    grouped_by_pipeline
  end
  
  
private

  def fetch_feed(feed)
    return "" unless feed
    url = URI.parse(feed)
    begin 
      http = Net::HTTP::new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      
      http.start do |http|
        req = Net::HTTP::Get.new(url.path)
        req.basic_auth USERNAME, PASSWORD if AUTH
        response = http.request(req)
        case response
          when Net::HTTPSuccess     then response.body
          when Net::HTTPRedirection then fetch_feed(response['location'])
          else response.error!
        end
      end
    rescue => e
      puts "Exception was #{e.message}"
      error_xml(feed)
    end
  end

  def error_xml(feed)
    error = <<EOF
<Projects>
<Project name="Could not connect to #{feed}" activity="Error" 
lastBuildStatus="Error" lastBuildLabel="unknown" lastBuildTime="unknown" webUrl="#{feed}"/>
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