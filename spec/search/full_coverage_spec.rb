# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/search/a_star'
require 'ai4r/search/minimax'

RSpec.describe 'Search Algorithms Full Coverage' do
  describe 'A* Complete Coverage' do
    describe 'Error Handling Edge Cases' do
      it 'handles all invalid grid configurations' do
        # Empty columns
        expect { Ai4r::Search::AStar.new([[], []]) }.to raise_error(ArgumentError, 'Grid rows cannot be empty')
        
        # Non-rectangular
        expect { Ai4r::Search::AStar.new([[0], [0, 0]]) }.to raise_error(ArgumentError, 'Grid must be rectangular')
        
        # Invalid cell values
        expect { Ai4r::Search::AStar.new([[0, 2]]) }.to raise_error(ArgumentError, /Invalid cell value/)
        expect { Ai4r::Search::AStar.new([[0, -1]]) }.to raise_error(ArgumentError, /Invalid cell value/)
        expect { Ai4r::Search::AStar.new([[0, 'x']]) }.to raise_error(ArgumentError, /Invalid cell value/)
      end

      it 'handles all invalid position errors' do
        grid = [[0, 0], [0, 0]]
        astar = Ai4r::Search::AStar.new(grid)
        
        # Out of bounds
        expect { astar.find_path([-1, 0], [1, 1]) }.to raise_error(ArgumentError, /start position .* is invalid/)
        expect { astar.find_path([2, 0], [1, 1]) }.to raise_error(ArgumentError, /start position .* is invalid/)
        expect { astar.find_path([0, -1], [1, 1]) }.to raise_error(ArgumentError, /start position .* is invalid/)
        expect { astar.find_path([0, 2], [1, 1]) }.to raise_error(ArgumentError, /start position .* is invalid/)
        
        # Invalid goal
        expect { astar.find_path([0, 0], [2, 2]) }.to raise_error(ArgumentError, /goal position .* is invalid/)
        
        # Non-array positions
        expect { astar.find_path('start', [1, 1]) }.to raise_error(ArgumentError, /start must be \[row, col\] array/)
        expect { astar.find_path([0, 0], 'goal') }.to raise_error(ArgumentError, /goal must be \[row, col\] array/)
        
        # Wrong array size
        expect { astar.find_path([0], [1, 1]) }.to raise_error(ArgumentError, /start must be \[row, col\] array/)
        expect { astar.find_path([0, 0, 0], [1, 1]) }.to raise_error(ArgumentError, /start must be \[row, col\] array/)
        
        # Non-integer coordinates
        expect { astar.find_path(['a', 'b'], [1, 1]) }.to raise_error(ArgumentError, /start coordinates must be integers/)
        expect { astar.find_path([0.5, 0.5], [1, 1]) }.to raise_error(ArgumentError, /start coordinates must be integers/)
      end

      it 'handles obstacles in start or goal positions' do
        grid = [[1, 0], [0, 0]]
        astar = Ai4r::Search::AStar.new(grid)
        
        expect { astar.find_path([0, 0], [1, 1]) }.to raise_error(ArgumentError, /start position .* is invalid/)
      end
    end

    describe 'All Heuristic Functions' do
      let(:astar_manhattan) { Ai4r::Search::AStar.new([[0, 0], [0, 0]], heuristic: :manhattan) }
      let(:astar_euclidean) { Ai4r::Search::AStar.new([[0, 0], [0, 0]], heuristic: :euclidean) }
      let(:astar_chebyshev) { Ai4r::Search::AStar.new([[0, 0], [0, 0]], heuristic: :chebyshev) }
      let(:astar_diagonal) { Ai4r::Search::AStar.new([[0, 0], [0, 0]], heuristic: :diagonal) }
      let(:astar_null) { Ai4r::Search::AStar.new([[0, 0], [0, 0]], heuristic: :null) }

      it 'calculates all heuristics correctly' do
        # Test each heuristic
        expect(astar_manhattan.heuristic_cost([0, 0], [3, 4])).to eq(7)
        expect(astar_euclidean.heuristic_cost([0, 0], [3, 4])).to eq(5.0)
        expect(astar_chebyshev.heuristic_cost([0, 0], [3, 4])).to eq(4)
        expect(astar_diagonal.heuristic_cost([0, 0], [3, 4])).to be_within(0.01).of(5.243)
        expect(astar_null.heuristic_cost([0, 0], [3, 4])).to eq(0.0)
      end

      it 'handles unknown heuristic in heuristic_cost' do
        astar = astar_manhattan
        astar.instance_variable_set(:@heuristic_function, :unknown)
        expect { astar.heuristic_cost([0, 0], [1, 1]) }.to raise_error(ArgumentError, /Unknown heuristic/)
      end
    end

    describe 'Movement Cost Calculations' do
      let(:astar) { Ai4r::Search::AStar.new([[0, 0], [0, 0]]) }

      it 'calculates all movement costs correctly' do
        # Orthogonal moves
        expect(astar.movement_cost([0, 0], [0, 1])).to eq(1.0)
        expect(astar.movement_cost([0, 0], [1, 0])).to eq(1.0)
        expect(astar.movement_cost([1, 1], [1, 0])).to eq(1.0)
        expect(astar.movement_cost([1, 1], [0, 1])).to eq(1.0)
        
        # Diagonal moves
        expect(astar.movement_cost([0, 0], [1, 1])).to eq(Math.sqrt(2))
        expect(astar.movement_cost([1, 0], [0, 1])).to eq(Math.sqrt(2))
        expect(astar.movement_cost([0, 1], [1, 0])).to eq(Math.sqrt(2))
        expect(astar.movement_cost([1, 1], [0, 0])).to eq(Math.sqrt(2))
      end
    end

    describe 'Neighbor Generation' do
      it 'handles all edge positions correctly' do
        grid = Array.new(5) { Array.new(5, 0) }
        astar = Ai4r::Search::AStar.new(grid)
        
        # Corners (3 neighbors each)
        expect(astar.get_neighbors([0, 0]).size).to eq(3)
        expect(astar.get_neighbors([0, 4]).size).to eq(3)
        expect(astar.get_neighbors([4, 0]).size).to eq(3)
        expect(astar.get_neighbors([4, 4]).size).to eq(3)
        
        # Edges (5 neighbors each)
        expect(astar.get_neighbors([0, 2]).size).to eq(5)
        expect(astar.get_neighbors([2, 0]).size).to eq(5)
        expect(astar.get_neighbors([4, 2]).size).to eq(5)
        expect(astar.get_neighbors([2, 4]).size).to eq(5)
        
        # Center (8 neighbors)
        expect(astar.get_neighbors([2, 2]).size).to eq(8)
      end
    end

    describe 'Node Struct Complete Coverage' do
      it 'tests all Node methods' do
        node1 = Ai4r::Search::AStar::Node.new([1, 2], 5.0, 3.0, 0, nil)
        node2 = Ai4r::Search::AStar::Node.new([1, 2], 6.0, 4.0, 0, nil)
        node3 = Ai4r::Search::AStar::Node.new([2, 3], 5.0, 3.0, 0, nil)
        
        # Calculate f_cost
        node1.calculate_f_cost
        expect(node1.f_cost).to eq(8.0)
        
        # Position equality
        expect(node1.same_position?(node2)).to be true
        expect(node1.same_position?(node3)).to be false
        
        # String representation
        str = node1.to_s
        expect(str).to include('Node')
        expect(str).to include('[1, 2]')
        expect(str).to include('g=5')
        expect(str).to include('h=3')
        expect(str).to include('f=8')
      end
    end
  end

  describe 'Minimax Complete Coverage' do
    # More complete game state
    class CompleteGameState
      attr_accessor :board, :current_player, :evaluation_value
      
      def initialize
        @board = Array.new(9, nil)
        @current_player = :max
        @evaluation_value = 0
      end
      
      def get_possible_moves
        @board.each_index.select { |i| @board[i].nil? }
      end
      
      def make_move(move)
        new_state = CompleteGameState.new
        new_state.board = @board.dup
        new_state.board[move] = @current_player
        new_state.current_player = (@current_player == :max ? :min : :max)
        new_state.evaluation_value = @evaluation_value
        new_state
      end
      
      def game_over?
        get_possible_moves.empty? || winner?
      end
      
      def evaluate
        return 1000 if winner? && winner_player == :max
        return -1000 if winner? && winner_player == :min
        @evaluation_value
      end
      
      def current_player
        @current_player
      end
      
      private
      
      def winner?
        lines = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        lines.any? { |line| line_complete?(line) }
      end
      
      def winner_player
        lines = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        lines.each do |line|
          if line_complete?(line)
            return @board[line[0]]
          end
        end
        nil
      end
      
      def line_complete?(line)
        values = line.map { |i| @board[i] }
        values.uniq.size == 1 && !values[0].nil?
      end
    end

    describe 'Initialization Edge Cases' do
      it 'validates all max_depth values' do
        expect { Ai4r::Search::Minimax.new(max_depth: 'five') }.to raise_error(ArgumentError, /max_depth must be a positive integer/)
        expect { Ai4r::Search::Minimax.new(max_depth: 0) }.to raise_error(ArgumentError, /max_depth must be a positive integer/)
        expect { Ai4r::Search::Minimax.new(max_depth: -5) }.to raise_error(ArgumentError, /max_depth must be a positive integer/)
        expect { Ai4r::Search::Minimax.new(max_depth: nil) }.to raise_error(ArgumentError, /max_depth must be a positive integer/)
      end
    end

    describe 'Game State Validation' do
      it 'validates nil game state' do
        minimax = Ai4r::Search::Minimax.new
        expect { minimax.find_best_move(nil) }.to raise_error(ArgumentError)
      end

      it 'validates game state with missing methods' do
        minimax = Ai4r::Search::Minimax.new
        
        # Missing all methods
        invalid = Object.new
        expect { minimax.find_best_move(invalid) }.to raise_error(ArgumentError, /must implement required methods/)
        
        # Missing specific methods
        partial = Object.new
        def partial.get_possible_moves; []; end
        expect { minimax.find_best_move(partial) }.to raise_error(ArgumentError, /must implement required methods/)
      end
    end

    describe 'MinimaxResult Methods' do
      it 'calculates pruning efficiency correctly' do
        result = Ai4r::Search::MinimaxResult.new(
          best_move: 4,
          best_value: 0,
          nodes_explored: 100,
          nodes_pruned: 25,
          search_time: 0.1,
          tree_size: 150,
          branching_factor: 3.5
        )
        
        expect(result.pruning_efficiency).to eq(16.67)
        
        # Edge case: zero tree size
        result.tree_size = 0
        expect(result.pruning_efficiency).to eq(0)
      end

      it 'has comprehensive string representation' do
        result = Ai4r::Search::MinimaxResult.new(
          best_move: 4,
          best_value: 10,
          nodes_explored: 100,
          nodes_pruned: 25,
          search_time: 0.123456,
          tree_size: 150,
          branching_factor: 3.567
        )
        
        str = result.to_s
        expect(str).to include('Minimax Search Result')
        expect(str).to include('Best move: 4')
        expect(str).to include('Expected value: 10')
        expect(str).to include('Nodes explored: 100')
        expect(str).to include('Nodes pruned: 25')
        expect(str).to include('Search time: 0.1235s')
        expect(str).to include('Tree size: 150')
        expect(str).to include('Branching factor: 3.57')
        expect(str).to include('Pruning efficiency: 16.67%')
      end
    end

    describe 'Base GameState Class' do
      it 'raises NotImplementedError for all abstract methods' do
        game_state = Ai4r::Search::GameState.new
        
        expect { game_state.get_possible_moves }.to raise_error(NotImplementedError, /must implement get_possible_moves/)
        expect { game_state.make_move(0) }.to raise_error(NotImplementedError, /must implement make_move/)
        expect { game_state.evaluate }.to raise_error(NotImplementedError, /must implement evaluate/)
        expect { game_state.game_over? }.to raise_error(NotImplementedError, /must implement game_over/)
        expect { game_state.current_player }.to raise_error(NotImplementedError, /must implement current_player/)
        expect { game_state.deep_copy }.to raise_error(NotImplementedError, /must implement deep_copy/)
        
        # Default implementations
        expect(game_state.winner).to be_nil
        expect(game_state.to_s).to eq('GameState()')
      end
    end

    describe 'Private Method Coverage' do
      it 'tests reset_statistics' do
        minimax = Ai4r::Search::Minimax.new
        
        # Set some values
        minimax.instance_variable_set(:@nodes_explored, 100)
        minimax.instance_variable_set(:@nodes_pruned, 50)
        
        # Reset
        minimax.send(:reset_statistics)
        
        expect(minimax.nodes_explored).to eq(0)
        expect(minimax.nodes_pruned).to eq(0)
        expect(minimax.instance_variable_get(:@max_depth_reached)).to eq(0)
      end

      it 'tests calculate_branching_factor' do
        minimax = Ai4r::Search::Minimax.new
        
        # Edge case: single node
        minimax.instance_variable_set(:@nodes_explored, 1)
        minimax.instance_variable_set(:@max_depth_reached, 0)
        expect(minimax.send(:calculate_branching_factor)).to eq(0)
        
        # Normal case
        minimax.instance_variable_set(:@nodes_explored, 100)
        minimax.instance_variable_set(:@max_depth_reached, 3)
        bf = minimax.send(:calculate_branching_factor)
        expect(bf).to be > 0
        expect(bf).to be < 100
      end
    end

    describe 'Educational Output Methods' do
      it 'respects verbose mode setting' do
        game = CompleteGameState.new
        minimax_quiet = Ai4r::Search::Minimax.new(verbose: false)
        minimax_verbose = Ai4r::Search::Minimax.new(verbose: true)
        
        # Quiet mode should not output
        expect { minimax_quiet.find_best_move(game) }.not_to output.to_stdout
        
        # Verbose mode should output
        expect { minimax_verbose.find_best_move(game) }.to output(/Minimax Search Starting/).to_stdout
      end

      it 'handles step-by-step mode without blocking' do
        game = CompleteGameState.new
        minimax = Ai4r::Search::Minimax.new(max_depth: 2, step_by_step: true)
        
        # Mock gets to avoid blocking
        allow(minimax).to receive(:gets)
        
        expect { minimax.find_best_move(game) }.to output(/Evaluating move/).to_stdout
      end
    end

    describe 'Tree Analysis Edge Cases' do
      it 'handles empty game tree' do
        game = CompleteGameState.new
        # Fill board completely
        game.board = [:max, :min, :max, :min, :max, :min, :max, :min, :max]
        
        minimax = Ai4r::Search::Minimax.new
        analysis = minimax.analyze_game_tree(game, 3)
        
        expect(analysis[:total_nodes]).to eq(1) # Just root
        expect(analysis[:average_branching_factor]).to eq(0)
      end

      it 'handles deep analysis correctly' do
        game = CompleteGameState.new
        minimax = Ai4r::Search::Minimax.new
        
        # Analyze to different depths
        shallow = minimax.analyze_game_tree(game, 1)
        deep = minimax.analyze_game_tree(game, 3)
        
        expect(deep[:total_nodes]).to be > shallow[:total_nodes]
        expect(deep[:depth_info].keys.max).to be > shallow[:depth_info].keys.max
      end
    end
  end
end