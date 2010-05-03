require File.join(File.expand_path(File.dirname(__FILE__)), "environment")

# require all controllers and models
acquire __DIR__/:controller/'*'
acquire __DIR__/:model/'*'

Ramaze.start :adapter => :webrick, :port => PORT