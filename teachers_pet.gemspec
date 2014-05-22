# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teachers_pet/version'

Gem::Specification.new do |s|
  s.name          = 'teachers_pet'
  s.version       = TeachersPet::VERSION
  s.summary       = "Command line tools to help teachers use GitHub in their classrooms"
  s.authors       = ["John Britton"]
  s.email         = 'public@johndbritton.com'
  s.homepage      = 'http://github.com/education/teachers_pet'
  s.license       = 'MIT'

  s.bindir        = 'bin'
  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'highline', '~> 1.6.21'
  s.add_dependency 'octokit', '~> 3.1.0'

  s.add_development_dependency 'bundler', '~> 1.5'
  s.add_development_dependency 'coveralls', '~> 0.7'
  s.add_development_dependency 'guard-rspec', '~> 4.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.14'
  # https://github.com/colszowka/simplecov/issues/281
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'webmock', '~> 1.17'
end
