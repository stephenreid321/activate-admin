require 'csv'
require 'padrino'
require 'will_paginate/view_helpers/sinatra'
require 'will_paginate/mongoid'
begin; require 'heroku-api'; rescue LoadError; end

module ActivateAdmin
  extend Padrino::Module
  gem! "activate-admin"
end

String.send(:define_method, :html_safe?){ true }