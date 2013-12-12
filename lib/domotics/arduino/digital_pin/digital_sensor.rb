module Domotics::Arduino
  module DigitalSensor
    include DigitalPin
    def initialize(args = {})
      super
      @board.set_watch @pin, ArduinoBase::WATCHON
    end
  end
end