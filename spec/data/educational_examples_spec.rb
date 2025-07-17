# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/educational/examples/data_examples'

RSpec.describe Ai4r::Data::EducationalExamples do
  describe '.tutorial_tracks' do
    it 'provides three tutorial tracks' do
      tracks = described_class.tutorial_tracks
      
      expect(tracks.keys).to match_array([:beginner, :intermediate, :advanced])
    end

    it 'each track has proper structure' do
      tracks = described_class.tutorial_tracks
      
      tracks.each do |level, track|
        expect(track).to include(
          :title,
          :description,
          :prerequisites,
          :learning_objectives,
          :modules
        )
      end
    end
  end

  describe '.beginner_track' do
    let(:track) { described_class.tutorial_tracks[:beginner] }

    it 'covers fundamental concepts' do
      modules = track[:modules].map { |m| m[:name] }
      
      expect(modules).to include(
        'Introduction to AI4R',
        'Basic Data Structures',
        'Simple Classification',
        'Basic Clustering'
      )
    end

    it 'provides hands-on exercises' do
      first_module = track[:modules].first
      
      expect(first_module[:exercises]).to be_an(Array)
      expect(first_module[:exercises].first).to include(:title, :difficulty, :code)
    end

    it 'includes quizzes' do
      first_module = track[:modules].first
      
      expect(first_module[:quiz]).to be_an(Array)
      expect(first_module[:quiz].first).to include(:question, :options, :answer)
    end
  end

  describe '.intermediate_track' do
    let(:track) { described_class.tutorial_tracks[:intermediate] }

    it 'builds on beginner concepts' do
      expect(track[:prerequisites]).to include('Beginner Track')
    end

    it 'covers advanced algorithms' do
      modules = track[:modules].map { |m| m[:name] }
      
      expect(modules).to include(
        'Advanced Classification',
        'Neural Networks',
        'Feature Engineering'
      )
    end

    it 'includes projects' do
      expect(track[:projects]).to be_an(Array)
      expect(track[:projects].first).to include(:name, :description, :requirements)
    end
  end

  describe '.advanced_track' do
    let(:track) { described_class.tutorial_tracks[:advanced] }

    it 'covers cutting-edge topics' do
      modules = track[:modules].map { |m| m[:name] }
      
      expect(modules).to include(
        'Deep Learning',
        'Ensemble Methods',
        'AutoML'
      )
    end

    it 'includes research papers' do
      expect(track[:research_papers]).to be_an(Array)
      expect(track[:research_papers].first).to include(:title, :authors, :year, :summary)
    end

    it 'provides capstone project' do
      expect(track[:capstone_project]).to include(
        :title,
        :description,
        :deliverables,
        :evaluation_criteria
      )
    end
  end

  describe '.interactive_examples' do
    it 'provides interactive code examples' do
      examples = described_class.interactive_examples
      
      expect(examples).to be_an(Array)
      expect(examples.first).to include(
        :title,
        :description,
        :code,
        :interactive_elements
      )
    end

    it 'includes visualization examples' do
      viz_example = described_class.interactive_examples.find { |e| e[:type] == 'visualization' }
      
      expect(viz_example).not_to be_nil
      expect(['scatter', 'line', 'bar', 'heatmap']).to include(viz_example[:visualization_type])
    end
  end

  describe '.code_challenges' do
    it 'provides programming challenges' do
      challenges = described_class.code_challenges
      
      expect(challenges).to be_an(Array)
      expect(challenges.first).to include(
        :title,
        :difficulty,
        :description,
        :starter_code,
        :test_cases,
        :solution
      )
    end

    it 'has challenges for all difficulty levels' do
      challenges = described_class.code_challenges
      difficulties = challenges.map { |c| c[:difficulty] }.uniq
      
      expect(difficulties).to include('easy', 'medium', 'hard')
    end
  end

  describe '.glossary' do
    it 'provides comprehensive AI glossary' do
      glossary = described_class.glossary
      
      expect(glossary).to be_a(Hash)
      expect(glossary).to include(
        'classification',
        'clustering',
        'neural network',
        'gradient descent'
      )
    end

    it 'each term has definition and example' do
      glossary = described_class.glossary
      
      glossary.each do |term, entry|
        expect(entry).to include(:definition, :example)
      end
    end
  end

  describe '.learning_paths' do
    it 'suggests personalized learning paths' do
      paths = described_class.learning_paths
      
      expect(paths).to include(
        :data_scientist,
        :ml_engineer,
        :researcher,
        :student
      )
    end

    it 'each path has recommended modules' do
      path = described_class.learning_paths[:data_scientist]
      
      expect(path).to include(:modules, :estimated_time, :prerequisites)
    end
  end

  describe '.real_world_applications' do
    it 'provides real-world use cases' do
      applications = described_class.real_world_applications
      
      expect(applications).to be_an(Array)
      expect(applications.first).to include(
        :industry,
        :problem,
        :solution,
        :ai4r_components,
        :code_example
      )
    end
  end

  describe '.performance_benchmarks' do
    it 'provides algorithm benchmarks' do
      benchmarks = described_class.performance_benchmarks
      
      expect(benchmarks).to include(
        :classification,
        :clustering,
        :neural_networks
      )
    end

    it 'includes comparison data' do
      classification_bench = described_class.performance_benchmarks[:classification]
      
      expect(classification_bench).to be_an(Array)
      expect(classification_bench.first).to include(
        :algorithm,
        :dataset,
        :accuracy,
        :training_time,
        :memory_usage
      )
    end
  end

  describe '.troubleshooting_guide' do
    it 'provides common issues and solutions' do
      guide = described_class.troubleshooting_guide
      
      expect(guide).to be_an(Array)
      expect(guide.first).to include(
        :issue,
        :symptoms,
        :possible_causes,
        :solutions
      )
    end
  end

  describe '.best_practices' do
    it 'provides AI4R best practices' do
      practices = described_class.best_practices
      
      expect(practices).to include(
        :data_preparation,
        :algorithm_selection,
        :model_evaluation,
        :deployment
      )
    end
  end

  describe '.community_resources' do
    it 'lists community resources' do
      resources = described_class.community_resources
      
      expect(resources).to include(
        :github,
        :documentation,
        :forums,
        :tutorials,
        :contributing
      )
    end
  end
end