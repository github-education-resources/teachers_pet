require File.expand_path("../lib/teachers_pet/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = 'teachers_pet'
  s.version       = TeachersPet::VERSION
  s.summary       = "Command line tools for teachers"
  s.description   = "A simple hello world gem"
  s.authors       = ["John Britton"]
  s.email         = 'public@johndbritton.com'
  s.homepage      = 'http://github.com/johndbritton/teachers_pet'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split $/

  s.add_dependency 'octokit'
end
