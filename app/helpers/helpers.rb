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
    Hash[model.admin_fields.map { |fieldname, options|
        options = {:type => options} if options.is_a?(Symbol)
        options[:index] = true if !options[:index]
        options[:edit] = true if !options[:edit]
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