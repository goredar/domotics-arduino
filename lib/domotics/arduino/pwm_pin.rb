module Domotics
  module Arduino
    module PWMPin

      def initialize(args = {})
        @pin = args[:pin]
        @device.set_pwm_frequency @pin, 1
        super
      end

      def set_state(value = 0)
        value = case value
        when 0, :off
          @device.set_low @pin
          0
        when 1..254
          @device.set_pwm @pin, value
          value
        when 255, :on
          @device.set_high @pin
          255
        end
        super value
      end
    end
  end
end
