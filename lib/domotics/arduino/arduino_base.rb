require 'serialport'
require 'thread'
require 'logger'
require 'timeout'

module Domotics
  module Arduino

    class ArduinoError < StandardError; end

    module ArduinoBase
      # Constants from Arduino
      LOW = 0
      HIGH = 1
      STATES = [LOW, HIGH]
      INPUT = 0
      OUTPUT = 1
      INPUTPULLUP = 2
      MODES = [INPUT, OUTPUT, INPUTPULLUP]
      # Replies from board
      SUCCESSREPRLY = 2
      FAILREPRLY = 3
      # Board events
      EVENTS = {'0' => :pin_state_change}
      # Commands for board
      SETPINMODE = 0
      GETDIGITAL = 1
      SETDIGITAL = 2
      GETADC = 3
      SETPWM = 4
      GETWATCH = 5
      SETWATCH = 6
      ECHOREPLY = 7
      DEFAULTS = 8
      SETPWMFREQ = 9
      # Watch states
      WATCHOFF = 0
      WATCHON = 1
      W_STATES = [WATCHOFF, WATCHON]
      # Timers
      TIMER_0 = 0
      TIMER_1 = 1
      TIMER_2 = 2
      TIMER_3 = 3
      TIMER_4 = 4
      TIMER_5 = 5
      def initialize(args = {})
        # grab args from hash
        @board_type = args[:board] || :mega
        unless [:nano, :mega].include? @board_type
          raise ArgumentError, 'Invalid board type. Use defaults.'
          @board_type = :mega
        end
        case @board_type
        when :nano
          @port_str = args[:port] || "/dev/ttyUSB0"
          @number_of_pins = 22
          # todo: address of last 2 pins on nano???
          @adc_pins = Array.new(8) { |index| 14+index }
          @pwm_pins = [3,5,6,9,10,11]
        when :mega
          @port_str = args[:port] || "/dev/ttyACM0"
          @number_of_pins = 70
          @adc_pins = Array.new(16) { |index| 54+index }
          @pwm_pins = Array.new(12) { |index| 2+index } + [44,45,46]
        end
        @logger = args[:logger] || Logger.new(STDERR)
        # Not allow multiple command sends
        @command_lock = Mutex.new
        @reply = Queue.new
        # connection
        @board_lock = Mutex.new
        @board = nil
        @board_listener = nil
        connect
        super unless self.class.superclass == Object
      end

      # ---0--- SETPINMODE 
      def set_mode(pin, mode)
        check_pin(pin); check_pin_watch(pin); raise ArgumentError, 'Error! Invalid mode.' unless MODES.include? mode
        @logger.warn { "Already set mode for pin: #{pin}." } if @pin_mode[pin] == mode
        @pin_mode[pin] = mode
        send_command(SETPINMODE, pin, mode)
      end
      def set_input_pullup(pin)
        set_mode(pin, INPUTPULLUP)
      end

      # ---1--- GETDIGITAL
      def get_digital(pin)
        check_pin(pin)
        send_command(GETDIGITAL, pin)
      end

      # ---2--- SETDIGITAL
      def set_digital(pin, state)
        check_pin(pin); check_pin_watch(pin); raise ArgumentError, 'Error! Invalid state.' unless STATES.include? state
        set_mode(pin, OUTPUT) unless @pin_mode[pin] == OUTPUT
        send_command(SETDIGITAL, pin, state)
      end
      def set_high(pin)
        set_digital(pin, HIGH)
      end
      def set_low(pin)
        set_digital(pin, LOW)
      end

      # ---3--- GETADC
      def get_adc(pin)
        check_pin(pin); raise ArgumentError, 'Not ADC pin.' unless @adc_pins.include? pin
        send_command(GETADC, pin)
      end

      # ---4--- SETPWM
      def set_pwm(pin, value)
        check_pin(pin); check_pin_watch(pin); raise ArgumentError, 'Not PWM or DAC pin.' unless @pwm_pins.include? pin
        raise ArgumentError, 'Invalid PWM value' unless value.is_a?(Integer) and value>=0 and value<=255
        send_command(SETPWM, pin, value)
      end

      # ---9--- SETPWMFREQ
      def set_pwm_frequency(pin, divisor = 5)
        case @board_type
        when :nano
          case pin
          when 9,10
            timer = TIMER_1
          when 3,11
            timer = TIMER_2
          else
            timer = nil
          end
        when :mega
          case pin
          when 2,3,5
            timer = TIMER_3
          when 6,7,8
            timer = TIMER_4
          when 9,10
            timer = TIMER_2
          when 11,12
            timer = TIMER_1
          when 44,45,46
            timer = TIMER_5
          else
            timer = nil
          end
        end
        raise ArgumentError, 'Invalid PWM pin for change frequency.' unless timer
        if timer == TIMER_2
          raise ArgumentError, 'Invalid timer divisor.' unless (1..7).include? divisor
        else
          raise ArgumentError, 'Invalid timer divisor.' unless (1..5).include? divisor
        end
        send_command(SETPWMFREQ, timer, divisor)
      end

      # ---5--- GETWATCH
      def get_watch(pin)
        check_pin(pin)
        send_command(GETWATCH, pin)
      end

      # ---6--- SETWATCH
      def set_watch(pin, watch)
        check_pin(pin); raise ArgumentError, 'Invalid watch mode.' unless W_STATES.include? watch
        @logger.warn { "Warning! already set watch mode for pin: #{pin}." } if @watch_list[pin] == watch
        set_mode(pin, INPUT) if @pin_mode[pin] == OUTPUT
        @watch_list[pin] = watch
        send_command(SETWATCH, pin, watch)
      end

      def destroy
        super if self.class.superclass != Object
        @logger.info { "Destroy board connection..." }
        @command_lock.synchronize do
          @board_listener.exit if @board_listener and @board_listener.alive?
        end
        @board.close
        @logger.info { "done." }
      end

      private

      # Default event handler simple prints event.
      def event_handler(hash)
        raise hash[:e] if hash[:e].is_a? ArduinoError
      end

      # Send command directly to board
      def send_command(command, pin = 0, value = 0)
        Timeout.timeout(1) do
          @command_lock.synchronize do
            @board.puts("#{command} #{pin} #{value}")
            # Get reply
            case reply = @reply.pop
            when 0
              0
            when 1
              1
            when SUCCESSREPRLY
              true
            when FAILREPRLY
              false
            when Array
              reply
            when ArduinoError
              raise reply
            else
              nil
            end
          end
        end
      rescue Timeout::Error
        raise ArgumentError, "Board [#{@port_str}] timeout."
      end
      # Listen for board replies and alarms
      def listen
        @board_lock.synchronize do
          @board_listener.exit if @board_listener and @board_listener.alive?
          @board_listener = Thread.new do
            loop do
              message = @board.gets
              unless message # message nil - board disconected
                if @command_lock.locked?
                  @reply.push ArduinoError.new("Board [#{@port_str}] i/o error.")
                else
                  @logger.error { "Board [#{@port_str}] i/o error." }
                  Thread.new { connect }
                end
                @board_lock.synchronize { @board_listener.exit }
              end
              message = message.chomp.force_encoding("ISO-8859-1").split
              case message.length
              when 1
                @reply.push(message[0].to_i)
              when 3
                event_handler :event => EVENTS[message[0]], :pin => message[1].to_i, :state => message[2].to_i
              when 2
                @reply.push(message.collect{ |m| m.to_i })
              else
                @reply.push ArduinoError.new("Invalid reply from board [#{@port_str}].") if @command_lock.locked?
              end
            end
          end
        end
      end
      # Connect to board
      def connect
        @board.close if @board and !@board.closed?
        # Release command lock
        @reply.push(FAILREPRLY) if @command_lock.locked?
        @logger.info { "Open serial connection to board [#{@port_str}]..." }
        baudrate = 115200; databits = 8; stopbits = 1; parity = SerialPort::NONE
        @board = SerialPort.new(@port_str, baudrate, databits, stopbits, parity)
        @board.read_timeout = 0
        @board.sync = true
        @logger.info { "done." }
        @logger.info { "Initializing board [#{@port_str}]..." }
        # Pin states and mods
        @pin_mode = Array.new(@number_of_pins, INPUT)
        @watch_list = Array.new(@number_of_pins, WATCHOFF)
        # Hard reset board (unless it's not a fake board from emulator)
        unless @port_str =~ /\A\/dev\/pts\/.*\Z/
          @board.dtr = 0
          sleep(2)
        end
        @logger.info { "done." }
        @logger.info { "Starting board [#{@port_str}] listener..." }
        listen
        @logger.info { "done." }
        @logger.info { "Checking connection with board [#{@port_str}]..." }
        a, b = 2.times.map { rand (0..9) }
        if send_command(ECHOREPLY, a, b) == [b, a]
          @logger.info { "done." }
        else
          raise ArduinoError, "Bad reply from board [#{@port_str}] (wrong firmware?)."
        end
        @logger.info { "Reset board [#{@port_str}] to defaults..." }
        @logger.info { "done." } if send_command(DEFAULTS)
      rescue Exception => e
        @logger.error { e.message }
        #@logger.debug { e.backtrace.join }
        tries = tries || 0
        tries += 1
        if tries <= 3
          @logger.info { "Attempt #{tries}: try to reconnect in #{2**tries} seconds." }
          sleep 2**tries
          retry
        end
        @logger.error { "Board [#{@port_str}] malfunction. Automatic restart failed." }
        event_handler event: :malfunction, e: ArduinoError.new("Board [#{@port_str}] malfunction. Automatic restart failed.")
      end
      # Checks
      def check_pin(pin)
        raise ArgumentError, 'Invalid pin number.' unless pin.is_a?(Integer) and pin>=0 and pin<@number_of_pins
      end
      def check_pin_watch(pin)
        raise ArgumentError, 'Cant access watched pin.' if @watch_list[pin] == WATCHON
      end

    rescue ArgumentError => e
      @logger.error e.message
      nil
    end
  end
end