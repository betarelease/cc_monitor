require "rexml/document"
require 'net/https'
require 'uri'
require 'ostruct'
require 'base64'

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
    pipeline_with_stages(grouped_by_pipeline)
  end
  
  
private

  def fetch_feed(feed)
    # http://martinottenwaelter.fr/2010/12/ruby19-and-the-ssl-error/
    # require 'net/https'
    # https = Net::HTTP.new('encrypted.google.com', 443)
    # https.use_ssl = true
    # https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # https.ca_path = '/etc/ssl/certs' if File.exists?('/etc/ssl/certs') # Ubuntu
    # https.ca_file = '/opt/local/share/curl/curl-ca-bundle.crt' if File.exists?('/opt/local/share/curl/curl-ca-bundle.crt') # Mac OS X
    # https.request_get('/')
    return "" unless feed
    url = URI.parse(feed)
    begin 
      http = Net::HTTP::new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      
      http.start do |http|
        req = Net::HTTP::Get.new(url.path)
        req.basic_auth USERNAME, Base64.decode64(PASSWORD) if AUTH
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
  
  def pipeline_with_stages(grouped_by_pipeline) 
    grouped_by_pipeline.each do |pipeline, stages|
      stages = stages.each {|stage| stage.name = stage.name.partition("::").last}
    end
  end
  
end