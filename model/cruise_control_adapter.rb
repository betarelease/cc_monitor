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

end