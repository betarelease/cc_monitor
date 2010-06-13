development_database = File.join(File.expand_path(File.dirname(__FILE__)), "../db.sqlite")

#copying development database to spec environment
`cp #{development_database} "db.sqlite"`

require File.join(File.expand_path(File.dirname(__FILE__)), "../environment")

require 'ramaze/spec/helper'
