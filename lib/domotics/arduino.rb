require 'bundler/setup'
# From arduino-base
require 'serialport'
require 'thread'
require 'logger'
require 'timeout'
# From board emulator
require 'pty'

Dir[File.dirname(__FILE__) + '/arduino/**/*.rb'].sort.each {|file| require file}