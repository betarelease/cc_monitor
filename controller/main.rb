# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class MainController < BaseController
  set_layout 'page'

  def index
    theme
    @projects = []
    CC_TRAY_FEEDS.each do |feed|
      @projects += CCTray.new.projects feed
    end
  end
  
end