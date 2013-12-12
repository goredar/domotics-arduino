module Domotics::Arduino
  # Normal open sensor
  module NOSensor
    include DigitalPin
    def initialize(args = {})
      super
      @board.set_input_pullup @pin
      @board.set_watch @pin, ArduinoBase::WATCHON
    end
    def to_hls(value)
      value == ArduinoBase::HIGH ? :off : :on
    end
  end
end