module Activate
  module NavigationHelpers
      
    def ul_nav(css_class, items)
      s = ''
      s << %Q{<ul class="#{css_class}">}      
      items.each { |name, path|
        s << '<li'
        s << %Q{ class="active" } if request.path == path
        s << '>'
        s << %Q{<a href="#{path}">#{name}</a>}
        s << '</li>'
      }
      s << '</ul>'
    end
    
  end
end