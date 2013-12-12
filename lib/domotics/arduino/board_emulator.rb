module Domotics::Arduino
  class BoardEmulator
    attr_accessor :type, :state_list
    def initialize(args = {})
      success = ArduinoBase::SUCCESSREPRLY
      @master, @slave = PTY.open
      @type = args[:type] || :normal
      @state_list = Hash.new(ArduinoBase::LOW)
      Thread.new do
        loop do
          case @type
          when :dead
            terminate
          when :crasy
            @master.gets
            @master.puts rand(4).times.map{ rand(10) }.join(' ')
          when :disconnect
            @master.gets
            @slave.close
            @master.close
          else
            message = @master.gets
            command, pin, value = message.chomp.split(" ").map{ |m| m.to_i }
            case command
            when ArduinoBase::ECHOREPLY
              @master.puts "#{value} #{pin}"
            when ArduinoBase::SETDIGITAL
              @state_list[pin] = value
              @master.puts success
            else
              @master.puts success
            end
          end
        end
      end
    end
    def port
      @slave.path
    end
    def set_internal_state(pin, state)
      @state_list[pin] = state
    end
    def toggle_pin(pin)
      @state_list[pin] = @state_list[pin] == ArduinoBase::LOW ? ArduinoBase::HIGH : ArduinoBase::LOW
      @master.puts "0 #{pin} #{@state_list[pin]}"
    end
  end
end