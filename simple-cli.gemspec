# This file is part of the sinatra-sse ruby gem.
#
# Copyright (c) 2016, 2017 @radiospiel, mediapeers Gem
# Distributed under the terms of the modified BSD license, see LICENSE.BSD

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple/cli/version'

Gem::Specification.new do |gem|
  gem.name     = "simple-cli"
  gem.version  = File.read('VERSION')

  gem.authors  = [ "radiospiel", "Mediafellows GmbH" ]
  gem.email    = "eno@radiospiel.org"
  gem.homepage = "https://github.com/mediafellows/simple-cli"
  gem.summary  = "Simple CLI builder for ruby"

  gem.metadata["github_repo"] = "https://github.com/mediafellows/simple-cl"

  gem.description = "Simple CLI builder"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths =  %w(lib)

  # executables are used for development purposes only
  gem.executables   = []

  gem.required_ruby_version = '> 2.5'

  # optional gems (required by some of the parts)

  # development gems
  gem.add_development_dependency 'rake', '~> 12'
  gem.add_development_dependency 'rspec', '~> 3.7'
  gem.add_development_dependency 'simplecov', '~> 0'
  gem.add_development_dependency 'rubocop', '= 0.52.1'
end
