module Domotics
  module Arduino
    # Normal_open sensor
    module NOSensor
      include DigitalPin
      def initialize(args_hash = {})
        super
        @board.set_watch @pin, ArduinoBase::WATCHON
      end
    end
  end
end