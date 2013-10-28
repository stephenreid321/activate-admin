# -*- encoding: utf-8 -*-
require File.expand_path('../lib/activate-admin/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Stephen Reid"]
  gem.email         = ["postscript07@gmail.com"]
  gem.description   = %q{An admin gem for Padrino/mongoid}
  gem.summary       = %q{A powerful, lightweight admin gem for Padrino/Mongoid with support for a variety of different field types}
  gem.homepage      = "https://github.com/postscript07/activate-admin"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "activate-admin"
  gem.require_paths = ["lib"]
  gem.version       = ActivateAdmin::VERSION

  gem.add_dependency 'padrino', '0.11.1'
  gem.add_dependency 'sinatra-simple-navigation'  
  gem.add_dependency 'will_paginate'
end
