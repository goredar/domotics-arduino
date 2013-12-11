require 'pty'

class BoardEmulator
  def initialize(args = {})
    success = Domotics::Arduino::ArduinoBase::SUCCESSREPRLY
    @master, @slave = PTY.open
    type = args[:type] || :normal
    unless type == :dead
      Thread.new do
        loop do
          raise unless message = @master.gets
          command, pin, value = message.chomp.split(" ").map{ |m| m.to_i }
          case command
          when Domotics::Arduino::ArduinoBase::ECHOREPLY
            @master.puts "#{value} #{pin}\n"
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