%w(vendor/rack-0.4.0/lib/rack vendor/ramaze-2008.11/lib/ramaze).each do |gem|
  require File.join(File.expand_path(File.dirname(__FILE__)), ".", gem)
end

require File.join(File.expand_path(File.dirname(__FILE__)), "environment")

# require all controllers and models
acquire __DIR__/:controller/'*'
acquire __DIR__/:model/'*'

Ramaze.start :adapter => :webrick, :port => PORT