# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/search/a_star'
require 'ai4r/search/minimax'

RSpec.describe 'Search Algorithms Comprehensive Coverage' do
  describe Ai4r::Search::AStar do
    describe '#initialize' do
      it 'creates AStar with default parameters' do
        grid = [[0, 0], [0, 0]]
        astar = described_class.new(grid)
        
        expect(astar).to be_a(described_class)
        expect(astar.heuristic_function).to eq(:manhattan)
      end

      it 'creates AStar with custom heuristic' do
        grid = [[0, 0], [0, 0]]
        astar = described_class.new(grid, heuristic: :euclidean)
        
        expect(astar.heuristic_function).to eq(:euclidean)
      end

      it 'creates AStar with educational options' do
        grid = [[0, 0], [0, 0]]
        astar = described_class.new(grid, 
                                  step_by_step: true, 
                                  verbose: true,
                                  max_iterations: 1000)
        
        expect(astar.step_by_step_mode).to be true
        expect(astar.verbose_mode).to be true
        expect(astar.max_iterations).to eq(1000)
      end

      context 'with invalid grid' do
        it 'raises error for nil grid' do
          expect { described_class.new(nil) }.to raise_error(ArgumentError, 'Grid cannot be nil')
        end

        it 'raises error for empty grid' do
          expect { described_class.new([]) }.to raise_error(ArgumentError, 'Grid cannot be empty')
        end

        it 'raises error for empty rows' do
          expect { described_class.new([[]]) }.to raise_error(ArgumentError, 'Grid rows cannot be empty')
        end

        it 'raises error for non-rectangular grid' do
          grid = [[0, 0], [0]]
          expect { described_class.new(grid) }.to raise_error(ArgumentError, 'Grid must be rectangular')
        end

        it 'raises error for invalid cell values' do
          grid = [[0, 2], [0, 0]]
          expect { described_class.new(grid) }.to raise_error(ArgumentError, /Invalid cell value/)
        end
      end

      context 'with invalid heuristic' do
        it 'raises error for unknown heuristic' do
          grid = [[0, 0], [0, 0]]
          expect { described_class.new(grid, heuristic: :unknown) }
            .to raise_error(ArgumentError, /Invalid heuristic/)
        end
      end
    end

    describe '#find_path' do
      let(:simple_grid) { [[0, 0, 0], [0, 0, 0], [0, 0, 0]] }
      let(:astar) { described_class.new(simple_grid) }

      it 'finds direct path in empty grid' do
        path = astar.find_path([0, 0], [2, 2])
        
        expect(path).to be_an(Array)
        expect(path.first).to eq([0, 0])
        expect(path.last).to eq([2, 2])
        expect(astar.nodes_explored).to be > 0
        expect(astar.path_cost).to be > 0
      end

      it 'finds path around obstacles' do
        grid = [
          [0, 0, 0],
          [0, 1, 0],
          [0, 0, 0]
        ]
        astar = described_class.new(grid)
        path = astar.find_path([0, 0], [2, 2])
        
        expect(path).not_to include([1, 1])
        expect(path).to be_an(Array)
      end

      it 'returns nil when no path exists' do
        grid = [
          [0, 1, 0],
          [1, 1, 1],
          [0, 1, 0]
        ]
        astar = described_class.new(grid)
        path = astar.find_path([0, 0], [2, 2])
        
        expect(path).to be_nil
      end

      it 'handles max iterations limit' do
        astar = described_class.new(simple_grid, max_iterations: 1)
        path = astar.find_path([0, 0], [2, 2])
        
        expect(path).to be_nil
      end

      it 'validates start position' do
        expect { astar.find_path([-1, 0], [2, 2]) }
          .to raise_error(ArgumentError, /start position .* is invalid/)
        
        expect { astar.find_path([0], [2, 2]) }
          .to raise_error(ArgumentError, /start must be \[row, col\] array/)
        
        expect { astar.find_path(['a', 'b'], [2, 2]) }
          .to raise_error(ArgumentError, /start coordinates must be integers/)
      end

      it 'validates goal position' do
        expect { astar.find_path([0, 0], [3, 3]) }
          .to raise_error(ArgumentError, /goal position .* is invalid/)
      end

      it 'finds path to same position' do
        path = astar.find_path([1, 1], [1, 1])
        
        expect(path).to eq([[1, 1]])
        expect(astar.path_cost).to eq(0)
      end

      it 'tracks statistics correctly' do
        astar.find_path([0, 0], [2, 2])
        
        expect(astar.nodes_explored).to be > 0
        expect(astar.nodes_generated).to be > 0
        expect(astar.search_time).to be > 0
        expect(astar.open_list_max_size).to be > 0
      end
    end

    describe '#heuristic_cost' do
      let(:grid) { [[0, 0], [0, 0]] }

      it 'calculates manhattan distance' do
        astar = described_class.new(grid, heuristic: :manhattan)
        cost = astar.heuristic_cost([0, 0], [1, 1])
        
        expect(cost).to eq(2)
      end

      it 'calculates euclidean distance' do
        astar = described_class.new(grid, heuristic: :euclidean)
        cost = astar.heuristic_cost([0, 0], [1, 1])
        
        expect(cost).to be_within(0.01).of(Math.sqrt(2))
      end

      it 'calculates chebyshev distance' do
        astar = described_class.new(grid, heuristic: :chebyshev)
        cost = astar.heuristic_cost([0, 0], [1, 1])
        
        expect(cost).to eq(1)
      end

      it 'calculates diagonal distance' do
        astar = described_class.new(grid, heuristic: :diagonal)
        cost = astar.heuristic_cost([0, 0], [2, 3])
        
        expect(cost).to be > 0
      end

      it 'returns 0 for null heuristic' do
        astar = described_class.new(grid, heuristic: :null)
        cost = astar.heuristic_cost([0, 0], [1, 1])
        
        expect(cost).to eq(0)
      end
    end

    describe '#get_neighbors' do
      let(:grid) { [[0, 0, 0], [0, 0, 0], [0, 0, 0]] }
      let(:astar) { described_class.new(grid) }

      it 'returns 8 neighbors for center position' do
        neighbors = astar.get_neighbors([1, 1])
        
        expect(neighbors.size).to eq(8)
        expect(neighbors).to include([0, 0], [0, 1], [0, 2])
        expect(neighbors).to include([1, 0], [1, 2])
        expect(neighbors).to include([2, 0], [2, 1], [2, 2])
      end

      it 'returns 3 neighbors for corner position' do
        neighbors = astar.get_neighbors([0, 0])
        
        expect(neighbors.size).to eq(3)
        expect(neighbors).to include([0, 1], [1, 0], [1, 1])
      end

      it 'excludes obstacles' do
        grid = [[0, 1, 0], [1, 0, 1], [0, 1, 0]]
        astar = described_class.new(grid)
        neighbors = astar.get_neighbors([1, 1])
        
        expect(neighbors.size).to eq(4)
        expect(neighbors).not_to include([0, 1], [1, 0], [1, 2], [2, 1])
      end
    end

    describe '#movement_cost' do
      let(:grid) { [[0, 0], [0, 0]] }
      let(:astar) { described_class.new(grid) }

      it 'returns 1.0 for orthogonal moves' do
        cost = astar.movement_cost([0, 0], [0, 1])
        expect(cost).to eq(1.0)
        
        cost = astar.movement_cost([0, 0], [1, 0])
        expect(cost).to eq(1.0)
      end

      it 'returns sqrt(2) for diagonal moves' do
        cost = astar.movement_cost([0, 0], [1, 1])
        expect(cost).to be_within(0.01).of(Math.sqrt(2))
      end
    end

    describe '#visualize_grid' do
      let(:grid) { [[0, 1, 0], [0, 0, 0], [0, 1, 0]] }
      let(:astar) { described_class.new(grid) }

      it 'visualizes grid without path' do
        visualization = astar.visualize_grid
        
        expect(visualization).to include('Grid Visualization')
        expect(visualization).to include('■') # obstacles
        expect(visualization).to include('·') # empty spaces
      end

      it 'visualizes grid with path' do
        path = [[0, 0], [1, 1], [2, 2]]
        visualization = astar.visualize_grid(path)
        
        expect(visualization).to include('●') # path markers
      end
    end

    describe '#compare_heuristics' do
      let(:grid) { [[0, 0, 0], [0, 0, 0], [0, 0, 0]] }
      let(:astar) { described_class.new(grid) }

      it 'compares all heuristic functions' do
        # Silence output during test
        allow(astar).to receive(:puts)
        
        results = astar.compare_heuristics([0, 0], [2, 2])
        
        expect(results).to be_a(Hash)
        expect(results.keys).to match_array(described_class::HEURISTIC_FUNCTIONS)
        
        results.each do |heuristic, data|
          expect(data).to include(:path_found, :path_length, :path_cost, 
                                 :nodes_explored, :search_time)
        end
      end
    end

    describe 'Node struct' do
      let(:node) { described_class::Node.new([0, 0], 5, 3, 0, nil) }

      it 'calculates f_cost correctly' do
        node.calculate_f_cost
        expect(node.f_cost).to eq(8)
      end

      it 'checks position equality' do
        other = described_class::Node.new([0, 0], 10, 20, 0, nil)
        expect(node.same_position?(other)).to be true
        
        different = described_class::Node.new([1, 1], 5, 3, 0, nil)
        expect(node.same_position?(different)).to be false
      end

      it 'has string representation' do
        expect(node.to_s).to include('Node')
        expect(node.to_s).to include('[0, 0]')
        expect(node.to_s).to include('g=5')
      end
    end

    describe 'Educational features' do
      let(:grid) { [[0, 0], [0, 0]] }

      it 'works in verbose mode' do
        astar = described_class.new(grid, verbose: true)
        
        expect { astar.find_path([0, 0], [1, 1]) }
          .to output(/A\* Search Starting/).to_stdout
      end

      it 'tracks step history in step-by-step mode' do
        astar = described_class.new(grid, step_by_step: true)
        
        # Mock gets to avoid waiting for input
        allow(astar).to receive(:gets)
        
        astar.find_path([0, 0], [1, 1])
        expect(astar.step_history).not_to be_empty
      end
    end
  end

  describe Ai4r::Search::Minimax do
    # Mock game state for testing
    class TestGameState
      attr_accessor :board, :current_player, :terminal, :moves, :score

      def initialize(board = nil, current_player = :max)
        @board = board || Array.new(9, nil)
        @current_player = current_player
        @terminal = false
        @moves = nil
        @score = 0
      end

      def get_possible_moves
        @moves || @board.each_index.select { |i| @board[i].nil? }
      end

      def make_move(move)
        new_state = TestGameState.new(@board.dup, next_player)
        new_state.board[move] = @current_player
        new_state
      end

      def terminal?
        @terminal
      end
      
      def game_over?
        @terminal || get_possible_moves.empty?
      end

      def evaluate
        @score
      end

      def maximizing_player?
        @current_player == :max
      end

      private

      def next_player
        @current_player == :max ? :min : :max
      end
    end

    describe '#initialize' do
      it 'creates minimax with default parameters' do
        minimax = described_class.new
        
        expect(minimax).to be_a(described_class)
        expect(minimax.alpha_beta_enabled).to be true
      end

      it 'creates minimax with custom depth' do
        minimax = described_class.new(max_depth: 10)
        
        expect(minimax.instance_variable_get(:@max_depth)).to eq(10)
      end

      it 'creates minimax without alpha-beta pruning' do
        minimax = described_class.new(alpha_beta: false)
        
        expect(minimax.alpha_beta_enabled).to be false
      end

      it 'creates minimax with educational options' do
        minimax = described_class.new(
          verbose: true,
          step_by_step: true,
          show_pruning: true
        )
        
        expect(minimax.verbose_mode).to be true
        expect(minimax.step_by_step_mode).to be true
        expect(minimax.show_pruning).to be true
      end

      it 'validates max depth' do
        expect { described_class.new(max_depth: -1) }
          .to raise_error(ArgumentError)
        
        expect { described_class.new(max_depth: 0) }
          .to raise_error(ArgumentError)
      end
    end

    describe '#find_best_move' do
      let(:minimax) { described_class.new(max_depth: 3) }
      let(:game_state) { TestGameState.new }

      it 'finds best move for simple game' do
        game_state.board = [:max, nil, nil, nil, :min, nil, nil, nil, nil]
        
        result = minimax.find_best_move(game_state)
        
        expect(result).to be_a(Ai4r::Search::MinimaxResult)
        expect(result.best_move).to be_between(0, 8)
        expect(game_state.board[result.best_move]).to be_nil
      end

      it 'returns nil for terminal state' do
        game_state.terminal = true
        game_state.moves = []  # No moves available
        
        result = minimax.find_best_move(game_state)
        
        expect(result).to be_nil
      end

      it 'tracks statistics' do
        result = minimax.find_best_move(game_state)
        
        expect(result.nodes_explored).to be > 0
        expect(result.search_time).to be > 0
        expect(result.tree_size).to be >= 0
        expect(result.branching_factor).to be >= 0
      end

      it 'handles single move scenario' do
        game_state.moves = [4]
        
        result = minimax.find_best_move(game_state)
        
        expect(result.best_move).to eq(4)
      end

      it 'validates game state' do
        expect { minimax.find_best_move(nil) }
          .to raise_error(ArgumentError)
        
        invalid_state = Object.new
        expect { minimax.find_best_move(invalid_state) }
          .to raise_error(ArgumentError)
      end
    end

    describe 'Alpha-beta pruning' do
      it 'prunes nodes with alpha-beta enabled' do
        minimax_with = described_class.new(max_depth: 4, alpha_beta: true)
        minimax_without = described_class.new(max_depth: 4, alpha_beta: false)
        
        game_state = TestGameState.new
        
        minimax_with.find_best_move(game_state)
        minimax_without.find_best_move(game_state)
        
        expect(minimax_with.nodes_explored).to be < minimax_without.nodes_explored
        expect(minimax_with.nodes_pruned).to be > 0
      end
    end

    describe 'Educational features' do
      let(:game_state) { TestGameState.new }

      it 'provides verbose output' do
        minimax = described_class.new(max_depth: 2, verbose: true)
        
        expect { minimax.find_best_move(game_state) }
          .to output(/Minimax Search Starting/).to_stdout
      end

      it 'shows pruning information' do
        minimax = described_class.new(max_depth: 2, show_pruning: true)
        
        # Create a state that will cause pruning
        game_state.board = [:max, :min, nil, nil, nil, nil, nil, nil, nil]
        game_state.score = 10
        
        allow(minimax).to receive(:puts)
        minimax.find_best_move(game_state)
      end
    end

    describe 'Private methods' do
      let(:minimax) { described_class.new }
      let(:game_state) { TestGameState.new }

      it 'validates max depth correctly' do
        expect(minimax.send(:validate_max_depth, 5)).to eq(5)
        
        expect { minimax.send(:validate_max_depth, 0) }
          .to raise_error(ArgumentError)
      end

      it 'validates game state interface' do
        expect { minimax.send(:validate_game_state, game_state) }
          .not_to raise_error
        
        invalid = Object.new
        expect { minimax.send(:validate_game_state, invalid) }
          .to raise_error(ArgumentError)
      end

      it 'calculates minimax value correctly' do
        # Test terminal state
        game_state.terminal = true
        game_state.score = 42
        
        value = minimax.send(:minimax_value, game_state, 3, -1000, 1000, true)
        expect(value).to eq(42)
        
        # Test depth limit
        game_state.terminal = false
        value = minimax.send(:minimax_value, game_state, 0, -1000, 1000, true)
        expect(value).to eq(42)
      end

      it 'resets statistics' do
        minimax.instance_variable_set(:@nodes_explored, 100)
        minimax.send(:reset_statistics)
        
        expect(minimax.nodes_explored).to eq(0)
        expect(minimax.nodes_pruned).to eq(0)
      end
    end

    describe 'Performance comparison' do
      it 'compares performance with and without pruning' do
        game_state = TestGameState.new
        
        minimax = described_class.new(max_depth: 3)
        allow(minimax).to receive(:puts)
        
        comparison = minimax.compare_pruning_performance(game_state)
        
        expect(comparison).to include(:with_pruning, :without_pruning)
        expect(comparison[:improvement]).to be_a(Hash)
      end
    end

    describe 'Game tree analysis' do
      it 'analyzes game tree structure' do
        game_state = TestGameState.new
        
        minimax = described_class.new(max_depth: 3)
        allow(minimax).to receive(:puts)
        
        analysis = minimax.analyze_game_tree(game_state, 2)
        
        expect(analysis).to include(:depth_info, :total_nodes, :average_branching_factor)
        expect(analysis[:total_nodes]).to be > 0
      end
    end
  end
end