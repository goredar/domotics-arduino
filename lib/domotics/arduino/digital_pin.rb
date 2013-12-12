module Domotics::Arduino
  module DigitalPin

    def initialize(args = {})
      @pin = args[:pin]
      @device.register_pin self, @pin
      super
    end

    def state!
      to_hls @device.get_digital(@pin)
    end

    def set_state(value)
      @device.set_digital @pin, to_lls(value)
      super
    end

    # Convert to High Level State
    def to_hls(value)
      value == ArduinoBase::HIGH ? :on : :off
    end

    # Convert to Low Level State
    def to_lls(value)
      value == :on ? ArduinoBase::HIGH : ArduinoBase::LOW
    end
  end
end
