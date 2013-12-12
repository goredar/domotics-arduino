module Domotics::Arduino
  module NOSensor
    include DigitalPin
    def initialize(args = {})
      super
      @board.set_watch @pin, ArduinoBase::WATCHON
    end
  end
end