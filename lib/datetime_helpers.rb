module Activate
  module DatetimeHelpers
     
    def date_select_tags(name, options={})
      value = options[:value] || Time.zone.now
      start_year = options[:start_year] ? options[:start_year].to_i : [Time.zone.now.year,value.year].min
      end_year = options[:end_year] ? options[:end_year].to_i : start_year+7
      disabled = options[:disabled] || false
      # options[:class]
      s = []
      s << '<span class="date">'
      s << select_tag(:"#{name}[day]", :options => 1.upto(31).map(&:to_s), :class => options[:class], :selected => value.day, :disabled => disabled)
      s << select_tag(:"#{name}[month]", :options => Date::MONTHNAMES[1..-1].each_with_index.map { |x,i| ["#{x}","#{i+1}"] }, :class => options[:class], :selected => value.month, :disabled => disabled)
      s << select_tag(:"#{name}[year]", :options => start_year.upto(end_year).map(&:to_s), :class => options[:class], :selected => value.year, :disabled => disabled)
      s << '</span>'
      s.join(' ')        
    end
    
    def datetime_select_tags(name, options={})      
      value = options[:value] || Time.zone.now
      disabled = options[:disabled] || false
      # options[:class]
      # options[:fives]
      s = []
      s << '<span class="time"> @ '
      s << select_tag(:"#{name}[hour]", :options => 0.upto(23).map { |x| [x < 10 ? "0#{x}" : "#{x}","#{x}"] }, :class => options[:class], :selected => value.hour, :disabled => disabled) 
      s << ':'
      s << select_tag(:"#{name}[min]", :options =>
          (options[:fives] ? 0.upto(11).map { |x| x*5 } : 0.upto(59) ).map { |x| [x < 10 ? "0#{x}" : "#{x}","#{x}"] },
        :class => options[:class], :selected => value.min, :disabled => disabled)
      s << '</span>'
      s.join(' ')      
      [date_select_tags(name, options), s].join(' ')
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