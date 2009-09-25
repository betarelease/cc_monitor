require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/cc_tray")

describe CCTray do
  it "fetch cc_tray xml should show error when cannot connect" do
    address = "http://localhost:80"
    CCTray.new.send(:fetch_xml, address).should =~ /Could not connect/
  end

  it "calculates time difference" do      
    CCTray.new.send(:difference, 2.days.ago).should == 48
  end
  
end
