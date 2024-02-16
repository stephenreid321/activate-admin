module ActivateAdmin
  class OperatorNotSupported < StandardError; end

  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Helpers
    register WillPaginate::Sinatra
    helpers Activate::ParamHelpers
    helpers Activate::NavigationHelpers

    use Rack::Session::Cookie, expire_after: 1.year.to_i, secret: ENV['SESSION_SECRET']
    set :show_exceptions, true
    set :public_folder, ActivateAdmin.root('app', 'assets')
    set :default_builder, 'ActivateFormBuilder'

    before do
      halt 403 if ENV['PERMITTED_IPS'] && (Padrino.env == :production) && !(ENV['PERMITTED_IPS'].split(',').include? request.ip)
      redirect url(:login) unless [url(:login), url(:logout), url(:forgot_password)].any? do |p|
                                    p == request.path
                                  end || %w[stylesheets javascripts].any? do |p|
                                           request.path.starts_with? "#{ActivateAdmin::App.uri_root}/#{p}"
                                         end || (Account.first.nil?) || (current_account && current_account.admin?)
      Time.zone = current_account.time_zone if current_account && current_account.respond_to?(:time_zone) && current_account.time_zone
      fix_params!
    end

    get :home, map: '/' do
      erb :home
    end

    get :config, map: '/config' do
      erb :config
    end

    get :index, map: '/index/:model', provides: %i[html json csv] do
      if persisted_field?(model, :created_at)
        @o = :created_at
        @d = :desc
      end
      if model.respond_to?(:filter_options)
        @o = model.filter_options[:o]
        @d = model.filter_options[:d]
      end
      @id = params[:id] if params[:id]
      @q = params[:q] if params[:q]
      @o = params[:o].to_sym if params[:o]
      @d = params[:d].to_sym if params[:d]
      @resources = model.all
      @resources = @resources.where(id: @id) if @id

      if @q
        query = []
        admin_fields(model).each do |fieldname, options|
          if options[:type] === :lookup
            assoc_name = assoc_name(model, fieldname)
            assoc_model = assoc_name.constantize
            assoc_fields = admin_fields(assoc_model)
            assoc_fieldname = lookup_method(assoc_model)
            assoc_options = assoc_fields[assoc_fieldname]
            if persisted_field?(assoc_model, assoc_fieldname)
              if matchable_regex.include?(assoc_options[:type])
                if active_record?
                  query << ["#{fieldname} in (?)",
                            assoc_model.where(["#{assoc_fieldname} ilike ?", "%#{@q}%"]).select(:id)]
                elsif mongoid?
                  query << { fieldname.to_sym.in => assoc_model.where(assoc_fieldname => /#{Regexp.escape(@q)}/i).pluck(:id) }
                end
              elsif matchable_number.include?(assoc_options[:type]) && (begin
 Float(@q) && true; rescue StandardError; false; end)
                if active_record?
                  query << ["#{fieldname} in (?)", assoc_model.where(assoc_fieldname => @q).select(:id)]
                elsif mongoid?
                  query << { fieldname.to_sym.in => assoc_model.where(assoc_fieldname => @q).pluck(:id) }
                end
              elsif matchable_id.include?(assoc_options[:type])
                if active_record?
                  query << ["#{fieldname} in (?)", assoc_model.where(assoc_fieldname => @q).select(:id)]
                elsif mongoid?
                  query << { fieldname.to_sym.in => assoc_model.where(assoc_fieldname => @q).pluck(:id) }
                end
              end
            end
          elsif persisted_field?(model, fieldname)
            if matchable_regex.include?(options[:type])
              if active_record?
                query << ["#{fieldname} ilike ?", "%#{@q}%"]
              elsif mongoid?
                query << { fieldname => /#{Regexp.escape(@q)}/i }
              end
            elsif matchable_number.include?(options[:type]) && (begin
 Float(@q) && true; rescue StandardError; false; end)
              query << { fieldname => @q }
            elsif matchable_id.include?(options[:type])
              query << { fieldname => @q }
            end
          end
        end
        if active_record?
          @resources = @resources.where.any_of(*query) unless query.empty?
        elsif mongoid?
          @resources = @resources.or(query)
        end
      end

      query = []
      if params[:qk]
        params[:qk].each_with_index do |fieldname, i|
          q = params[:qv][i]
          q = nil if q == 'nil'
          b = params[:qb][i].to_sym
          if !fieldname.include?('.')
            collection_model = model
            collection_key = :id
          else
            collection, fieldname = fieldname.split('.')
            collection_assoc = assoc(model, collection, relationship: :has_many)
            collection_model = collection_assoc.class_name.constantize
            collection_key = collection_assoc.inverse_foreign_key.to_sym
          end
          options = admin_fields(collection_model)[fieldname.to_sym]
          if options[:type] == :lookup
            case b
            when :in
              if active_record?
                query << ['id in (?)', collection_model.where(fieldname => q).select(collection_key)]
              elsif mongoid?
                query << { :id.in => collection_model.where(fieldname => q).pluck(collection_key) }
              end
            when :nin
              if active_record?
                query << ['id not in (?)', collection_model.where(fieldname => q).select(collection_key)]
              elsif mongoid?
                query << { :id.nin => collection_model.where(fieldname => q).pluck(collection_key) }
              end
            when :gt, :gte, :lt, :lte
              raise OperatorNotSupported
            end
          elsif persisted_field?(collection_model, fieldname)
            if matchable_regex.include?(options[:type])
              case b
              when :in
                if q.nil?
                  if active_record?
                    query << ['id in (?)', collection_model.where(fieldname => nil).select(collection_key)]
                  elsif mongoid?
                    query << { :id.in => collection_model.where(fieldname => nil).pluck(collection_key) }
                  end
                elsif active_record?
                  query << ['id in (?)',
                            collection_model.where(["#{fieldname} ilike ?", "%#{q}%"]).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname => /#{Regexp.escape(q)}/i).pluck(collection_key) }
                end
              when :nin
                if q.nil?
                  if active_record?
                    query << ['id not in (?)', collection_model.where(fieldname => nil).select(collection_key)]
                  elsif mongoid?
                    query << { :id.nin => collection_model.where(fieldname => nil).pluck(collection_key) }
                  end
                elsif active_record?
                  query << ['id not in (?)',
                            collection_model.where(["#{fieldname} ilike ?", "%#{q}%"]).select(collection_key)]
                elsif mongoid?
                  query << { :id.nin => collection_model.where(fieldname => /#{Regexp.escape(q)}/i).pluck(collection_key) }
                end
              when :gt, :gte, :lt, :lte
                raise OperatorNotSupported
              end
            elsif matchable_number.include?(options[:type]) && (begin
 Float(q) && true; rescue StandardError; false; end || q.nil?)
              case b
              when :in
                if active_record?
                  query << ['id in (?)', collection_model.where(fieldname => q).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname => q).pluck(collection_key) }
                end
              when :nin
                if active_record?
                  query << ['id not in (?)', collection_model.where(fieldname => q).select(collection_key)]
                elsif mongoid?
                  query << { :id.nin => collection_model.where(fieldname => q).pluck(collection_key) }
                end
              when :gt, :gte, :lt, :lte
                if active_record?
                  query << ['id in (?)',
                            collection_model.where(["#{fieldname} #{inequality(b)} ?", q]).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname.to_sym.send(b) => q).pluck(collection_key) }
                end
              end
            elsif matchable_id.include?(options[:type])
              case b
              when :in
                if active_record?
                  query << ['id in (?)', collection_model.where(fieldname => q).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname => q).pluck(collection_key) }
                end
              when :nin
                if active_record?
                  query << ['id not in (?)', collection_model.where(fieldname => q).select(collection_key)]
                elsif mongoid?
                  query << { :id.nin => collection_model.where(fieldname => q).pluck(collection_key) }
                end
              end
            elsif options[:type] == :geopicker
              case b
              when :in
                if active_record?
                  # TODO
                  raise OperatorNotSupported
                elsif mongoid?
                  query << { :id.in => collection_model.where(coordinates: { '$geoWithin' => { '$centerSphere' => [
                                                                Geocoder.coordinates(q.split(':')[0].strip).reverse, ((d = q.split(':')[1]) ? d.strip.to_i : 20) / 3963.1676
                                                              ] } }).pluck(collection_key) }
                end
              when :nin
                if active_record?
                  # TODO
                  raise OperatorNotSupported
                elsif mongoid?
                  query << { :id.nin => collection_model.where(coordinates: { '$geoWithin' => { '$centerSphere' => [
                                                                 Geocoder.coordinates(q.split(':')[0].strip).reverse, ((d = q.split(':')[1]) ? d.strip.to_i : 20) / 3963.1676
                                                               ] } }).pluck(collection_key) }
                end
              when :gt, :gte, :lt, :lte
                raise OperatorNotSupported
              end
            elsif options[:type] == :check_box
              case b
              when :in
                if active_record?
                  query << ['id in (?)', collection_model.where(fieldname => eval(q)).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname => eval(q)).pluck(collection_key) }
                end
              when :nin
                if active_record?
                  query << ['id not in (?)', collection_model.where(fieldname => eval(q)).select(collection_key)]
                elsif mongoid?
                  query << { :id.nin => collection_model.where(fieldname => eval(q)).pluck(collection_key) }
                end
              when :gt, :gte, :lt, :lte
                raise OperatorNotSupported
              end
            elsif options[:type] == :date
              case b
              when :in
                if active_record?
                  query << ['id in (?)', collection_model.where(fieldname => Date.parse(q)).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname => Date.parse(q)).pluck(collection_key) }
                end
              when :nin
                if active_record?
                  query << ['id not in (?)', collection_model.where(fieldname => Date.parse(q)).select(collection_key)]
                elsif mongoid?
                  query << { :id.nin => collection_model.where(fieldname => Date.parse(q)).pluck(collection_key) }
                end
              when :gt, :gte, :lt, :lte
                if active_record?
                  query << ['id in (?)',
                            collection_model.where(["#{fieldname} #{inequality(b)} ?",
                                                    Date.parse(q)]).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname.to_sym.send(b) => Date.parse(q)).pluck(collection_key) }
                end
              end
            elsif options[:type] == :datetime
              case b
              when :in
                if active_record?
                  query << ['id in (?)', collection_model.where(fieldname => Time.zone.parse(q)).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname => Time.zone.parse(q)).pluck(collection_key) }
                end
              when :nin
                if active_record?
                  query << ['id not in (?)',
                            collection_model.where(fieldname => Time.zone.parse(q)).select(collection_key)]
                elsif mongoid?
                  query << { :id.nin => collection_model.where(fieldname => Time.zone.parse(q)).pluck(collection_key) }
                end
              when :gt, :gte, :lt, :lte
                if active_record?
                  query << ['id in (?)',
                            collection_model.where(["#{fieldname} #{inequality(b)} ?",
                                                    Time.zone.parse(q)]).select(collection_key)]
                elsif mongoid?
                  query << { :id.in => collection_model.where(fieldname.to_sym.send(b) => Time.zone.parse(q)).pluck(collection_key) }
                end
              end
            end
          end
        end
      end

      case params[:all_any]
      when 'all'
        if active_record?
          query.each { |q| @resources = @resources.where(q) }
        elsif mongoid?
          @resources = @resources.all_of(query)
        end
      when 'any'
        if active_record?
          @resources = @resources.where.any_of(*query) unless query.empty?
        elsif mongoid?
          @resources = @resources.or(query)
        end
      end

      @resources = @resources.order("#{@o} #{@d}") if @o && @d
      case content_type
      when :html
        @resources = @resources.paginate(page: params[:page], per_page: 25)
        instance_variable_set("@#{model.to_s.underscore.gsub('/', '_').pluralize}", @resources)
        erb :index
      when :json
        {
          results: @resources.map do |resource|
                     { id: resource.id.to_s,
                       text: "#{resource.send(lookup_method(resource.class))} (id:#{resource.id})" }
                   end
        }.to_json
      when :csv
        fields = admin_fields(model).select { |_fieldname, options| options[:index] }
        CSV.generate do |csv|
          csv << fields.keys
          @resources.each do |resource|
            csv << fields.map do |fieldname, options|
              if (options[:type] === :lookup) && resource.send(fieldname)
                assoc_name = assoc_name(model, fieldname)
                "#{assoc_name.constantize.find(resource.send(fieldname)).send(lookup_method(assoc_name.constantize))} (id:#{resource.send(fieldname)})"
              elsif %i[date datetime].include?(options[:type])
                resource.send(fieldname).try(:iso8601)
              else
                resource.send(fieldname)
              end
            end
          end
        end
      end
    end

    get :new, map: '/new/:model' do
      @resource = model.new
      instance_variable_set("@#{model.to_s.underscore.gsub('/', '_')}", @resource)
      erb :build
    end

    post :new, map: '/new/:model' do
      @resource = model.new(params[model.to_s.underscore.gsub('/', '_')])
      instance_variable_set("@#{model.to_s.underscore.gsub('/', '_')}", @resource)
      if @resource.save
        flash[:notice] = "<strong>Awesome!</strong> The #{human_model_name(model).downcase} was created successfully."
        params[:popup] ? refreshParent : redirect(url(:index, model: model.to_s))
      else
        flash.now[:error] =
          "<strong>Oops.</strong> Some errors prevented the #{human_model_name(model).downcase} from being saved."
        erb :build
      end
    end

    get :edit, map: '/edit/:model/:id' do
      @resource = model.find(params[:id])
      instance_variable_set("@#{model.to_s.underscore.gsub('/', '_')}", @resource)
      erb :build
    end

    post :edit, map: '/edit/:model/:id' do
      @resource = model.find(params[:id])
      instance_variable_set("@#{model.to_s.underscore.gsub('/', '_')}", @resource)
      if @resource.update_attributes(params[model.to_s.underscore.gsub('/', '_')])
        flash[:notice] =
          "<strong>Sweet!</strong> The #{human_model_name(model).downcase} was updated successfully."
        params[:popup] ? refreshParent : redirect(url(:edit, model: model.to_s, id: @resource.id))
      else
        flash.now[:error] =
          "<strong>Oops.</strong> Some errors prevented the #{human_model_name(model).downcase} from being saved."
        erb :build
      end
    end

    get :destroy, map: '/destroy/:model/:id' do
      resource = model.find(params[:id])
      if resource.destroy
        flash[:notice] = "<strong>Boom!</strong> The #{human_model_name(model).downcase} was deleted."
      else
        flash[:error] = "<strong>Darn!</strong> The #{human_model_name(model).downcase} couldn't be deleted."
      end
      params[:popup] ? refreshParent : redirect(url(:index, model: model.to_s))
    end

    get :login, map: '/login' do
      erb :login
    end

    post :login, map: '/login' do
      if account = Account.authenticate(params[:email], params[:password])
        session[:account_id] = account.id.to_s
        flash[:notice] = 'Logged in successfully.'
        redirect url(:home)
      elsif Padrino.env == :development && params[:bypass]
        account = Account.first
        session[:account_id] = account.id.to_s
        flash[:notice] = 'Logged in successfully.'
        redirect url(:home)
      else
        flash[:error] = 'Login or password wrong.'
        redirect url(:login)
      end
    end

    get :logout, map: '/logout' do
      session.clear
      redirect url(:login)
    end

    post :forgot_password, map: '/forgot_password' do
      if active_record?
        account = Account.where('email ilike ?', params[:email]).first
      elsif mongoid?
        account = Account.find_by(email: /^#{Regexp.escape(params[:email])}$/i)
      end
      if account
        if account.reset_password!
          flash[:notice] = "A new password was sent to #{account.email}"
        else
          flash[:error] = 'There was a problem resetting your password.'
        end
      else
        flash[:error] = "There's no account registered under that email address."
      end
      redirect url(:login)
    end
  end
end
