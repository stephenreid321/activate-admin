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
    :a => :datetime,
    :b => :check_box,
    :c => :file,
    :d => :slug,
    :e => :image, # define self#rotate_fieldname_by for rotation    
    :f => :wysiwyg, 
    :g => :text_area,
    :h => :password,
    :i => :select, # define self.options
    :j => :lookup, # define self.lookup
    :k => :collection, # define self.lookup
    :l => :text # default
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