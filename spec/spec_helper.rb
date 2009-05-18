%w(vendor/rack-0.4.0/lib/rack vendor/ramaze-2008.11/lib/ramaze).each do |gem|
  require File.join(File.expand_path(File.dirname(__FILE__)), "..", gem)
end
require 'ramaze/spec/helper'
