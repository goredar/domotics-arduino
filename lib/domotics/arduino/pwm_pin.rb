module Domotics
  module Arduino
    module PWMPin

      def initialize(args_hash = {})
        @board = Domotics::Device[args_hash[:device]]
        @pin = args_hash[:pin]
        @board.set_pwm_frequency @pin, 1
        super
      end

      def set_state(value = 0)
        value = case value
        when 0, :off
          @board.set_low @pin
          0
        when 1..254
          @board.set_pwm @pin, value
          value
        when 255, :on
          @board.set_high @pin
          255
        end
        super value
      end
    end
  end
end