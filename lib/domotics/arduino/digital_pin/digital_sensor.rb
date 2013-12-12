module Domotics::Arduino
  module DigitalSensor
    include DigitalPin
    def initialize(args = {})
      super
      @device.set_watch @pin, ArduinoBase::WATCHON
    end
  end
end
