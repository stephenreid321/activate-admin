Gem::Specification.new do |gem|
  gem.name          = 'activate-admin'
  gem.description   = 'A powerful, lightweight admin gem for Padrino/Mongoid with support for a variety of different field types'
  gem.summary       = 'A powerful, lightweight admin gem for Padrino/Mongoid with support for a variety of different field types'
  gem.version       = '0.0.9'
  gem.authors       = ['Stephen Reid']
  gem.email         = ['stephen@stephenreid.net']
  gem.require_paths = ['lib']

  gem.add_dependency 'activate-tools'
  gem.add_dependency 'padrino'
  gem.add_dependency 'will_paginate'
end
