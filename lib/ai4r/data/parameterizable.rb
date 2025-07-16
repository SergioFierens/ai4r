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
        def get_parameters_info
          return @_params_info_ || {}
        end

        # Set info on what can be parameterized on this algorithm.
        # You must provide a hash with the following format:
        # { :param_name => "Info on the parameter" }
        def parameters_info(params_info)
          @_params_info_ = params_info
          params_info.each_key do |param|
            attr_accessor param
          end
        end
      end

      # Set parameter values on this algorithm instance.
      # You must provide a hash with the folowing format:
      # { :param_name => parameter_value }
      def set_parameters(params)
        raise ArgumentError, 'Parameters must be a Hash' unless params.is_a?(Hash)

        self.class.get_parameters_info.each_key do |key|
          next unless respond_to?(:"#{key}=")

          next unless params.key? key

          value = params[key]
          # Basic type validation
          validate_parameter(key, value)
          send(:"#{key}=", value)
        end
        return self
      end

      private

      # Basic parameter validation
      def validate_parameter(key, value)
        case key
        when :max_iterations
          unless value.nil? || (value.is_a?(Integer) && value > 0)
            raise ArgumentError, 'max_iterations must be a positive integer or nil'
          end
        when :learning_rate
          raise ArgumentError, 'learning_rate must be a positive number' unless value.is_a?(Numeric) && value > 0
        when :momentum
          unless value.is_a?(Numeric) && value >= 0 && value <= 1
            raise ArgumentError, 'momentum must be a number between 0 and 1'
          end
        when :distance_function
          raise ArgumentError, 'distance_function must be callable' unless value.nil? || value.respond_to?(:call)
        when :propagation_function, :derivative_propagation_function, :initial_weight_function
          raise ArgumentError, "#{key} must be callable" unless value.nil? || value.respond_to?(:call)
        end
      end

      public

      # Get parameter values on this algorithm instance.
      # Returns a hash with the folowing format:
      # { :param_name => parameter_value }
      def get_parameters
        params = {}
        self.class.get_parameters_info.each_key do |key|
          params[key] = send(key) if respond_to?(key)
        end
        return params
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
