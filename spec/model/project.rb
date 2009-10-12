require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/project")

describe Project do
  describe "find_or_create" do
    it "should save project details only for a different build label" do
      project = Project.new(:name => "some project", 
                            :last_build_label => "previous", 
                            :last_build_status => "Success")
      project.save!
      project.last_build_time = element.attributes['lastBuildTime']
      project.last_build_status = element.attributes['lastBuildStatus']
      project.last_build_label = element.attributes['lastBuildLabel']
      project.activity = element.attributes['activity']
      project.web_url = element.attributes['webUrl']
      
      input_project = {"name" => "some project",
                       "lastBuildStatus" => "Failure",
                       "lastBuildLabel" => "previous",
                       "lastBuildTime" => Time.now.to_s,
                       "activity" => "Sleeping",
                       "webUrl" => "www.com"}
      found_project = Project.find_or_create(input_project)
      found_project.last_build_label.should == "previous"
      found_project.last_build_status.should == "Failure"
      found_project.last_build_time.should == Time.now.to_s
      found_project.activity.should == "Sleeping"
      found_project.webUrl.should == "www.com"
      
      
    end
  end

end
