# frozen_string_literal: true

# Educational implementations of classification algorithms with step-by-step execution
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'educational_classification'
require_relative 'id3'
require_relative 'naive_bayes'
require_relative 'multilayer_perceptron'
require_relative 'one_r'
require_relative 'zero_r'

module Ai4r
  module Classifiers
    # Educational ID3 implementation with step-by-step execution
    class EducationalID3 < ID3
      def initialize(configuration, monitor)
        super()
        @configuration = configuration
        @monitor = monitor
      end

      def build_with_steps(data_set, &block)
        @data_set = data_set
        data_set.check_not_empty

        # Step 1: Initialize data
        yield({
          step: 1,
          type: :initialization,
          description: 'Initialize decision tree construction',
          details: "Dataset contains #{data_set.data_items.length} examples with #{data_set.data_labels.length - 1} attributes"
        })

        # Step 2: Build tree with detailed steps
        @tree = build_tree_with_steps(data_set.data_items, [], 2, &block)

        # Final step
        yield({
          step: 999,
          type: :completion,
          description: 'Decision tree construction complete',
          details: "Tree has #{count_nodes(@tree)} nodes with #{count_leaves(@tree)} leaf nodes"
        })

        self
      end

      def build(data_set)
        @data_set = data_set
        data_set.check_not_empty
        preprocess_data(data_set.data_items)
        self
      end

      private

      def build_tree_with_steps(data_examples, used_attributes, step_number, &block)
        # Check for base cases
        return ErrorNode.new if data_examples.nil? || data_examples.empty?

        domain = domain(data_examples)

        # Pure node (all examples have same class)
        if domain.last.length == 1
          class_name = domain.last.first
          yield({
            step: step_number,
            type: :leaf_creation,
            description: 'Create leaf node',
            details: "All #{data_examples.length} examples belong to class '#{class_name}'"
          })
          return CategoryNode.new(@data_set.category_label, class_name)
        end

        # Find best attribute to split on
        best_attribute_index = find_best_attribute_with_steps(data_examples, domain, used_attributes, step_number,
                                                              &block)

        # Check if we can split further
        if used_attributes.include?(best_attribute_index)
          most_common_class = most_freq(data_examples, domain)
          yield({
            step: step_number + 1,
            type: :leaf_creation,
            description: 'Create leaf node (no more attributes)',
            details: "Cannot split further, choosing most frequent class: '#{most_common_class}'"
          })
          return CategoryNode.new(@data_set.category_label, most_common_class)
        end

        # Split data by best attribute
        split_data_examples = split_data_examples(data_examples, domain, best_attribute_index)

        if split_data_examples.length == 1
          most_common_class = most_freq(data_examples, domain)
          yield({
            step: step_number + 2,
            type: :leaf_creation,
            description: 'Create leaf node (no useful split)',
            details: "Split doesn't improve purity, choosing most frequent class: '#{most_common_class}'"
          })
          return CategoryNode.new(@data_set.category_label, most_common_class)
        end

        # Create internal node
        attribute_name = @data_set.data_labels[best_attribute_index]
        yield({
          step: step_number + 3,
          type: :internal_node_creation,
          description: 'Create internal node',
          details: "Splitting on attribute '#{attribute_name}' with #{split_data_examples.length} branches"
        })

        # Recursively build child nodes
        child_nodes = split_data_examples.map.with_index do |subset, index|
          if subset && !subset.empty?
            build_tree_with_steps(subset, used_attributes + [best_attribute_index], step_number + 10 + (index * 10),
                                  &block)
          else
            most_common_class = most_freq(data_examples, domain)
            CategoryNode.new(@data_set.category_label, most_common_class)
          end
        end

        EvaluationNode.new(@data_set.data_labels, best_attribute_index, domain[best_attribute_index], child_nodes)
      end

      def find_best_attribute_with_steps(data_examples, domain, used_attributes, step_number)
        best_attribute = nil
        best_information_gain = -1
        best_index = 0

        yield({
          step: step_number,
          type: :attribute_evaluation,
          description: 'Evaluate attributes for splitting',
          details: "Calculating information gain for #{domain.length - 1} attributes"
        })

        domain[0...-1].each_with_index do |_attribute_domain, index|
          next if used_attributes.include?(index)

          # Calculate information gain
          freq_grid = freq_grid(index, data_examples, domain)
          current_entropy = entropy(freq_grid, data_examples.length)
          information_gain = calculate_information_gain(data_examples, freq_grid, current_entropy)

          attribute_name = @data_set.data_labels[index]

          if @configuration.verbose
            puts "    Attribute '#{attribute_name}': Information Gain = #{information_gain.round(4)}"
          end

          next unless information_gain > best_information_gain

          best_information_gain = information_gain
          best_attribute = attribute_name
          best_index = index
        end

        yield({
          step: step_number + 1,
          type: :best_attribute_selection,
          description: 'Select best attribute for splitting',
          details: "Chosen attribute: '#{best_attribute}' with information gain: #{best_information_gain.round(4)}",
          attribute: best_attribute,
          information_gain: best_information_gain
        })

        best_index
      end

      def calculate_information_gain(data_examples, _freq_grid, current_entropy)
        # Calculate entropy before split
        class_counts = Hash.new(0)
        data_examples.each { |example| class_counts[example.last] += 1 }

        total_entropy = 0
        class_counts.each_value do |count|
          probability = count.to_f / data_examples.length
          total_entropy -= probability * Math.log2(probability) if probability > 0
        end

        # Information gain = entropy before split - weighted entropy after split
        total_entropy - current_entropy
      end

      def count_nodes(node)
        return 1 if node.nil? || node.is_a?(CategoryNode) || node.is_a?(ErrorNode)

        if node.is_a?(EvaluationNode)
          1 + node.nodes.sum { |child| count_nodes(child) }
        else
          1
        end
      end

      def count_leaves(node)
        return 1 if node.nil? || node.is_a?(CategoryNode) || node.is_a?(ErrorNode)

        if node.is_a?(EvaluationNode)
          node.nodes.sum { |child| count_leaves(child) }
        else
          0
        end
      end
    end

    # Educational Naive Bayes implementation with step-by-step execution
    class EducationalNaiveBayes < NaiveBayes
      def initialize(configuration, monitor)
        super()
        @configuration = configuration
        @monitor = monitor
      end

      def build_with_steps(data_set)
        raise 'Error instance must be passed' unless data_set.is_a?(Ai4r::Data::DataSet)
        raise 'Data should not be empty' if data_set.data_items.empty?

        # Step 1: Initialize data structures
        yield({
          step: 1,
          type: :initialization,
          description: 'Initialize Naive Bayes classifier',
          details: "Dataset contains #{data_set.data_items.length} examples with #{data_set.data_labels.length - 1} features"
        })

        initialize_domain_data(data_set)

        # Step 2: Build domain mappings
        yield({
          step: 2,
          type: :domain_mapping,
          description: 'Build attribute and class mappings',
          details: "Found #{@klasses.length} classes: #{@klasses.join(', ')}"
        })

        initialize_klass_index

        # Step 3: Initialize probability arrays
        yield({
          step: 3,
          type: :probability_initialization,
          description: 'Initialize probability storage',
          details: "Created probability arrays for #{@data_labels.length} attributes"
        })

        initialize_pc

        # Step 4: Calculate probabilities
        yield({
          step: 4,
          type: :probability_calculation,
          description: 'Calculate class and conditional probabilities',
          details: 'Computing prior probabilities and conditional probabilities for each feature'
        })

        calculate_probabilities_with_steps(&block)

        # Final step
        yield({
          step: 5,
          type: :completion,
          description: 'Naive Bayes training complete',
          details: "Learned #{@klasses.length} class priors and #{@pcp.flatten.length} conditional probabilities"
        })

        self
      end

      def build(data_set)
        raise 'Error instance must be passed' unless data_set.is_a?(Ai4r::Data::DataSet)
        raise 'Data should not be empty' if data_set.data_items.empty?

        initialize_domain_data(data_set)
        initialize_klass_index
        initialize_pc
        calculate_probabilities

        self
      end

      private

      def calculate_probabilities_with_steps
        # Calculate class probabilities
        @klasses.each { |klass| @class_counts[klass_index(klass)] = 0 }

        @data_items.each do |entry|
          @class_counts[klass_index(entry.klass)] += 1
        end

        @class_counts.each_with_index do |count, index|
          @class_prob[index] = count.to_f / @data_items.length
          class_name = @klasses[index]

          yield({
            step: 4.1,
            type: :class_probability,
            description: 'Calculate class probability',
            details: "P(#{class_name}) = #{@class_prob[index].round(4)}",
            class_name: class_name,
            prior_probability: @class_prob[index]
          })
        end

        # Count feature-class combinations
        @data_items.each do |item|
          @data_labels.each_with_index do |_label, dl_index|
            feature_value = item[dl_index]
            class_name = item.klass

            if value_index(feature_value, dl_index) && klass_index(class_name)
              @pcc[dl_index][value_index(feature_value, dl_index)][klass_index(class_name)] += 1
            end
          end
        end

        # Calculate conditional probabilities
        @pcc.each_with_index do |attributes, a_index|
          attribute_name = @data_labels[a_index]

          attributes.each_with_index do |values, v_index|
            attribute_value = @domains[a_index][v_index]

            values.each_with_index do |count, k_index|
              class_name = @klasses[k_index]
              denominator = @class_counts[k_index] + @m

              if denominator > 0
                @pcp[a_index][v_index][k_index] = (count.to_f + (@m * @class_prob[k_index])) / denominator

                if @configuration.verbose
                  puts "    P(#{attribute_name}=#{attribute_value}|#{class_name}) = #{@pcp[a_index][v_index][k_index].round(4)}"
                end
              else
                @pcp[a_index][v_index][k_index] = 0.0
              end
            end
          end
        end
      end
    end

    # Educational Multilayer Perceptron implementation with step-by-step execution
    class EducationalMultilayerPerceptron < MultilayerPerceptron
      def initialize(configuration, monitor)
        super()
        @configuration = configuration
        @monitor = monitor
      end

      def build_with_steps(data_set)
        data_set.check_not_empty

        # Step 1: Initialize network structure
        yield({
          step: 1,
          type: :initialization,
          description: 'Initialize neural network structure',
          details: "Dataset contains #{data_set.data_items.length} examples"
        })

        @data_set = data_set
        @domains = @data_set.build_domains.collect(&:to_a)
        @outputs = @domains.last.length
        @inputs = 0
        @domains[0...-1].each { |domain| @inputs += domain.length }
        @structure = [@inputs] + @hidden_layers + [@outputs]

        # Step 2: Create network
        yield({
          step: 2,
          type: :network_creation,
          description: 'Create neural network',
          details: "Network structure: #{@structure.join(' → ')} (#{@inputs} inputs, #{@outputs} outputs)"
        })

        @network = @network_class.new(@structure)

        # Step 3: Training loop
        total_iterations = @training_iterations * data_set.data_items.length
        current_iteration = 0

        @training_iterations.times do |epoch|
          yield({
            step: 3 + epoch,
            type: :training_epoch,
            description: "Training epoch #{epoch + 1}/#{@training_iterations}",
            details: "Processing #{data_set.data_items.length} training examples"
          })

          data_set.data_items.each_with_index do |data_item, _example_index|
            input_values = data_to_input(data_item[0...-1])
            output_values = data_to_output(data_item.last)
            @network.train(input_values, output_values)

            current_iteration += 1

            if @configuration.verbose && (current_iteration % 100 == 0)
              puts "    Processed #{current_iteration}/#{total_iterations} training examples"
            end
          end
        end

        # Final step
        yield({
          step: 3 + @training_iterations,
          type: :completion,
          description: 'Neural network training complete',
          details: "Completed #{@training_iterations} epochs with #{data_set.data_items.length} examples each"
        })

        self
      end

      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        @domains = @data_set.build_domains.collect(&:to_a)
        @outputs = @domains.last.length
        @inputs = 0
        @domains[0...-1].each { |domain| @inputs += domain.length }
        @structure = [@inputs] + @hidden_layers + [@outputs]
        @network = @network_class.new(@structure)

        @training_iterations.times do
          data_set.data_items.each do |data_item|
            input_values = data_to_input(data_item[0...-1])
            output_values = data_to_output(data_item.last)
            @network.train(input_values, output_values)
          end
        end

        self
      end
    end

    # Educational OneR implementation with step-by-step execution
    class EducationalOneR < OneR
      def initialize(configuration, monitor)
        super()
        @configuration = configuration
        @monitor = monitor
      end

      def build_with_steps(data_set)
        data_set.check_not_empty

        # Step 1: Initialize
        yield({
          step: 1,
          type: :initialization,
          description: 'Initialize OneR classifier',
          details: "Dataset contains #{data_set.data_items.length} examples with #{data_set.data_labels.length - 1} attributes"
        })

        @data_set = data_set
        @domains = @data_set.build_domains

        # Step 2: Evaluate each attribute
        best_attribute = nil
        best_error_rate = Float::INFINITY
        best_rules = nil

        @data_set.data_labels[0...-1].each_with_index do |attribute_name, attr_index|
          yield({
            step: 2 + attr_index,
            type: :attribute_evaluation,
            description: "Evaluate attribute '#{attribute_name}'",
            details: "Creating rules for attribute with #{@domains[attr_index].length} possible values"
          })

          rules, error_rate = evaluate_attribute(attr_index)

          puts "    Attribute '#{attribute_name}': Error rate = #{error_rate.round(4)}" if @configuration.verbose

          next unless error_rate < best_error_rate

          best_error_rate = error_rate
          best_attribute = attribute_name
          best_rules = rules
        end

        # Step 3: Select best attribute
        yield({
          step: 2 + @data_set.data_labels.length,
          type: :best_attribute_selection,
          description: 'Select best attribute',
          details: "Chosen attribute: '#{best_attribute}' with error rate: #{best_error_rate.round(4)}"
        })

        @best_attribute_index = @data_set.data_labels.index(best_attribute)
        @rules = best_rules

        # Final step
        yield({
          step: 3 + @data_set.data_labels.length,
          type: :completion,
          description: 'OneR training complete',
          details: "Created #{@rules.length} rules for attribute '#{best_attribute}'"
        })

        self
      end

      def build(data_set)
        # Original OneR implementation would go here
        # For now, we'll use a simplified version
        data_set.check_not_empty
        @data_set = data_set
        @domains = @data_set.build_domains

        # Find best attribute
        best_attribute = nil
        best_error_rate = Float::INFINITY
        best_rules = nil

        @data_set.data_labels[0...-1].each_with_index do |attribute_name, attr_index|
          rules, error_rate = evaluate_attribute(attr_index)

          next unless error_rate < best_error_rate

          best_error_rate = error_rate
          best_attribute = attribute_name
          best_rules = rules
        end

        @best_attribute_index = @data_set.data_labels.index(best_attribute)
        @rules = best_rules

        self
      end

      def eval(data_item)
        return nil unless @rules && @best_attribute_index

        attribute_value = data_item[@best_attribute_index]
        @rules[attribute_value] || @rules.values.first
      end

      def get_rules
        return 'No rules generated' unless @rules

        attribute_name = @data_set.data_labels[@best_attribute_index]
        rules_text = @rules.map do |value, predicted_class|
          "if #{attribute_name} == '#{value}' then class = '#{predicted_class}'"
        end.join("\nelse ")

        "#{rules_text}\nelse class = '#{@rules.values.first}'"
      end

      private

      def evaluate_attribute(attr_index)
        # Create frequency table
        freq_table = Hash.new { |h, k| h[k] = Hash.new(0) }

        @data_set.data_items.each do |item|
          attribute_value = item[attr_index]
          class_value = item.last
          freq_table[attribute_value][class_value] += 1
        end

        # Create rules (most frequent class for each attribute value)
        rules = {}
        total_errors = 0

        freq_table.each do |attr_value, class_counts|
          most_frequent_class = class_counts.max_by { |_, count| count }[0]
          rules[attr_value] = most_frequent_class

          # Count errors for this rule
          total_examples = class_counts.values.sum
          correct_predictions = class_counts[most_frequent_class]
          total_errors += (total_examples - correct_predictions)
        end

        error_rate = total_errors.to_f / @data_set.data_items.length

        [rules, error_rate]
      end
    end

    # Educational ZeroR implementation with step-by-step execution
    class EducationalZeroR < ZeroR
      def initialize(configuration, monitor)
        super()
        @configuration = configuration
        @monitor = monitor
      end

      def build_with_steps(data_set)
        data_set.check_not_empty

        # Step 1: Initialize
        yield({
          step: 1,
          type: :initialization,
          description: 'Initialize ZeroR classifier',
          details: "Dataset contains #{data_set.data_items.length} examples"
        })

        @data_set = data_set

        # Step 2: Count class frequencies
        yield({
          step: 2,
          type: :class_counting,
          description: 'Count class frequencies',
          details: 'Analyzing distribution of target classes'
        })

        class_counts = Hash.new(0)
        @data_set.data_items.each do |item|
          class_value = item.last
          class_counts[class_value] += 1
        end

        # Step 3: Find most frequent class
        @most_frequent_class = class_counts.max_by { |_, count| count }[0]
        @class_distribution = class_counts

        yield({
          step: 3,
          type: :class_selection,
          description: 'Select most frequent class',
          details: "Most frequent class: '#{@most_frequent_class}' (#{class_counts[@most_frequent_class]} out of #{@data_set.data_items.length} examples)"
        })

        # Final step
        yield({
          step: 4,
          type: :completion,
          description: 'ZeroR training complete',
          details: "Will always predict class: '#{@most_frequent_class}'"
        })

        self
      end

      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set

        class_counts = Hash.new(0)
        @data_set.data_items.each do |item|
          class_value = item.last
          class_counts[class_value] += 1
        end

        @most_frequent_class = class_counts.max_by { |_, count| count }[0]
        @class_distribution = class_counts

        self
      end

      def eval(_data_item)
        @most_frequent_class
      end

      def get_rules
        "always predict class = '#{@most_frequent_class}'"
      end
    end
  end
end
