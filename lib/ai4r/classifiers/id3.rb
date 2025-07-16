# frozen_string_literal: true

# Author::    Sergio Fierens (Implementation, Quinlan is
# the creator of the algorithm)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/data_set'
require_relative '../classifiers/classifier'

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
    #           else
    #             raise 'There was not enough information during training to do '
    #                   'a proper induction for this data element'
    #           end
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
      attr_reader :data_set, :majority_class, :validation_set

      parameters_info max_depth: 'Maximum recursion depth. Default is nil (no limit).',
                      min_gain: 'Minimum information gain required to split. Default is 0.',
                      on_unknown: 'Behaviour when evaluating unseen attribute values: '

      # @return [Object]
      def initialize
        super()
        @max_depth = nil
        @min_gain = 0
        @on_unknown = :raise
      end

      # Create a new ID3 classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as the
      # item class.
      # @param data_set [Object]
      # @param options [Object]
      # @return [Object]
      def build(data_set, options = {})
        data_set.check_not_empty
        @data_set = data_set
        @validation_set = options[:validation_set]
        preprocess_data(@data_set.data_items)
        prune! if @validation_set
        self
      end

      # You can evaluate new data, predicting its category.
      # e.g.
      #   id3.eval(['New York',  '<30', 'F'])  # => 'Y'
      # @param data [Object]
      # @return [Object]
      def eval(data)
        @tree&.value(data, self)
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
      #           else
      #             raise 'There was not enough information during training to do '
      #                   'a proper induction for this data element'
      #           end
      #
      # It is a nice way to inspect induction results, and also to execute them:
      #     age_range = '<30'
      #     marketing_target = nil
      #     eval id3.get_rules
      #     puts marketing_target
      #       # =>  'Y'
      # @return [Object]
      def get_rules
        # return "Empty ID3 tree" if !@tree
        rules = @tree.get_rules
        rules = rules.collect do |rule|
          "#{rule[0..-2].join(' and ')} then #{rule.last}"
        end
        error_msg = 'There was not enough information during training to do a proper induction for this data element'
        "if #{rules.join("\nelsif ")}\nelse raise '#{error_msg}' end"
      end
      # rubocop:enable Naming/AccessorMethodName

      # Return a nested Hash representation of the decision tree.  This
      # structure can easily be converted to JSON or other formats.
      # Leaf nodes are represented by their category value, while internal
      # nodes are hashes keyed by attribute value.
      # @return [Object]
      def to_h
        @tree&.to_h
      end

      # Generate GraphViz DOT syntax describing the decision tree.  Nodes are
      # labeled with attribute names or category values and edges are labeled
      # with attribute values.
      # @return [Object]
      def to_graphviz
        return 'digraph G {}' unless @tree

        lines = ['digraph G {']
        @tree.to_graphviz(0, lines)
        lines << '}'
        lines.join("\n")
      end

      # Prune the decision tree using the validation set provided during build.
      # Subtrees are replaced by a single leaf when this increases the
      # classification accuracy on the validation data.
      # @return [Object]
      def prune!
        return self unless @validation_set

        @tree = prune_node(@tree, @validation_set.data_items)
        self
      end

      # @param data_examples [Object]
      # @return [Object]
      def preprocess_data(data_examples)
        @majority_class = most_freq(data_examples, domain(data_examples))
        @tree = build_node(data_examples, [], 0)
      end

      # @param data_examples [Object]
      # @param flag_att [Object]
      # @param depth [Object]
      # @return [Object]
      # rubocop:disable Metrics/MethodLength
      def build_node(data_examples, flag_att = [], depth = 0)
        return ErrorNode.new if data_examples.empty?

        domain = domain(data_examples)
        return CategoryNode.new(@data_set.category_label, domain.last[0]) if domain.last.length == 1

        if flag_att.length >= domain.length - 1
          return CategoryNode.new(@data_set.category_label,
                                  most_freq(data_examples,
                                            domain))
        end

        if @max_depth && depth >= @max_depth
          return CategoryNode.new(@data_set.category_label, most_freq(data_examples, domain))
        end

        best_index = nil
        best_entropy = nil
        best_split = nil
        best_threshold = nil
        numeric = false

        domain[0..-2].each_index do |index|
          next if flag_att.include?(index)

          if domain[index].all? { |v| v.is_a? Numeric }
            threshold, split, entropy = best_numeric_split(data_examples, index, domain)
            if best_entropy.nil? || entropy < best_entropy
              best_entropy = entropy
              best_index = index
              best_split = split
              best_threshold = threshold
              numeric = true
            end
          else
            freq_grid = freq_grid(index, data_examples, domain)
            entropy = entropy(freq_grid, data_examples.length)
            if best_entropy.nil? || entropy < best_entropy
              best_entropy = entropy
              best_index = index
              best_split = split_data_examples(data_examples, domain, index)
              numeric = false
            end
          end
          # rubocop:enable Metrics/ClassLength
        end

        gain = information_gain(data_examples, domain, best_index)
        if gain < @min_gain
          return CategoryNode.new(@data_set.category_label,
                                  most_freq(data_examples, domain))
        end
        if best_split.length == 1
          return CategoryNode.new(@data_set.category_label,
                                  most_freq(data_examples, domain))
        end

        nodes = best_split.collect do |partial_data_examples|
          build_node(partial_data_examples, numeric ? flag_att : [*flag_att, best_index], depth + 1)
        end
        majority = most_freq(data_examples, domain)

        if numeric
          EvaluationNode.new(@data_set.data_labels, best_index, best_threshold, nodes, true,
                             majority)
        else
          EvaluationNode.new(@data_set.data_labels, best_index, domain[best_index], nodes, false,
                             majority)
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

      # @param values [Object]
      # @return [Object]
      def self.sum(values)
        values.sum
      end

      # @param z [Object]
      # @return [Object]
      def self.log2(z)
        return 0.0 if z.zero?

        Math.log(z) / LOG2
      end

      private

      # @param examples [Object]
      # @param domain [Object]
      # @return [Object]
      def most_freq(examples, _domain)
        examples.map(&:last).tally.max_by { _2 }&.first
      end

      # @param data_examples [Object]
      # @param att_index [Object]
      # @return [Object]
      def split_data_examples_by_value(data_examples, att_index)
        att_value_examples = Hash.new { |hsh, key| hsh[key] = [] }
        data_examples.each do |example|
          att_value = example[att_index]
          att_value_examples[att_value] << example
        end
        att_value_examples
      end

      # @param data_examples [Object]
      # @param domain [Object]
      # @param att_index [Object]
      # @return [Object]
      def split_data_examples(data_examples, domain, att_index)
        att_value_examples = split_data_examples_by_value(data_examples, att_index)
        attribute_domain = domain[att_index]
        data_examples_array = []
        att_value_examples.each do |att_value, example_set|
          att_value_index = attribute_domain.index(att_value)
          data_examples_array[att_value_index] = example_set
        end
        data_examples_array
      end

      # @param data_examples [Object]
      # @param att_index [Object]
      # @param threshold [Object]
      # @return [Object]
      def split_data_examples_numeric(data_examples, att_index, threshold)
        lower = []
        higher = []
        data_examples.each do |example|
          if example[att_index] <= threshold
            lower << example
          else
            higher << example
          end
        end
        [lower, higher]
      end

      # @param data_examples [Object]
      # @param att_index [Object]
      # @return [Object]
      def candidate_thresholds(data_examples, att_index)
        values = data_examples.collect { |d| d[att_index] }.uniq.sort
        thresholds = []
        values.each_cons(2) { |a, b| thresholds << ((a + b) / 2.0) }
        thresholds
      end

      # @param split_data [Object]
      # @param domain [Object]
      # @return [Object]
      def entropy_for_numeric_split(split_data, domain)
        category_domain = domain.last
        grid = split_data.collect do |subset|
          counts = Array.new(category_domain.length, 0)
          subset.each do |example|
            cat_idx = category_domain.index(example.last)
            counts[cat_idx] += 1
          end
          counts
        end
        entropy(grid, split_data[0].length + split_data[1].length)
      end

      # @param data_examples [Object]
      # @param att_index [Object]
      # @param domain [Object]
      # @return [Object]
      def best_numeric_split(data_examples, att_index, domain)
        best_threshold = nil
        best_entropy = nil
        best_split = nil
        candidate_thresholds(data_examples, att_index).each do |threshold|
          split = split_data_examples_numeric(data_examples, att_index, threshold)
          e = entropy_for_numeric_split(split, domain)
          next unless best_entropy.nil? || e < best_entropy

          best_entropy = e
          best_threshold = threshold
          best_split = split
        end
        [best_threshold, best_split, best_entropy]
      end

      # @param data_examples [Object]
      # @param domain [Object]
      # @param flag_att [Object]
      # @return [Object]
      def min_entropy_index(data_examples, domain, flag_att = [])
        min_entropy = nil
        min_index = 0
        domain[0..-2].each_index do |index|
          next if flag_att.include?(index)

          freq_grid = freq_grid(index, data_examples, domain)
          entropy = entropy(freq_grid, data_examples.length)
          if !min_entropy || entropy < min_entropy
            min_entropy = entropy
            min_index = index
          end
        end
        min_index
      end

      # @param data_examples [Object]
      # @param domain [Object]
      # @param att_index [Object]
      # @return [Object]
      def information_gain(data_examples, domain, att_index)
        total_entropy = class_entropy(data_examples, domain)
        freq_grid_att = freq_grid(att_index, data_examples, domain)
        att_entropy = entropy(freq_grid_att, data_examples.length)
        total_entropy - att_entropy
      end

      # @param data_examples [Object]
      # @param domain [Object]
      # @return [Object]
      def class_entropy(data_examples, domain)
        category_domain = domain.last
        freqs = Array.new(category_domain.length, 0)
        data_examples.each do |ex|
          cat = ex.last
          idx = category_domain.index(cat)
          freqs[idx] += 1
        end
        entropy([freqs], data_examples.length)
      end

      # @param data_examples [Object]
      # @return [Object]
      def domain(data_examples)
        # return build_domains(data_examples)
        domain = Array.new(@data_set.data_labels.length) { [] }
        data_examples.each do |data|
          data.each_with_index do |att_value, i|
            domain[i] << att_value if i < domain.length && !domain[i].include?(att_value)
          end
        end
        domain
      end

      # @param att_index [Object]
      # @param data_examples [Object]
      # @param domain [Object]
      # @return [Object]
      def freq_grid(att_index, data_examples, domain)
        # Initialize empty grid
        feature_domain = domain[att_index]
        category_domain = domain.last
        grid = Array.new(feature_domain.length) { Array.new(category_domain.length, 0) }
        # Fill frecuency with grid
        data_examples.each do |example|
          att_val = example[att_index]
          att_val_index = feature_domain.index(att_val)
          category = example.last
          category_index = category_domain.index(category)
          grid[att_val_index][category_index] += 1
        end
        grid
      end

      # @param freq_grid [Object]
      # @param total_examples [Object]
      # @return [Object]
      def entropy(freq_grid, total_examples)
        # Calc entropy of each element
        entropy = 0
        freq_grid.each do |att_freq|
          att_total_freq = ID3.sum(att_freq)
          partial_entropy = 0
          unless att_total_freq.zero?
            att_freq.each do |freq|
              prop = freq.to_f / att_total_freq
              partial_entropy += (-1 * prop * ID3.log2(prop))
            end
          end
          entropy += (att_total_freq.to_f / total_examples) * partial_entropy
        end
        entropy
      end

      # @param node [Object]
      # @param examples [Object]
      # @return [Object]
      def prune_node(node, examples)
        return node if node.is_a?(CategoryNode) || node.is_a?(ErrorNode)

        subsets = split_examples(node, examples)

        node.nodes.each_with_index do |child, i|
          node.nodes[i] = prune_node(child, subsets[i])
        end

        leaf = CategoryNode.new(@data_set.category_label, node.majority)
        replace_with_leaf?(leaf, node, examples) ? leaf : node
      end

      def split_examples(node, examples)
        if node.numeric
          Array.new(2) { [] }.tap do |subsets|
            examples.each do |ex|
              idx = ex[node.index] <= node.threshold ? 0 : 1
              subsets[idx] << ex
            end
          end
        else
          Array.new(node.values.length) { [] }.tap do |subsets|
            examples.each do |ex|
              idx = node.values.index(ex[node.index])
              subsets[idx] << ex if idx
            end
          end
        end
      end

      def replace_with_leaf?(leaf, node, examples)
        before = accuracy_for_node(node, examples)
        after  = accuracy_for_node(leaf, examples)
        after && before && after >= before
      end

      # @param node [Object]
      # @param examples [Object]
      # @return [Object]
      def accuracy_for_node(node, examples)
        return nil if examples.empty?

        correct = examples.count do |ex|
          node.value(ex[0..-2], self) == ex.last
        end
        correct.to_f / examples.length
      end

      LOG2 = Math.log(2)
    end

    class EvaluationNode # :nodoc: all
      attr_reader :index, :values, :nodes, :numeric, :threshold, :majority

      # @param data_labels [Object]
      # @param index [Object]
      # @param values_or_threshold [Object]
      # @param nodes [Object]
      # @param numeric [Object]
      # @param majority [Object]
      # @return [Object]
      # rubocop:disable Style/OptionalBooleanParameter
      def initialize(data_labels, index, values_or_threshold, nodes, numeric = false,
                     majority = nil)
        @index = index
        @numeric = numeric
        if numeric
          @threshold = values_or_threshold
          @values = nil
        else
          @values = values_or_threshold
        end
        @nodes = nodes
        @majority = majority
        @data_labels = data_labels
      end
      # rubocop:enable Metrics/ParameterLists, Style/OptionalBooleanParameter

      # @param data [Object]
      # @param classifier [Object]
      # @return [Object]
      def value(data, classifier = nil)
        value = data[@index]
        if @numeric
          node = value <= @threshold ? @nodes[0] : @nodes[1]
          node.value(data, classifier)
        else
          unless @values.include?(value)
            return nil if classifier&.on_unknown == :nil
            return @majority if classifier&.on_unknown == :most_frequent

            return ErrorNode.new.value(data, classifier)
          end
          @nodes[@values.index(value)].value(data, classifier)
        end
      end

      # @return [Object]
      # rubocop:disable Naming/AccessorMethodName
      def get_rules
        rule_set = []
        @nodes.each_with_index do |child_node, child_node_index|
          if @numeric
            op = child_node_index.zero? ? '<=' : '>'
            my_rule = "#{@data_labels[@index]} #{op} #{@threshold}"
          else
            my_rule = "#{@data_labels[@index]}=='#{@values[child_node_index]}'"
          end
          child_node_rules = child_node.get_rules
          child_node_rules.each do |child_rule|
            child_rule.unshift(my_rule)
          end
          rule_set += child_node_rules
        end
        rule_set
      end
      # rubocop:enable Naming/AccessorMethodName

      # @return [Object]
      def to_h
        hash = {}
        @nodes.each_with_index do |child, i|
          hash[@values[i]] = child.to_h
        end
        { @data_labels[@index] => hash }
      end

      # @param id [Object]
      # @param lines [Object]
      # @param parent [Object]
      # @param edge_label [Object]
      # @return [Object]
      def to_graphviz(id, lines, parent = nil, edge_label = nil)
        my_id = id
        lines << "  node#{my_id} [label=\"#{@data_labels[@index]}\"]"
        lines << "  node#{parent} -> node#{my_id} [label=\"#{edge_label}\"]" if parent
        next_id = my_id
        @nodes.each_with_index do |child, idx|
          next_id += 1
          next_id = child.to_graphviz(next_id, lines, my_id, @values[idx])
        end
        next_id
      end
    end

    class CategoryNode # :nodoc: all
      # @param label [Object]
      # @param value [Object]
      # @return [Object]
      def initialize(label, value)
        @label = label
        @value = value
      end

      # @param data [Object]
      # @param classifier [Object]
      # @return [Object]
      def value(_data, _classifier = nil)
        @value
      end

      # @return [Object]
      # rubocop:disable Naming/AccessorMethodName
      def get_rules
        [["#{@label}='#{@value}'"]]
      end
      # rubocop:enable Naming/AccessorMethodName

      # @return [Object]
      def to_h
        @value
      end

      # @param id [Object]
      # @param lines [Object]
      # @param parent [Object]
      # @param edge_label [Object]
      # @return [Object]
      def to_graphviz(id, lines, parent = nil, edge_label = nil)
        my_id = id
        lines << "  node#{my_id} [label=\"#{@value}\", shape=box]"
        lines << "  node#{parent} -> node#{my_id} [label=\"#{edge_label}\"]" if parent
        my_id
      end
    end

    # Raised when the training data is insufficient to build a model.
    class ModelFailureError < StandardError
      MSG = 'There was not enough information during training to do a proper ' \
            'induction for this data element.'
    end

    class ErrorNode # :nodoc: all
      # @param data [Object]
      # @param classifier [Object]
      # @return [Object]
      def value(data, _classifier = nil)
        raise ModelFailureError, "#{ModelFailureError::MSG} for the data element #{data}."
      end

      # @return [Object]
      # rubocop:disable Naming/AccessorMethodName
      def get_rules
        []
      end
      # rubocop:enable Naming/AccessorMethodName

      # @return [Object]
      def to_h
        nil
      end

      # @param id [Object]
      # @param lines [Object]
      # @param parent [Object]
      # @param edge_label [Object]
      # @return [Object]
      def to_graphviz(id, lines, parent = nil, edge_label = nil)
        my_id = id
        lines << "  node#{my_id} [label=\"?\", shape=box]"
        lines << "  node#{parent} -> node#{my_id} [label=\"#{edge_label}\"]" if parent
        my_id
      end
    end
  end
end
