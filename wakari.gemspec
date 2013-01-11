# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wakari/version'

Gem::Specification.new do |gem|
  gem.name          = "wakari"
  gem.version       = Wakari::VERSION
  gem.authors       = ["Valery Kvon"]
  gem.email         = ["addagger@gmail.com"]
  gem.homepage      = %q{http://vkvon.ru/projects/wakari}
  gem.description   = %q{Add translations for models}
  gem.summary       = %q{Multilang assets for Rails}

  gem.add_development_dependency "gaigo"
  gem.add_development_dependency "acts_as_list"
  gem.add_development_dependency "delegate_attributes"
  gem.add_development_dependency "kabuki"
  
  gem.rubyforge_project = "wakari"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.licenses       = ['MIT']
end