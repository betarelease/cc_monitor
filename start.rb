require "./vendor/ramaze-2008.11/lib/ramaze"

# require all controllers and models
acquire __DIR__/:controller/'*'
acquire __DIR__/:model/'*'

Ramaze.start :adapter => :webrick, :port => 9080
