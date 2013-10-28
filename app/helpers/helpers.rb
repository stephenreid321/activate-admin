ActivateAdmin::App.helpers do
  
  def current_account
    @current_account ||= Account.find(session[:account_id]) if session[:account_id]
  end
  
  def models
    ENV['ACTIVATE_ADMIN_MODELS'] ? (ENV['ACTIVATE_ADMIN_MODELS'].split(',').map { |x| x.constantize }) : (Dir.entries("#{PADRINO_ROOT}/models").select { |filename| filename.ends_with?('.rb') }.map { |filename| filename.split('.rb').first.camelize.constantize })
  end
  
  def model
    params[:model].constantize
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