# frozen_string_literal: true

module DataHelper
  # Generate simple 2D clustered data for testing
  def generate_clustered_data(clusters: 2, points_per_cluster: 10, dimensions: 2, spread: 0.5)
    data_items = []
    labels = []
    
    clusters.times do |cluster_id|
      # Generate center for this cluster
      center = Array.new(dimensions) { rand(0..10) }
      
      points_per_cluster.times do
        # Generate point around center
        point = center.map { |c| c + rand(-spread..spread) }
        data_items << point
        labels << "Cluster#{cluster_id}"
      end
    end
    
    Ai4r::Data::DataSet.new(
      data_items: data_items,
      labels: labels
    )
  end
  
  # Generate XOR dataset for neural network testing
  def generate_xor_data
    Ai4r::Data::DataSet.new(
      data_items: [[0, 0], [0, 1], [1, 0], [1, 1]],
      labels: [0, 1, 1, 0]
    )
  end
  
  # Generate linearly separable data for classification
  def generate_linear_data(samples: 20)
    data_items = []
    labels = []
    
    (samples / 2).times do
      # Class A - below line y = x
      x = rand(0..5)
      y = rand(0..x)
      data_items << [x, y]
      labels << 'A'
    end
    
    (samples / 2).times do
      # Class B - above line y = x
      x = rand(0..5)
      y = rand(x..5)
      data_items << [x, y]
      labels << 'B'
    end
    
    Ai4r::Data::DataSet.new(
      data_items: data_items,
      labels: labels
    )
  end
  
  # Generate time series data
  def generate_time_series(length: 100, trend: 0.1, noise: 0.5)
    data = []
    value = 0
    
    length.times do |t|
      value += trend + rand(-noise..noise)
      data << [t, value]
    end
    
    Ai4r::Data::DataSet.new(data_items: data)
  end
  
  # Generate dataset with missing values
  def generate_missing_data(rows: 10, cols: 3, missing_percent: 0.1)
    data_items = rows.times.map do
      cols.times.map do
        rand < missing_percent ? nil : rand(0..10)
      end
    end
    
    Ai4r::Data::DataSet.new(data_items: data_items)
  end
end

RSpec.configure do |config|
  config.include DataHelper
end