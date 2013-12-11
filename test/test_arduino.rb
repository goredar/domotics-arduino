require 'test/unit'
require 'domotics/arduino'
require 'board_emulator'

class ArduinoTestBoard
  include Domotics::Arduino::ArduinoBase
end

class ArduinoTest < Test::Unit::TestCase
  def setup
  end
  def test_open_connection
    assert brd = ArduinoTestBoard.new(port: BoardEmulator.new.port)
    assert !brd.destroy
  end
  def test_dead_board
    assert_raise Domotics::Arduino::ArduinoError do
      ArduinoTestBoard.new(port: BoardEmulator.new(type: :dead).port)
    end
  end
end