# frozen_string_literal: true

module AssertionHelper
  # Assert that a matrix is symmetric
  def expect_symmetric_matrix(matrix)
    expect(matrix.size).to eq(matrix.first.size)
    
    matrix.each_with_index do |row, i|
      row.each_with_index do |value, j|
        expect(value).to eq(matrix[j][i]),
          "Matrix not symmetric at [#{i},#{j}]: #{value} != #{matrix[j][i]}"
      end
    end
  end
  
  # Assert that values are within a range
  def expect_in_range(values, min, max)
    values = [values].flatten
    values.each do |value|
      expect(value).to be_between(min, max).inclusive
    end
  end
  
  # Assert that an array is sorted
  def expect_sorted(array, order: :ascending)
    sorted = order == :ascending ? array.sort : array.sort.reverse
    expect(array).to eq(sorted)
  end
  
  # Assert that clusters are well-separated
  def expect_well_separated_clusters(clusters, min_separation: 1.0)
    centroids = clusters.map { |cluster| calculate_centroid(cluster) }
    
    centroids.combination(2).each do |c1, c2|
      distance = euclidean_distance(c1, c2)
      expect(distance).to be >= min_separation,
        "Clusters too close: distance #{distance} < #{min_separation}"
    end
  end
  
  # Assert convergence behavior
  def expect_convergence(values, tolerance: 0.01)
    return if values.size < 2
    
    differences = values.each_cons(2).map { |a, b| (b - a).abs }
    expect(differences.last).to be < tolerance,
      "Not converged: last difference #{differences.last} >= #{tolerance}"
  end
  
  # Assert probability distribution
  def expect_probability_distribution(probs)
    expect(probs).to all(be >= 0)
    expect(probs).to all(be <= 1)
    expect(probs.sum).to be_within(0.001).of(1.0)
  end
  
  # Assert valid confusion matrix
  def expect_valid_confusion_matrix(matrix, num_classes)
    expect(matrix.size).to eq(num_classes)
    expect(matrix).to all(have_attributes(size: num_classes))
    
    matrix.each do |row|
      expect(row).to all(be >= 0)
      expect(row).to all(be_an(Integer))
    end
  end
  
  private
  
  def calculate_centroid(points)
    return [] if points.empty?
    
    dimensions = points.first.size
    centroid = Array.new(dimensions, 0.0)
    
    points.each do |point|
      point.each_with_index { |val, i| centroid[i] += val }
    end
    
    centroid.map { |sum| sum / points.size }
  end
  
  def euclidean_distance(p1, p2)
    Math.sqrt(p1.zip(p2).map { |a, b| (a - b)**2 }.sum)
  end
end

RSpec.configure do |config|
  config.include AssertionHelper
end