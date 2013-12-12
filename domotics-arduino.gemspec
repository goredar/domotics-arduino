# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'domotics/arduino/version'

Gem::Specification.new do |spec|
  spec.name          = "domotics-arduino"
  spec.version       = Domotics::Arduino::VERSION
  spec.authors       = ["Goredar"]
  spec.email         = ["goredar@gmail.com"]
  spec.description   = %q{Arduino part of Domotics}
  spec.summary       = %q{Hardware drivers for arduino}
  spec.homepage      = "https://dom.goredar.it"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "serialport"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end