require 'set'
require File.dirname(__FILE__) + '/../data/csv_data_set'
require File.dirname(__FILE__) + '/../classifiers/classifier'

module Ai4r
  module Classifiers
    class Bayes < Classifier

      def initialize(data, m=0)
        raise "Error instance must be passed" unless data.is_a?(DataSet)

        @class_counts = []
        @class_prob = []
        @m = m
        @pcc = []
        @pcp = []
        @klass_index = {}
        @values = {}

        @data = data
        @domains = @data.build_domains

        build data
      end

      def eval(data)

        prob = @class_prob.map {|cp| cp}

        prob.each_with_index do |prob_entry, prob_index|
          data.each_with_index do |att, index|
            next if value_index(att, index).nil?
            prob[prob_index] *= @pcp[index][value_index(att, index)][prob_index]
          end
        end

        prob_sum = prob.inject(0){|b,i| b+i}

        # normalize probabilities to sum to 1
        if prob_sum > 0
          prob.each_with_index do |prob_entry, index|
            prob[index] /= prob_sum
          end
        end

        [index_to_klass(prob.index(prob.max)),prob.max]
      end

      def build(data)
        initialize_klass_index
        initialize_pc
        calculate_class_probabilities
      end

      private

      def index_to_klass(index)
        result = @klass_index.detect do |k,v|
          v == index          
        end
        result ? result.first : nil
      end

      def initialize_klass_index
        @data.klasses.each_with_index do |dl, index|
          @klass_index[dl] = index
        end

        @data.data_labels.each_with_index do |dl, index|
          @values[index] = {}
          @domains[index].each_with_index do |d, d_index|
            @values[index][d] = d_index
          end
        end
      end

      def klass_index(klass)
        @klass_index[klass]
      end

      def value_index(value, dl_index)
        @values[dl_index][value]
      end

      def build_array(dl, index)
        domains = Array.new(@domains[index].length)
        domains.each_with_index do |p1, d_index|
          domains[d_index] = Array.new @data.klasses.length, 0
        end
        domains
      end

      def initialize_pc
        @data.data_labels.each_with_index do |dl, index|
          @pcc << build_array(dl, index)
          @pcp << build_array(dl, index)

        end
      end

      def calculate_class_probabilities
        @data.klasses.each {|dl| @class_counts[klass_index(dl)] = 0}

        @data.data_items.each do |entry|
          @class_counts[klass_index(entry.klass)] += 1
        end

        @class_counts.each_with_index do |k, index|
          @class_prob[index] = k.to_f / @data.data_items.length
        end

        count_instances
        calculate_conditional_probabilities
      end

      def count_instances
        @data.data_items.each do |item|
          @data.data_labels.each_with_index do |dl, dl_index|
            @pcc[dl_index][value_index(item[dl_index], dl_index)][klass_index(item.klass)] += 1
          end
        end
      end

      def calculate_conditional_probabilities
        @pcc.each_with_index do |attributes, a_index|
          attributes.each_with_index do |values, v_index|
            values.each_with_index do |klass, k_index|
              @pcp[a_index][v_index][k_index] = (klass.to_f + @m * @class_prob[k_index]) / (@class_counts[k_index] + @m).to_f
            end
          end
        end
      end

    end
  end
end
