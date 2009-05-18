class CcTray
  def parse(feed)
    doc = REXML::Document.new feed
    projects = []
    doc.elements.each('Projects/Project') do |element|
      yield element
    end
  end
  
  def fetch(address)
    feed = Project.fetch_xml address
    projects = []
    parse(feed) do |element|
      if element.attributes['name'].include? "Could not connect"
        project = OpenStruct.new(element.attributes)
      else
        project = Project.find_or_create(element)
        project.last_successful_build = Project.difference(project.last_successful_build)
        project.last_failed_build = Project.difference(project.last_failed_build)
      end
      projects << project
    end
    projects
  end
  
end