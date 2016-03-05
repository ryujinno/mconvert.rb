# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mconvert/version'

Gem::Specification.new do |spec|
  spec.name          = 'mconvert'
  spec.version       = MConvert::VERSION
  spec.authors       = ['Ryu Jinno']
  spec.email         = ['ryujinno@gmail.com']

  spec.summary       = %q{Multiprocessed lossless music file comverter}
  spec.description   = %q{Multiprocessed lossless music file converter}
  spec.homepage      = 'https://github.com/ryujinno/mconvert.rb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_dependency             'thor',    '~> 0'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake',    '~> 10'
  spec.add_development_dependency 'rspec',   '~> 3'
end
