module Padrino
  module Helpers
    module FormBuilder
      class ActivateFormBuilder < AbstractFormBuilder
                        
        # Text
                
        def text_block(fieldname)
          content = text_field(fieldname, :class => 'form-control')
          block_layout(fieldname, content)
        end
        
        def disabled_text_block(fieldname)
          content = text_field(fieldname, :class => 'form-control', :disabled => true)
          block_layout(fieldname, content)
        end        
        
        def password_block(fieldname)
          content = password_field(fieldname, :class => 'form-control')
          block_layout(fieldname, content)          
        end        
        
        def slug_block(fieldname)
          content = text_field(fieldname, :class => 'form-control slug')
          block_layout(fieldname, content)
        end        
        
        def text_area_block(fieldname, rows: 10)
          content = text_area(fieldname, :class => 'form-control', :rows => rows)
          block_layout(fieldname, content)
        end
        
        def disabled_text_area_block(fieldname, rows: 10)
          content = text_area(fieldname, :class => 'form-control', :rows => rows, :disabled => true)
          block_layout(fieldname, content)
        end         
        
        def wysiwyg_block(fieldname, rows: 10)
          content = text_area(fieldname, :class => 'form-control wysiwyg', :rows => rows)
          block_layout(fieldname, content)
        end    
        
        # Selects and checkboxes

        def check_box_block(fieldname)
          content = check_box(fieldname)
          block_layout(fieldname, content)
        end
                        
        def select_block(fieldname, options: model.send(fieldname.to_s.pluralize))
          content = select(fieldname, :class => 'form-control', :options => options)
          block_layout(fieldname, content)
        end        
        
        # Files and images
        
        def file_block(fieldname)
          content = ''
          if !object.persisted? or !object.send(fieldname)
            content << file_field(fieldname)
          else         
            content << %Q{
              <div>
                <i class="fa fa-download"></i> <a target="_blank" href="#{object.send(fieldname).url}">#{object.send(fieldname).url}</a>
              </div>          
              <div>
                #{file_field fieldname}
              </div>      
              <div>
                Remove #{check_box :"remove_#{fieldname}"}
              </div>
            }
          end          
          block_layout(fieldname, content)
        end
        
        def image_block(fieldname, rotate: true)
          content = ''
          if !object.persisted? or !object.send(fieldname)
            content << file_field(fieldname)
          else          
            content << %Q{
            <div style="margin-bottom: 1em">
              <a target="_blank" href="#{object.send(fieldname).url}"><img style="max-height: 200px" src="#{object.send(fieldname).url}"></a>
            </div>
            <div>
              #{file_field fieldname}
            </div>
            }
            if object.respond_to?(:"rotate_#{fieldname}_by") and rotate
              content << %Q{                  
                <div class="input-group" style="width: 13em">              
                  <span style="display: table-cell">Rotate by</span>
                  #{select :"rotate_#{fieldname}_by", :options => ['','90','180','270'], :class => 'form-control'}
                  <span class="input-group-addon">&deg;</span>
                </div>               
              }
            end
            content << %Q{
              <div>
                Remove #{check_box :"remove_#{fieldname}"}
              </div>
            }       
          end    
          block_layout(fieldname, content)
        end         
        
        # Dates and times
        
        def time_block(fieldname)
          content = @template.time_select_tags("#{model.to_s.underscore}[#{fieldname}]", :class => 'form-control', :value => object.send(fieldname))
          block_layout(fieldname, content)
        end
        
        def date_block(fieldname)
          content = @template.date_select_tags("#{model.to_s.underscore}[#{fieldname}]", :class => 'form-control', :value => object.send(fieldname))
          block_layout(fieldname, content)
        end
        
        def datetime_block(fieldname)
          content = @template.datetime_select_tags("#{model.to_s.underscore}[#{fieldname}]", :class => 'form-control', :value => object.send(fieldname))
          block_layout(fieldname, content)
        end        
        
        # Lookups and collections
                                    
        def lookup_block(fieldname, selected: nil)
          content = select(fieldname, :class => 'form-control', :options => ['']+(assoc_name = model.fields[fieldname.to_s].metadata.try(:class_name)).constantize.all.map { |x| [x.send(assoc_name.constantize.send(:lookup)), x.id] }, :selected => (selected || object.send(fieldname)))
          block_layout(fieldname, content)          
        end        
        
        def collection_block(fieldname)
          content = %Q{<ul class="list-unstyled">}
          object.send(fieldname).each { |x|
            content << %Q{<li><a class="popup" href="#{@template.url(:edit, :popup => true, :model => (assoc_name = fieldname.to_s.singularize.camelize), :id => x.id)}">#{x.send(assoc_name.constantize.send(:lookup))}</a></li>}
          }
          content << %Q{<li><a class="btn btn-default popup" href="#{@template.url(:new, :popup => true, :model => (assoc_name = fieldname.to_s.singularize.camelize), :"#{model.to_s.underscore}_id" => object.id)}"><i class="fa fa-pencil"></i> New #{fieldname.to_s.singularize.humanize.downcase}</a></li>}
          content << %Q{</ul>} 
          block_layout(fieldname, content)                            
        end        
                                
        def block_layout(fieldname, content)
          block = %Q{
            <div class="form-group #{'has-error' if !error_message_on(fieldname).blank?}">
              <label class="control-label col-md-3">#{model.human_attribute_name(fieldname)}</label>
              <div class="col-md-6">
                #{content}
          }
          if object.new_record? and model.respond_to?(:new_hints) and model.new_hints[fieldname]        
            block << %Q{
                <p class="hint help-block">#{model.new_hints[fieldname]}</p>
            }
          elsif !object.new_record? and model.respond_to?(:edit_hints) and model.edit_hints[fieldname]
            block << %Q{
                <p class="hint help-block">#{model.edit_hints[fieldname]}</p>
            }
          end
          if !error_message_on(fieldname).blank?
            block << %Q{
                <p class="help-block">#{error_message_on fieldname, :prepend => model.human_attribute_name(fieldname)}</p>
            }
          end
          block << %Q{
              </div>
            </div>
          }
          block
        end   
        
        # Submission
        
        def submit_block(destroy_url: nil)
          content = %Q{
            <div class="form-group">
              <div class="col-md-offset-3 col-md-6">
                <button class="btn btn-primary" type="submit">Save changes</button> }
          if !object.new_record? and destroy_url
            content << %Q{<a class="btn btn-danger" data-confirm="Are you sure you want to delete this #{model.to_s.underscore.humanize.downcase}?" href="#{destroy_url}">Delete</a>}
          end
          content << %Q{
              </div>
            </div>
          }
        end          
        
        protected
        
        def model
          object.class
        end        
                
      end
    end
  end
end

