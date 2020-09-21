# frozen_string_literal: true

require_relative 'lib/amocrm_client/version'

Gem::Specification.new do |spec|
  spec.name       = 'amocrm_client'
  spec.files      = Dir['lib/**/*.rb']
  spec.executable = 'amocrm_client'
  spec.version    = AmocrmClient::VERSION
  spec.authors    = ['Maxim Aleynikov']
  spec.email      = 'm.aleynikov@@netology-group.ru'
  spec.homepage   = 'https://netology-group.ru'
  spec.license    = 'MIT'
  spec.summary    = 'AmocrmClient'
  spec.description = 'Client for amocrm'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'anyway_config', '>= 2.0.0'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'redlock'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'mock_redis'
end
