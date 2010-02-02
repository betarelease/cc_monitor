TITLE = "TEST PUBLISHER BUILD MONITOR"

PORT = "9080"

#cc rb example   http://cruisecontrol/XmlStatusReport.aspx
#cc java example http://cruisecontrol:8080/dashboard/cctray.xml
PROJECTS = "http://localhost:3000/test_publisher"

AUTH = false
# required only when AUTH is true
# USERNAME = "username"
# PASSWORD = "password"

# valid environments are test, production, development
ENVIRONMENT = "test"