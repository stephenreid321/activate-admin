module Activate
  module ParamHelpers

    def fix_params!
      datetime_hashes_to_datetimes!(params)      
      date_hashes_to_dates!(params)      
      file_hashes_to_files!(params)
      coordinate_hashes_to_coordinates!(params)
      blanks_to_nils!(params)    
    end
  
    def datetime_hashes_to_datetimes!(hash)
      hash.each { |k,v|
        if v.is_a?(Hash) and [:year, :month, :day, :hour, :min].all? { |x| v.has_key?(x.to_s) }
          hash[k] = Time.zone.local(v[:year].to_i, v[:month].to_i, v[:day].to_i, v[:hour].to_i, v[:min].to_i)
        elsif v.is_a?(Hash)
          datetime_hashes_to_datetimes!(v)
        end
      }
    end
    
    def date_hashes_to_dates!(hash)
      hash.each { |k,v|
        if v.is_a?(Hash) and [:year, :month, :day].all? { |x| v.has_key?(x.to_s) }
          hash[k] = Date.new(v[:year].to_i, v[:month].to_i, v[:day].to_i)
        elsif v.is_a?(Hash)
          date_hashes_to_dates!(v)
        end
      }
    end
    
    def file_hashes_to_files!(hash)
      hash.each { |k, v|
        if v.is_a?(Hash) and v[:tempfile]
          tempfile = v[:tempfile]
          tempfile.original_filename = v[:filename]
          hash[k] = tempfile
        elsif v.is_a?(Hash)
          file_hashes_to_files!(v)
        end
      }
    end
    
    def coordinate_hashes_to_coordinates!(hash)
      hash.each { |k,v|
        if v.is_a?(Hash) and [:lat, :lng].all? { |x| v.has_key?(x.to_s) }
          hash[k] = [v[:lng].to_f, v[:lat].to_f]
        elsif v.is_a?(Hash)
          coordinate_hashes_to_coordinates!(v)
        end
      }
    end    
  
    def blanks_to_nils!(hash)   
      hash.each { |k,v|
        if v.blank?
          hash[k] = nil
        elsif v.is_a? Array
          v.each_with_index { |x,i| v[i] = nil if x.blank? }.compact!
        elsif v.is_a? Hash
          blanks_to_nils!(v)
        end
      }
    end

  end
end

class Tempfile  
  attr_accessor :original_filename
end