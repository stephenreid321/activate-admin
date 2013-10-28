require 'csv'

require 'padrino'
require 'sinatra/simple-navigation'
require 'will_paginate/view_helpers/sinatra'
require 'will_paginate/mongoid'

require 'datetime_helpers'
require 'param_helpers'

module ActivateAdmin
  extend Padrino::Module
  gem! "activate-admin"
end

SimpleNavigation::config_file_paths << "#{ActivateAdmin.root}/lib"