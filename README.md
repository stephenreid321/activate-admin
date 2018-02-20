activate-admin
=================

A powerful, lightweight admin gem for Padrino with support for Mongoid and ActiveRecord and a variety of different field types

Setup
---

In the Gemfile of your application:
```
gem 'will_paginate', github: 'mislav/will_paginate'
gem 'activerecord_any_of', github: 'oelmekki/activerecord_any_of' # if using ActiveRecord
gem 'activate-tools', github: 'wordsandwriting/activate-tools'
gem 'activate-admin', github: 'wordsandwriting/activate-admin'
```

In config/apps.rb:
``` ruby
Padrino.mount('ActivateAdmin::App', :app_file => ActivateAdmin.root('app/app.rb')).to('/admin')
```

Say you have a model User with the fields User#name and User#birthday. Then in the model:
``` ruby
def self.admin_fields
  {
    :name => :text, # same as {:type => :text, :edit => true, :index => true, :new_hint => nil, :edit_hint => nil, :new_tip => nil, :edit_tip => nil, :lookup => true, :full => false}
    :birthday => :date
  }
end
```

See [https://github.com/wordsandwriting/activate-tools/blob/master/lib/form_builder.rb](https://github.com/wordsandwriting/activate-tools/blob/master/lib/form_builder.rb)
for field types.

Start your app and navigate to /admin. Voila!

filter_options
-----

``` ruby
def self.filter_options
  {
    :q => 'default query', 
    :f => [:field1 => 'default query on field1', :field2 => 'default query on field2'],
    :o => :field1, # default field to order_by
    :d => :asc # default order direction
  }
end
```

Environment variables
-----
* Set site name: `ENV['ADMIN_SITE_NAME']`
* Include only certain models: `ENV['ADMIN_MODELS']`
* Feature certain models: `ENV['FEATURED_MODELS']`
* Review and modify configuration variables: `ENV['HEROKU_OAUTH_TOKEN']` and `ENV['APP_NAME']`
* Permit only certain IPs: `ENV['PERMITTED_IPS']` (comma separated)