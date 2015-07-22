# The Specification class contains the information for a Gem.
# Typically defined in a .gemspec file or a Rakefile
# Starting in RubyGems 2.0, a Specification can hold arbitrary metadata.
# See metadata for restrictions on the format and size of metadata items you
# may add to a specification.
#
# http://guides.rubygems.org/specification-reference

Gem::Specification.new do |s|
  s.name = 'logstash-input-gitrepo'
  # Version messaging from Logstash (0.9.x):
  # "This plugin should work but would benefit from use by folks like you.
  #  Please let us know if you find bugs or have suggestions on how to improve
  #  this plugin."
  s.version = '0.9.0.poc'
  s.licenses = ['Apache License (2.0)']
  s.summary = 'This input streams from Git repository at a definable interval.'
  s.description = 'This gem is a logstash plugin required to be installed on
                  top of the Logstash core pipeline using $LS_HOME/bin/plugin
                  install gemname. This gem is not a stand-alone program'
  s.authors = ['Alexander Braverman Masis']
  s.email = 'alexbmasis@gmail.com'
  s.homepage = 'https://github.com/abraverm/logstash-input-git'
  s.require_paths = ['lib']
  # Files
  s.files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  # Tests
  # s.test_files = s.files.grep(%r{^(test|spec|features)/})
  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'input' }
  # Gem dependencies
  s.add_runtime_dependency 'logstash-core', '>= 1.4.0', '< 2.0.0'
  s.add_runtime_dependency 'git'
  s.add_runtime_dependency 'logstash-codec-json'
  s.add_development_dependency 'logstash-devutils'
end
