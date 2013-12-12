module Domotics::Arduino
  # Normal_close sensor
  module NCSensor
    include  DigitalPin
    def initialize(args = {})
      super
      @board.set_input_pullup @pin
      @board.set_watch @pin, ArduinoBase::WATCHON
    end
  end
end