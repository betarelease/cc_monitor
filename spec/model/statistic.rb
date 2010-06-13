require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/project")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/statistic")

describe Statistic do
  it "should add new statistic for project" do
    project = Project.new(:name => "some project", 
                          :last_build_label => "previous", 
                          :last_build_status => "Success")
    project.save!
    result = project.last_build_status == "Success"
    statistic = Statistic.new(:project => project, :date => Date.today, :result => result)
    statistic.save!
    
    project.today_success.should == 100
  end
end