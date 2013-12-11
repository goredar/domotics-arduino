#!/usr/bin/ruby -w
# coding: utf-8
module Domotics
  module Arduino
    # Normal_close sensor
    module NCSensor
      include  DigitalPin
      def initialize(args_hash = {})
        super
        @board.set_input_pullup @pin
        @board.set_watch @pin, ArduinoSerial::WATCHON
      end
    end
  end
end