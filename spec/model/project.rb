require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../vendor/activerecord-2.1.1/lib/activerecord")
require File.join(File.expand_path(File.dirname(__FILE__)), "../../model/project")


describe Project do
  describe "statistics" do
    it "should return sickness as opposite of health" do
      project = Project.new(:name => "some project", 
                            :success_count => 2,
                            :failure_count => 8, 
                            :build_count => 10)
      project.sickness.should == 100 - project.health
      
    end

    it "should return health as a percentage of success to total build count" do
      project = Project.new(:name => "some project", 
                            :success_count => 2,
                            :failure_count => 8, 
                            :build_count => 10)
      project.health.should == 20
    end
    
    it "should return health as a percentage of success to total build count" do
      project = Project.new(:name => "some project", :last_build_time => Time.utc(2000, "jan", 1, 20, 15, 1))
      project
    end

    it "should 0 if success_count is nil" do
      project = Project.new(:name => "some project", 
                            :success_count => nil,
                            :failure_count => 8, 
                            :build_count => 10)
      project.successes.should == 0
    end  

    it "should 0 if failure_count is nil" do
      project = Project.new(:name => "some project", 
                            :success_count => 1,
                            :failure_count => nil, 
                            :build_count => 10)
      project.failures.should == 0
    end
    
  end
  
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
      found_project.last_build_label.should == "previous"
      found_project.last_build_status.should == "Failure"
      found_project.last_build_time.should == Time.now.to_s
      found_project.activity.should == "Sleeping"
      found_project.webUrl.should == "www.com"
    end
  end

end
