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

module Delayed
  module Backend
    module Mongoid
      class Job
        def self.admin_fields
          {
            :priority => :number,
            :attempts => :number,
            :handler => :text_area,            
            :run_at => :datetime,
            :locked_at => :datetime,
            :locked_by => :text,
            :failed_at => :datetime,
            :last_error => :text_area,
            :queue => :text
          }
        end
      end
    end
  end
end