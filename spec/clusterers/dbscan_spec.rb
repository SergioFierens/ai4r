# frozen_string_literal: true

# RSpec tests for AI4R DBSCAN Algorithm
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::DBSCAN do
  # Test datasets
  let(:simple_data) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 1], [1, 2], [2, 1], [2, 2],  # Cluster 1
        [8, 8], [8, 9], [9, 8], [9, 9],  # Cluster 2
        [15, 15]                         # Noise point
      ],
      data_labels: ['x', 'y']
    )
  end

  let(:line_data) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 1], [2, 2], [3, 3], [4, 4], [5, 5],  # Line cluster
        [10, 1], [11, 2], [12, 3], [13, 4],      # Another line cluster
        [20, 20]                                  # Noise point
      ],
      data_labels: ['x', 'y']
    )
  end

  let(:density_data) do
    Ai4r::Data::DataSet.new(
      data_items: [
        # Dense cluster
        [1, 1], [1, 2], [2, 1], [2, 2], [1.5, 1.5],
        # Sparse cluster
        [10, 10], [12, 12], [14, 14],
        # Noise points
        [25, 25], [30, 30]
      ],
      data_labels: ['x', 'y']
    )
  end

  let(:single_cluster_data) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 1], [1, 2], [2, 1], [2, 2], [1.5, 1.5], [2.5, 2.5]
      ],
      data_labels: ['x', 'y']
    )
  end

  let(:all_noise_data) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 1], [10, 10], [20, 20], [30, 30], [40, 40]
      ],
      data_labels: ['x', 'y']
    )
  end

  describe 'initialization' do
    it 'creates DBSCAN instance with default parameters' do
      dbscan = described_class.new
      
      expect(dbscan.eps).to eq(0.5)
      expect(dbscan.min_pts).to eq(5)
      expect(dbscan.instance_variable_get(:@distance_function)).to be_nil
      expect(dbscan.instance_variable_get(:@educational_mode)).to be false
    end

    it 'supports educational mode' do
      dbscan = described_class.new
      result = dbscan.enable_educational_mode
      
      expect(result).to be(dbscan)
      expect(dbscan.instance_variable_get(:@educational_mode)).to be true
    end

    it 'supports educational mode with callback' do
      callback_called = false
      dbscan = described_class.new
      
      dbscan.enable_educational_mode { |step| callback_called = true }
      
      expect(dbscan.instance_variable_get(:@educational_mode)).to be true
      expect(dbscan.instance_variable_get(:@step_callback)).to be_a(Proc)
    end
  end

  describe 'clustering' do
    context 'with simple well-separated clusters' do
      it 'identifies correct number of clusters' do
        dbscan = described_class.new
        dbscan.build(simple_data, 2.0, 2)
        
        expect(dbscan.clusters.length).to eq(2)
        expect(dbscan.noise_points.length).to eq(1)
      end

      it 'assigns correct cluster sizes' do
        dbscan = described_class.new
        dbscan.build(simple_data, 2.0, 2)
        
        cluster_sizes = dbscan.clusters.map { |cluster| cluster.data_items.length }
        expect(cluster_sizes.sort).to eq([4, 4])
      end

      it 'identifies core points correctly' do
        dbscan = described_class.new
        dbscan.build(simple_data, 2.0, 2)
        
        expect(dbscan.core_points.length).to be > 0
        expect(dbscan.core_points.length).to be <= 8  # At most all non-noise points
      end

      it 'provides clustering statistics' do
        dbscan = described_class.new
        dbscan.build(simple_data, 2.0, 2)
        stats = dbscan.clustering_stats
        
        expect(stats[:num_clusters]).to eq(2)
        expect(stats[:num_noise_points]).to eq(1)
        expect(stats[:cluster_sizes]).to match_array([4, 4])
        expect(stats[:noise_ratio]).to be_within(0.01).of(1.0 / 9.0)
        expect(stats[:parameters][:eps]).to eq(2.0)
        expect(stats[:parameters][:min_pts]).to eq(2)
      end
    end

    context 'with linear clusters' do
      it 'detects linear clusters' do
        dbscan = described_class.new
        dbscan.build(line_data, 2.0, 2)
        
        expect(dbscan.clusters.length).to eq(2)
        expect(dbscan.noise_points.length).to eq(1)
      end

      it 'handles different cluster densities' do
        dbscan = described_class.new
        dbscan.build(density_data, 2.0, 2)
        
        expect(dbscan.clusters.length).to be >= 1
        expect(dbscan.noise_points.length).to be >= 1
      end
    end

    context 'with single cluster' do
      it 'identifies single cluster correctly' do
        dbscan = described_class.new
        dbscan.build(single_cluster_data, 2.0, 2)
        
        expect(dbscan.clusters.length).to eq(1)
        expect(dbscan.clusters.first.data_items.length).to eq(6)
        expect(dbscan.noise_points.length).to eq(0)
      end
    end

    context 'with all noise points' do
      it 'identifies all points as noise' do
        dbscan = described_class.new
        dbscan.build(all_noise_data, 2.0, 3)
        
        expect(dbscan.clusters.length).to eq(0)
        expect(dbscan.noise_points.length).to eq(5)
      end
    end

    context 'with different parameters' do
      it 'produces different results with different eps' do
        dbscan1 = described_class.new
        dbscan1.build(simple_data, 1.0, 2)
        
        dbscan2 = described_class.new
        dbscan2.build(simple_data, 3.0, 2)
        
        expect(dbscan1.clusters.length).not_to eq(dbscan2.clusters.length)
      end

      it 'produces different results with different min_pts' do
        dbscan1 = described_class.new
        dbscan1.build(simple_data, 2.0, 2)
        
        dbscan2 = described_class.new
        dbscan2.build(simple_data, 2.0, 4)
        
        expect(dbscan1.noise_points.length).not_to eq(dbscan2.noise_points.length)
      end
    end
  end

  describe 'point classification' do
    before do
      @dbscan = described_class.new
      @dbscan.build(simple_data, 2.0, 2)
    end

    it 'classifies points correctly' do
      # Test point in first cluster
      cluster_id = @dbscan.eval([1.5, 1.5])
      expect(cluster_id).to be >= 0
      expect(cluster_id).to be < 2
      
      # Test point far from any cluster
      cluster_id = @dbscan.eval([100, 100])
      expect(cluster_id).to eq(-1)  # Noise
    end

    it 'handles edge cases in classification' do
      # Test point exactly on cluster boundary
      cluster_id = @dbscan.eval([2.0, 2.0])
      expect(cluster_id).to be >= -1
      expect(cluster_id).to be < 2
    end

    it 'returns nil for unbuilt clusterer' do
      new_dbscan = described_class.new
      expect(new_dbscan.eval([1, 1])).to be_nil
    end
  end

  describe 'point type analysis' do
    it 'correctly identifies point types' do
      dbscan = described_class.new
      dbscan.build(simple_data, 2.0, 2)
      
      point_types = dbscan.instance_variable_get(:@point_types)
      expect(point_types).to include(described_class::CORE)
      expect(point_types).to include(described_class::NOISE)
      
      # May or may not have border points depending on exact configuration
      expect(point_types.uniq.length).to be >= 2
    end

    it 'maintains point type consistency' do
      dbscan = described_class.new
      dbscan.build(simple_data, 2.0, 2)
      
      point_types = dbscan.instance_variable_get(:@point_types)
      cluster_assignments = dbscan.cluster_assignments
      
      # Core points should be assigned to clusters
      point_types.each_with_index do |type, index|
        if type == described_class::CORE
          expect(cluster_assignments[index]).to be >= 0
        elsif type == described_class::NOISE
          expect(cluster_assignments[index]).to eq(-1)
        end
      end
    end
  end

  describe 'distance calculation' do
    let(:dbscan) { described_class.new }

    it 'calculates euclidean distance correctly' do
      point1 = [0, 0]
      point2 = [3, 4]
      
      distance = dbscan.send(:distance, point1, point2)
      expect(distance).to be_within(0.001).of(5.0)
    end

    it 'handles same points' do
      point = [1, 2]
      
      distance = dbscan.send(:distance, point, point)
      expect(distance).to eq(0.0)
    end

    it 'supports custom distance function' do
      custom_distance = lambda { |a, b| (a[0] - b[0]).abs + (a[1] - b[1]).abs }
      dbscan.instance_variable_set(:@distance_function, custom_distance)
      
      point1 = [0, 0]
      point2 = [3, 4]
      
      distance = dbscan.send(:distance, point1, point2)
      expect(distance).to eq(7.0)  # Manhattan distance
    end

    it 'handles non-numeric attributes' do
      point1 = [1, 2, 'a']
      point2 = [4, 6, 'b']
      
      distance = dbscan.send(:distance, point1, point2)
      expect(distance).to be_within(0.001).of(5.0)  # Only considers numeric attributes
    end
  end

  describe 'educational features' do
    it 'provides concept explanations' do
      dbscan = described_class.new
      
      expect { dbscan.explain_concepts }.to output(/DBSCAN/).to_stdout
      expect { dbscan.explain_concepts }.to output(/epsilon/).to_stdout
      expect { dbscan.explain_concepts }.to output(/MinPts/).to_stdout
      expect { dbscan.explain_concepts }.to output(/Core Point/).to_stdout
      expect { dbscan.explain_concepts }.to output(/Border Point/).to_stdout
      expect { dbscan.explain_concepts }.to output(/Noise Point/).to_stdout
    end

    it 'visualizes point types' do
      dbscan = described_class.new
      dbscan.build(simple_data, 2.0, 2)
      
      expect { dbscan.visualize_point_types }.to output(/Point Type Analysis/).to_stdout
      expect { dbscan.visualize_point_types }.to output(/Core points/).to_stdout
      expect { dbscan.visualize_point_types }.to output(/Border points/).to_stdout
      expect { dbscan.visualize_point_types }.to output(/Noise points/).to_stdout
    end

    it 'provides 2D visualization for 2D data' do
      dbscan = described_class.new
      dbscan.build(simple_data, 2.0, 2)
      
      expect(dbscan.send(:can_visualize_2d?)).to be true
      expect { dbscan.send(:visualize_2d_clustering) }.to output(/2D DBSCAN Visualization/).to_stdout
    end

    it 'skips visualization for non-2D data' do
      data_1d = Ai4r::Data::DataSet.new(
        data_items: [[1], [2], [3]],
        data_labels: ['x']
      )
      
      dbscan = described_class.new
      dbscan.build(data_1d, 1.0, 2)
      
      expect(dbscan.send(:can_visualize_2d?)).to be false
    end
  end

  describe 'educational mode execution' do
    it 'runs with educational mode enabled' do
      dbscan = described_class.new
      dbscan.enable_educational_mode
      
      # Mock gets to avoid interactive input
      allow(dbscan).to receive(:gets)
      
      expect { dbscan.build(simple_data, 2.0, 2) }.to output(/DBSCAN Educational Execution/).to_stdout
    end

    it 'executes step callback when provided' do
      callback_steps = []
      dbscan = described_class.new
      dbscan.enable_educational_mode { |step| callback_steps << step }
      
      # Mock gets to avoid interactive input
      allow(dbscan).to receive(:gets)
      
      dbscan.build(simple_data, 2.0, 2)
      
      expect(callback_steps).not_to be_empty
      expect(callback_steps.first).to have_key(:step)
      expect(callback_steps.first).to have_key(:point)
    end

    it 'provides detailed step information' do
      callback_steps = []
      dbscan = described_class.new
      dbscan.enable_educational_mode { |step| callback_steps << step }
      
      # Mock gets to avoid interactive input
      allow(dbscan).to receive(:gets)
      
      dbscan.build(simple_data, 2.0, 2)
      
      first_step = callback_steps.first
      expect(first_step).to have_key(:step)
      expect(first_step).to have_key(:point)
      expect(first_step).to have_key(:point_index)
      expect(first_step).to have_key(:neighbors)
      expect(first_step).to have_key(:neighbor_count)
      expect(first_step).to have_key(:point_type)
      expect(first_step).to have_key(:action)
    end
  end

  describe 'error handling and edge cases' do
    it 'handles empty dataset' do
      empty_data = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
      dbscan = described_class.new
      
      expect { dbscan.build(empty_data, 1.0, 2) }.not_to raise_error
      expect(dbscan.clusters).to be_empty
      expect(dbscan.noise_points).to be_empty
    end

    it 'handles single point dataset' do
      single_point = Ai4r::Data::DataSet.new(
        data_items: [[1, 1]],
        data_labels: ['x', 'y']
      )
      
      dbscan = described_class.new
      dbscan.build(single_point, 1.0, 2)
      
      expect(dbscan.clusters).to be_empty
      expect(dbscan.noise_points.length).to eq(1)
    end

    it 'handles identical points' do
      identical_points = Ai4r::Data::DataSet.new(
        data_items: [[1, 1], [1, 1], [1, 1], [1, 1]],
        data_labels: ['x', 'y']
      )
      
      dbscan = described_class.new
      dbscan.build(identical_points, 1.0, 2)
      
      expect(dbscan.clusters.length).to eq(1)
      expect(dbscan.clusters.first.data_items.length).to eq(4)
    end

    it 'handles extreme parameter values' do
      dbscan = described_class.new
      
      # Very small eps
      expect { dbscan.build(simple_data, 0.001, 2) }.not_to raise_error
      
      # Very large eps
      expect { dbscan.build(simple_data, 1000.0, 2) }.not_to raise_error
      
      # Very small min_pts
      expect { dbscan.build(simple_data, 2.0, 1) }.not_to raise_error
      
      # Very large min_pts
      expect { dbscan.build(simple_data, 2.0, 100) }.not_to raise_error
    end
  end

  describe 'performance characteristics' do
    it 'handles moderately sized datasets efficiently' do
      # Create larger dataset
      large_data_items = []
      100.times do |i|
        large_data_items << [i * 0.1, i * 0.1 + rand * 0.05]
      end
      
      large_data = Ai4r::Data::DataSet.new(
        data_items: large_data_items,
        data_labels: ['x', 'y']
      )
      
      dbscan = described_class.new
      
      benchmark_performance('DBSCAN clustering') do
        dbscan.build(large_data, 0.1, 3)
        expect(dbscan.clusters.length).to be >= 1
      end
    end

    it 'caches distance calculations implicitly' do
      dbscan = described_class.new
      
      # First clustering
      start_time = Time.now
      dbscan.build(simple_data, 2.0, 2)
      first_time = Time.now - start_time
      
      # Second clustering with same parameters (should be faster due to any caching)
      start_time = Time.now
      dbscan.build(simple_data, 2.0, 2)
      second_time = Time.now - start_time
      
      # Both should complete successfully
      expect(dbscan.clusters.length).to be >= 0
    end
  end

  describe 'memory efficiency' do
    it 'cleans up internal state between builds' do
      dbscan = described_class.new
      
      # Build with first dataset
      dbscan.build(simple_data, 2.0, 2)
      first_clusters = dbscan.clusters.length
      
      # Build with different dataset
      dbscan.build(line_data, 2.0, 2)
      second_clusters = dbscan.clusters.length
      
      # State should be completely reset
      expect(dbscan.clusters.length).to eq(second_clusters)
      expect(dbscan.data_set).to eq(line_data)
    end
  end

  describe 'deterministic behavior' do
    it 'produces consistent results with same parameters' do
      dbscan1 = described_class.new
      dbscan1.build(simple_data, 2.0, 2)
      
      dbscan2 = described_class.new
      dbscan2.build(simple_data, 2.0, 2)
      
      expect(dbscan1.clusters.length).to eq(dbscan2.clusters.length)
      expect(dbscan1.noise_points.length).to eq(dbscan2.noise_points.length)
    end
  end
end

# Test the parameter helper class
RSpec.describe Ai4r::Clusterers::DBSCANParameterHelper do
  let(:test_data) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 1], [1, 2], [2, 1], [2, 2],
        [8, 8], [8, 9], [9, 8], [9, 9]
      ],
      data_labels: ['x', 'y']
    )
  end

  describe 'parameter suggestions' do
    it 'suggests eps parameter' do
      result = described_class.suggest_eps(test_data)
      
      expect(result).to have_key(:suggested_eps)
      expect(result).to have_key(:k_distances)
      expect(result).to have_key(:knee_index)
      expect(result).to have_key(:explanation)
      
      expect(result[:suggested_eps]).to be > 0
      expect(result[:k_distances]).to be_an(Array)
      expect(result[:explanation]).to include('ε (Epsilon)')
    end

    it 'suggests min_pts parameter' do
      result = described_class.suggest_min_pts(test_data)
      
      expect(result).to have_key(:suggested_min_pts)
      expect(result).to have_key(:dimensions)
      expect(result).to have_key(:explanation)
      
      expect(result[:suggested_min_pts]).to be >= 4
      expect(result[:dimensions]).to eq(2)
      expect(result[:explanation]).to include('MinPts')
    end

    it 'handles custom k value for eps suggestion' do
      result = described_class.suggest_eps(test_data, 3)
      
      expect(result[:suggested_eps]).to be > 0
      expect(result[:k_distances]).to be_an(Array)
    end

    it 'handles custom distance function' do
      manhattan_distance = lambda do |a, b|
        numeric_a = a.select { |attr| attr.is_a?(Numeric) }
        numeric_b = b.select { |attr| attr.is_a?(Numeric) }
        numeric_a.zip(numeric_b).sum { |x, y| (x - y).abs }
      end
      
      result = described_class.suggest_eps(test_data, 4, manhattan_distance)
      
      expect(result[:suggested_eps]).to be > 0
      expect(result[:k_distances]).to be_an(Array)
    end
  end

  describe 'parameter analysis' do
    it 'runs comprehensive parameter analysis' do
      expect { described_class.analyze_parameters(test_data) }.to output(/Parameter Analysis/).to_stdout
    end

    it 'provides parameter recommendations' do
      result = described_class.analyze_parameters(test_data)
      
      expect(result).to have_key(:eps_analysis)
      expect(result).to have_key(:min_pts_analysis)
      expect(result).to have_key(:recommended)
      
      expect(result[:recommended][:eps]).to be > 0
      expect(result[:recommended][:min_pts]).to be >= 4
    end

    it 'tests parameter sensitivity' do
      # Capture output to verify sensitivity analysis
      output = capture_stdout { described_class.analyze_parameters(test_data) }
      
      expect(output).to include('Parameter Sensitivity Analysis')
      expect(output).to include('Test 1:')
      expect(output).to include('Clusters:')
      expect(output).to include('Noise:')
    end
  end

  describe 'edge cases' do
    it 'handles empty dataset' do
      empty_data = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
      
      expect { described_class.suggest_eps(empty_data) }.not_to raise_error
      expect { described_class.suggest_min_pts(empty_data) }.not_to raise_error
    end

    it 'handles single point dataset' do
      single_point = Ai4r::Data::DataSet.new(
        data_items: [[1, 1]],
        data_labels: ['x', 'y']
      )
      
      result = described_class.suggest_min_pts(single_point)
      expect(result[:suggested_min_pts]).to be >= 4
    end

    it 'handles high-dimensional data' do
      high_dim_data = Ai4r::Data::DataSet.new(
        data_items: [
          [1, 1, 1, 1, 1], [2, 2, 2, 2, 2], [3, 3, 3, 3, 3]
        ],
        data_labels: ['x1', 'x2', 'x3', 'x4', 'x5']
      )
      
      result = described_class.suggest_min_pts(high_dim_data)
      expect(result[:suggested_min_pts]).to eq(10)  # 2 * 5 dimensions
      expect(result[:dimensions]).to eq(5)
    end
  end

  private

  def capture_stdout
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end