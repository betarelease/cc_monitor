require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/cc_tray")

describe CCTray do
  describe "fetch cc_tray xml" do
    it "should show error when cannot connect" do
      address = "http://localhost:80"
      CCTray.new.send(:fetch, address).should =~ /Could not connect/
    end
  end
  
  describe "pipelines" do
    it "should understand and seggregate pipelines" do
      cc_tray = CCTray.new
      projects = [{:name => "Pipeline_1::stage1"}, {:name => "Pipeline_1::stage2"}, {:name => "Pipeline_2::stage1"}, {:name => "Pipeline_2::stage2"}]
      cc_tray.pipelines(projects).should_be [{"Pipeline_1" => [{:name => "Pipeline_1::stage1"}, {:name => "Pipeline_1::stage2"}]},
                                   {"Pipeline_2" => [{:name => "Pipeline_2::stage1"}, {:name => "Pipeline_2::stage2"}]}]
    end
  end

end
