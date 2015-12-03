module ActivateAdmin
  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Helpers
    register WillPaginate::Sinatra    
    helpers Activate::DatetimeHelpers
    helpers Activate::ParamHelpers
    helpers Activate::NavigationHelpers
      
    enable :sessions
    set :show_exceptions, true
    set :public_folder,  ActivateAdmin.root('app', 'assets')
    set :default_builder, 'ActivateFormBuilder'
       
    before do      
      if ENV['PERMITTED_IPS'] and Padrino.env == :production
        halt 403 unless ENV['PERMITTED_IPS'].split(',').include? request.ip
      end      
      redirect url(:login) unless [url(:login), url(:logout), url(:forgot_password)].any? { |p| p == request.path } or ['stylesheets','javascripts'].any? { |p| request.path.starts_with? "#{ActivateAdmin::App.uri_root}/#{p}" } or Account.count == 0 or (current_account and current_account.admin?)
      Time.zone = current_account.time_zone if current_account and current_account.respond_to?(:time_zone) and current_account.time_zone
      fix_params!
    end 
            
    get :home, :map => '/' do
      erb :home
    end  
    
    get :config, :map => '/config' do
      erb :config
    end
    
    post :config, :map => '/config' do
      heroku = PlatformAPI.connect_oauth(ENV['HEROKU_OAUTH_TOKEN'])
      heroku.config_var.update(ENV['APP_NAME'], Hash[heroku.config_var.info(ENV['APP_NAME']).map { |k,v| [k, params[k]] }])
      flash[:notice] = "Your config vars were updated. You may have to refresh the page for your changes to take effect."
      redirect url(:config)
    end
          
    get :index, :map => '/index/:model', :provides => [:html, :json, :csv] do
      if persisted_field?(model, :created_at)
        @o = :created_at
        @d = :desc
      end
      if model.respond_to?(:filter_options)
        @q, @f, @o, @d, = model.filter_options[:q], model.filter_options[:f], model.filter_options[:o], model.filter_options[:d]
      end
      @id = params[:id] if params[:id]
      @q = params[:q] if params[:q]
      @f = params[:f] if params[:f]
      @o = params[:o].to_sym if params[:o]
      @d = params[:d].to_sym if params[:d]        
      @resources = model.all
      @resources = @resources.where(id: @id) if @id
      if @q
        q = []
        admin_fields(model).each { |fieldname, options|
          if options[:type] === :lookup
            assoc_name = assoc_name(model, fieldname)            
            assoc_model = assoc_name.constantize
            assoc_fields = admin_fields(assoc_model)
            assoc_fieldname = lookup_method(assoc_model)
            assoc_options = assoc_fields[assoc_fieldname]
            if persisted_field?(assoc_model, assoc_fieldname)
              if matchable_regex.include?(assoc_options[:type])
                if model.respond_to?(:column_names) # ActiveRecord/PostgreSQL
                  q << ["#{fieldname} in (?)", assoc_model.where(["#{assoc_fieldname} ilike ?", "%#{@q}%"]).select(:id)]
                else # Mongoid
                  q << {fieldname.to_sym.in => assoc_model.where(assoc_fieldname => /#{Regexp.escape(@q)}/i).only(:id).map(&:id) }
                end                                   
              elsif matchable_number.include?(assoc_options[:type]) and (begin; Float(@q) and true; rescue; false; end)
                if model.respond_to?(:column_names) # ActiveRecord/PostgreSQL
                  q << ["#{fieldname} in (?)", assoc_model.where(assoc_fieldname => @q).select(:id)]
                else # Mongoid
                  q << {fieldname.to_sym.in => assoc_model.where(assoc_fieldname => @q).only(:id).map(&:id) }
                end                 
              end
            end
          elsif persisted_field?(model, fieldname)
            if matchable_regex.include?(options[:type]) 
              if model.respond_to?(:column_names) # ActiveRecord/PostgreSQL
                q << ["#{fieldname} ilike ?", "%#{@q}%"]
              else # Mongoid
                q << {fieldname => /#{Regexp.escape(@q)}/i }
              end            
            elsif matchable_number.include?(options[:type]) and (begin; Float(@q) and true; rescue; false; end)
              q << {fieldname => @q}
            end
          end        
        }
        if model.respond_to?(:column_names) # ActiveRecord/PostgreSQL          
          @resources = @resources.where.any_of(*q) if !q.empty?
        else # Mongoid
          @resources = @resources.or(q)          
        end
      end
      @f.each { |fieldname,q|
        if q
          if fieldname.include?('.')  
            # TODO: ActiveRecord/PostgreSQL
            collection, fieldname = fieldname.split('.')
            collection_assoc = assoc(model, collection, relationship: :has_many)
            collection_model = collection_assoc.class_name.constantize
            options = admin_fields(collection_model)[fieldname.to_sym]            
            if options[:type] == :lookup              
              @resources = @resources.where(:id.in => collection_model.where(fieldname => q).pluck(collection_assoc.inverse_foreign_key.to_sym))
            elsif persisted_field?(collection_model, fieldname)
              if matchable_regex.include?(options[:type]) 
                if model.respond_to?(:column_names) # ActiveRecord/PostgreSQL
                  @resources = @resources.where(:id.in => collection_model.where(["#{fieldname} ilike ?", "%#{q}%"]).pluck(collection_assoc.inverse_foreign_key.to_sym))
                else # Mongoid
                  @resources = @resources.where(:id.in => collection_model.where(fieldname => /#{Regexp.escape(q)}/i).pluck(collection_assoc.inverse_foreign_key.to_sym))
                end                    
              elsif matchable_number.include?(options[:type]) and (begin; Float(q) and true; rescue; false; end)
                @resources = @resources.where(:id.in => collection_model.where(fieldname => q).pluck(collection_assoc.inverse_foreign_key.to_sym))
              elsif options[:type] == :geopicker
                @resources = @resources.where(:id.in => collection_model.where(:coordinates => { "$geoWithin" => { "$centerSphere" => [Geocoder.coordinates(q.split(',')[0]).reverse, (q.split(',')[1] || 20).to_i / 3963.1676 ]}}).pluck(collection_assoc.inverse_foreign_key.to_sym))
              end
            end                       
          else
            options = admin_fields(model)[fieldname.to_sym]
            if options[:type] == :lookup            
              assoc_name = assoc_name(model, fieldname)
              assoc_model = assoc_name.constantize
              assoc_fields = admin_fields(assoc_model)
              assoc_fieldname = lookup_method(assoc_model)
              assoc_options = assoc_fields[assoc_fieldname]         
              if q.starts_with?('id:') or (q.length == 24 and q[0] =~ /\d/) # Mongo ObjectId
                @resources = @resources.where(fieldname.to_sym => q.split('id:').last)
              elsif persisted_field?(assoc_model, assoc_fieldname)
                if matchable_regex.include?(assoc_options[:type])
                  if model.respond_to?(:column_names) # ActiveRecord/PostgreSQL
                    @resources = @resources.where("#{fieldname} in (?)", assoc_model.where(["#{assoc_fieldname} ilike ?", "%#{q}%"]).select(:id))
                  else # Mongoid
                    @resources = @resources.where({fieldname.to_sym.in => assoc_model.where(assoc_fieldname => /#{Regexp.escape(q)}/i).only(:id).map(&:id)})
                  end                                   
                elsif matchable_number.include?(assoc_options[:type]) and (begin; Float(q) and true; rescue; false; end)
                  if model.respond_to?(:column_names) # ActiveRecord/PostgreSQL
                    @resources = @resources.where("#{fieldname} in (?)", assoc_model.where(assoc_fieldname => q).select(:id))
                  else # Mongoid
                    @resources = @resources.where({fieldname.to_sym.in => assoc_model.where(assoc_fieldname => q).only(:id).map(&:id)})
                  end                 
                end
              end
            elsif persisted_field?(model, fieldname)
              if matchable_regex.include?(options[:type]) 
                if model.respond_to?(:column_names) # ActiveRecord/PostgreSQL
                  @resources = @resources.where(["#{fieldname} ilike ?", "%#{q}%"])
                else # Mongoid
                  @resources = @resources.where(fieldname => /#{Regexp.escape(q)}/i)
                end                    
              elsif matchable_number.include?(options[:type]) and (begin; Float(q) and true; rescue; false; end)
                @resources = @resources.where(fieldname => q)
              elsif options[:type] == :geopicker
                @resources = @resources.where(:coordinates => { "$geoWithin" => { "$centerSphere" => [Geocoder.coordinates(q.split(',')[0]).reverse, (q.split(',')[1] || 20).to_i / 3963.1676 ]}})
              end
            end
          end
        end
      } if @f
      if @o and @d
        @resources = @resources.order("#{@o} #{@d}")
      end
      case content_type
      when :html
        @resources = @resources.paginate(:page => params[:page], :per_page => 25)
        instance_variable_set("@#{model.to_s.underscore.pluralize}", @resources)
        erb :index
      when :json
        {
          results: @resources.map { |resource| {id: resource.id.to_s, text: "#{resource.send(lookup_method(resource.class))} (id:#{resource.id})"} }
        }.to_json        
      when :csv
        CSV.generate do |csv|
          csv << admin_fields(model).keys
          @resources.each do |resource|
            csv << admin_fields(model).map { |fieldname, options|
              if options[:type] === :lookup and resource.send(fieldname)
                assoc_name = assoc_name(model, fieldname)
                "#{assoc_name.constantize.find(resource.send(fieldname)).send(lookup_method(assoc_name.constantize))} (id:#{resource.send(fieldname)})"
              else
                resource.send(fieldname)
              end
            }
          end
        end     
      end   
    end
    
    get :new, :map => '/new/:model' do
      @resource = model.new
      instance_variable_set("@#{model.to_s.underscore}", @resource)
      erb :build
    end
  
    post :new, :map => '/new/:model', :provides => [:html, :json] do
      @resource = model.new(params[model.to_s.underscore])
      instance_variable_set("@#{model.to_s.underscore}", @resource)
      if @resource.save
        case content_type
        when :html        
          flash[:notice] = "<strong>Awesome!</strong> The #{human_model_name(model).downcase} was created successfully."
          params[:popup] ? refreshParent : redirect(url(:index, :model => model.to_s))
        when :json
          {url: @resource.send(ENV['INLINE_UPLOAD_MODEL_FILE_FIELD']).url}.to_json
        end
      else
        case content_type
        when :html              
          flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the #{human_model_name(model).downcase} from being saved."
          erb :build
        when :json
          error
        end
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
      erb :login
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
        flash[:error] = "Login or password wrong."
        redirect url(:login)
      end
    end

    get :logout, :map => '/logout' do
      session.clear
      redirect url(:login)
    end  
    
    post :forgot_password, :map => '/forgot_password' do      
      if Account.respond_to?(:column_names) # ActiveRecord/PostgreSQL
        account = Account.where('email ilike ?', params[:email]).first
      else # Mongoid
        account = Account.find_by(email: /^#{Regexp.escape(params[:email])}$/i)
      end      
      if account
        if account.reset_password!
          flash[:notice] = "A new password was sent to #{account.email}"
        else
          flash[:error] = "There was a problem resetting your password."
        end
      else        
        flash[:error] = "There's no account registered under that email address."
      end
      redirect url(:login)      
    end
    
  end
end
