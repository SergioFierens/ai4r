# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/data/data_set'
require 'ai4r/data/educational_data_examples'

RSpec.describe 'Ai4r::Data Educational Data Examples' do
  describe 'Iris Dataset' do
    it 'creates an Iris dataset with correct structure' do
      dataset = Ai4r::Data::DataSet.create_iris_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_items.size).to eq(150)
      expect(dataset.data_labels).to eq(['sepal_length', 'sepal_width', 'petal_length', 'petal_width', 'species'])
    end

    it 'contains all three Iris species' do
      dataset = Ai4r::Data::DataSet.create_iris_dataset
      species = dataset.data_items.map(&:last).uniq.sort
      
      expect(species).to eq(['setosa', 'versicolor', 'virginica'])
    end

    it 'has correct number of samples per species' do
      dataset = Ai4r::Data::DataSet.create_iris_dataset
      species_counts = dataset.data_items.group_by(&:last).transform_values(&:count)
      
      expect(species_counts['setosa']).to eq(50)
      expect(species_counts['versicolor']).to eq(50)
      expect(species_counts['virginica']).to eq(50)
    end
  end

  describe 'Weather Dataset' do
    it 'creates a weather dataset for classification' do
      dataset = Ai4r::Data::DataSet.create_weather_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to eq(['outlook', 'temperature', 'humidity', 'wind', 'play_tennis'])
    end

    it 'contains categorical and binary data' do
      dataset = Ai4r::Data::DataSet.create_weather_dataset
      play_values = dataset.data_items.map(&:last).uniq.sort
      
      expect(play_values).to eq(['no', 'yes'])
    end
  end

  describe 'XOR Dataset' do
    it 'creates XOR dataset for neural network testing' do
      dataset = Ai4r::Data::DataSet.create_xor_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_items.size).to eq(4)
      expect(dataset.data_labels).to eq(['x1', 'x2', 'output'])
    end

    it 'implements correct XOR logic' do
      dataset = Ai4r::Data::DataSet.create_xor_dataset
      
      expect(dataset.data_items).to include([0, 0, 0])
      expect(dataset.data_items).to include([0, 1, 1])
      expect(dataset.data_items).to include([1, 0, 1])
      expect(dataset.data_items).to include([1, 1, 0])
    end
  end

  describe 'Clustering Datasets' do
    it 'creates 2D clustering dataset' do
      dataset = Ai4r::Data::DataSet.create_2d_clustering_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to eq(['x', 'y'])
      expect(dataset.data_items.first.size).to eq(2)
    end

    it 'creates blobs dataset with specified clusters' do
      n_clusters = 3
      dataset = Ai4r::Data::DataSet.create_blobs_dataset(n_clusters: n_clusters, n_samples: 30)
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_items.size).to eq(30)
    end

    it 'creates concentric circles dataset' do
      dataset = Ai4r::Data::DataSet.create_concentric_circles_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to eq(['x', 'y', 'cluster'])
    end
  end

  describe 'Time Series Datasets' do
    it 'creates sine wave dataset' do
      dataset = Ai4r::Data::DataSet.create_sine_wave_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to eq(['time', 'value'])
    end

    it 'creates stock price simulation' do
      dataset = Ai4r::Data::DataSet.create_stock_price_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to include('open', 'high', 'low', 'close', 'volume')
    end
  end

  describe 'Text Classification Datasets' do
    it 'creates sentiment analysis dataset' do
      dataset = Ai4r::Data::DataSet.create_sentiment_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to eq(['text', 'sentiment'])
      
      sentiments = dataset.data_items.map(&:last).uniq.sort
      expect(sentiments).to eq(['negative', 'positive'])
    end

    it 'creates spam classification dataset' do
      dataset = Ai4r::Data::DataSet.create_spam_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to eq(['text', 'is_spam'])
    end
  end

  describe 'Regression Datasets' do
    it 'creates linear regression dataset' do
      dataset = Ai4r::Data::DataSet.create_linear_regression_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to eq(['x', 'y'])
    end

    it 'creates polynomial regression dataset' do
      dataset = Ai4r::Data::DataSet.create_polynomial_dataset(degree: 3)
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_items.first.size).to eq(2)
    end

    it 'creates housing price dataset' do
      dataset = Ai4r::Data::DataSet.create_housing_dataset
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_labels).to include('bedrooms', 'bathrooms', 'sqft', 'price')
    end
  end

  describe 'Educational Tutorials' do
    it 'provides beginner tutorial' do
      tutorial = Ai4r::Data::DataSet.beginner_tutorial
      
      expect(tutorial).to be_a(Hash)
      expect(tutorial[:title]).to include('Beginner')
      expect(tutorial[:datasets]).to be_an(Array)
      expect(tutorial[:exercises]).to be_an(Array)
    end

    it 'provides intermediate tutorial' do
      tutorial = Ai4r::Data::DataSet.intermediate_tutorial
      
      expect(tutorial).to be_a(Hash)
      expect(tutorial[:title]).to include('Intermediate')
      expect(tutorial[:topics]).to include('Feature Engineering')
    end

    it 'provides advanced tutorial' do
      tutorial = Ai4r::Data::DataSet.advanced_tutorial
      
      expect(tutorial).to be_a(Hash)
      expect(tutorial[:title]).to include('Advanced')
      expect(tutorial[:topics]).to include('Dimensionality Reduction')
    end
  end
end