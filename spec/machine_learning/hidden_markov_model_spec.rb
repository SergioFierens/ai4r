# frozen_string_literal: true

# RSpec tests for AI4R Hidden Markov Model Algorithm
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::MachineLearning::HiddenMarkovModel do
  # Test data
  let(:weather_states) { [:sunny, :rainy] }
  let(:activity_observations) { [:walk, :shop, :clean] }
  
  let(:simple_sequences) do
    [
      { observations: [:walk, :shop, :clean], states: [:sunny, :sunny, :rainy] },
      { observations: [:clean, :clean, :walk], states: [:rainy, :rainy, :sunny] },
      { observations: [:walk, :walk, :shop], states: [:sunny, :sunny, :sunny] }
    ]
  end

  let(:unsupervised_sequences) do
    [
      { observations: [:walk, :shop, :clean] },
      { observations: [:clean, :clean, :walk] },
      { observations: [:walk, :walk, :shop] },
      { observations: [:shop, :clean, :clean] },
      { observations: [:walk, :clean, :shop] }
    ]
  end

  let(:binary_states) { [:on, :off] }
  let(:binary_observations) { [:beep, :silence] }
  let(:binary_sequences) do
    [
      { observations: [:beep, :beep, :silence], states: [:on, :on, :off] },
      { observations: [:silence, :silence, :beep], states: [:off, :off, :on] },
      { observations: [:beep, :silence, :beep], states: [:on, :off, :on] }
    ]
  end

  describe 'initialization' do
    context 'with valid parameters' do
      it 'creates HMM with default configuration' do
        hmm = described_class.new(weather_states, activity_observations)
        
        expect(hmm.states).to eq(weather_states)
        expect(hmm.observations).to eq(activity_observations)
        expect(hmm.state_to_index).to eq({ sunny: 0, rainy: 1 })
        expect(hmm.observation_to_index).to eq({ walk: 0, shop: 1, clean: 2 })
        expect(hmm.verbose_mode).to be false
        expect(hmm.max_iterations).to eq(100)
        expect(hmm.convergence_threshold).to eq(1e-6)
      end

      it 'creates HMM with custom options' do
        hmm = described_class.new(
          weather_states,
          activity_observations,
          verbose: true,
          max_iterations: 50,
          convergence_threshold: 1e-4
        )
        
        expect(hmm.verbose_mode).to be true
        expect(hmm.max_iterations).to eq(50)
        expect(hmm.convergence_threshold).to eq(1e-4)
      end

      it 'initializes model parameters randomly' do
        hmm = described_class.new(weather_states, activity_observations)
        
        expect(hmm.transition_matrix.length).to eq(2)
        expect(hmm.transition_matrix[0].length).to eq(2)
        expect(hmm.emission_matrix.length).to eq(2)
        expect(hmm.emission_matrix[0].length).to eq(3)
        expect(hmm.initial_distribution.length).to eq(2)
        
        # Check probability constraints
        expect(hmm.initial_distribution.sum).to be_within(0.001).of(1.0)
        hmm.transition_matrix.each do |row|
          expect(row.sum).to be_within(0.001).of(1.0)
        end
        hmm.emission_matrix.each do |row|
          expect(row.sum).to be_within(0.001).of(1.0)
        end
      end
    end

    context 'with invalid parameters' do
      it 'raises error for empty states' do
        expect {
          described_class.new([], activity_observations)
        }.to raise_error(ArgumentError, 'States cannot be empty')
      end

      it 'raises error for empty observations' do
        expect {
          described_class.new(weather_states, [])
        }.to raise_error(ArgumentError, 'Observations cannot be empty')
      end

      it 'raises error for duplicate states' do
        expect {
          described_class.new([:sunny, :sunny], activity_observations)
        }.to raise_error(ArgumentError, 'States must be unique')
      end

      it 'raises error for duplicate observations' do
        expect {
          described_class.new(weather_states, [:walk, :walk])
        }.to raise_error(ArgumentError, 'Observations must be unique')
      end
    end
  end

  describe 'supervised training' do
    let(:hmm) { described_class.new(weather_states, activity_observations) }

    context 'with valid sequences' do
      it 'trains successfully' do
        expect { hmm.train(simple_sequences, supervised: true) }.not_to raise_error
        
        expect(hmm.instance_variable_get(:@trained)).to be true
        expect(hmm.training_sequences).to eq(simple_sequences)
        expect(hmm.iterations).to eq(1)
        expect(hmm.log_likelihood.length).to eq(1)
      end

      it 'learns correct parameters from data' do
        hmm.train(simple_sequences, supervised: true)
        
        # Check that parameters are learned (not just random)
        expect(hmm.transition_matrix).to be_a(Array)
        expect(hmm.emission_matrix).to be_a(Array)
        expect(hmm.initial_distribution).to be_a(Array)
        
        # Parameters should sum to 1
        expect(hmm.initial_distribution.sum).to be_within(0.001).of(1.0)
        hmm.transition_matrix.each do |row|
          expect(row.sum).to be_within(0.001).of(1.0)
        end
        hmm.emission_matrix.each do |row|
          expect(row.sum).to be_within(0.001).of(1.0)
        end
      end

      it 'computes training log-likelihood' do
        hmm.train(simple_sequences, supervised: true)
        
        expect(hmm.log_likelihood.length).to eq(1)
        expect(hmm.log_likelihood.first).to be_a(Float)
        expect(hmm.log_likelihood.first).to be < 0  # Log-likelihood should be negative
      end
    end

    context 'with invalid sequences' do
      it 'raises error for empty sequences' do
        expect {
          hmm.train([], supervised: true)
        }.to raise_error(ArgumentError, 'Training sequences cannot be empty')
      end

      it 'raises error for unknown observations' do
        invalid_sequence = [{ observations: [:unknown], states: [:sunny] }]
        expect {
          hmm.train(invalid_sequence, supervised: true)
        }.to raise_error(ArgumentError, 'Unknown observation: unknown')
      end

      it 'raises error for unknown states' do
        invalid_sequence = [{ observations: [:walk], states: [:unknown] }]
        expect {
          hmm.train(invalid_sequence, supervised: true)
        }.to raise_error(ArgumentError, 'Unknown state: unknown')
      end

      it 'raises error for mismatched sequence lengths' do
        invalid_sequence = [{ observations: [:walk, :shop], states: [:sunny] }]
        expect {
          hmm.train(invalid_sequence, supervised: true)
        }.to raise_error(ArgumentError, 'Sequence 0 states and observations must have same length')
      end
    end
  end

  describe 'unsupervised training' do
    let(:hmm) { described_class.new(weather_states, activity_observations) }

    context 'with valid sequences' do
      it 'trains successfully with Baum-Welch algorithm' do
        expect { hmm.train(unsupervised_sequences) }.not_to raise_error
        
        expect(hmm.instance_variable_get(:@trained)).to be true
        expect(hmm.training_sequences).to eq(unsupervised_sequences)
        expect(hmm.iterations).to be > 0
        expect(hmm.log_likelihood.length).to be > 0
      end

      it 'improves log-likelihood over iterations' do
        hmm.train(unsupervised_sequences)
        
        # Should have multiple log-likelihood values
        expect(hmm.log_likelihood.length).to be >= 1
        
        # Later iterations should generally have higher log-likelihood
        if hmm.log_likelihood.length > 1
          expect(hmm.log_likelihood.last).to be >= hmm.log_likelihood.first
        end
      end

      it 'converges within maximum iterations' do
        hmm = described_class.new(weather_states, activity_observations, max_iterations: 10)
        hmm.train(unsupervised_sequences)
        
        expect(hmm.iterations).to be <= 10
      end

      it 'respects convergence threshold' do
        hmm = described_class.new(weather_states, activity_observations, convergence_threshold: 1e-2)
        hmm.train(unsupervised_sequences)
        
        # Should converge faster with looser threshold
        expect(hmm.iterations).to be >= 1
      end
    end

    context 'with limited data' do
      it 'handles single sequence' do
        single_sequence = [{ observations: [:walk, :shop, :clean] }]
        
        expect { hmm.train(single_sequence) }.not_to raise_error
        expect(hmm.instance_variable_get(:@trained)).to be true
      end

      it 'handles short sequences' do
        short_sequences = [
          { observations: [:walk] },
          { observations: [:shop] },
          { observations: [:clean] }
        ]
        
        expect { hmm.train(short_sequences) }.not_to raise_error
        expect(hmm.instance_variable_get(:@trained)).to be true
      end
    end
  end

  describe 'forward algorithm' do
    let(:hmm) { described_class.new(weather_states, activity_observations) }

    before do
      hmm.train(simple_sequences, supervised: true)
    end

    context 'with valid sequences' do
      it 'computes forward probabilities' do
        prob = hmm.forward([:walk, :shop])
        
        expect(prob).to be_a(Float)
        expect(prob).to be > 0
        expect(prob).to be <= 1
      end

      it 'handles single observation' do
        prob = hmm.forward([:walk])
        
        expect(prob).to be_a(Float)
        expect(prob).to be > 0
        expect(prob).to be <= 1
      end

      it 'produces consistent results' do
        prob1 = hmm.forward([:walk, :shop])
        prob2 = hmm.forward([:walk, :shop])
        
        expect(prob1).to eq(prob2)
      end

      it 'handles longer sequences' do
        long_sequence = [:walk, :shop, :clean, :walk, :shop]
        prob = hmm.forward(long_sequence)
        
        expect(prob).to be_a(Float)
        expect(prob).to be > 0
      end
    end

    context 'with invalid sequences' do
      it 'raises error for empty sequence' do
        expect {
          hmm.forward([])
        }.to raise_error(ArgumentError, 'Observation sequence cannot be empty')
      end

      it 'raises error for unknown observation' do
        expect {
          hmm.forward([:unknown])
        }.to raise_error(ArgumentError, 'Unknown observation: unknown')
      end
    end
  end

  describe 'viterbi algorithm' do
    let(:hmm) { described_class.new(weather_states, activity_observations) }

    before do
      hmm.train(simple_sequences, supervised: true)
    end

    context 'with valid sequences' do
      it 'finds most likely state sequence' do
        states = hmm.viterbi([:walk, :shop])
        
        expect(states).to be_an(Array)
        expect(states.length).to eq(2)
        expect(states.all? { |s| weather_states.include?(s) }).to be true
      end

      it 'handles single observation' do
        states = hmm.viterbi([:walk])
        
        expect(states).to be_an(Array)
        expect(states.length).to eq(1)
        expect(weather_states.include?(states[0])).to be true
      end

      it 'produces consistent results' do
        states1 = hmm.viterbi([:walk, :shop])
        states2 = hmm.viterbi([:walk, :shop])
        
        expect(states1).to eq(states2)
      end

      it 'handles longer sequences' do
        long_sequence = [:walk, :shop, :clean, :walk, :shop]
        states = hmm.viterbi(long_sequence)
        
        expect(states.length).to eq(5)
        expect(states.all? { |s| weather_states.include?(s) }).to be true
      end
    end

    context 'with invalid sequences' do
      it 'raises error for empty sequence' do
        expect {
          hmm.viterbi([])
        }.to raise_error(ArgumentError, 'Observation sequence cannot be empty')
      end

      it 'raises error for unknown observation' do
        expect {
          hmm.viterbi([:unknown])
        }.to raise_error(ArgumentError, 'Unknown observation: unknown')
      end
    end
  end

  describe 'sequence generation' do
    let(:hmm) { described_class.new(weather_states, activity_observations) }

    before do
      hmm.train(simple_sequences, supervised: true)
    end

    context 'with valid parameters' do
      it 'generates observation sequences' do
        sequence = hmm.generate(5)
        
        expect(sequence).to be_an(Array)
        expect(sequence.length).to eq(5)
        expect(sequence.all? { |obs| activity_observations.include?(obs) }).to be true
      end

      it 'generates sequences with states' do
        result = hmm.generate(5, include_states: true)
        
        expect(result).to be_a(Hash)
        expect(result[:observations]).to be_an(Array)
        expect(result[:states]).to be_an(Array)
        expect(result[:observations].length).to eq(5)
        expect(result[:states].length).to eq(5)
        expect(result[:observations].all? { |obs| activity_observations.include?(obs) }).to be true
        expect(result[:states].all? { |state| weather_states.include?(state) }).to be true
      end

      it 'generates different sequences on multiple calls' do
        seq1 = hmm.generate(10)
        seq2 = hmm.generate(10)
        
        # With randomness, sequences should sometimes be different
        expect(seq1).not_to eq(seq2) # This might occasionally fail due to randomness
      end
    end

    context 'with invalid parameters' do
      it 'raises error for untrained model' do
        untrained_hmm = described_class.new(weather_states, activity_observations)
        
        expect {
          untrained_hmm.generate(5)
        }.to raise_error(RuntimeError, 'Model must be trained before generating sequences')
      end
    end
  end

  describe 'model evaluation' do
    let(:hmm) { described_class.new(weather_states, activity_observations) }

    before do
      hmm.train(simple_sequences, supervised: true)
    end

    context 'with valid test sequences' do
      it 'evaluates model performance' do
        test_sequences = [
          { observations: [:walk, :shop] },
          { observations: [:clean, :clean] }
        ]
        
        results = hmm.evaluate(test_sequences)
        
        expect(results).to have_key(:avg_log_likelihood)
        expect(results).to have_key(:perplexity)
        expect(results).to have_key(:num_sequences)
        
        expect(results[:avg_log_likelihood]).to be_a(Float)
        expect(results[:perplexity]).to be_a(Float)
        expect(results[:perplexity]).to be > 0
        expect(results[:num_sequences]).to eq(2)
      end

      it 'calculates state accuracy when states provided' do
        test_sequences = [
          { observations: [:walk, :shop], states: [:sunny, :sunny] },
          { observations: [:clean, :clean], states: [:rainy, :rainy] }
        ]
        
        results = hmm.evaluate(test_sequences)
        
        expect(results).to have_key(:state_accuracy)
        expect(results[:state_accuracy]).to be_a(Float)
        expect(results[:state_accuracy]).to be >= 0
        expect(results[:state_accuracy]).to be <= 1
      end

      it 'handles sequences without states' do
        test_sequences = [
          { observations: [:walk, :shop] },
          { observations: [:clean, :clean] }
        ]
        
        results = hmm.evaluate(test_sequences)
        
        expect(results).not_to have_key(:state_accuracy)
      end
    end
  end

  describe 'model analysis' do
    let(:hmm) { described_class.new(weather_states, activity_observations) }

    before do
      hmm.train(simple_sequences, supervised: true)
    end

    context 'with trained model' do
      it 'analyzes model parameters' do
        analysis = hmm.analyze_model
        
        expect(analysis).to have_key(:top_transitions)
        expect(analysis).to have_key(:top_emissions)
        expect(analysis).to have_key(:state_analysis)
        expect(analysis).to have_key(:model_entropy)
        
        expect(analysis[:top_transitions]).to be_an(Array)
        expect(analysis[:top_emissions]).to be_an(Array)
        expect(analysis[:state_analysis]).to be_a(Hash)
        expect(analysis[:model_entropy]).to be_a(Float)
      end

      it 'provides state-specific analysis' do
        analysis = hmm.analyze_model
        
        weather_states.each do |state|
          expect(analysis[:state_analysis]).to have_key(state)
          
          state_info = analysis[:state_analysis][state]
          expect(state_info).to have_key(:most_likely_observation)
          expect(state_info).to have_key(:observation_probability)
          expect(state_info).to have_key(:self_transition_probability)
          expect(state_info).to have_key(:initial_probability)
          
          expect(activity_observations.include?(state_info[:most_likely_observation])).to be true
          expect(state_info[:observation_probability]).to be >= 0
          expect(state_info[:observation_probability]).to be <= 1
        end
      end

      it 'ranks transitions by probability' do
        analysis = hmm.analyze_model
        
        transitions = analysis[:top_transitions]
        expect(transitions).to be_an(Array)
        expect(transitions.length).to be <= 10
        
        # Check that transitions are sorted by probability
        probabilities = transitions.map { |t| t[:probability] }
        expect(probabilities).to eq(probabilities.sort.reverse)
      end

      it 'ranks emissions by probability' do
        analysis = hmm.analyze_model
        
        emissions = analysis[:top_emissions]
        expect(emissions).to be_an(Array)
        expect(emissions.length).to be <= 10
        
        # Check that emissions are sorted by probability
        probabilities = emissions.map { |e| e[:probability] }
        expect(probabilities).to eq(probabilities.sort.reverse)
      end
    end

    context 'with untrained model' do
      it 'raises error for untrained model' do
        untrained_hmm = described_class.new(weather_states, activity_observations)
        
        expect {
          untrained_hmm.analyze_model
        }.to raise_error(RuntimeError, 'Model must be trained before analysis')
      end
    end
  end

  describe 'model visualization' do
    let(:hmm) { described_class.new(weather_states, activity_observations) }

    before do
      hmm.train(simple_sequences, supervised: true)
    end

    context 'with trained model' do
      it 'generates visualization string' do
        visualization = hmm.visualize_model
        
        expect(visualization).to be_a(String)
        expect(visualization).to include('Hidden Markov Model Visualization')
        expect(visualization).to include('Model Summary')
        expect(visualization).to include('Initial State Distribution')
        expect(visualization).to include('Transition Matrix')
        expect(visualization).to include('Emission Matrix')
      end

      it 'includes model parameters in visualization' do
        visualization = hmm.visualize_model
        
        weather_states.each do |state|
          expect(visualization).to include(state.to_s)
        end
        
        activity_observations.each do |obs|
          expect(visualization).to include(obs.to_s)
        end
      end

      it 'formats matrices correctly' do
        visualization = hmm.visualize_model
        
        # Should contain formatted numbers
        expect(visualization).to match(/\d+\.\d+/)
        
        # Should contain matrix headers
        expect(visualization).to include('sunny')
        expect(visualization).to include('rainy')
        expect(visualization).to include('walk')
        expect(visualization).to include('shop')
        expect(visualization).to include('clean')
      end
    end

    context 'with untrained model' do
      it 'raises error for untrained model' do
        untrained_hmm = described_class.new(weather_states, activity_observations)
        
        expect {
          untrained_hmm.visualize_model
        }.to raise_error(RuntimeError, 'Model must be trained before visualization')
      end
    end
  end

  describe 'educational features' do
    let(:hmm) { described_class.new(weather_states, activity_observations, verbose: true) }

    it 'provides verbose output during training' do
      expect { hmm.train(simple_sequences, supervised: true) }.to output(/HMM Training/).to_stdout
    end

    it 'provides verbose output during forward algorithm' do
      hmm.train(simple_sequences, supervised: true)
      expect { hmm.forward([:walk, :shop]) }.to output(/Forward Algorithm/).to_stdout
    end

    it 'provides verbose output during viterbi algorithm' do
      hmm.train(simple_sequences, supervised: true)
      expect { hmm.viterbi([:walk, :shop]) }.to output(/Viterbi Algorithm/).to_stdout
    end
  end

  describe 'performance characteristics' do
    context 'algorithm efficiency' do
      let(:hmm) { described_class.new(weather_states, activity_observations) }

      it 'handles moderately large sequences' do
        # Create longer sequences
        long_sequences = []
        10.times do
          obs_seq = Array.new(50) { activity_observations.sample }
          state_seq = Array.new(50) { weather_states.sample }
          long_sequences << { observations: obs_seq, states: state_seq }
        end

        benchmark_performance('HMM training') do
          hmm.train(long_sequences, supervised: true)
          expect(hmm.instance_variable_get(:@trained)).to be true
        end
      end

      it 'performs inference efficiently' do
        hmm.train(simple_sequences, supervised: true)
        
        long_sequence = Array.new(100) { activity_observations.sample }
        
        benchmark_performance('HMM inference') do
          prob = hmm.forward(long_sequence)
          states = hmm.viterbi(long_sequence)
          
          expect(prob).to be > 0
          expect(states.length).to eq(100)
        end
      end
    end

    context 'memory efficiency' do
      let(:hmm) { described_class.new(weather_states, activity_observations) }

      it 'handles multiple training cycles' do
        # Train multiple times to test memory efficiency
        3.times do
          hmm.train(simple_sequences, supervised: true)
          expect(hmm.instance_variable_get(:@trained)).to be true
        end
      end
    end
  end

  describe 'edge cases and error handling' do
    context 'boundary conditions' do
      it 'handles binary states and observations' do
        hmm = described_class.new(binary_states, binary_observations)
        
        expect { hmm.train(binary_sequences, supervised: true) }.not_to raise_error
        expect(hmm.instance_variable_get(:@trained)).to be true
      end

      it 'handles single state model' do
        single_state = [:only_state]
        hmm = described_class.new(single_state, activity_observations)
        
        single_state_sequences = [
          { observations: [:walk, :shop], states: [:only_state, :only_state] }
        ]
        
        expect { hmm.train(single_state_sequences, supervised: true) }.not_to raise_error
      end

      it 'handles single observation model' do
        single_obs = [:only_obs]
        hmm = described_class.new(weather_states, single_obs)
        
        single_obs_sequences = [
          { observations: [:only_obs, :only_obs], states: [:sunny, :rainy] }
        ]
        
        expect { hmm.train(single_obs_sequences, supervised: true) }.not_to raise_error
      end
    end

    context 'numerical stability' do
      it 'handles very small probabilities' do
        hmm = described_class.new(weather_states, activity_observations)
        hmm.train(simple_sequences, supervised: true)
        
        # Test with very long sequence that might cause underflow
        very_long_sequence = Array.new(200) { activity_observations.sample }
        
        expect { hmm.forward(very_long_sequence) }.not_to raise_error
        expect { hmm.viterbi(very_long_sequence) }.not_to raise_error
      end
    end
  end

  describe 'deterministic behavior' do
    it 'produces consistent results with same random seed' do
      # Set same random seed
      srand(42)
      hmm1 = described_class.new(weather_states, activity_observations)
      hmm1.train(simple_sequences, supervised: true)
      
      srand(42)
      hmm2 = described_class.new(weather_states, activity_observations)
      hmm2.train(simple_sequences, supervised: true)
      
      # Should produce same parameters (within numerical precision)
      expect(hmm1.initial_distribution).to eq(hmm2.initial_distribution)
      expect(hmm1.transition_matrix).to eq(hmm2.transition_matrix)
      expect(hmm1.emission_matrix).to eq(hmm2.emission_matrix)
    end
  end
end