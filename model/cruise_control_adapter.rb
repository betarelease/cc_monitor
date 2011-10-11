module CruiseControlAdapter
  def parse(feed)
    xml = fetch feed
    doc = REXML::Document.new xml
    projects = []
    doc.elements.each('Projects/Project') do |element|
      yield element
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

  def fetch(feed)
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
          when Net::HTTPRedirection then fetch(response['location'])
          else response.error!
        end
      end
    rescue => e
      puts "Exception was #{e.message}"
      error_xml(feed)
    end
  end
  
  def pipeline_with_stages(grouped_by_pipeline) 
    grouped_by_pipeline.each do |pipeline, stages|
      stages = stages.each {|stage| stage.name = stage.name.partition("::").last}
    end
  end

  def convert( element )
    values = {}
    element.attributes.each do |name, value|
      values.merge!( name.underscore.to_sym => value.to_s )
    end
    OpenStruct.new(values)
  end
  
  def refine(element)
    return convert(element) if NO_STATS || element.attributes['name'].include?("Could not connect")
    record(element)
  end
  
  def record(element)
    project = Project.find_or_create(element)
    project.record!(element)
    project
  end
  

end