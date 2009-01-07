require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/project")

describe Project do
  # it "should calculate time difference in hours" do
  #   puts Project.difference(Time.now).should == 0
  #   puts Project.difference(Time.at(0)).should == 0
  # end

  it "should parse cc_tray xml" do
    Project.stubs(:fetch_xml).returns("<>")
  end
  
end