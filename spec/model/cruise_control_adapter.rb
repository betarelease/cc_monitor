require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")

describe CruiseControlAdapter do
  
  class Model 
    include CruiseControlAdapter
  end
  
  describe "fetch cc_tray xml" do
    it "should show error when cannot connect" do
      address = "http://localhost:80"
      Model.new.fetch(address).should =~ /Could not connect/
    end
  end
  
  it "should convert to openstruct with ruby conventions" do
    element = OpenStruct.new( :name => "element_name", "attrFromXml" => "value")
    converted = Model.new.convert( element )
    converted.name == "element_name"
    converted.attr_from_xml.should == "value"
  end

  it "should convert to openstruct when NO_STATS is true" do
    NO_STATS = true
    element = OpenStruct.new( :name => "element_name", "attrFromXml" => "value")
    converted = Model.new.refine( element )
    converted.name == "element_name"
    converted.attr_from_xml.should == "value"
    NO_STATS = false
  end
  
  it "should convert to openstruct when it cannot connect" do
    element = OpenStruct.new( :name => "Could not connect", "attrFromXml" => "value")
    converted = Model.new.refine( element )
    converted.name == "Could not connect"
    converted.attr_from_xml.should == "value"
  end
  
  it "should record when NO_STATS is false" do
    NO_STATS = false    
    element = OpenStruct.new( :name => "element_name", "attrFromXml" => "value")
    converted = Model.new.refine( element )
    converted.name == "element_name"
    converted.attr_from_xml.should == "value"
  end
  
end