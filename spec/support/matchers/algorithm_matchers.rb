# frozen_string_literal: true

# Matcher to check if algorithm converges
RSpec::Matchers.define :converge do |options = {}|
  match do |algorithm|
    max_iterations = options[:within] || 100
    tolerance = options[:tolerance] || 0.001
    
    previous_state = nil
    @iterations = 0
    
    max_iterations.times do |i|
      algorithm.step
      current_state = algorithm.state
      
      if previous_state && (current_state - previous_state).abs < tolerance
        @iterations = i + 1
        return true
      end
      
      previous_state = current_state
    end
    
    false
  end
  
  failure_message do |algorithm|
    "expected algorithm to converge within #{expected} iterations, but did not"
  end
  
  description do
    "converge within specified iterations"
  end
end

# Matcher to check if clusters are well-separated
RSpec::Matchers.define :have_well_separated_clusters do |min_separation = 1.0|
  match do |clusterer|
    return false unless clusterer.respond_to?(:clusters)
    
    clusters = clusterer.clusters
    return true if clusters.size < 2
    
    centroids = clusters.map do |cluster|
      calculate_centroid(cluster.data_items)
    end
    
    centroids.combination(2).all? do |c1, c2|
      distance(c1, c2) >= min_separation
    end
  end
  
  failure_message do |clusterer|
    "expected clusters to be separated by at least #{min_separation}, but some were closer"
  end
  
  def calculate_centroid(points)
    return nil if points.empty?
    dimensions = points.first.size
    centroid = Array.new(dimensions, 0.0)
    
    points.each do |point|
      point.each_with_index { |val, i| centroid[i] += val }
    end
    
    centroid.map { |sum| sum / points.size }
  end
  
  def distance(p1, p2)
    Math.sqrt(p1.zip(p2).map { |a, b| (a - b)**2 }.sum)
  end
end

# Matcher to check if output is valid probability distribution
RSpec::Matchers.define :be_valid_probability_distribution do
  match do |probs|
    probs.all? { |p| p >= 0 && p <= 1 } && (probs.sum - 1.0).abs < 0.001
  end
  
  failure_message do |probs|
    if probs.any? { |p| p < 0 || p > 1 }
      "expected all probabilities to be in [0,1], but got #{probs}"
    else
      "expected probabilities to sum to 1.0, but got #{probs.sum}"
    end
  end
end

# Matcher to check if matrix is symmetric
RSpec::Matchers.define :be_symmetric_matrix do
  match do |matrix|
    return false unless matrix.is_a?(Array) && matrix.all? { |row| row.is_a?(Array) }
    return false unless matrix.size == matrix.first.size
    
    matrix.each_with_index do |row, i|
      row.each_with_index do |value, j|
        return false unless value == matrix[j][i]
      end
    end
    
    true
  end
  
  failure_message do |matrix|
    "expected matrix to be symmetric, but it was not"
  end
end

# Matcher to check if values are monotonically increasing/decreasing
RSpec::Matchers.define :be_monotonic do |direction = :increasing|
  match do |values|
    return true if values.size < 2
    
    case direction
    when :increasing
      values.each_cons(2).all? { |a, b| a <= b }
    when :decreasing
      values.each_cons(2).all? { |a, b| a >= b }
    else
      false
    end
  end
  
  failure_message do |values|
    "expected values to be monotonically #{direction}, but they were not: #{values}"
  end
end

# Matcher for performance bounds
RSpec::Matchers.define :complete_within do |time_limit|
  supports_block_expectations
  
  match do |block|
    start_time = Time.now
    block.call
    elapsed = Time.now - start_time
    @actual_time = elapsed
    elapsed <= time_limit
  end
  
  failure_message do |block|
    "expected block to complete within #{time_limit}s, but took #{@actual_time}s"
  end
end

# Matcher to check if algorithm produces consistent results
RSpec::Matchers.define :produce_consistent_results do |runs = 5|
  match do |algorithm|
    results = runs.times.map { algorithm.run }
    
    # Check if all results are the same (for deterministic algorithms)
    # or within reasonable bounds (for stochastic algorithms)
    if algorithm.respond_to?(:deterministic?) && algorithm.deterministic?
      results.uniq.size == 1
    else
      # For stochastic algorithms, check if results are similar
      @variance = calculate_variance(results)
      @variance < 0.1  # Threshold can be adjusted
    end
  end
  
  failure_message do |algorithm|
    "expected algorithm to produce consistent results, but variance was #{@variance}"
  end
  
  def calculate_variance(results)
    return 0 if results.empty?
    
    # Simple variance calculation for numeric results
    if results.first.is_a?(Numeric)
      mean = results.sum.to_f / results.size
      variance = results.map { |r| (r - mean)**2 }.sum / results.size
      Math.sqrt(variance) / mean.abs  # Coefficient of variation
    else
      # For non-numeric results, use uniqueness ratio
      results.uniq.size.to_f / results.size
    end
  end
end