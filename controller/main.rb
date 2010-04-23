# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class MainController < Ramaze::Controller
  layout '/page'

  # the index action is called automatically when no other action is specified
  def index    
    require 'socket'
    local_ip_address = UDPSocket.open {|s| s.connect '64.233.187.99', 1; s.addr.last}
    @host_url = "http://#{local_ip_address}:#{PORT}"
    @title = TITLE
    @projects = []
    @projects += CCTray.new.fetch PROJECTS
  end
end