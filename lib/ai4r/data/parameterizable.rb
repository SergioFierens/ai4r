# frozen_string_literal: true

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
        # @return [Object]
        def get_parameters_info
          @_params_info_ || {}
        end

        # Set info on what can be parameterized on this algorithm.
        # You must provide a hash with the following format:
        # { :param_name => "Info on the parameter" }
        # @param params_info [Object]
        # @return [Object]
        def parameters_info(params_info)
          @_params_info_ = get_parameters_info.merge(params_info)
          params_info.each_key do |param|
            attr_accessor param
          end
        end
      end

      # Set parameter values on this algorithm instance.
      # You must provide a hash with the folowing format:
      # { :param_name => parameter_value }
      # @param params [Object]
      # @return [Object]
      def set_parameters(params)
        params.each do |key, val|
          public_send("#{key}=", val) if respond_to?("#{key}=")
        end
        self
      end

      # Get parameter values on this algorithm instance.
      # Returns a hash with the folowing format:
      # { :param_name => parameter_value }
      # @return [Object]
      def get_parameters
        params = {}
        self.class.get_parameters_info.each_key do |key|
          params[key] = send(key) if respond_to?(key)
        end
        params
      end

      # @param base [Object]
      # @return [Object]
      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
