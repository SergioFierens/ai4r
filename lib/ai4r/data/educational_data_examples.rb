# frozen_string_literal: true

require_relative 'data_set'

module Ai4r
  module Data
    class DataSet
      # Educational example datasets for learning and testing
      
      # Classic datasets
      def self.create_iris_dataset
        data_items = []
        
        # Setosa samples (50)
        50.times do
          data_items << [5.0 + rand * 0.5, 3.5 + rand * 0.5, 1.4 + rand * 0.3, 0.2 + rand * 0.1, 'setosa']
        end
        
        # Versicolor samples (50)
        50.times do
          data_items << [5.9 + rand * 0.8, 2.8 + rand * 0.4, 4.3 + rand * 0.5, 1.3 + rand * 0.3, 'versicolor']
        end
        
        # Virginica samples (50)
        50.times do
          data_items << [6.3 + rand * 0.9, 2.9 + rand * 0.5, 5.6 + rand * 0.6, 1.8 + rand * 0.4, 'virginica']
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['sepal_length', 'sepal_width', 'petal_length', 'petal_width', 'species']
        )
      end
      
      def self.create_weather_dataset
        data_items = [
          ['sunny', 'hot', 'high', 'weak', 'no'],
          ['sunny', 'hot', 'high', 'strong', 'no'],
          ['overcast', 'hot', 'high', 'weak', 'yes'],
          ['rain', 'mild', 'high', 'weak', 'yes'],
          ['rain', 'cool', 'normal', 'weak', 'yes'],
          ['rain', 'cool', 'normal', 'strong', 'no'],
          ['overcast', 'cool', 'normal', 'strong', 'yes'],
          ['sunny', 'mild', 'high', 'weak', 'no'],
          ['sunny', 'cool', 'normal', 'weak', 'yes'],
          ['rain', 'mild', 'normal', 'weak', 'yes'],
          ['sunny', 'mild', 'normal', 'strong', 'yes'],
          ['overcast', 'mild', 'high', 'strong', 'yes'],
          ['overcast', 'hot', 'normal', 'weak', 'yes'],
          ['rain', 'mild', 'high', 'strong', 'no']
        ]
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['outlook', 'temperature', 'humidity', 'wind', 'play_tennis']
        )
      end
      
      def self.create_xor_dataset
        DataSet.new(
          data_items: [
            [0, 0, 0],
            [0, 1, 1],
            [1, 0, 1],
            [1, 1, 0]
          ],
          data_labels: ['x1', 'x2', 'output']
        )
      end
      
      # Clustering datasets
      def self.create_2d_clustering_dataset
        data_items = []
        
        # Generate 3 clusters
        # Cluster 1
        20.times do
          data_items << [2.0 + rand * 2, 2.0 + rand * 2]
        end
        
        # Cluster 2
        20.times do
          data_items << [7.0 + rand * 2, 2.0 + rand * 2]
        end
        
        # Cluster 3
        20.times do
          data_items << [4.5 + rand * 2, 6.0 + rand * 2]
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['x', 'y']
        )
      end
      
      def self.create_blobs_dataset(n_clusters: 3, n_samples: 100)
        data_items = []
        samples_per_cluster = n_samples / n_clusters
        
        n_clusters.times do |i|
          center_x = i * 5.0
          center_y = i * 3.0
          
          samples_per_cluster.times do
            data_items << [center_x + rand * 2 - 1, center_y + rand * 2 - 1]
          end
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['x', 'y']
        )
      end
      
      def self.create_concentric_circles_dataset
        data_items = []
        
        # Inner circle
        30.times do |i|
          angle = i * 2 * Math::PI / 30
          radius = 2.0 + rand * 0.3
          data_items << [radius * Math.cos(angle), radius * Math.sin(angle), 0]
        end
        
        # Outer circle
        50.times do |i|
          angle = i * 2 * Math::PI / 50
          radius = 5.0 + rand * 0.3
          data_items << [radius * Math.cos(angle), radius * Math.sin(angle), 1]
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['x', 'y', 'cluster']
        )
      end
      
      # Time series datasets
      def self.create_sine_wave_dataset
        data_items = []
        
        100.times do |i|
          time = i * 0.1
          value = Math.sin(time) + rand * 0.1 - 0.05
          data_items << [time, value]
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['time', 'value']
        )
      end
      
      def self.create_stock_price_dataset
        data_items = []
        price = 100.0
        
        100.times do |i|
          open_price = price
          high = price + rand * 5
          low = price - rand * 5
          close = price + (rand - 0.5) * 3
          volume = 1000000 + rand * 500000
          
          data_items << [open_price, high, low, close, volume]
          price = close
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['open', 'high', 'low', 'close', 'volume']
        )
      end
      
      # Text classification datasets
      def self.create_sentiment_dataset
        data_items = [
          ['This movie is amazing and wonderful!', 'positive'],
          ['I love this product, it works great', 'positive'],
          ['Excellent service and fast delivery', 'positive'],
          ['Best purchase I ever made', 'positive'],
          ['Highly recommend to everyone', 'positive'],
          ['This is terrible and disappointing', 'negative'],
          ['Worst experience ever, totally broken', 'negative'],
          ['Complete waste of money', 'negative'],
          ['Poor quality and bad service', 'negative'],
          ['I hate this, it never works', 'negative']
        ]
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['text', 'sentiment']
        )
      end
      
      def self.create_spam_dataset
        data_items = [
          ['Get your degree online now!', 1],
          ['Meeting scheduled for tomorrow at 3pm', 0],
          ['You won $1000000! Click here!', 1],
          ['Please review the attached document', 0],
          ['Free pills! Limited time offer!', 1],
          ['Can we reschedule our lunch?', 0],
          ['Congratulations! You are our winner!', 1],
          ['The project deadline is next Friday', 0]
        ]
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['text', 'is_spam']
        )
      end
      
      # Regression datasets
      def self.create_linear_regression_dataset
        data_items = []
        
        50.times do |i|
          x = i * 0.5
          y = 2 * x + 3 + (rand - 0.5) * 2
          data_items << [x, y]
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['x', 'y']
        )
      end
      
      def self.create_polynomial_dataset(degree: 2)
        data_items = []
        
        50.times do |i|
          x = (i - 25) * 0.2
          y = x**degree + (rand - 0.5) * 2
          data_items << [x, y]
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['x', 'y']
        )
      end
      
      def self.create_housing_dataset
        data_items = []
        
        50.times do
          bedrooms = 1 + rand(4)
          bathrooms = 1 + rand(3)
          sqft = 500 + bedrooms * 300 + rand(500)
          price = 50000 + bedrooms * 30000 + bathrooms * 10000 + sqft * 100 + rand(20000)
          
          data_items << [bedrooms, bathrooms, sqft, price]
        end
        
        DataSet.new(
          data_items: data_items,
          data_labels: ['bedrooms', 'bathrooms', 'sqft', 'price']
        )
      end
      
      # Educational tutorials
      def self.beginner_tutorial
        {
          title: 'Beginner\'s Guide to AI4R Data',
          description: 'Learn the basics of working with datasets in AI4R',
          datasets: [
            { name: 'Iris', method: :create_iris_dataset, difficulty: 'easy' },
            { name: 'Weather', method: :create_weather_dataset, difficulty: 'easy' },
            { name: 'XOR', method: :create_xor_dataset, difficulty: 'medium' }
          ],
          exercises: [
            {
              task: 'Load the Iris dataset and print the first 5 samples',
              hint: 'Use create_iris_dataset and data_items[0..4]',
              solution: 'dataset = Ai4r::Data::DataSet.create_iris_dataset; puts dataset.data_items[0..4]'
            }
          ]
        }
      end
      
      def self.intermediate_tutorial
        {
          title: 'Intermediate Data Handling',
          description: 'Advanced dataset manipulation and preprocessing',
          topics: ['Feature Engineering', 'Data Normalization', 'Train/Test Split'],
          datasets: [
            { name: 'Clustering', method: :create_blobs_dataset },
            { name: 'Time Series', method: :create_sine_wave_dataset }
          ],
          exercises: []
        }
      end
      
      def self.advanced_tutorial
        {
          title: 'Advanced Data Science with AI4R',
          description: 'Complex data handling and analysis',
          topics: ['Dimensionality Reduction', 'Feature Selection', 'Data Augmentation'],
          datasets: [
            { name: 'Text Classification', method: :create_sentiment_dataset },
            { name: 'Complex Regression', method: :create_polynomial_dataset }
          ],
          exercises: []
        }
      end
    end
  end
end