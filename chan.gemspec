# coding: utf-8
require './lib/chan'

Gem::Specification.new do |spec|
  spec.name          = "chan"
  spec.version       = Chan::VERSION
  spec.authors       = ["cielavenir"]
  spec.email         = ["cielartisan@gmail.com"]
  spec.description   = "Bidirectional enumerator (channel) or the chan object like in Golang"
  spec.summary       = "Bidirectional channel like the Golang chan object"
  spec.homepage      = "http://github.com/cielavenir/ruby-chan"
  spec.license       = "Ruby License (2-clause BSDL or Artistic)"

  spec.files         = `git ls-files`.split($/) + [
    "LICENSE.txt",
    "README.md",
    "CHANGELOG.md",
  ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
