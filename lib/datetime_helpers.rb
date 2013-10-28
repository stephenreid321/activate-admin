module ActivateAdmin
  module DatetimeHelpers
      
    def datetime_select_tags(name, options)
      v = options[:value] || Time.zone.now
      c = options[:class]
      id = options[:id]
      s = []
      s << "<style>.datetime select { width: auto }</style>"
      s << "<span id=\"#{id if id}\" class=\"datetime #{c if c}\">"
      s << select_tag(:"#{name}[day]", :options => (1..31).to_a.map(&:to_s), :selected => v.day )
      s << select_tag(:"#{name}[month]", :options => Date::MONTHNAMES[1..-1].each_with_index.map { |x,i| [x,i+1] }, :selected => v.month)
      s << select_tag(:"#{name}[year]", :options => (1900..2020).to_a.map(&:to_s), :selected => v.year )
      s << '@'
      s << select_tag(:"#{name}[hour]", :options => (0..23).to_a.map { |x| [x < 10 ? "0#{x}" : x.to_s,x] }, :selected => v.hour ) 
      s << ':'
      s << select_tag(:"#{name}[min]", :options => (0..59).to_a.map { |x| [x < 10 ? "0#{x}" : x.to_s,x] }, :selected => v.min )
      s << '</span>'
      s.join(' ').html_safe
    end    
  
    def compact_time_ago(t)
      d = Time.now - t
      if d < 1.day
        time_ago_in_words(t) + ' ago'
      elsif d < 3.days
        t.strftime('%A') + " at #{t.to_s(:time)}"
      else
        t
      end
    end   
  end
end