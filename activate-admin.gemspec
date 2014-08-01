# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "activate-admin"
  gem.description   = %q{A powerful, lightweight admin gem for Padrino/Mongoid with support for a variety of different field types}
  gem.summary       = %q{A powerful, lightweight admin gem for Padrino/Mongoid with support for a variety of different field types}
  gem.version       = '0.0.1'
  gem.authors       = ["Stephen Reid"]
  gem.email         = ["stephen.reid.inbox@gmail.com"]    
  gem.require_paths = ["lib"]
  
  gem.add_dependency 'padrino'
  gem.add_dependency 'will_paginate'
  gem.add_dependency 'activate-tools'
end
