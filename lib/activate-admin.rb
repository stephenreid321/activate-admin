require 'csv'
require 'padrino'
require 'will_paginate/view_helpers/sinatra'
require 'will_paginate/mongoid'
module ActivateAdmin
  extend Padrino::Module
  gem! 'activate-admin'
end
