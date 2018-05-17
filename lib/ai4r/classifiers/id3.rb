# Author::    Sergio Fierens (Implementation, Quinlan is 
# the creator of the algorithm)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/data_set'
require File.dirname(__FILE__) + '/../classifiers/classifier'

module Ai4r
  
  module Classifiers

    # = Introduction
    # This is an implementation of the ID3 algorithm (Quinlan) 
    # Given a set of preclassified examples, it builds a top-down 
    # induction of decision tree, biased by the information gain and 
    # entropy measure.
    #
    # * http://en.wikipedia.org/wiki/Decision_tree
    # * http://en.wikipedia.org/wiki/ID3_algorithm
    #
    # = How to use it
    #   
    #   DATA_LABELS = [ 'city', 'age_range', 'gender', 'marketing_target'  ]
    #
    #   DATA_ITEMS = [  
    #          ['New York',  '<30',      'M', 'Y'],
    #          ['Chicago',     '<30',      'M', 'Y'],
    #          ['Chicago',     '<30',      'F', 'Y'],
    #          ['New York',  '<30',      'M', 'Y'],
    #          ['New York',  '<30',      'M', 'Y'],
    #          ['Chicago',     '[30-50)',  'M', 'Y'],
    #          ['New York',  '[30-50)',  'F', 'N'],
    #          ['Chicago',     '[30-50)',  'F', 'Y'],
    #          ['New York',  '[30-50)',  'F', 'N'],
    #          ['Chicago',     '[50-80]', 'M', 'N'],
    #          ['New York',  '[50-80]', 'F', 'N'],
    #          ['New York',  '[50-80]', 'M', 'N'],
    #          ['Chicago',     '[50-80]', 'M', 'N'],
    #          ['New York',  '[50-80]', 'F', 'N'],
    #          ['Chicago',     '>80',      'F', 'Y']
    #        ]
    #   
    #   data_set = DataSet.new(:data_items=>DATA_SET, :data_labels=>DATA_LABELS)
    #   id3 = Ai4r::Classifiers::ID3.new.build(data_set)
    #   
    #   id3.get_rules
    #     # =>  if age_range=='<30' then marketing_target='Y'
    #           elsif age_range=='[30-50)' and city=='Chicago' then marketing_target='Y'
    #           elsif age_range=='[30-50)' and city=='New York' then marketing_target='N'
    #           elsif age_range=='[50-80]' then marketing_target='N'
    #           elsif age_range=='>80' then marketing_target='Y'
    #           else raise 'There was not enough information during training to do a proper induction for this data element' end
    #   
    #   id3.eval(['New York', '<30', 'M'])
    #     # =>  'Y'
    #   
    # = A better way to load the data  
    # 
    # In the real life you will use lot more data training examples, with more
    # attributes. Consider moving your data to an external CSV (comma separate 
    # values) file.
    #                 
    #   data_file = "#{File.dirname(__FILE__)}/data_set.csv"
    #   data_set = DataSet.load_csv_with_labels data_file
    #   id3 = Ai4r::Classifiers::ID3.new.build(data_set)      
    #   
    # = A nice tip for data evaluation
    # 
    #   id3 = Ai4r::Classifiers::ID3.new.build(data_set)
    #
    #   age_range = '<30'
    #   marketing_target = nil
    #   eval id3.get_rules   
    #   puts marketing_target
    #     # =>  'Y'  
    #
    # = More about ID3 and decision trees
    # 
    # * http://en.wikipedia.org/wiki/Decision_tree
    # * http://en.wikipedia.org/wiki/ID3_algorithm
    #   
    # = About the project
    # Author::    Sergio Fierens
    # License::   MPL 1.1
    # Url::       https://github.com/SergioFierens/ai4r
    class ID3 < Classifier
      
      attr_reader :data_set
       
      # Create a new ID3 classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as the
      # item class.
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        preprocess_data(@data_set.data_items)
        return self
      end

      # You can evaluate new data, predicting its category.
      # e.g.
      #   id3.eval(['New York',  '<30', 'F'])  # => 'Y'
      def eval(data)
        @tree.value(data) if @tree
      end

      # This method returns the generated rules in ruby code.
      # e.g.
      #   
      #   id3.get_rules
      #     # =>  if age_range=='<30' then marketing_target='Y'
      #           elsif age_range=='[30-50)' and city=='Chicago' then marketing_target='Y'
      #           elsif age_range=='[30-50)' and city=='New York' then marketing_target='N'
      #           elsif age_range=='[50-80]' then marketing_target='N'
      #           elsif age_range=='>80' then marketing_target='Y'
      #           else raise 'There was not enough information during training to do a proper induction for this data element' end
      #
      # It is a nice way to inspect induction results, and also to execute them:  
      #     age_range = '<30'
      #     marketing_target = nil
      #     eval id3.get_rules   
      #     puts marketing_target
      #       # =>  'Y'
      def get_rules
        #return "Empty ID3 tree" if !@tree
        rules = @tree.get_rules
        rules = rules.collect do |rule|
          "#{rule[0..-2].join(' and ')} then #{rule.last}"
        end
        return "if #{rules.join("\nelsif ")}\nelse raise 'There was not enough information during training to do a proper induction for this data element' end"
      end

      private
      def preprocess_data(data_examples)
        @tree = build_node(data_examples)
      end

      private
      def build_node(data_examples, flag_att = [])
        return ErrorNode.new if data_examples.length == 0
        domain = domain(data_examples)   
        return CategoryNode.new(@data_set.category_label, domain.last[0]) if domain.last.length == 1
        min_entropy_index = min_entropy_index(data_examples, domain, flag_att)
        split_data_examples = split_data_examples(data_examples, domain, min_entropy_index)
        return CategoryNode.new(@data_set.category_label, most_freq(data_examples, domain)) if split_data_examples.length == 1
        nodes = split_data_examples.collect do |partial_data_examples|  
          build_node(partial_data_examples, [*flag_att, min_entropy_index])
        end
        return EvaluationNode.new(@data_set.data_labels, min_entropy_index, domain[min_entropy_index], nodes)
      end

      private 
      def self.sum(values)
        values.inject( 0 ) { |sum,x| sum+x }
      end

      private
      def self.log2(z)
        return 0.0 if z == 0
        Math.log(z)/LOG2
      end

      private       
      def most_freq(examples, domain)
        category_domain = domain.last
        freqs = Array.new(category_domain.length, 0)
        examples.each do |example|
          example_category = example.last
          cat_index = category_domain.index(example_category)
          freqs[cat_index] += 1
        end
        max_freq = freqs.max
        max_freq_index = freqs.index(max_freq)
        category_domain[max_freq_index]
      end

      private
      def split_data_examples_by_value(data_examples, att_index)
        att_value_examples = Hash.new {|hsh,key| hsh[key] = [] }
        data_examples.each do |example|
          att_value = example[att_index]
          att_value_examples[att_value] << example
        end
        att_value_examples
      end

      private
      def split_data_examples(data_examples, domain, att_index)
        att_value_examples = split_data_examples_by_value(data_examples, att_index)
        attribute_domain = domain[att_index]
        data_examples_array = []
        att_value_examples.each do |att_value, example_set|
           att_value_index = attribute_domain.index(att_value)
           data_examples_array[att_value_index] = example_set
        end
        return data_examples_array
      end

      private 
      def min_entropy_index(data_examples, domain, flag_att=[])
        min_entropy = nil
        min_index = 0
        domain[0..-2].each_index do |index|
          unless flag_att.include?(index)
            freq_grid = freq_grid(index, data_examples, domain)
            entropy = entropy(freq_grid, data_examples.length)
            if (!min_entropy || entropy < min_entropy)
              min_entropy = entropy
              min_index = index
            end
          end
        end
        return min_index
      end

      private
      def domain(data_examples)
        #return build_domains(data_examples)
        domain = Array.new( @data_set.data_labels.length ) { [] }
        data_examples.each do |data|
          data.each_with_index do |att_value, i|
            domain[i] << att_value if i<domain.length && !domain[i].include?(att_value)
          end
        end
        return domain
      end
       
      private 
      def freq_grid(att_index, data_examples, domain)
        #Initialize empty grid
        feature_domain = domain[att_index]
        category_domain = domain.last
        grid = Array.new(feature_domain.length) { Array.new(category_domain.length, 0) }
        #Fill frecuency with grid
        data_examples.each do |example|
          att_val = example[att_index]
          att_val_index = feature_domain.index(att_val)
          category = example.last
          category_index = category_domain.index(category)
          grid[att_val_index][category_index] += 1
        end
        return grid
      end

      private 
      def entropy(freq_grid, total_examples)
        #Calc entropy of each element
        entropy = 0
        freq_grid.each do |att_freq|
          att_total_freq = ID3.sum(att_freq)
          partial_entropy = 0
          unless att_total_freq == 0
            att_freq.each do |freq|
              prop = freq.to_f/att_total_freq
              partial_entropy += (-1*prop*ID3.log2(prop))
            end
          end
          entropy += (att_total_freq.to_f/total_examples) * partial_entropy
        end
        return entropy
      end

      private
      LOG2 = Math.log(2)
    end

    class EvaluationNode #:nodoc: all
      
      attr_reader :index, :values, :nodes
      
      def initialize(data_labels, index, values, nodes)
        @index = index
        @values = values
        @nodes = nodes
        @data_labels = data_labels
      end
      
      def value(data)
        value = data[@index]
        return ErrorNode.new.value(data) unless @values.include?(value)
        return nodes[@values.index(value)].value(data)
      end
      
      def get_rules
        rule_set = []
        @nodes.each_with_index do |child_node, child_node_index|
          my_rule = "#{@data_labels[@index]}=='#{@values[child_node_index]}'"
          child_node_rules = child_node.get_rules
          child_node_rules.each do |child_rule|
            child_rule.unshift(my_rule)
          end
          rule_set += child_node_rules
        end
        return rule_set
      end
      
    end

    class CategoryNode #:nodoc: all
      def initialize(label, value)
        @label = label
        @value = value
      end
      def value(data)
        return @value
      end
      def get_rules
        return [["#{@label}='#{@value}'"]]
      end
    end

    class ModelFailureError < StandardError
      default_message = "There was not enough information during training to do a proper induction for this data element."
    end

    class ErrorNode #:nodoc: all
      def value(data)
        raise ModelFailureError, "There was not enough information during training to do a proper induction for the data element #{data}."
      end
      def get_rules
        return []
      end
    end

  end
end
