require File.join(File.expand_path(File.dirname(__FILE__)), "../spec_helper")
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
    
    describe "failures" do
      it "should be 0 if success_count is nil" do
        project = Project.new(:name => "some project", 
                              :success_count => nil,
                              :failure_count => 8, 
                              :build_count => 10)
        project.successes.should == 0
      end  
    end
  
    describe "successes" do
      it "should be 0 if failure_count is nil" do
        project = Project.new(:name => "some project", 
                              :success_count => 1,
                              :failure_count => nil, 
                              :build_count => 10)
        project.failures.should == 0
      end
    end  
  end
  
end
