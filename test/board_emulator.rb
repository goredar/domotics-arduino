require 'pty'

class BoardEmulator
  def initialize(args = {})
    success = Domotics::Arduino::ArduinoBase::SUCCESSREPRLY
    @master, @slave = PTY.open
    type = args[:type] || :normal
    Thread.new do
      case type
      when :dead
        terminate
      when :crasy
        loop do
          @master.gets
          ans = rand(4).times.map{ rand(10) }.join(' ')
          @master.puts ans
        end
      when :disconnect
        @master.gets
        @slave.close
        @master.close
      else
        loop do
          raise unless message = @master.gets
          command, pin, value = message.chomp.split(" ").map{ |m| m.to_i }
          case command
          when Domotics::Arduino::ArduinoBase::ECHOREPLY
            @master.puts "#{value} #{pin}"
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
end