# frozen_string_literal: true

require_relative './lib/rspec_flat_error_formatter/version'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'rspec_flat_error_formatter'
  spec.version       = RspecFlatErrorFormatterVersion::VERSION
  spec.authors       = ['Victor Zagorodny']
  spec.email         = ['post.vittorius@gmail.com']

  spec.summary       = 'RSpec formater that produces output easily consumable by automated tools'
  spec.homepage      = 'https://github.com/vittorius/rspec_flat_error_formatter'
  spec.license       = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'rspec-core', '~> 3.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.23'
end
