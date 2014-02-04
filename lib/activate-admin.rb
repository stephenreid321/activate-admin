require 'csv'

require 'padrino'
require 'will_paginate/view_helpers/sinatra'
require 'will_paginate/mongoid'
require 'heroku-api'

require 'datetime_helpers'
require 'param_helpers'
require 'navigation_helpers'

module ActivateAdmin
  extend Padrino::Module
  gem! "activate-admin"
end

String.send(:define_method, :html_safe?){ true }