require 'test/unit'
require 'domotics/arduino'
require 'board_emulator'

class ArduinoTestBoard
  include Domotics::Arduino::ArduinoBase
end

class ArduinoTest < Test::Unit::TestCase
  def asetup
    @brd = ArduinoTestBoard.new(port: BoardEmulator.new.port)
  end
  def test_dead_board
    assert_raise Domotics::Arduino::ArduinoError do
      ArduinoTestBoard.new(port: BoardEmulator.new(type: :dead).port)
    end
  end
  def test_crasy_board
    assert_raise Domotics::Arduino::ArduinoError do
      ArduinoTestBoard.new(port: BoardEmulator.new(type: :crasy).port)
    end
  end
  def test_disconnected_board
    assert_raise Domotics::Arduino::ArduinoError do
      ArduinoTestBoard.new(port: BoardEmulator.new(type: :disconnect).port)
    end
  end
  def atest_set_pin_mode
    @brd
  end
  def ateardown
    @brd.destroy
  end
end