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

    it "parse xml" do
      address = :address
      xml = <<EOF
<Projects>
<Project name="Could not connect to #{address}" activity="Error" lastBuildStatus="Error" lastBuildLabel="unknown" lastBuildTime="unknown" webUrl="#{address}"/>
</Projects>
EOF
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
  
end
