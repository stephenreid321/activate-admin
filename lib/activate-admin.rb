require 'csv'
require 'padrino'
require 'will_paginate/view_helpers/sinatra'
begin; require 'will_paginate/mongoid'; rescue LoadError; end
begin; require 'will_paginate/active_record'; rescue LoadError; end
begin; require 'platform-api'; rescue LoadError; end

module ActivateAdmin
  extend Padrino::Module
  gem! "activate-admin"
end