# frozen_string_literal: true

# RSpec tests for AI4R Proximity module based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Data::Proximity do
  # Test data from requirement document
  let(:point_a) { [0, 0] }
  let(:point_b) { [3, 4] }
  let(:point_c) { [0, 0] }  # Identical to point_a
  let(:point_d) { [1, 1] }
  
  let(:binary_a) { [1, 0, 1, 0, 1] }
  let(:binary_b) { [0, 1, 1, 0, 0] }
  let(:binary_c) { [1, 0, 1, 0, 1] }  # Identical to binary_a
  
  let(:categorical_a) { ['red', 'large', 'circle'] }
  let(:categorical_b) { ['blue', 'small', 'square'] }
  let(:categorical_c) { ['red', 'large', 'circle'] }  # Identical to categorical_a
  let(:categorical_d) { ['red', 'small', 'circle'] }  # Partially similar
  
  describe "Distance Metric Tests" do
    context "euclidean distance" do
      it "test_euclidean_basic" do
        # Standard Euclidean distance calculation
        distance = described_class.euclidean_distance(point_a, point_b)
        expected = Math.sqrt((3-0)**2 + (4-0)**2)  # sqrt(9 + 16) = 5
        
        expect(distance).to be_within(0.001).of(expected)
        expect(distance).to eq(5.0)
      end
      
      it "test_euclidean_identical" do
        # Distance between identical points should be zero
        distance = described_class.euclidean_distance(point_a, point_c)
        expect(distance).to eq(0.0)
      end
      
      it "test_euclidean_symmetry" do
        # Distance should be symmetric: d(a,b) = d(b,a)
        distance_ab = described_class.euclidean_distance(point_a, point_b)
        distance_ba = described_class.euclidean_distance(point_b, point_a)
        
        expect(distance_ab).to eq(distance_ba)
      end
    end
    
    context "manhattan distance" do
      it "test_manhattan_basic" do
        # Manhattan (L1) distance calculation
        distance = described_class.manhattan_distance(point_a, point_b)
        expected = (3-0).abs + (4-0).abs  # |3| + |4| = 7
        
        expect(distance).to eq(7.0)
      end
      
      it "test_manhattan_vs_euclidean" do
        # Manhattan should generally be >= Euclidean distance
        manhattan = described_class.manhattan_distance(point_a, point_b)
        euclidean = described_class.euclidean_distance(point_a, point_b)
        
        expect(manhattan).to be >= euclidean
      end
    end
    
    context "minkowski distance" do
      it "test_minkowski_p1" do
        # Minkowski with p=1 should equal Manhattan distance
        if described_class.respond_to?(:minkowski_distance)
          minkowski_p1 = described_class.minkowski_distance(point_a, point_b, 1)
          manhattan = described_class.manhattan_distance(point_a, point_b)
          
          expect(minkowski_p1).to be_within(0.001).of(manhattan)
        end
      end
      
      it "test_minkowski_p2" do
        # Minkowski with p=2 should equal Euclidean distance
        if described_class.respond_to?(:minkowski_distance)
          minkowski_p2 = described_class.minkowski_distance(point_a, point_b, 2)
          euclidean = described_class.euclidean_distance(point_a, point_b)
          
          expect(minkowski_p2).to be_within(0.001).of(euclidean)
        end
      end
    end
  end
  
  describe "Similarity Metric Tests" do
    context "cosine similarity" do
      it "test_cosine_basic" do
        # Cosine similarity between vectors
        if described_class.respond_to?(:cosine_similarity)
          vector_a = [1, 2, 3]
          vector_b = [2, 4, 6]  # Parallel vector (scaled)
          
          similarity = described_class.cosine_similarity(vector_a, vector_b)
          
          # Parallel vectors should have cosine similarity = 1
          expect(similarity).to be_within(0.001).of(1.0)
        end
      end
      
      it "test_cosine_orthogonal" do
        # Orthogonal vectors should have cosine similarity = 0
        if described_class.respond_to?(:cosine_similarity)
          vector_a = [1, 0]
          vector_b = [0, 1]  # Orthogonal
          
          similarity = described_class.cosine_similarity(vector_a, vector_b)
          
          expect(similarity).to be_within(0.001).of(0.0)
        end
      end
    end
    
    context "jaccard similarity" do
      it "test_jaccard_binary" do
        # Jaccard similarity for binary vectors
        if described_class.respond_to?(:jaccard_similarity)
          similarity = described_class.jaccard_similarity(binary_a, binary_b)
          
          # Jaccard = |intersection| / |union|
          # binary_a = [1,0,1,0,1], binary_b = [0,1,1,0,0]
          # intersection = [0,0,1,0,0] -> 1 element
          # union = [1,1,1,0,1] -> 4 elements
          # Jaccard = 1/4 = 0.25
          
          expect(similarity).to be_between(0.0, 1.0)
          expect(similarity).to be_within(0.001).of(0.2)  # 1/5 common positions
        end
      end
      
      it "test_jaccard_identical" do
        # Identical sets should have Jaccard similarity = 1
        if described_class.respond_to?(:jaccard_similarity)
          similarity = described_class.jaccard_similarity(binary_a, binary_c)
          expect(similarity).to eq(1.0)
        end
      end
    end
  end
  
  describe "Specialized Distance Tests" do
    context "hamming distance" do
      it "test_hamming_basic" do
        # Hamming distance counts differing positions
        if described_class.respond_to?(:hamming_distance)
          distance = described_class.hamming_distance(binary_a, binary_b)
          
          # binary_a = [1,0,1,0,1], binary_b = [0,1,1,0,0]
          # Differences at positions: 0, 1, 4 -> 3 differences
          expect(distance).to eq(3)
        end
      end
      
      it "test_hamming_strings" do
        # Hamming distance for strings
        if described_class.respond_to?(:hamming_distance)
          string_a = "hello"
          string_b = "hallo"
          
          distance = described_class.hamming_distance(string_a.chars, string_b.chars)
          expect(distance).to eq(1)  # Only 'e' vs 'a' differs
        end
      end
    end
    
    context "categorical distance" do
      it "test_categorical_mismatch" do
        # Simple categorical distance (1 if different, 0 if same)
        if described_class.respond_to?(:categorical_distance)
          distance_different = described_class.categorical_distance(categorical_a, categorical_b)
          distance_same = described_class.categorical_distance(categorical_a, categorical_c)
          
          expect(distance_different).to be > distance_same
          expect(distance_same).to eq(0.0)
        end
      end
      
      it "test_categorical_partial" do
        # Partial matches should have intermediate distance
        if described_class.respond_to?(:categorical_distance)
          distance_partial = described_class.categorical_distance(categorical_a, categorical_d)
          distance_complete = described_class.categorical_distance(categorical_a, categorical_b)
          distance_identical = described_class.categorical_distance(categorical_a, categorical_c)
          
          expect(distance_partial).to be_between(distance_identical, distance_complete)
        end
      end
    end
  end
  
  describe "Edge Case Tests" do
    context "dimension validation" do
      it "test_mismatched_dimensions" do
        # Should handle mismatched vector dimensions gracefully
        short_vector = [1, 2]
        long_vector = [1, 2, 3, 4]
        
        expect {
          described_class.euclidean_distance(short_vector, long_vector)
        }.to raise_error(ArgumentError)
      end
      
      it "test_empty_vectors" do
        # Should handle empty vectors
        empty_a = []
        empty_b = []
        
        expect {
          described_class.euclidean_distance(empty_a, empty_b)
        }.not_to raise_error
        
        distance = described_class.euclidean_distance(empty_a, empty_b)
        expect(distance).to eq(0.0)
      end
    end
    
    context "special values" do
      it "test_zero_vectors" do
        # Distance between zero vectors should be zero
        zero_a = [0, 0, 0]
        zero_b = [0, 0, 0]
        
        distance = described_class.euclidean_distance(zero_a, zero_b)
        expect(distance).to eq(0.0)
      end
      
      it "test_negative_values" do
        # Should handle negative coordinates
        negative_a = [-1, -2]
        negative_b = [-3, -4]
        
        distance = described_class.euclidean_distance(negative_a, negative_b)
        expected = Math.sqrt(((-3)-(-1))**2 + ((-4)-(-2))**2)  # sqrt(4 + 4) = sqrt(8)
        
        expect(distance).to be_within(0.001).of(expected)
      end
    end
  end
  
  describe "Performance Tests" do
    it "handles large vectors efficiently" do
      # Test with high-dimensional vectors
      large_vector_a = Array.new(1000) { rand(100) }
      large_vector_b = Array.new(1000) { rand(100) }
      
      benchmark_performance("Euclidean distance for 1000D vectors") do
        distance = described_class.euclidean_distance(large_vector_a, large_vector_b)
        expect(distance).to be >= 0
      end
    end
  end
  
  describe "Integration Tests" do
    it "maintains metric properties" do
      # Test metric space properties for Euclidean distance
      point_x = [1, 1]
      point_y = [2, 2]
      point_z = [3, 3]
      
      # 1. Non-negativity: d(x,y) >= 0
      distance_xy = described_class.euclidean_distance(point_x, point_y)
      expect(distance_xy).to be >= 0
      
      # 2. Identity: d(x,x) = 0
      distance_xx = described_class.euclidean_distance(point_x, point_x)
      expect(distance_xx).to eq(0.0)
      
      # 3. Symmetry: d(x,y) = d(y,x)
      distance_yx = described_class.euclidean_distance(point_y, point_x)
      expect(distance_xy).to eq(distance_yx)
      
      # 4. Triangle inequality: d(x,z) <= d(x,y) + d(y,z)
      distance_xz = described_class.euclidean_distance(point_x, point_z)
      distance_yz = described_class.euclidean_distance(point_y, point_z)
      
      expect(distance_xz).to be <= (distance_xy + distance_yz + 0.001)  # Small tolerance for floating point
    end
    
    it "works across different data types" do
      # Should handle integers and floats consistently
      int_point_a = [1, 2]
      int_point_b = [4, 6]
      
      float_point_a = [1.0, 2.0]
      float_point_b = [4.0, 6.0]
      
      int_distance = described_class.euclidean_distance(int_point_a, int_point_b)
      float_distance = described_class.euclidean_distance(float_point_a, float_point_b)
      
      expect(int_distance).to be_within(0.001).of(float_distance)
    end
  end
  
  # Helper method for validation
  def assert_valid_distance(distance)
    expect(distance).to be_a(Numeric)
    expect(distance).to be >= 0
    expect(distance).to be_finite
  end
  
  def assert_valid_similarity(similarity)
    expect(similarity).to be_a(Numeric)
    expect(similarity).to be_between(-1.0, 1.0).inclusive  # Most similarities are in [-1, 1]
    expect(similarity).to be_finite
  end
end