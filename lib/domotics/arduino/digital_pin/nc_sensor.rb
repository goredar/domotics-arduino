module Domotics::Arduino
  # Normal close sensor
  module NCSensor
    include DigitalPin
    def initialize(args = {})
      super
      @device.set_input_pullup @pin
      @device.set_watch @pin, ArduinoBase::WATCHON
    end
  end
end
