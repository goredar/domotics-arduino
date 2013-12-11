require "serialport"
require "thread"
Dir[File.dirname(__FILE__) + '/arduino/**/*.rb'].sort.each {|file| require file}

#module Domotics
#  module Arduino
#    # Your code goes here...
#  end
#end