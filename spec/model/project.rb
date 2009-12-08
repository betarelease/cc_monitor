require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/project")

describe Project do
  describe "find_or_create" do
    it "should save project details only for a different build label" do
      project = Project.new(:name => "some project", 
                            :last_build_label => "previous", 
                            :last_build_status => "Success")
      project.save!
      class Element
        def attributes
          {'lastBuildTime' => Time.now, 
            'lastBuildStatus' => "Success",
            'lastBuildLabel' => "12345", 
            'activity' => "Building", 
            'web_url' => "www.com" }
        end
      end
      
      
      element = Element.new
      project.last_build_time = element.attributes['lastBuildTime']
      project.last_build_status = element.attributes['lastBuildStatus']
      project.last_build_label = element.attributes['lastBuildLabel']
      project.activity = element.attributes['activity']
      project.web_url = element.attributes['webUrl']
      
      class InputProject
        def attributes
          {"name" => "some project",
            "lastBuildStatus" => "Failure",
            "lastBuildLabel" => "previous",
            "lastBuildTime" => Time.now.to_s,
            "activity" => "Sleeping",
            "webUrl" => "www.com"}        
        end
      end
      input_project = InputProject.new
      found_project = Project.find_or_create(input_project)
      puts Project.count
      puts found_project.inspect
      found_project.last_build_label.should == "previous"
      found_project.last_build_status.should == "Failure"
      found_project.last_build_time.should == Time.now.to_s
      found_project.activity.should == "Sleeping"
      found_project.webUrl.should == "www.com"
    end
  end

end
