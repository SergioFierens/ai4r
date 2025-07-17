# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/educational/examples/clusterer_examples'

RSpec.describe Ai4r::Clusterers::EducationalExamples do
  describe '.beginner_tutorial' do
    it 'provides basic clustering concepts' do
      tutorial = described_class.beginner_tutorial
      
      expect(tutorial).to include(
        title: 'Clustering Fundamentals for Beginners',
        description: a_string_including('clustering'),
        concepts: an_instance_of(Array),
        examples: an_instance_of(Array)
      )
    end

    it 'includes K-means example' do
      tutorial = described_class.beginner_tutorial
      example = tutorial[:examples].find { |e| e[:algorithm] == 'K-means' }
      
      expect(example).not_to be_nil
      expect(example[:code]).to include('KMeans')
      expect(example[:explanation]).to be_a(String)
    end

    it 'provides interactive exercises' do
      tutorial = described_class.beginner_tutorial
      
      expect(tutorial[:exercises]).to be_an(Array)
      expect(tutorial[:exercises].first).to include(:task, :hint, :solution)
    end
  end

  describe '.intermediate_tutorial' do
    it 'covers hierarchical clustering' do
      tutorial = described_class.intermediate_tutorial
      
      expect(tutorial[:algorithms]).to include('Hierarchical Clustering')
      expect(tutorial[:concepts]).to include('Linkage Methods')
    end

    it 'includes DBSCAN example' do
      tutorial = described_class.intermediate_tutorial
      example = tutorial[:examples].find { |e| e[:algorithm] == 'DBSCAN' }
      
      expect(example).not_to be_nil
      expect(example[:parameters]).to include(:epsilon, :min_points)
    end

    it 'provides comparison examples' do
      tutorial = described_class.intermediate_tutorial
      
      expect(tutorial[:comparisons]).to be_an(Array)
      expect(tutorial[:comparisons].first).to include(:algorithms, :dataset, :results)
    end
  end

  describe '.advanced_tutorial' do
    it 'covers advanced clustering topics' do
      tutorial = described_class.advanced_tutorial
      
      expect(tutorial[:topics]).to include(
        'Gaussian Mixture Models',
        'Spectral Clustering',
        'Cluster Validation'
      )
    end

    it 'includes mathematical foundations' do
      tutorial = described_class.advanced_tutorial
      
      expect(tutorial[:mathematics]).to be_an(Array)
      expect(tutorial[:mathematics].first).to include(:concept, :formula, :explanation)
    end

    it 'provides research papers' do
      tutorial = described_class.advanced_tutorial
      
      expect(tutorial[:references]).to be_an(Array)
      expect(tutorial[:references].first).to include(:title, :authors, :year)
    end
  end

  describe '.clustering_comparison' do
    let(:dataset) { Ai4r::Data::DataSet.create_blobs_dataset }

    it 'compares multiple clustering algorithms' do
      comparison = described_class.clustering_comparison(dataset)
      
      expect(comparison).to include(:dataset_info, :results, :recommendations)
      expect(comparison[:results]).to have_key(:kmeans)
      expect(comparison[:results]).to have_key(:dbscan)
      expect(comparison[:results]).to have_key(:hierarchical)
    end

    it 'provides performance metrics' do
      comparison = described_class.clustering_comparison(dataset)
      
      kmeans_result = comparison[:results][:kmeans]
      expect(kmeans_result).to include(:time, :clusters, :silhouette_score)
    end

    it 'generates visualization data' do
      comparison = described_class.clustering_comparison(dataset)
      
      expect(comparison[:visualizations]).to be_an(Array)
      expect(comparison[:visualizations].first).to include(:type, :data, :config)
    end
  end

  describe '.explain_algorithm' do
    it 'explains K-means algorithm' do
      explanation = described_class.explain_algorithm(:kmeans)
      
      expect(explanation).to include(
        :name,
        :description,
        :pros,
        :cons,
        :use_cases,
        :parameters,
        :complexity
      )
    end

    it 'provides step-by-step walkthrough' do
      explanation = described_class.explain_algorithm(:kmeans)
      
      expect(explanation[:steps]).to be_an(Array)
      expect(explanation[:steps].first).to include(:step_number, :description, :code)
    end

    it 'includes visual aids' do
      explanation = described_class.explain_algorithm(:kmeans)
      
      expect(explanation[:visualizations]).to be_an(Array)
      expect(explanation[:visualizations].first).to include(:type, :description)
    end
  end

  describe '.create_example_dataset' do
    it 'creates appropriate dataset for algorithm' do
      dataset = described_class.create_example_dataset(:kmeans)
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_items).not_to be_empty
    end

    it 'creates challenging dataset for DBSCAN' do
      dataset = described_class.create_example_dataset(:dbscan)
      
      # Should include noise points
      expect(dataset.data_items.size).to be > 50
    end
  end

  describe '.evaluate_clustering' do
    let(:dataset) { Ai4r::Data::DataSet.create_blobs_dataset(n_clusters: 3) }
    let(:clusters) do
      kmeans = Ai4r::Clusterers::KMeans.new
      kmeans.build(dataset, 3)
      kmeans.clusters
    end

    it 'calculates clustering metrics' do
      evaluation = described_class.evaluate_clustering(dataset, clusters)
      
      expect(evaluation).to include(
        :silhouette_score,
        :davies_bouldin_index,
        :calinski_harabasz_score
      )
    end

    it 'provides interpretation' do
      evaluation = described_class.evaluate_clustering(dataset, clusters)
      
      expect(evaluation[:interpretation]).to be_a(String)
      expect(['Poor', 'Fair', 'Good', 'Excellent']).to include(evaluation[:quality_rating])
    end
  end

  describe '.suggest_parameters' do
    let(:dataset) { Ai4r::Data::DataSet.create_blobs_dataset }

    it 'suggests K for K-means' do
      suggestions = described_class.suggest_parameters(:kmeans, dataset)
      
      expect(suggestions[:k]).to be_a(Integer)
      expect(suggestions[:k]).to be_between(2, 10)
      expect(suggestions[:elbow_plot]).to be_an(Array)
    end

    it 'suggests epsilon for DBSCAN' do
      suggestions = described_class.suggest_parameters(:dbscan, dataset)
      
      expect(suggestions[:epsilon]).to be_a(Float)
      expect(suggestions[:min_points]).to be_a(Integer)
      expect(suggestions[:k_distance_plot]).to be_an(Array)
    end
  end

  describe '.common_mistakes' do
    it 'lists common clustering mistakes' do
      mistakes = described_class.common_mistakes
      
      expect(mistakes).to be_an(Array)
      expect(mistakes.first).to include(
        :mistake,
        :example,
        :consequence,
        :solution
      )
    end
  end

  describe '.best_practices' do
    it 'provides clustering best practices' do
      practices = described_class.best_practices
      
      expect(practices).to include(
        :data_preparation,
        :algorithm_selection,
        :parameter_tuning,
        :validation,
        :interpretation
      )
    end
  end
end