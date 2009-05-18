require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/project")

describe Project do
  it "fetch cc_tray xml" do
    address = :address
    xml = <<EOF
<Projects>
<Project name="Could not connect to #{address}" activity="Error" lastBuildStatus="Error" lastBuildLabel="unknown" lastBuildTime="unknown" webUrl="#{address}"/>
</Projects>
EOF
    url = {:host => "host", :port => "port"}
    URI.should_receive(:parse).with(address).and_return(url)
    # NET::HTTP.should_receive(:start).with(url[:host], url[:port]).and_yield
    Project.fetch_xml(address).should == xml
  end

  it "parse xml for Error project" do
    address = :address
    xml = :xml
    Project.should_receive(:fetch_xml).and_return(xml)
    attributes = {'name' => "Could not connect", 'activity' => "", 'lastBuildTime' => "",
                  'lastBuildLabel' => "", 'lastBuildStatus' => "", 'webUrl' => "#{address}"}
    doc = OpenStruct.new
    element = OpenStruct.new(:attributes => attributes)
    elements = OpenStruct.new
    elements.should_receive(:each).and_yield(element)
    doc.should_receive(:elements).and_return(elements)
    REXML::Document.should_receive(:new).and_return(doc)
    Project.fetch(address).should == [xml]
  end
    
    it "calculates time difference" do      
      Project.difference(2.days.ago).should == 48
    end
    
    it "parse xml for valid project" do
      address = :address
      xml = :xml
      Project.should_receive(:fetch_xml).and_return(xml)
      attributes = {'name' => "testProject", 'activity' => "Sleeping", 'lastBuildTime' => "unknown",
                    'lastBuildLabel' => "1.0", 'lastBuildStatus' => "Success", 'webUrl' => "http://www.com"}
      doc = OpenStruct.new
      element = OpenStruct.new(:attributes => attributes)
      elements = OpenStruct.new
      elements.should_receive(:each).and_yield(element)
      REXML::Document.should_receive(:new).and_return(doc)
      Project.fetch(address)
    end
  
end
