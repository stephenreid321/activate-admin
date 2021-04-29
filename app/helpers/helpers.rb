ActivateAdmin::App.helpers do
  def current_account
    @current_account ||= Account.find(session[:account_id]) if session[:account_id]
  end

  def models
    if ENV['ADMIN_MODELS']
      (ENV['ADMIN_MODELS'].split(',').map do |x|
         x.constantize
       end)
    else
      (Dir.entries("#{PADRINO_ROOT}/models").select do |filename|
         filename.ends_with?('.rb')
       end.map do |filename|
         filename.split('.rb').first.camelize.constantize
       end)
    end
  end

  def model
    params[:model].constantize
  end

  def admin_fields(model)
    admin_fields = model.admin_fields
    admin_fields[:created_at] = { type: :datetime, edit: false } if persisted_field?(model, :created_at)
    admin_fields[:updated_at] = { type: :datetime, edit: false } if persisted_field?(model, :updated_at)
    admin_fields = Hash[admin_fields.map do |fieldname, options|
                          options = { type: options } if options.is_a?(Symbol)
                          options[:index] = true if !options.keys.include?(:index) && queryable.include?(options[:type])
                          options[:edit] = true unless options.keys.include?(:edit)
                          options[:disabled] = true if fieldname == :id
                          if %i[lookup
                                collection].include?(options[:type])
                            options[:class_name] = assoc(model, fieldname, relationship: case options[:type]
                                                                                         when :lookup then :belongs_to
                                                                                         when :collection then :has_many
                                                                                         end).class_name
                          end
                          [fieldname, options]
                        end]
    admin_fields[admin_fields.first.first][:lookup] = true unless admin_fields.find do |_fieldname, options|
                                                                    options[:lookup]
                                                                  end
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
    admin_fields(model).find { |_fieldname, options| options[:lookup] }.first
  end

  def persisted_field?(model, fieldname)
    fieldname.to_s == 'id' or if active_record?
                                model.column_names.include?(fieldname.to_s)
                              elsif mongoid?
                                model.fields[fieldname.to_s]
                              end
  end

  def matchable_regex
    %i[text slug text_area wysiwyg email url select radio]
  end

  def matchable_number
    [:number]
  end

  def matchable_id
    [:id]
  end

  def queryable
    matchable_regex + matchable_number + matchable_id + %i[lookup geopicker check_box date datetime]
  end

  def human_model_name(model)
    model.to_s.underscore.gsub('/', '_').humanize
  end

  def refreshParent
    '
      <script>
      window.opener.location.reload(false);
      window.close();
      </script>
    '
  end

  def active_record?
    models.first.respond_to?(:column_names)
  end

  def mongoid?
    !active_record?
  end

  def inequality(b)
    case b
    when :gt
      '>'
    when :gte
      '>='
    when :lt
      '<'
    when :lte
      '<='
    end
  end
end
