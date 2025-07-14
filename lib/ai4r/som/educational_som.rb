# frozen_string_literal: true

# Educational Self-Organizing Map (SOM) framework
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'som'
require_relative 'layer'
require_relative 'two_phase_layer'
require_relative '../data/parameterizable'

module Ai4r
  module Som
    
    # Educational SOM framework designed for students and teachers
    # to understand, experiment with, and visualize self-organizing maps
    class EducationalSom
      
      attr_reader :som, :monitor, :configuration, :training_history, :map_info
      
      def initialize(input_dimension, map_size, config = {})
        @input_dimension = input_dimension
        @map_size = map_size
        @configuration = SomConfiguration.new(config)
        @monitor = SomMonitor.new
        @training_history = []
        @map_info = {}
        @step_mode = false
        @visualization_enabled = false
        
        # Create layer based on configuration
        @layer = create_layer(@configuration.layer_type, @configuration.epochs, @configuration)
        
        # Initialize the SOM
        @som = EducationalSomCore.new(@input_dimension, @map_size, @layer, @configuration, @monitor)
      end
      
      # Enable step-by-step execution for educational purposes
      def enable_step_mode
        @step_mode = true
        self
      end
      
      # Enable visualization output
      def enable_visualization
        @visualization_enabled = true
        self
      end
      
      # Configure SOM parameters with educational explanations
      def configure(params)
        @configuration.update(params)
        @configuration.explain_changes if @configuration.verbose
        self
      end
      
      # Train the SOM with educational features
      def train(training_data)
        @training_data = training_data
        @monitor.start_training(training_data, @configuration.epochs)
        
        puts "Starting SOM training..." if @configuration.verbose
        puts "Map size: #{@map_size}x#{@map_size}" if @configuration.verbose
        puts "Input dimension: #{@input_dimension}" if @configuration.verbose
        puts "Training data: #{training_data.length} examples" if @configuration.verbose
        
        if @step_mode
          train_step_by_step(training_data)
        else
          train_normal(training_data)
        end
        
        @monitor.finish_training(@som)
        collect_map_info
        self
      end
      
      # Find the best matching unit (BMU) for an input
      def find_bmu(input)
        @som.find_bmu(input)
      end
      
      # Get the weight vector of a specific node
      def get_node_weights(x, y)
        @som.get_node(x, y).weights
      end
      
      # Calculate map quality metrics
      def calculate_map_quality
        SomQualityAnalyzer.new(@som, @training_data, @configuration).analyze
      end
      
      # Visualize the SOM map and training process
      def visualize
        SomVisualizer.new(@som, @map_info, @training_history, @configuration).visualize
      end
      
      # Export SOM map and training data
      def export_som(filename)
        SomExporter.new(@som, @map_info, @training_history).export(filename)
      end
      
      # Analyze the topology and organization of the map
      def analyze_topology
        SomTopologyAnalyzer.new(@som, @training_data, @configuration).analyze
      end
      
      # Get neighborhood information for educational purposes
      def get_neighborhood_info(center_x, center_y, radius)
        neighbors = []
        
        (0...@map_size).each do |x|
          (0...@map_size).each do |y|
            distance = Math.sqrt((x - center_x)**2 + (y - center_y)**2)
            if distance <= radius
              neighbors << {
                x: x,
                y: y,
                distance: distance,
                influence: @layer.influence_decay(distance, radius),
                weights: @som.get_node(x, y).weights.dup
              }
            end
          end
        end
        
        neighbors.sort_by { |n| n[:distance] }
      end
      
      private
      
      def create_layer(layer_type, epochs, configuration)
        case layer_type
        when :standard
          Layer.new(epochs, configuration.initial_learning_rate, configuration.initial_radius)
        when :two_phase
          TwoPhaseLayer.new(epochs, configuration.initial_learning_rate, configuration.initial_radius)
        else
          Layer.new(epochs, configuration.initial_learning_rate, configuration.initial_radius)
        end
      end
      
      def train_step_by_step(training_data)
        puts "\n=== Step-by-step SOM training ===" if @configuration.verbose
        
        @som.train_with_steps(training_data) do |step_info|
          @training_history << step_info
          
          if @configuration.verbose
            puts "\nEpoch #{step_info[:epoch]}/#{@configuration.epochs}: #{step_info[:description]}"
            puts "  Learning rate: #{step_info[:learning_rate].round(4)}" if step_info[:learning_rate]
            puts "  Neighborhood radius: #{step_info[:radius].round(4)}" if step_info[:radius]
            puts "  Quantization error: #{step_info[:quantization_error].round(6)}" if step_info[:quantization_error]
            puts "  #{step_info[:details]}" if step_info[:details]
          end
          
          visualize_step(step_info) if @visualization_enabled
          
          if @step_mode && step_info[:epoch] % 10 == 0
            puts "Press Enter to continue..."
            gets
          end
        end
      end
      
      def train_normal(training_data)
        @som.initiate_map
        @som.train(training_data)
      end
      
      def collect_map_info
        @map_info = {
          input_dimension: @input_dimension,
          map_size: @map_size,
          total_nodes: @map_size * @map_size,
          training_examples: @training_data&.length || 0,
          training_time: @monitor.training_time,
          final_quantization_error: @monitor.final_quantization_error,
          epochs_completed: @monitor.epochs_completed
        }
      end
      
      def visualize_step(step_info)
        SomVisualizer.new(@som, @map_info, @training_history, @configuration).visualize_step(step_info)
      end
    end
    
    # Configuration class for SOM parameters
    class SomConfiguration
      attr_accessor :epochs, :initial_learning_rate, :initial_radius, :layer_type
      attr_accessor :verbose, :neighborhood_function, :learning_rate_decay, :radius_decay
      
      def initialize(params = {})
        # Default parameters
        @epochs = params[:epochs] || 100
        @initial_learning_rate = params[:initial_learning_rate] || 0.1
        @initial_radius = params[:initial_radius] || 3.0
        @layer_type = params[:layer_type] || :standard
        @verbose = params[:verbose] || false
        @neighborhood_function = params[:neighborhood_function] || :gaussian
        @learning_rate_decay = params[:learning_rate_decay] || :exponential
        @radius_decay = params[:radius_decay] || :exponential
        
        @explanations = {}
      end
      
      def update(params)
        params.each do |key, value|
          if respond_to?("#{key}=")
            old_value = send(key)
            send("#{key}=", value)
            @explanations[key] = explain_parameter_change(key, old_value, value)
          end
        end
      end
      
      def explain_changes
        @explanations.each do |param, explanation|
          puts "#{param}: #{explanation}"
        end
        @explanations.clear
      end
      
      def explain_all_parameters
        puts "\n=== SOM Parameters Explanation ==="
        puts "epochs: Number of training iterations (current: #{@epochs})"
        puts "initial_learning_rate: Starting learning rate (current: #{@initial_learning_rate})"
        puts "initial_radius: Starting neighborhood radius (current: #{@initial_radius})"
        puts "layer_type: Training algorithm variant (current: #{@layer_type})"
        puts "neighborhood_function: Shape of neighborhood influence (current: #{@neighborhood_function})"
        puts "learning_rate_decay: How learning rate decreases over time (current: #{@learning_rate_decay})"
        puts "radius_decay: How neighborhood radius shrinks over time (current: #{@radius_decay})"
      end
      
      private
      
      def explain_parameter_change(param, old_value, new_value)
        case param
        when :epochs
          "Training epochs changed from #{old_value} to #{new_value} - affects map quality and training time"
        when :initial_learning_rate
          "Initial learning rate changed from #{old_value} to #{new_value} - affects adaptation speed"
        when :initial_radius
          "Initial radius changed from #{old_value} to #{new_value} - affects neighborhood size"
        when :layer_type
          "Layer type changed from #{old_value} to #{new_value} - affects training algorithm behavior"
        else
          "Changed #{param} from #{old_value} to #{new_value}"
        end
      end
    end
    
    # Monitoring class for tracking SOM training
    class SomMonitor
      attr_reader :start_time, :training_time, :quantization_errors, :epoch_data
      
      def initialize
        @quantization_errors = []
        @epoch_data = []
        @epochs_completed = 0
      end
      
      def start_training(training_data, total_epochs)
        @start_time = Time.now
        @training_data = training_data
        @total_epochs = total_epochs
        @quantization_errors.clear
        @epoch_data.clear
        @epochs_completed = 0
      end
      
      def record_epoch(epoch, quantization_error, additional_data = {})
        @quantization_errors << quantization_error
        @epochs_completed = epoch + 1
        
        epoch_info = {
          epoch: epoch,
          quantization_error: quantization_error,
          timestamp: Time.now
        }.merge(additional_data)
        
        @epoch_data << epoch_info
        epoch_info
      end
      
      def finish_training(som)
        @end_time = Time.now
        @training_time = @end_time - @start_time
        @final_som = som
        @final_quantization_error = @quantization_errors.last || Float::INFINITY
      end
      
      def final_quantization_error
        @final_quantization_error
      end
      
      def training_time
        @training_time
      end
      
      def epochs_completed
        @epochs_completed
      end
      
      def summary
        return "Training not completed" unless @training_time
        
        {
          training_time: @training_time,
          epochs_completed: @epochs_completed,
          final_quantization_error: @final_quantization_error,
          error_reduction: calculate_error_reduction
        }
      end
      
      def plot_quantization_error
        return "No error data available" if @quantization_errors.empty?
        
        puts "\n=== Quantization Error Curve ==="
        puts "Epoch | Error"
        puts "------|------"
        
        # Sample points for plotting
        sample_indices = if @quantization_errors.length > 20
          step = @quantization_errors.length / 20
          (0...@quantization_errors.length).step(step).to_a
        else
          (0...@quantization_errors.length).to_a
        end
        
        max_error = @quantization_errors.max
        sample_indices.each do |i|
          error = @quantization_errors[i]
          bar_length = max_error > 0 ? [(error / max_error * 30).to_i, 1].max : 1
          bar = "█" * bar_length
          puts sprintf("%5d | %s %.6f", i, bar, error)
        end
        
        puts "\nFinal quantization error: #{@final_quantization_error.round(6)}"
      end
      
      private
      
      def calculate_error_reduction
        return 0 if @quantization_errors.length < 2
        
        initial_error = @quantization_errors.first
        final_error = @quantization_errors.last
        
        return 0 if initial_error == 0
        
        ((initial_error - final_error) / initial_error * 100).round(2)
      end
    end
    
    # Enhanced SOM core with educational features
    class EducationalSomCore < Som
      def initialize(input_dimension, map_size, layer, configuration, monitor)
        super(input_dimension, map_size, layer)
        @configuration = configuration
        @monitor = monitor
      end
      
      def train_with_steps(training_data)
        initiate_map
        
        @layer.epochs.times do |epoch|
          quantization_error = 0
          learning_rate = @layer.learning_rate_decay(epoch)
          radius = @layer.radius_decay(epoch)
          
          # Process each training example
          training_data.each do |input|
            bmu, distance = find_bmu(input)
            quantization_error += distance**2
            
            # Update weights in neighborhood
            adjust_nodes(input, [bmu, distance], radius, learning_rate)
          end
          
          # Calculate average quantization error
          avg_quantization_error = quantization_error / training_data.length
          
          # Record epoch data
          epoch_data = @monitor.record_epoch(epoch, avg_quantization_error, {
            learning_rate: learning_rate,
            radius: radius,
            bmu_coordinates: get_node_coordinates(find_bmu(training_data.first)[0])
          })
          
          # Yield step information
          yield({
            epoch: epoch,
            description: "SOM adaptation complete",
            quantization_error: avg_quantization_error,
            learning_rate: learning_rate,
            radius: radius,
            details: "Updated weights for #{training_data.length} inputs"
          })
        end
      end
      
      def get_all_node_weights
        weights_matrix = []
        
        (0...@number_of_nodes).each do |x|
          weights_row = []
          (0...@number_of_nodes).each do |y|
            weights_row << get_node(x, y).weights.dup
          end
          weights_matrix << weights_row
        end
        
        weights_matrix
      end
      
      def calculate_quantization_error(training_data)
        total_error = 0
        
        training_data.each do |input|
          _, distance = find_bmu(input)
          total_error += distance**2
        end
        
        total_error / training_data.length
      end
      
      def get_node_coordinates(node)
        @nodes.each_with_index do |n, index|
          if n == node
            x = index / @number_of_nodes
            y = index % @number_of_nodes
            return [x, y]
          end
        end
        [0, 0]  # Fallback
      end
      
      def calculate_neighborhood_preservation(training_data)
        # Calculate how well the SOM preserves neighborhood relationships
        preservation_score = 0
        total_comparisons = 0
        
        training_data.each_with_index do |input1, i|
          training_data.each_with_index do |input2, j|
            next if i >= j
            
            # Input space distance
            input_distance = euclidean_distance(input1, input2)
            
            # Map space distance
            bmu1_coords = get_node_coordinates(find_bmu(input1)[0])
            bmu2_coords = get_node_coordinates(find_bmu(input2)[0])
            map_distance = euclidean_distance(bmu1_coords, bmu2_coords)
            
            # Check if relative ordering is preserved
            training_data.each_with_index do |input3, k|
              next if k == i || k == j
              
              input_distance_3 = euclidean_distance(input1, input3)
              bmu3_coords = get_node_coordinates(find_bmu(input3)[0])
              map_distance_3 = euclidean_distance(bmu1_coords, bmu3_coords)
              
              # Check if ordering is preserved
              if (input_distance < input_distance_3) == (map_distance < map_distance_3)
                preservation_score += 1
              end
              total_comparisons += 1
            end
          end
        end
        
        total_comparisons > 0 ? preservation_score.to_f / total_comparisons : 0
      end
      
      private
      
      def euclidean_distance(vec1, vec2)
        sum = 0
        vec1.each_with_index do |v1, i|
          v2 = vec2[i] || 0
          sum += (v1 - v2)**2
        end
        Math.sqrt(sum)
      end
    end
    
    # SOM quality analysis tools
    class SomQualityAnalyzer
      def initialize(som, training_data, configuration)
        @som = som
        @training_data = training_data
        @configuration = configuration
      end
      
      def analyze
        puts "\n=== SOM Quality Analysis ==="
        
        # Quantization error
        quantization_error = @som.calculate_quantization_error(@training_data)
        puts "Quantization Error: #{quantization_error.round(6)}"
        
        # Topographic error
        topographic_error = calculate_topographic_error
        puts "Topographic Error: #{topographic_error.round(6)}"
        
        # Neighborhood preservation
        neighborhood_preservation = @som.calculate_neighborhood_preservation(@training_data)
        puts "Neighborhood Preservation: #{neighborhood_preservation.round(4)}"
        
        # Map utilization
        utilization = calculate_map_utilization
        puts "Map Utilization: #{utilization.round(4)}"
        
        # Map quality summary
        quality_score = calculate_overall_quality(quantization_error, topographic_error, neighborhood_preservation, utilization)
        puts "Overall Quality Score: #{quality_score.round(4)}"
        
        {
          quantization_error: quantization_error,
          topographic_error: topographic_error,
          neighborhood_preservation: neighborhood_preservation,
          map_utilization: utilization,
          overall_quality: quality_score
        }
      end
      
      private
      
      def calculate_topographic_error
        # Percentage of data for which first and second BMUs are not adjacent
        topographic_errors = 0
        
        @training_data.each do |input|
          bmu_distances = []
          
          # Calculate distances to all nodes
          (0...@som.number_of_nodes).each do |x|
            (0...@som.number_of_nodes).each do |y|
              node = @som.get_node(x, y)
              distance = node.distance_to_input(input)
              bmu_distances << { x: x, y: y, distance: distance }
            end
          end
          
          # Sort by distance and get first two BMUs
          sorted_bmus = bmu_distances.sort_by { |bmu| bmu[:distance] }
          first_bmu = sorted_bmus[0]
          second_bmu = sorted_bmus[1]
          
          # Check if they are adjacent
          x_diff = (first_bmu[:x] - second_bmu[:x]).abs
          y_diff = (first_bmu[:y] - second_bmu[:y]).abs
          
          unless (x_diff <= 1 && y_diff <= 1) && (x_diff + y_diff > 0)
            topographic_errors += 1
          end
        end
        
        topographic_errors.to_f / @training_data.length
      end
      
      def calculate_map_utilization
        # Percentage of nodes that are BMU for at least one input
        used_nodes = Set.new
        
        @training_data.each do |input|
          bmu, _ = @som.find_bmu(input)
          bmu_coords = @som.get_node_coordinates(bmu)
          used_nodes << bmu_coords
        end
        
        total_nodes = @som.number_of_nodes * @som.number_of_nodes
        used_nodes.length.to_f / total_nodes
      end
      
      def calculate_overall_quality(quant_error, topo_error, neighborhood_pres, utilization)
        # Weighted combination of quality metrics (higher is better)
        # Normalize quantization error (lower is better, so invert)
        normalized_quant = 1.0 / (1.0 + quant_error)
        
        # Topographic error (lower is better, so invert)
        normalized_topo = 1.0 - topo_error
        
        # Weighted average
        (0.3 * normalized_quant + 0.3 * normalized_topo + 0.2 * neighborhood_pres + 0.2 * utilization)
      end
    end
    
    # SOM topology analysis tools
    class SomTopologyAnalyzer
      def initialize(som, training_data, configuration)
        @som = som
        @training_data = training_data
        @configuration = configuration
      end
      
      def analyze
        puts "\n=== SOM Topology Analysis ==="
        
        analyze_weight_distribution
        analyze_node_distances
        analyze_cluster_formation
        suggest_improvements
      end
      
      private
      
      def analyze_weight_distribution
        puts "Weight Distribution Analysis:"
        
        all_weights = []
        (0...@som.number_of_nodes).each do |x|
          (0...@som.number_of_nodes).each do |y|
            node_weights = @som.get_node(x, y).weights
            all_weights.concat(node_weights)
          end
        end
        
        mean_weight = all_weights.sum / all_weights.length
        weight_variance = all_weights.sum { |w| (w - mean_weight)**2 } / all_weights.length
        weight_std = Math.sqrt(weight_variance)
        
        puts "  Mean weight: #{mean_weight.round(4)}"
        puts "  Weight std: #{weight_std.round(4)}"
        puts "  Weight range: [#{all_weights.min.round(4)}, #{all_weights.max.round(4)}]"
      end
      
      def analyze_node_distances
        puts "\nNode Distance Analysis:"
        
        neighbor_distances = []
        
        (0...@som.number_of_nodes).each do |x|
          (0...@som.number_of_nodes).each do |y|
            node = @som.get_node(x, y)
            
            # Check adjacent neighbors
            [[x+1, y], [x-1, y], [x, y+1], [x, y-1]].each do |nx, ny|
              if nx >= 0 && nx < @som.number_of_nodes && ny >= 0 && ny < @som.number_of_nodes
                neighbor = @som.get_node(nx, ny)
                distance = calculate_weight_distance(node.weights, neighbor.weights)
                neighbor_distances << distance
              end
            end
          end
        end
        
        avg_neighbor_distance = neighbor_distances.sum / neighbor_distances.length
        puts "  Average neighbor distance: #{avg_neighbor_distance.round(4)}"
        
        if avg_neighbor_distance < 0.1
          puts "  ✓ Good topology preservation (low neighbor distances)"
        elsif avg_neighbor_distance > 1.0
          puts "  ⚠️ Poor topology preservation (high neighbor distances)"
        else
          puts "  ~ Moderate topology preservation"
        end
      end
      
      def analyze_cluster_formation
        puts "\nCluster Formation Analysis:"
        
        # Find BMU for each training example
        bmu_counts = Hash.new(0)
        
        @training_data.each do |input|
          bmu, _ = @som.find_bmu(input)
          bmu_coords = @som.get_node_coordinates(bmu)
          bmu_counts[bmu_coords] += 1
        end
        
        active_nodes = bmu_counts.keys.length
        total_nodes = @som.number_of_nodes * @som.number_of_nodes
        
        puts "  Active nodes: #{active_nodes}/#{total_nodes} (#{(active_nodes.to_f/total_nodes*100).round(1)}%)"
        
        # Find most popular nodes
        top_nodes = bmu_counts.sort_by { |_, count| -count }.first(5)
        puts "  Top BMU nodes:"
        top_nodes.each_with_index do |(coords, count), index|
          puts "    #{index + 1}. Node #{coords.inspect}: #{count} inputs"
        end
      end
      
      def suggest_improvements
        puts "\nSuggestions for Improvement:"
        
        # Map size suggestions
        data_to_node_ratio = @training_data.length.to_f / (@som.number_of_nodes * @som.number_of_nodes)
        
        if data_to_node_ratio < 5
          puts "  • Consider reducing map size (current ratio: #{data_to_node_ratio.round(1)} data points per node)"
        elsif data_to_node_ratio > 50
          puts "  • Consider increasing map size (current ratio: #{data_to_node_ratio.round(1)} data points per node)"
        end
        
        # Training suggestions
        if @configuration.epochs < 100
          puts "  • Consider increasing training epochs for better convergence"
        end
        
        if @configuration.initial_learning_rate > 0.5
          puts "  • Consider reducing initial learning rate for more stable training"
        end
        
        puts "  • Monitor quantization error to assess map quality"
        puts "  • Use validation data to prevent overfitting"
        puts "  • Consider different neighborhood functions for different data types"
      end
      
      def calculate_weight_distance(weights1, weights2)
        sum = 0
        weights1.each_with_index do |w1, i|
          w2 = weights2[i] || 0
          sum += (w1 - w2)**2
        end
        Math.sqrt(sum)
      end
    end
    
    # SOM visualization tools
    class SomVisualizer
      def initialize(som, map_info, training_history, configuration)
        @som = som
        @map_info = map_info
        @training_history = training_history
        @configuration = configuration
      end
      
      def visualize
        puts "\n=== SOM Visualization ==="
        puts "Map Size: #{@map_info[:map_size]}x#{@map_info[:map_size]}"
        puts "Input Dimension: #{@map_info[:input_dimension]}"
        puts "Total Nodes: #{@map_info[:total_nodes]}"
        puts "Training Examples: #{@map_info[:training_examples]}"
        
        if @map_info[:training_time]
          puts "Training Time: #{@map_info[:training_time].round(3)} seconds"
          puts "Final Quantization Error: #{@map_info[:final_quantization_error].round(6)}"
        end
        
        visualize_map_structure
        visualize_weight_distribution if @map_info[:input_dimension] <= 3
        visualize_training_progress if @training_history.any?
      end
      
      def visualize_step(step_info)
        puts "\n--- Epoch #{step_info[:epoch]} Visualization ---"
        puts "Learning Rate: #{step_info[:learning_rate].round(4)}"
        puts "Neighborhood Radius: #{step_info[:radius].round(4)}"
        puts "Quantization Error: #{step_info[:quantization_error].round(6)}"
      end
      
      private
      
      def visualize_map_structure
        puts "\n=== SOM Map Structure ==="
        puts "Node Layout (#{@map_info[:map_size]}x#{@map_info[:map_size]} grid):"
        
        # Simple ASCII representation
        (0...@map_info[:map_size]).each do |x|
          print "  "
          (0...@map_info[:map_size]).each do |y|
            print "◯ "
          end
          puts
        end
        
        puts "\nEach ◯ represents a node with #{@map_info[:input_dimension]}-dimensional weight vector"
      end
      
      def visualize_weight_distribution
        puts "\n=== Weight Distribution Visualization ==="
        
        if @map_info[:input_dimension] == 1
          visualize_1d_weights
        elsif @map_info[:input_dimension] == 2
          visualize_2d_weights
        elsif @map_info[:input_dimension] == 3
          visualize_3d_weights
        end
      end
      
      def visualize_1d_weights
        puts "1D Weight Values (scaled):"
        
        # Get all weights and find range
        all_weights = []
        (0...@map_info[:map_size]).each do |x|
          (0...@map_info[:map_size]).each do |y|
            all_weights << @som.get_node(x, y).weights[0]
          end
        end
        
        min_weight = all_weights.min
        max_weight = all_weights.max
        range = max_weight - min_weight
        
        # Display as ASCII bar chart
        (0...@map_info[:map_size]).each do |x|
          (0...@map_info[:map_size]).each do |y|
            weight = @som.get_node(x, y).weights[0]
            normalized = range > 0 ? (weight - min_weight) / range : 0.5
            bar_length = (normalized * 10).to_i
            bar = "█" * bar_length + "░" * (10 - bar_length)
            print "#{bar} "
          end
          puts
        end
      end
      
      def visualize_2d_weights
        puts "2D Weight Coordinates:"
        puts "(showing first component of weight vectors)"
        
        (0...@map_info[:map_size]).each do |x|
          (0...@map_info[:map_size]).each do |y|
            weights = @som.get_node(x, y).weights
            print sprintf("(%5.2f,%5.2f) ", weights[0], weights[1])
          end
          puts
        end
      end
      
      def visualize_3d_weights
        puts "3D Weight Vectors (first 3 components):"
        
        (0...@map_info[:map_size]).each do |x|
          (0...@map_info[:map_size]).each do |y|
            weights = @som.get_node(x, y).weights
            print sprintf("(%4.2f,%4.2f,%4.2f) ", weights[0], weights[1], weights[2])
          end
          puts
        end
      end
      
      def visualize_training_progress
        puts "\n=== Training Progress ==="
        
        if @training_history.length > 10
          # Sample key epochs for display
          sample_epochs = [0, @training_history.length / 4, @training_history.length / 2, 
                          3 * @training_history.length / 4, @training_history.length - 1]
          
          puts "Key Training Epochs:"
          puts "Epoch | Quant Error | Learn Rate | Radius"
          puts "------|-------------|------------|-------"
          
          sample_epochs.each do |index|
            epoch_data = @training_history[index]
            if epoch_data
              puts sprintf("%5d | %11.6f | %10.4f | %6.2f", 
                          epoch_data[:epoch], 
                          epoch_data[:quantization_error] || 0,
                          epoch_data[:learning_rate] || 0,
                          epoch_data[:radius] || 0)
            end
          end
        else
          puts "All Training Epochs:"
          puts "Epoch | Quant Error | Learn Rate | Radius"
          puts "------|-------------|------------|-------"
          
          @training_history.each do |epoch_data|
            puts sprintf("%5d | %11.6f | %10.4f | %6.2f", 
                        epoch_data[:epoch], 
                        epoch_data[:quantization_error] || 0,
                        epoch_data[:learning_rate] || 0,
                        epoch_data[:radius] || 0)
          end
        end
      end
    end
    
    # SOM export tools
    class SomExporter
      def initialize(som, map_info, training_history)
        @som = som
        @map_info = map_info
        @training_history = training_history
      end
      
      def export(filename)
        case File.extname(filename).downcase
        when '.json'
          export_json(filename)
        when '.csv'
          export_csv(filename)
        else
          export_text(filename)
        end
      end
      
      private
      
      def export_json(filename)
        require 'json'
        
        # Extract all node weights
        node_weights = []
        (0...@map_info[:map_size]).each do |x|
          (0...@map_info[:map_size]).each do |y|
            node_weights << {
              x: x,
              y: y,
              weights: @som.get_node(x, y).weights
            }
          end
        end
        
        result = {
          map_info: @map_info,
          training_history: @training_history,
          node_weights: node_weights
        }
        
        File.write(filename, JSON.pretty_generate(result))
        puts "Exported SOM to #{filename}"
      end
      
      def export_csv(filename)
        require 'csv'
        
        CSV.open(filename, 'w') do |csv|
          # Header
          headers = ['x', 'y'] + (0...@map_info[:input_dimension]).map { |i| "weight_#{i}" }
          csv << headers
          
          # Node data
          (0...@map_info[:map_size]).each do |x|
            (0...@map_info[:map_size]).each do |y|
              weights = @som.get_node(x, y).weights
              csv << [x, y] + weights
            end
          end
        end
        
        puts "Exported SOM weights to #{filename}"
      end
      
      def export_text(filename)
        File.open(filename, 'w') do |file|
          file.puts "Self-Organizing Map Export"
          file.puts "=" * 50
          file.puts "Map Size: #{@map_info[:map_size]}x#{@map_info[:map_size]}"
          file.puts "Input Dimension: #{@map_info[:input_dimension]}"
          file.puts "Total Nodes: #{@map_info[:total_nodes]}"
          file.puts "Training Examples: #{@map_info[:training_examples]}"
          file.puts "Training Time: #{@map_info[:training_time]} seconds"
          file.puts
          
          file.puts "Node Weights:"
          (0...@map_info[:map_size]).each do |x|
            (0...@map_info[:map_size]).each do |y|
              weights = @som.get_node(x, y).weights
              file.puts "Node (#{x},#{y}): #{weights.inspect}"
            end
          end
          
          file.puts "\nTraining History:"
          @training_history.each do |epoch_data|
            file.puts "Epoch #{epoch_data[:epoch]}: Error = #{epoch_data[:quantization_error]}"
          end
        end
        
        puts "Exported SOM to #{filename}"
      end
    end
  end
end