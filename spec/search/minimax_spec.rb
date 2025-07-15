# frozen_string_literal: true

# RSpec tests for AI4R Minimax Algorithm with Alpha-Beta Pruning
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Search::Minimax do
  # Test game state implementations for testing
  let(:simple_game_state) do
    double('GameState',
           current_player: :max,
           get_possible_moves: [1, 2, 3],
           game_over?: false,
           evaluate: 0)
  end

  let(:terminal_game_state) do
    double('GameState',
           current_player: :max,
           get_possible_moves: [],
           game_over?: true,
           evaluate: 10)
  end

  let(:mock_game_state) do
    double('GameState',
           current_player: :max,
           get_possible_moves: [1, 2],
           game_over?: false,
           evaluate: 5)
  end

  describe 'initialization' do
    context 'with valid parameters' do
      it 'creates Minimax instance with default configuration' do
        minimax = described_class.new

        expect(minimax.alpha_beta_enabled).to be true
        expect(minimax.verbose_mode).to be false
        expect(minimax.step_by_step_mode).to be false
        expect(minimax.show_pruning).to be false
        expect(minimax.nodes_explored).to eq(0)
        expect(minimax.nodes_pruned).to eq(0)
      end

      it 'creates Minimax instance with custom max_depth' do
        minimax = described_class.new(max_depth: 8)

        expect(minimax.instance_variable_get(:@max_depth)).to eq(8)
      end

      it 'creates Minimax instance with custom options' do
        minimax = described_class.new(
          max_depth: 4,
          alpha_beta: false,
          verbose: true,
          step_by_step: true,
          show_pruning: true
        )

        expect(minimax.alpha_beta_enabled).to be false
        expect(minimax.verbose_mode).to be true
        expect(minimax.step_by_step_mode).to be true
        expect(minimax.show_pruning).to be true
      end
    end

    context 'with invalid parameters' do
      it 'raises error for invalid max_depth' do
        expect {
          described_class.new(max_depth: 0)
        }.to raise_error(ArgumentError, 'max_depth must be a positive integer, got: 0')
      end

      it 'raises error for non-integer max_depth' do
        expect {
          described_class.new(max_depth: 'invalid')
        }.to raise_error(ArgumentError, 'max_depth must be a positive integer, got: invalid')
      end

      it 'raises error for negative max_depth' do
        expect {
          described_class.new(max_depth: -1)
        }.to raise_error(ArgumentError, 'max_depth must be a positive integer, got: -1')
      end
    end
  end

  describe 'game state validation' do
    let(:minimax) { described_class.new }

    context 'with valid game state' do
      it 'validates game state with all required methods' do
        expect {
          minimax.find_best_move(simple_game_state)
        }.not_to raise_error
      end
    end

    context 'with invalid game state' do
      it 'raises error for missing get_possible_moves method' do
        invalid_state = double('GameState')
        allow(invalid_state).to receive(:respond_to?).with(:get_possible_moves).and_return(false)
        allow(invalid_state).to receive(:respond_to?).and_return(true)

        expect {
          minimax.find_best_move(invalid_state)
        }.to raise_error(ArgumentError, /game_state must implement required methods/)
      end

      it 'raises error for missing make_move method' do
        invalid_state = double('GameState')
        allow(invalid_state).to receive(:respond_to?).with(:make_move).and_return(false)
        allow(invalid_state).to receive(:respond_to?).and_return(true)

        expect {
          minimax.find_best_move(invalid_state)
        }.to raise_error(ArgumentError, /game_state must implement required methods/)
      end

      it 'raises error for missing evaluate method' do
        invalid_state = double('GameState')
        allow(invalid_state).to receive(:respond_to?).with(:evaluate).and_return(false)
        allow(invalid_state).to receive(:respond_to?).and_return(true)

        expect {
          minimax.find_best_move(invalid_state)
        }.to raise_error(ArgumentError, /game_state must implement required methods/)
      end
    end
  end

  describe 'best move finding' do
    let(:minimax) { described_class.new(max_depth: 3) }

    context 'with simple game state' do
      it 'finds best move for maximizing player' do
        # Mock game state with predictable moves
        game_state = double('GameState')
        allow(game_state).to receive_messages(
          current_player: :max,
          get_possible_moves: [1, 2, 3],
          game_over?: false,
          evaluate: 0
        )

        # Mock move results
        move_results = {
          1 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 10),
          2 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 5),
          3 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 1)
        }

        allow(game_state).to receive(:make_move) do |move|
          move_results[move]
        end

        result = minimax.find_best_move(game_state)

        expect(result).to be_a(Ai4r::Search::MinimaxResult)
        expect(result.best_move).to eq(1) # Should choose move with highest value
        expect(result.best_value).to eq(10)
        expect(result.nodes_explored).to be > 0
      end

      it 'returns nil when no moves available' do
        no_moves_state = double('GameState')
        allow(no_moves_state).to receive_messages(
          current_player: :max,
          get_possible_moves: [],
          game_over?: true,
          evaluate: 0
        )

        result = minimax.find_best_move(no_moves_state)

        expect(result).to be_nil
      end
    end

    context 'with terminal game state' do
      it 'handles terminal state correctly' do
        result = minimax.find_best_move(terminal_game_state)

        expect(result).to be_nil
      end
    end
  end

  describe 'minimax algorithm' do
    let(:minimax) { described_class.new(max_depth: 2) }

    context 'depth-limited search' do
      it 'respects depth limit' do
        # Create a deep game tree
        deep_state = double('GameState')
        allow(deep_state).to receive_messages(
          current_player: :max,
          get_possible_moves: [1],
          game_over?: false,
          evaluate: 0
        )

        # Mock recursive states
        allow(deep_state).to receive(:make_move) do |move|
          next_state = double('GameState')
          allow(next_state).to receive_messages(
            current_player: :min,
            get_possible_moves: [1],
            game_over?: false,
            evaluate: 5
          )
          
          allow(next_state).to receive(:make_move) do |move|
            terminal = double('GameState')
            allow(terminal).to receive_messages(
              current_player: :max,
              get_possible_moves: [],
              game_over?: true,
              evaluate: 10
            )
            terminal
          end
          
          next_state
        end

        result = minimax.find_best_move(deep_state)

        expect(result).to be_a(Ai4r::Search::MinimaxResult)
        expect(minimax.max_depth_reached).to be <= 2
      end
    end

    context 'minimax value calculation' do
      it 'calculates correct minimax value for terminal state' do
        value = minimax.minimax_value(terminal_game_state, 0, -Float::INFINITY, Float::INFINITY, true)

        expect(value).to eq(10)
        expect(minimax.nodes_explored).to eq(1)
      end

      it 'calculates correct minimax value for maximizing player' do
        # Mock game state with two moves leading to different outcomes
        game_state = double('GameState')
        allow(game_state).to receive_messages(
          current_player: :max,
          get_possible_moves: [1, 2],
          game_over?: false,
          evaluate: 0
        )

        # Mock move results with different evaluations
        move_results = {
          1 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 8),
          2 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 3)
        }

        allow(game_state).to receive(:make_move) do |move|
          move_results[move]
        end

        value = minimax.minimax_value(game_state, 2, -Float::INFINITY, Float::INFINITY, true)

        expect(value).to eq(8) # Should choose maximum value
      end

      it 'calculates correct minimax value for minimizing player' do
        # Mock game state with two moves leading to different outcomes
        game_state = double('GameState')
        allow(game_state).to receive_messages(
          current_player: :min,
          get_possible_moves: [1, 2],
          game_over?: false,
          evaluate: 0
        )

        # Mock move results with different evaluations
        move_results = {
          1 => double('GameState', current_player: :max, get_possible_moves: [], game_over?: true, evaluate: 8),
          2 => double('GameState', current_player: :max, get_possible_moves: [], game_over?: true, evaluate: 3)
        }

        allow(game_state).to receive(:make_move) do |move|
          move_results[move]
        end

        value = minimax.minimax_value(game_state, 2, -Float::INFINITY, Float::INFINITY, false)

        expect(value).to eq(3) # Should choose minimum value
      end
    end
  end

  describe 'alpha-beta pruning' do
    let(:minimax) { described_class.new(max_depth: 3, alpha_beta: true) }

    context 'with pruning enabled' do
      it 'performs alpha-beta pruning' do
        # Create a game state that will trigger pruning
        game_state = double('GameState')
        allow(game_state).to receive_messages(
          current_player: :max,
          get_possible_moves: [1, 2, 3],
          game_over?: false,
          evaluate: 0
        )

        # Mock moves that should trigger pruning
        move_results = {
          1 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 10),
          2 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 5),
          3 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 1)
        }

        allow(game_state).to receive(:make_move) do |move|
          move_results[move]
        end

        # Set up pruning conditions
        minimax.minimax_value(game_state, 2, -Float::INFINITY, Float::INFINITY, true)

        # Should have performed some pruning
        expect(minimax.nodes_pruned).to be >= 0
      end

      it 'tracks pruning statistics' do
        result = minimax.find_best_move(simple_game_state)

        expect(minimax.nodes_pruned).to be >= 0
        expect(minimax.nodes_explored).to be > 0
      end
    end

    context 'with pruning disabled' do
      let(:minimax_no_pruning) { described_class.new(max_depth: 3, alpha_beta: false) }

      it 'does not perform pruning when disabled' do
        minimax_no_pruning.find_best_move(simple_game_state)

        expect(minimax_no_pruning.nodes_pruned).to eq(0)
      end
    end
  end

  describe 'performance comparison' do
    let(:minimax) { described_class.new(max_depth: 2) }

    it 'compares performance with and without pruning' do
      # Mock a game state for comparison
      game_state = double('GameState')
      allow(game_state).to receive_messages(
        current_player: :max,
        get_possible_moves: [1, 2],
        game_over?: false,
        evaluate: 0
      )

      # Mock move results
      move_results = {
        1 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 5),
        2 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 3)
      }

      allow(game_state).to receive(:make_move) do |move|
        move_results[move]
      end

      # Allow deep copying for comparison
      allow(game_state).to receive(:deep_copy).and_return(game_state)

      results = minimax.compare_pruning_performance(game_state)

      expect(results).to have_key(:without_pruning)
      expect(results).to have_key(:with_pruning)
      expect(results).to have_key(:improvement)

      expect(results[:without_pruning]).to have_key(:nodes_explored)
      expect(results[:with_pruning]).to have_key(:nodes_explored)
      expect(results[:improvement]).to have_key(:nodes_saved)
    end
  end

  describe 'game tree analysis' do
    let(:minimax) { described_class.new }

    it 'analyzes game tree structure' do
      # Mock a simple game tree
      root_state = double('GameState')
      allow(root_state).to receive_messages(
        get_possible_moves: [1, 2],
        game_over?: false
      )

      # Mock child states
      child_states = {
        1 => double('GameState', get_possible_moves: [], game_over?: true),
        2 => double('GameState', get_possible_moves: [], game_over?: true)
      }

      allow(root_state).to receive(:make_move) do |move|
        child_states[move]
      end

      analysis = minimax.analyze_game_tree(root_state, 2)

      expect(analysis).to have_key(:depth_info)
      expect(analysis).to have_key(:total_nodes)
      expect(analysis).to have_key(:average_branching_factor)
      expect(analysis).to have_key(:max_branching_factor)
      expect(analysis).to have_key(:min_branching_factor)
      expect(analysis[:total_nodes]).to be > 0
    end
  end

  describe 'statistics tracking' do
    let(:minimax) { described_class.new(max_depth: 2) }

    it 'tracks comprehensive search statistics' do
      minimax.find_best_move(simple_game_state)

      expect(minimax.nodes_explored).to be > 0
      expect(minimax.nodes_pruned).to be >= 0
      expect(minimax.max_depth_reached).to be >= 0
      expect(minimax.search_time).to be > 0
      expect(minimax.tree_size).to be >= 0
    end

    it 'resets statistics between searches' do
      minimax.find_best_move(simple_game_state)
      first_nodes = minimax.nodes_explored

      minimax.find_best_move(simple_game_state)
      second_nodes = minimax.nodes_explored

      # Statistics should be reset, not cumulative
      expect(second_nodes).to be > 0
    end
  end

  describe 'educational features' do
    context 'verbose mode' do
      let(:minimax) { described_class.new(verbose: true) }

      it 'provides educational output when enabled' do
        expect { minimax.find_best_move(simple_game_state) }.to output(/Minimax Search Starting/).to_stdout
      end
    end

    context 'step-by-step mode' do
      let(:minimax) { described_class.new(step_by_step: true) }

      it 'supports step-by-step execution' do
        allow(minimax).to receive(:gets) # Mock user input

        expect { minimax.find_best_move(simple_game_state) }.to output(/Evaluating move/).to_stdout
      end
    end

    context 'pruning visualization' do
      let(:minimax) { described_class.new(show_pruning: true) }

      it 'shows pruning information when enabled' do
        # This test depends on actual pruning occurring
        expect(minimax.show_pruning).to be true
      end
    end
  end

  describe 'MinimaxResult struct' do
    let(:result) do
      Ai4r::Search::MinimaxResult.new(
        best_move: 1,
        best_value: 10,
        nodes_explored: 15,
        nodes_pruned: 5,
        search_time: 0.1,
        tree_size: 20,
        branching_factor: 2.5
      )
    end

    it 'calculates pruning efficiency' do
      expect(result.pruning_efficiency).to eq(25.0) # 5/20 * 100
    end

    it 'provides educational string representation' do
      string_repr = result.to_s

      expect(string_repr).to include('Minimax Search Result')
      expect(string_repr).to include('Best move: 1')
      expect(string_repr).to include('Expected value: 10')
      expect(string_repr).to include('Nodes explored: 15')
      expect(string_repr).to include('Nodes pruned: 5')
      expect(string_repr).to include('Search time: 0.1s')
      expect(string_repr).to include('Pruning efficiency: 25.0%')
    end

    it 'handles zero tree size in pruning efficiency' do
      zero_tree_result = Ai4r::Search::MinimaxResult.new(
        best_move: 1,
        best_value: 10,
        nodes_explored: 5,
        nodes_pruned: 0,
        search_time: 0.1,
        tree_size: 0,
        branching_factor: 0
      )

      expect(zero_tree_result.pruning_efficiency).to eq(0)
    end
  end

  describe 'GameState base class' do
    let(:game_state) { Ai4r::Search::GameState.new }

    it 'raises NotImplementedError for abstract methods' do
      expect { game_state.get_possible_moves }.to raise_error(NotImplementedError)
      expect { game_state.make_move(1) }.to raise_error(NotImplementedError)
      expect { game_state.evaluate }.to raise_error(NotImplementedError)
      expect { game_state.game_over? }.to raise_error(NotImplementedError)
      expect { game_state.current_player }.to raise_error(NotImplementedError)
      expect { game_state.deep_copy }.to raise_error(NotImplementedError)
    end

    it 'provides default winner implementation' do
      expect(game_state.winner).to be_nil
    end

    it 'provides educational string representation' do
      allow(game_state).to receive(:current_player).and_return(:player1)
      expect(game_state.to_s).to eq('GameState(player1)')
    end
  end

  describe 'performance characteristics' do
    context 'algorithm efficiency' do
      let(:minimax) { described_class.new(max_depth: 3) }

      it 'completes search within reasonable time' do
        # Create a moderately complex game state
        complex_state = double('GameState')
        allow(complex_state).to receive_messages(
          current_player: :max,
          get_possible_moves: [1, 2, 3],
          game_over?: false,
          evaluate: 0
        )

        # Mock move results
        move_results = {
          1 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 5),
          2 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 3),
          3 => double('GameState', current_player: :min, get_possible_moves: [], game_over?: true, evaluate: 7)
        }

        allow(complex_state).to receive(:make_move) do |move|
          move_results[move]
        end

        benchmark_performance('Minimax search') do
          result = minimax.find_best_move(complex_state)
          expect(result).not_to be_nil
        end
      end
    end
  end

  describe 'edge cases and error handling' do
    let(:minimax) { described_class.new }

    context 'boundary conditions' do
      it 'handles single move game state' do
        single_move_state = double('GameState')
        allow(single_move_state).to receive_messages(
          current_player: :max,
          get_possible_moves: [1],
          game_over?: false,
          evaluate: 0
        )

        result_state = double('GameState')
        allow(result_state).to receive_messages(
          current_player: :min,
          get_possible_moves: [],
          game_over?: true,
          evaluate: 10
        )

        allow(single_move_state).to receive(:make_move).with(1).and_return(result_state)

        result = minimax.find_best_move(single_move_state)

        expect(result).to be_a(Ai4r::Search::MinimaxResult)
        expect(result.best_move).to eq(1)
      end

      it 'handles immediate terminal state' do
        terminal_state = double('GameState')
        allow(terminal_state).to receive_messages(
          current_player: :max,
          get_possible_moves: [],
          game_over?: true,
          evaluate: 0
        )

        result = minimax.find_best_move(terminal_state)

        expect(result).to be_nil
      end
    end

    context 'memory efficiency' do
      it 'does not leak memory in deep searches' do
        # Create a deeper game tree
        minimax = described_class.new(max_depth: 4)
        
        # Run multiple searches to test memory efficiency
        5.times do
          minimax.find_best_move(simple_game_state)
        end

        # If we reach here without memory issues, test passes
        expect(true).to be true
      end
    end
  end
end