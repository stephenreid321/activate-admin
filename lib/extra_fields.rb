class ExtraFields
  
  def self.fields(model)    
    varname = "EXTRA_FIELDS_#{model.to_s.upcase}"
    ENV[varname] ? Hash[*ENV[varname].split(',').map { |pair| pair.split(':').map { |x| x.to_sym } }.flatten(1)] : {}    
  end
  
  def self.set(model)   
    fields(model).each { |fieldname, fieldtype|
      case fieldtype
      when :text
        model.field fieldname, :type => String
      when :text_area
        model.field fieldname, :type => String        
      when :file
        model.field "#{fieldname}_uid".to_sym, :type => String
        model.send(:dragonfly_accessor, fieldname, :app => :files) # assumes Dragonfly app named :files
      end
    }
  end
  
  def self.display(fieldtype, result)
    case fieldtype
    when :text
      result
    when :text_area
      result
    when :file
      %Q{<a href="#{result.url}">#{result.name}</a>}
    end
  end
  
  
end
  