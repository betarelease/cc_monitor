require 'webrick'

class TestPublisher < WEBrick::HTTPServlet::AbstractServlet
  
  RESPONSE_TYPES = {0 => :building, 1 => :sleeping, 2 => :checking_modifications}
  BUILD_STATUS = {0 => "Success", 1 => "Failure", 2 => "Failure"}
  def do_GET(request, response)
    status, content_type, body = do_stuff_with(request)
    
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end
  
  def do_stuff_with(request)
    random_response = RESPONSE_TYPES[rand(2)]
    status_code = BUILD_STATUS[rand(2)]
    xml_response = self.send(random_response, status_code)
    puts xml_response
    return 200, "text/xml", xml_response
  end
  
  def building(last_build_status)
    building = <<XML
    <Projects>
      <Project name="test project" activity="Building" 
               lastBuildStatus="#{last_build_status}" lastBuildLabel="#{rand(100)}" 
               lastBuildTime="unknown" webUrl="http://www.com"/>
    </Projects>
XML
  end

  def sleeping(last_build_status)
    building = <<XML
    <Projects>
      <Project name="test project" activity="Sleeping" 
               lastBuildStatus="#{last_build_status}" lastBuildLabel="#{rand(100)}" 
               lastBuildTime="unknown" webUrl="http://www.com"/>
    </Projects>
XML
  end
  
  def checking_modifications(last_build_status)
    building = <<XML
    <Projects>
      <Project name="test project" activity="Checking Modifications" 
               lastBuildStatus="#{last_build_status}" lastBuildLabel="#{rand(100)}" 
               lastBuildTime="unknown" webUrl="http://www.com"/>
    </Projects>
XML
  end
  
end

if __FILE__ == $0
  server = WEBrick::HTTPServer.new(:Port => 3000)
  server.mount "/test_publisher", TestPublisher
  trap("INT"){ server.shutdown }

  server.start
end