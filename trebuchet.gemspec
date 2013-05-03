$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'trebuchet-lt'
  s.version     = '0.0.1'
  s.summary     = 'Distributed Load Testing Made Easy'
  s.description = 'Trebuchet is a gem for distributed performance testing. It spins up arbitrary ec2 micro servers, and does performance testing from them.'

  s.required_ruby_version     = '>= 1.9.3'

  s.license = 'MIT'

  s.author   = 'Nathaniel Barnes'
  s.email    = 'Nathaniel.R.Barnes@gmail.com'
  s.homepage = 'http://github.com/NateBarnes/trebuchet'

  s.files       = `git ls-files`.split("\n")
  s.bindir      = 'bin'
  s.executables = ['trebuchet']

  s.add_dependency 'celluloid'
  s.add_dependency 'fog'
end
