# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class PipelinesController < BaseController

  def index
    theme
    CC_TRAY_FEEDS.each do |feed|
      @pipelines = CCTray.new.pipelines feed
    end
  end
  
  def hot
    theme
    CC_TRAY_FEEDS.each do |feed|
      @pipelines = CCTray.new.filter feed
    end    
  end
  
end