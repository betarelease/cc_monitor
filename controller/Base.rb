# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class BaseController < Ramaze::Controller
  set_layout 'page'

  def graph
    @title = TITLE
    @project = Project.find(1)
    @projects = Project.find(:all)
  end
  
  def dashboard_url
    require 'socket'
    local_ip_address = UDPSocket.open {|s| s.connect '64.233.187.99', 1; s.addr.last}
    @host_url ||= "http://#{local_ip_address}:#{PORT}"    
  end
  
  def theme
    @title = TITLE  
    @host_url = dashboard_url
    @theme = THEMES[ Date.today.day % THEMES.size ] unless THEMES.blank?
  end
end