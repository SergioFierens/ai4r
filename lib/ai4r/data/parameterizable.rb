# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

module Ai4r
  module Data
    module Parameterizable
	
      module ClassMethods
        
        # Get info on what can be parameterized on this algorithm.
        # It returns a hash with the following format:
        # { :param_name => "Info on the parameter" }
        def get_parameters_info
          return @_params_info_ || {}
        end
        
        # Set info on what can be parameterized on this algorithm.
        # You must provide a hash with the following format:
        # { :param_name => "Info on the parameter" }        
        def parameters_info(params_info)
          @_params_info_ = params_info
          params_info.keys.each do |param|
            attr_accessor param
          end
        end
      end
  
      # Set parameter values on this algorithm instance.
      # You must provide a hash with the folowing format:
      # { :param_name => parameter_value }
      def set_parameters(params)
        self.class.get_parameters_info.keys.each do | key |
          if self.respond_to?("#{key}=".to_sym)
            send("#{key}=".to_sym, params[key]) if params.has_key? key
          end
        end
        return self
      end
      
      # Get parameter values on this algorithm instance.
      # Returns a hash with the folowing format:
      # { :param_name => parameter_value }
      def get_parameters
        params = {}
        self.class.get_parameters_info.keys.each do | key |
          params[key] = send(key) if self.respond_to?(key)
        end
        return params
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
  
    end
  end
end

