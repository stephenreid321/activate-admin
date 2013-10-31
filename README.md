activate-admin
=================

fields_for_index
-----

``` ruby
def self.fields_for_index
  [:field1, :field3]
end
```

fields_for_form
-----
``` ruby
def self.fields_for_form
  {
    :field => :date,
    :field => :time,
    :field => :datetime,
    :field => :check_box,
    :field => :file,
    :field => :slug,
    :field => :image, # define self#rotate_fieldname_by for rotation    
    :field => :wysiwyg, 
    :field => :text_area,
    :field => :password,
    :field => :select, # define self.options
    :field => :lookup, # define self.lookup
    :field => :collection, # define self.lookup
    :field => :text # default
  }
end
```

Hints
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