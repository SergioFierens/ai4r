# frozen_string_literal: true

# RSpec tests for AI4R Parameterizable module based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

# Create a test class that includes Parameterizable for testing
class ParameterizableTestClass
  include Ai4r::Data::Parameterizable
end

RSpec.describe Ai4r::Data::Parameterizable do
  let(:test_object) { ParameterizableTestClass.new }
  
  describe "Parameter Management Tests" do
    context "basic parameter operations" do
      it "test_set_single_parameter" do
        # Should allow setting single parameter
        test_object.set_parameters(learning_rate: 0.5)
        
        expect(test_object.get_parameters).to include(learning_rate: 0.5)
      end
      
      it "test_set_multiple_parameters" do
        # Should allow setting multiple parameters at once
        params = {
          learning_rate: 0.3,
          momentum: 0.9,
          max_iterations: 1000
        }
        
        test_object.set_parameters(params)
        
        result = test_object.get_parameters
        expect(result).to include(params)
      end
    end
    
    context "parameter validation" do
      it "test_parameter_types" do
        # Should handle different parameter types correctly
        mixed_params = {
          learning_rate: 0.5,      # Float
          iterations: 100,         # Integer
          use_bias: true,          # Boolean
          method: 'gradient',      # String
          layers: [10, 5, 1]       # Array
        }
        
        test_object.set_parameters(mixed_params)
        
        result = test_object.get_parameters
        expect(result[:learning_rate]).to be_a(Float)
        expect(result[:iterations]).to be_a(Integer)
        expect(result[:use_bias]).to be_a(TrueClass)
        expect(result[:method]).to be_a(String)
        expect(result[:layers]).to be_an(Array)
      end
      
      it "test_parameter_update" do
        # Should allow updating existing parameters
        test_object.set_parameters(learning_rate: 0.1)
        expect(test_object.get_parameters[:learning_rate]).to eq(0.1)
        
        # Update the parameter
        test_object.set_parameters(learning_rate: 0.2)
        expect(test_object.get_parameters[:learning_rate]).to eq(0.2)
        
        # Other parameters should remain unchanged if set
        test_object.set_parameters(momentum: 0.9)
        test_object.set_parameters(learning_rate: 0.3)
        
        params = test_object.get_parameters
        expect(params[:learning_rate]).to eq(0.3)
        expect(params[:momentum]).to eq(0.9)
      end
    end
  end
  
  describe "Integration Tests" do
    it "provides consistent parameter interface" do
      # Parameterizable should provide consistent interface across AI4R
      expect(test_object).to respond_to(:set_parameters)
      expect(test_object).to respond_to(:get_parameters)
      
      # Should handle empty parameters gracefully
      empty_params = test_object.get_parameters
      expect(empty_params).to be_a(Hash)
      
      # Should allow chaining if implemented
      result = test_object.set_parameters(test_param: 'value')
      # Result should be the object itself or parameters
      expect(result).not_to be_nil
    end
    
    it "works with algorithm-specific parameters" do
      # Test with parameters typical for different AI4R algorithms
      neural_network_params = {
        learning_rate: 0.01,
        momentum: 0.9,
        hidden_layers: [10, 5],
        activation: 'sigmoid'
      }
      
      test_object.set_parameters(neural_network_params)
      
      genetic_algorithm_params = {
        population_size: 100,
        mutation_rate: 0.1,
        crossover_rate: 0.8,
        max_generations: 1000
      }
      
      test_object.set_parameters(genetic_algorithm_params)
      
      # Should contain all parameters
      all_params = test_object.get_parameters
      expect(all_params).to include(neural_network_params)
      expect(all_params).to include(genetic_algorithm_params)
    end
    
    it "maintains parameter isolation" do
      # Multiple instances should have separate parameters
      test_object1 = ParameterizableTestClass.new
      test_object2 = ParameterizableTestClass.new
      
      test_object1.set_parameters(param1: 'value1')
      test_object2.set_parameters(param2: 'value2')
      
      params1 = test_object1.get_parameters
      params2 = test_object2.get_parameters
      
      expect(params1).to include(param1: 'value1')
      expect(params1).not_to include(param2: 'value2')
      
      expect(params2).to include(param2: 'value2')
      expect(params2).not_to include(param1: 'value1')
    end
    
    it "handles edge cases gracefully" do
      # Should handle nil parameters
      expect {
        test_object.set_parameters(nil_param: nil)
      }.not_to raise_error
      
      # Should handle empty hash
      expect {
        test_object.set_parameters({})
      }.not_to raise_error
      
      # Should handle symbol and string keys consistently
      test_object.set_parameters('string_key' => 'value1')
      test_object.set_parameters(symbol_key: 'value2')
      
      params = test_object.get_parameters
      expect(params.length).to be >= 2
    end
  end
  
  describe "Performance Tests" do
    it "handles large parameter sets efficiently" do
      # Test with many parameters
      large_params = {}
      100.times do |i|
        large_params["param_#{i}".to_sym] = rand(1000)
      end
      
      benchmark_performance("Setting 100 parameters") do
        test_object.set_parameters(large_params)
      end
      
      benchmark_performance("Getting 100 parameters") do
        result = test_object.get_parameters
        expect(result.length).to be >= 100
      end
    end
  end
end