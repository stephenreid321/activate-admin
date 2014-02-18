module Padrino
  module Helpers
    module FormBuilder
      class ActivateFormBuilder < AbstractFormBuilder
                        
        # Text
                
        def text_block(fieldname, placeholder: nil, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = text_field(fieldname, :class => 'form-control', :disabled => disabled, :placeholder => placeholder)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end
                    
        def password_block(fieldname, placeholder: nil, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = password_field(fieldname, :class => 'form-control', :disabled => disabled, :placeholder => placeholder)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end        
        
        def slug_block(fieldname, placeholder: nil, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = text_field(fieldname, :class => 'form-control slug', :disabled => disabled, :placeholder => placeholder)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end        
        
        def text_area_block(fieldname, rows: 10, placeholder: nil, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = text_area(fieldname, :class => 'form-control', :rows => rows, :disabled => disabled, :placeholder => placeholder)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end
                
        def wysiwyg_block(fieldname, rows: 10, placeholder: nil, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = text_area(fieldname, :class => 'form-control wysiwyg', :rows => rows, :disabled => disabled, :placeholder => placeholder)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end    
        
        # Selects and checkboxes

        def check_box_block(fieldname, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = check_box(fieldname, :disabled => disabled)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end
                        
        def select_block(fieldname, options: model.send(fieldname.to_s.pluralize), disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = select(fieldname, :class => 'form-control', :options => options, :disabled => disabled)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end       
        
        def radio_block(fieldname, options: model.send(fieldname.to_s.pluralize), disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = ''          
          options = Hash[*options.map { |x| [x,x] }.flatten] if options.is_a? Array
          options.each { |k,v|
            content << %Q{
              <div class="radio">
                <label>
            }
            content << radio_button(fieldname, :value => v, :checked => (v == object.send(fieldname)), :disabled => disabled)
            content << %Q{
                #{k}
              </label>
            </div>
            }
          }
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end
        
        # Files and images
        
        def file_block(fieldname, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = ''
          if !object.persisted? or !object.send(fieldname)
            content << file_field(fieldname)
          else         
            content << %Q{
              <div>
                <i class="fa fa-download"></i> <a target="_blank" href="#{object.send(fieldname).url}">#{object.send(fieldname).name}</a>
              </div>          
              <div>
                #{file_field(fieldname, :disabled => disabled)}
              </div>      
              <div>
                Remove #{check_box(:"remove_#{fieldname}", :disabled => disabled)}
              </div>
            }
          end          
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end
        
        def image_block(fieldname, rotate: true, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = ''
          if !object.persisted? or !object.send(fieldname)
            content << file_field(fieldname)
          else          
            content << %Q{
            <div style="margin-bottom: 1em">
              <a target="_blank" href="#{object.send(fieldname).url}"><img style="max-height: 200px" src="#{object.send(fieldname).url}"></a>
            </div>
            <div>
              #{file_field(fieldname, :disabled => disabled)}
            </div>
            }
            if object.respond_to?(:"rotate_#{fieldname}_by") and rotate
              content << %Q{                  
                <div class="input-group" style="width: 13em">              
                  <span style="display: table-cell">Rotate by</span>
                  #{select(:"rotate_#{fieldname}_by", :options => ['','90','180','270'], :class => 'form-control', :disabled => disabled)}
                  <span class="input-group-addon">&deg;</span>
                </div>               
              }
            end
            content << %Q{
              <div>
                Remove #{check_box(:"remove_#{fieldname}", :disabled => disabled)}
              </div>
            }       
          end    
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end         
        
        # Dates and times
                
        def date_block(fieldname, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = @template.date_select_tags("#{model.to_s.underscore}[#{fieldname}]", :class => 'form-control', :value => object.send(fieldname), :disabled => disabled)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end
        
        def datetime_block(fieldname, fives: false, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = @template.datetime_select_tags("#{model.to_s.underscore}[#{fieldname}]", :class => 'form-control', :value => object.send(fieldname), :disabled => disabled, :fives => fives)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end        
        
        # Lookups and collections
                                    
        def lookup_block(fieldname, selected: nil, disabled: false, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = select(fieldname, :class => 'form-control', :options => ['']+(assoc_name = model.fields[fieldname.to_s].metadata.try(:class_name)).constantize.all.map { |x| [x.send(assoc_name.constantize.send(:lookup)), x.id] }, :selected => (selected || object.send(fieldname)), :disabled => disabled)
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)
        end        
        
        def collection_block(fieldname, tip: nil, hint: nil, label_class: nil, div_class: nil)
          content = %Q{<ul class="list-unstyled">}
          object.send(fieldname).each { |x|
            content << %Q{<li><a class="popup" href="#{@template.url(:edit, :popup => true, :model => (assoc_name = fieldname.to_s.singularize.camelize), :id => x.id)}">#{x.send(assoc_name.constantize.send(:lookup))}</a></li>}
          }
          content << %Q{<li><a class="btn btn-default popup" href="#{@template.url(:new, :popup => true, :model => (assoc_name = fieldname.to_s.singularize.camelize), :"#{model.to_s.underscore}_id" => object.id)}"><i class="fa fa-pencil"></i> New #{fieldname.to_s.singularize.humanize.downcase}</a></li>}
          content << %Q{</ul>} 
          block_layout(fieldname, content, tip: tip, hint: hint, label_class: label_class, div_class: div_class)                         
        end        
                                
        def block_layout(fieldname, content, tip: nil, hint: nil, label_class: nil, div_class: nil)
          
          tip = if tip
            tip
          elsif object.new_record? and model.respond_to?(:new_tips) and model.new_tips[fieldname]
            model.new_tips[fieldname]
          elsif !object.new_record? and model.respond_to?(:edit_tips) and model.edit_tips[fieldname]
            model.edit_tips[fieldname]
          end
          
          hint = if hint
            hint
          elsif object.new_record? and model.respond_to?(:new_hints) and model.new_hints[fieldname]
            model.new_hints[fieldname]
          elsif !object.new_record? and model.respond_to?(:edit_hints) and model.edit_hints[fieldname]
            model.edit_hints[fieldname]
          end          
                                  
          block = %Q{
            <div class="form-group #{'has-error' if !error_message_on(fieldname).blank?}">
              <label for="#{model.to_s.underscore}_#{fieldname}" class="control-label #{label_class || 'col-md-3'}">
                #{model.human_attribute_name(fieldname)}
          }          
          if tip
            block << "
            <i id=\"tip-#{fieldname}\" class=\"fa fa-question-circle\" title=\"#{tip}\"></i>
            <script>
              $(function() {
                $('#tip-#{fieldname}').tooltip({placement: 'right'});
            });
            </script>
            " 
          end
          block << %Q{
              </label>
              <div class="#{div_class || 'col-md-6'}">
                #{content}
          }
          if hint
            block << %Q{
                <p class="hint help-block">#{hint}</p>
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
        
        def submit_block(destroy_url: nil, div_class: nil)
          content = %Q{
            <div class="form-group">
              <div class="#{div_class || 'col-md-offset-3 col-md-6'}">
                <button class="btn btn-primary" type="submit">#{object.new_record? ? "Create #{model.to_s.underscore.humanize.downcase}" : "Update #{model.to_s.underscore.humanize.downcase}"}</button> }
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

