module ActivateAdmin
  module ParamHelpers

    def fix_params!
      datetime_hashes_to_datetimes!(params)
      file_hashes_to_files!(params)
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
    
    def file_hashes_to_files!(hash)
      hash.each { |k, v|
        if v.is_a?(Hash) and v[:tempfile]
          hash[k] = v[:tempfile]
        elsif v.is_a?(Hash)
          file_hashes_to_files!(v)
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