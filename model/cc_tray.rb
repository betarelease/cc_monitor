class CcTray
  def parse(feed)
    doc = REXML::Document.new feed
    projects = []
    doc.elements.each('Projects/Project') do |element|
      yield element
    end
  end
end