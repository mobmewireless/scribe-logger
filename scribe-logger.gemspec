# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'scribe_logger/version'

Gem::Specification.new do |s|
  s.name        = 'scribe-logger'
  s.version     = Scribe::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nanda Sankaran']
  s.email       = ['nanda@mobme.in']
  s.homepage    = ''
  s.summary     = %q{A scribe logger for writing to Hive tables}
  s.description = %q{A scribe logger for writing to Hive tables}

  s.rubyforge_project = 'scribe-logger'

  s.add_dependency('rack')
  s.add_dependency('activerecord')
  s.add_dependency('thrift_client')
  s.add_dependency('uuid')
  s.add_dependency('activerecord-hive-adapter')

  s.add_development_dependency('rake')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
