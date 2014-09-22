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
    Hash[admin_fields.map { |fieldname, options|
        options = {:type => options} if options.is_a?(Symbol)
        options[:index] = true if !options.keys.include?(:index) and [:text, :number, :slug, :text_area, :wysiwyg, :check_box, :select, :radio_button, :date, :datetime, :lookup].include?(options[:type])
        options[:edit] = true if !options.keys.include?(:edit)
        [fieldname, options]
      }]
  end
  
  def assoc_name(model, fieldname)
    model.reflect_on_all_associations(:belongs_to).find { |assoc| assoc.foreign_key == fieldname.to_s }.class_name
  end
  
  def persisted_field?(model, fieldname)
    if model.respond_to?(:column_names)        
      model.column_names.include?(fieldname.to_s)
    else
      model.fields[fieldname.to_s]
    end
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