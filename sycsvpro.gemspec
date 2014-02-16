# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','sycsvpro','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'sycsvpro'
  s.version = Sycsvpro::VERSION
  s.author = 'Pierre Sugar'
  s.email = 'pierre@sugaryourcoffee.de'
  s.homepage = 'https://github.com/sugaryourcoffee/syc-svpro'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Processing of csv files'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','sycsvpro.rdoc']
  s.rdoc_options << '--title' << 'sycsvpro' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'sycsvpro'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('rspec')
  s.add_runtime_dependency('gli','2.9.0')
end
