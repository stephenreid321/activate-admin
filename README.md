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
    :name => :text,
    :birthday => :date
  }
end
```
Start your app and navigate to /admin. Voila!

Environment variables
-----
* Include only certain models: `ENV['ADMIN_MODELS']`
* Set site name: `ENV['ADMIN_SITE_NAME']`
* Inline uploads: `ENV['INLINE_UPLOAD_MODEL']` and `ENV['INLINE_UPLOAD_MODEL_FILE_FIELD']`
* Review and modify configuration variables: `ENV['HEROKU_OAUTH_TOKEN']` and `ENV['APP_NAME']`

Available field types
-----
``` ruby
def self.admin_fields
  {
    :field => :text,
    :field => :password,
    :field => :slug,
    :field => :text_area,
    :field => :wysiwyg, 
    :field => :check_box,
    :field => :select, # define self.options
    :field => :file,
    :field => :image, # define self#rotate_fieldname_by for rotation  
    :field => :time,
    :field => :date,
    :field => :datetime,
    :field => :lookup, # for belongs_to relationships; define self.lookup on associated model
    :field => :collection, # for has_many relationships; define self.lookup on associated model
  }
end
```

Hints and tips
-----

``` ruby
def self.new_hints
  {
    :field1 => 'Hint text shown by field1 when creating a record'      
  }
end 

def self.edit_hints
  {
    :field2 => 'Hint text shown by field2 when editing a record'      
  }
end 
```

Same for `self.new_tips` and `self.edit_tips`

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
