ActivateAdmin::App.helpers do
  
  def current_account
    @current_account ||= Account.find(session[:account_id]) if session[:account_id]
  end
  
  def models
    ENV['ADMIN_MODELS'] ? (ENV['ADMIN_MODELS'].split(',').map { |x| x.constantize }) : (Dir.entries("#{PADRINO_ROOT}/models").select { |filename| filename.ends_with?('.rb') }.map { |filename| filename.split('.rb').first.camelize.constantize })
  end
  
  def model
    params[:model].constantize
  end  
    
  def admin_fields(model)
    admin_fields = model.admin_fields
    admin_fields[:created_at] = {:type => :datetime, :edit => false} if persisted_field?(model, :created_at)
    admin_fields[:updated_at] = {:type => :datetime, :edit => false} if persisted_field?(model, :updated_at)
    admin_fields = Hash[admin_fields.map { |fieldname, options|        
        options = {:type => options} if options.is_a?(Symbol)        
        options[:index] = true if !options.keys.include?(:index) and queryable.include?(options[:type])
        options[:edit] = true if !options.keys.include?(:edit)
        options[:disabled] = true if fieldname == :id    
        options[:class_name] = assoc(model, fieldname, relationship: case options[:type]; when :lookup; :belongs_to; when :collection; :has_many; end).class_name if [:lookup, :collection].include?(options[:type])        
        [fieldname, options]
      }]
    admin_fields[admin_fields.first.first][:lookup] = true if !admin_fields.find { |fieldname, options| options[:lookup] }
    admin_fields
  end
  
  def assoc(model, fieldname, relationship: :belongs_to)
    case relationship
    when :belongs_to
      model.reflect_on_all_associations(:belongs_to).find { |assoc| assoc.foreign_key == fieldname.to_s }
    when :has_many
      model.reflect_on_all_associations(:has_many).find { |assoc| assoc.name == fieldname.to_sym }
    end
  end
      
  def assoc_name(model, fieldname)
    assoc(model, fieldname).class_name
  end
  
  def lookup_method(model)
    admin_fields(model).find { |fieldname, options| options[:lookup] }.first
  end
  
  def persisted_field?(model, fieldname)
    if model.respond_to?(:column_names)  # ActiveRecord/PostgreSQL     
      model.column_names.include?(fieldname.to_s)
    else # Mongoid
      model.fields[fieldname.to_s]
    end
  end  
    
  def matchable_regex
    [:text, :slug, :text_area, :wysiwyg, :email, :url, :select, :radio_button]
  end
  
  def matchable_number
    [:number]
  end
  
  def queryable
    matchable_regex + matchable_number + [:lookup, :geopicker, :check_box, :date, :datetime]
  end
    
  def human_model_name(model)
    model.to_s.underscore.humanize
  end  
  
  def refreshParent
    %q{
      <script>
      window.opener.location.reload(false);
      window.close();
      </script>
    }
  end
           
end