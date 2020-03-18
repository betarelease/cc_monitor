# DESCRIPTION

CC Monitor as the name suggests allows you to monitor multiple Continuous Integration environments. Currently it can parse cc_tray compatible xml for CruiseControl. 
CC Monitor collects all the build information and puts it on a dashboard. CC Monitor is different that the dashboard that comes with Cruisecontrol. With CC Monitor you can actually monitor different Cruisecontrol environments just by specifying the location of the cc_tray.xml file.

CC Monitor provides a big visible display which can be projected to the whole development room. Having a big visible display of Cruise builds can help the team monitor the health of the code all the time and they do not need to look at their local CruiseControl Monitors. 

Currently it can display information that is part of the xml file. Apart from that it also displays the progress over a period of time to indicate how healthy the application has been. 

## Features:
1. Shows meaningful error when CC Monitor cannot connect to Build Machine
2. Bacon tested 
3. configuration support for rss feeds
4. Added rack and activerecord gems to the install
5. Better pictures and css to indicate build health
6. Added graphical display for health of application over time
7. Themes
CC Monitor displays nice activity based images to make watching the builds more fun. By default it comes with a theme randomizer that shows these images based on the date. But can be customized to only show images based on the team's theme.
Custom themes can be added by editing only a few stylesheet files.
(The team idea shamelessly stolen from cc_dashboard. ;P)


## USAGE

To use just download and change the project url in controller/main.rb.

Type 'rake monitor:clean' - to setup the database
then type 
'rake monitor:start'

## DEVELOPMENT
'rake monitor:test' starts a random feed publisher along with the monitor thus allowing rapid disconnected development if you would like to contribute.


### Features to come:
1. Resetting graphs daily
2. Adding audible indications to the monitor
3. Marking fix owners for broken builds
and many more....


[License](./License)