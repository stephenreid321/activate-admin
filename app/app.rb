module ActivateAdmin
  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Helpers
    register Sinatra::SimpleNavigation
    register WillPaginate::Sinatra    
    helpers ActivateAdmin::DatetimeHelpers
    helpers ActivateAdmin::ParamHelpers  
      
    enable :sessions
    set :show_exceptions, true
    set :public_folder,  ActivateAdmin.root('app', 'assets')
       
    before do
      redirect url(:login) unless [url(:login), url(:logout)].any? { |p| p == request.path } or ['stylesheets','javascripts','fonts'].any? { |p| request.path.starts_with? "#{ActivateAdmin::App.uri_root}/#{p}" } or (current_account and current_account.role == 'admin')
      fix_params!    
      Time.zone = current_account.time_zone if current_account and current_account.time_zone     
    end 
            
    get :home, :map => '/' do
      erb :home
    end  
  
    get :index, :map => '/index/:model', :provides => [:html, :csv] do
      if model.respond_to?(:filter_options)
        @q, @f, @o, @d, = model.filter_options[:q], model.filter_options[:f], model.filter_options[:o], model.filter_options[:d]
      end
      @q = params[:q] if params[:q]
      @f = params[:f] if params[:f]
      @o = params[:o].to_sym if params[:o]
      @d = params[:d].to_sym if params[:d]        
      @resources = model.all      
      if @q
        q = []
        model.fields.each { |fieldstring, fieldobj|
          if fieldobj.type == String and !fieldstring.starts_with?('_')          
            q << {fieldstring.to_sym => /#{@q}/i }
          elsif fieldstring.ends_with?('_id') && fieldstring != '_id' && Object.const_defined?((assoc_name = model.fields[fieldstring].metadata.class_name))          
            q << {"#{assoc_name.underscore}_id".to_sym.in => assoc_name.constantize.where(assoc_name.constantize.send(:lookup) => /#{@q}/i).only(:_id).map(&:_id) }
          end          
        }
        @resources = @resources.or(q)
      end
      @f.each { |k,v|      
        if model.fields[k].type == String
          @resources = @resources.where(k.to_sym => /#{v}/i)
        elsif k.ends_with?('_id') && Object.const_defined?((assoc_name = model.fields[k].metadata.class_name))
          @resources = @resources.where({"#{assoc_name.underscore}_id".to_sym.in => assoc_name.constantize.where(assoc_name.constantize.send(:lookup) => /#{v}/i).only(:_id).map(&:_id) })
        end
      } if @f
      @resources = @resources.order_by(@o.to_sym.send(@d)) if @o and @d
      case content_type
      when :html
        @resources = @resources.per_page(1).page(params[:page])
        instance_variable_set("@#{model.to_s.underscore.pluralize}", @resources)
        erb :index
      when :csv
        CSV.generate do |csv|
          csv << model.fields_for_index
          @resources.each do |resource|
            csv << model.fields_for_index.map { |fieldname| resource.send(fieldname) }
          end
        end     
      end   
    end
    
    get :new, :map => '/new/:model' do
      @resource = model.new
      instance_variable_set("@#{model.to_s.underscore}", @resource)
      erb :build
    end
  
    post :new, :map => '/new/:model' do
      @resource = model.new(params[model.to_s.underscore])
      instance_variable_set("@#{model.to_s.underscore}", @resource)
      if @resource.save
        flash[:notice] = "<strong>Awesome!</strong> The #{human_model_name(model).downcase} was created successfully."
        params[:popup] ? refreshParent : redirect(url(:index, :model => model.to_s))
      else
        flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the #{human_model_name(model).downcase} from being saved."
        erb :build
      end
    end
  
    get :edit, :map => '/edit/:model/:id' do
      @resource = model.find(params[:id])
      instance_variable_set("@#{model.to_s.underscore}", @resource)
      erb :build
    end

    post :edit, :map => '/edit/:model/:id' do
      @resource = model.find(params[:id])
      instance_variable_set("@#{model.to_s.underscore}", @resource)
      if @resource.update_attributes(params[model.to_s.underscore])
        flash[:notice] = "<strong>Sweet!</strong> The #{human_model_name(model).downcase} was updated successfully."      
        params[:popup] ? refreshParent : redirect(url(:edit, :model => model.to_s, :id => @resource.id))
      else
        flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the #{human_model_name(model).downcase} from being saved."
        erb :build
      end
    end

    get :destroy, :map => '/destroy/:model/:id' do
      resource = model.find(params[:id])
      if resource.destroy
        flash[:notice] = "<strong>Boom!</strong> The #{human_model_name(model).downcase} was deleted."
      else
        flash[:error] = "<strong>Darn!</strong> The #{human_model_name(model).downcase} couldn't be deleted."
      end
      params[:popup] ? refreshParent : redirect(url(:index, :model => model.to_s))
    end
    
    get :login, :map => '/login' do
      erb :login_page
    end

    post :login, :map => '/login' do
      if account = Account.authenticate(params[:email], params[:password])
        session[:account_id] = account.id
        flash[:notice] = "Logged in successfully."
        redirect url(:home)
      elsif Padrino.env == :development && params[:bypass]
        account = Account.first
        session[:account_id] = account.id
        flash[:notice] = "Logged in successfully."
        redirect url(:home)
      else
        params[:email], params[:password] = h(params[:email]), h(params[:password])
        flash[:warning] = "Login or password wrong."
        redirect url(:login)
      end
    end

    get :logout, :map => '/logout' do
      session.clear
      redirect url(:login)
    end  
  end
end
