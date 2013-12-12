require 'test/unit'
require 'domotics/arduino'

class ArduinoTestBoard
  attr_reader :last_event
  include Domotics::Arduino::ArduinoBase
  def event_handler(event)
    super
    @last_event = event
  end
end

class ArduinoTest < Test::Unit::TestCase
  def setup
    #@brd = ArduinoTestBoard.new(port: Domotics::Arduino::BoardEmulator.new.port)
  end
  def test_dead_board
    assert_raise(Domotics::Arduino::ArduinoError) { emulate :dead }
  end
  def test_crasy_board
    assert_raise(Domotics::Arduino::ArduinoError) { emulate :crasy }
  end
  def test_disconnected_board
    assert_raise(Domotics::Arduino::ArduinoError) { emulate :disconnect }
  end
  def test_set_digital
    brd, emul = emulate
    brd.set_digital(13, Domotics::Arduino::ArduinoBase::HIGH)
    assert_equal Domotics::Arduino::ArduinoBase::HIGH, emul.state_list[13]
  end
  def test_watch
    brd, emul = emulate
    emul.toggle_pin (13)
    sleep 0.1
    assert_equal Hash[:event, :pin_state_changed, :pin, 13, :state, Domotics::Arduino::ArduinoBase::HIGH], brd.last_event
  end
  def emulate(type = :normal)
    emul = Domotics::Arduino::BoardEmulator.new :type => type
    brd = ArduinoTestBoard.new port: emul.port, retry_wait: 1
    [brd, emul]
  end
  def teardown
    #@brd.destroy
  end
end