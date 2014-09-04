# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'mconvert'
  spec.version       = '0.0.2'
  spec.authors       = ['Ryu Jinno']
  spec.email         = ['ryujinno@gmail.com']
  spec.summary       = %q{Multithreaded music file comverter}
  spec.description   = %q{Multithreaded lossless music file converter}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_dependency             'thor'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
