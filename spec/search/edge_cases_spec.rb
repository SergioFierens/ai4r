# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/search/a_star'
require 'ai4r/search/minimax'

RSpec.describe 'Search Algorithms Edge Cases and Advanced Features' do
  describe 'A* Edge Cases' do
    describe 'Complex Grid Scenarios' do
      it 'handles maze-like grids' do
        # Create a complex maze
        grid = [
          [0, 1, 0, 0, 0, 1, 0],
          [0, 1, 0, 1, 0, 1, 0],
          [0, 0, 0, 1, 0, 0, 0],
          [1, 1, 1, 1, 1, 1, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 1, 1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0, 0, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid)
        path = astar.find_path([0, 0], [6, 6])
        
        expect(path).not_to be_nil
        expect(path.first).to eq([0, 0])
        expect(path.last).to eq([6, 6])
        
        # Verify path doesn't go through obstacles
        path.each do |pos|
          expect(grid[pos[0]][pos[1]]).to eq(0)
        end
      end

      it 'handles isolated islands' do
        # Grid with unreachable areas
        grid = [
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid)
        
        # Try to reach isolated area
        path = astar.find_path([0, 0], [4, 4])
        expect(path).to be_nil
      end

      it 'handles spiral paths' do
        # Create spiral maze
        grid = [
          [0, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 1, 0],
          [0, 1, 0, 1, 0],
          [0, 1, 0, 0, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid)
        path = astar.find_path([0, 0], [2, 2])
        
        expect(path).not_to be_nil
        expect(path.length).to be > 10 # Long winding path
      end
    end

    describe 'Heuristic Comparisons' do
      let(:grid) do
        [
          [0, 0, 0, 0, 0],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0]
        ]
      end

      it 'compares all heuristics on same problem' do
        results = {}
        
        Ai4r::Search::AStar::HEURISTIC_FUNCTIONS.each do |heuristic|
          astar = Ai4r::Search::AStar.new(grid, heuristic: heuristic)
          path = astar.find_path([0, 0], [4, 4])
          
          results[heuristic] = {
            path_length: path.length,
            nodes_explored: astar.nodes_explored,
            path_cost: astar.path_cost
          }
        end
        
        # Null heuristic (Dijkstra) should explore most nodes
        expect(results[:null][:nodes_explored]).to be >= results[:manhattan][:nodes_explored]
        
        # All should find optimal path (same cost)
        costs = results.values.map { |r| r[:path_cost] }
        expect(costs.uniq.size).to eq(1)
      end
    end

    describe 'Performance Under Stress' do
      it 'handles large grids efficiently' do
        # Create 50x50 grid with random obstacles
        size = 50
        grid = Array.new(size) { Array.new(size, 0) }
        
        # Add random obstacles (20% coverage)
        (size * size * 0.2).to_i.times do
          row = rand(size)
          col = rand(size)
          # Don't block start or goal
          unless (row == 0 && col == 0) || (row == size-1 && col == size-1)
            grid[row][col] = 1
          end
        end
        
        astar = Ai4r::Search::AStar.new(grid, max_iterations: 5000)
        
        start_time = Time.now
        path = astar.find_path([0, 0], [size-1, size-1])
        search_time = Time.now - start_time
        
        # Should complete reasonably fast
        expect(search_time).to be < 1.0
        
        if path
          expect(astar.nodes_explored).to be > 0
          expect(astar.open_list_max_size).to be > 0
        end
      end

      it 'respects iteration limits' do
        # Large grid that would take many iterations
        grid = Array.new(100) { Array.new(100, 0) }
        
        astar = Ai4r::Search::AStar.new(grid, max_iterations: 10)
        path = astar.find_path([0, 0], [99, 99])
        
        # Should hit iteration limit
        expect(path).to be_nil
        expect(astar.nodes_explored).to eq(10)
      end
    end

    describe 'Grid Visualization' do
      it 'generates useful visualizations' do
        grid = [
          [0, 1, 0],
          [0, 1, 0],
          [0, 0, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid)
        
        # Visualize empty grid
        viz = astar.visualize_grid
        expect(viz).to include('Grid Visualization')
        expect(viz).to include('■') # obstacles
        expect(viz).to include('·') # empty
        
        # Visualize with path
        path = [[0, 0], [0, 2], [1, 2], [2, 2]]
        viz_with_path = astar.visualize_grid(path)
        expect(viz_with_path).to include('●') # path markers
      end
    end
  end

  describe 'Minimax Edge Cases' do
    # Enhanced game state for testing
    class AdvancedGameState
      attr_accessor :board, :current_player, :max_depth_override
      
      def initialize(board_size = 3)
        @board = Array.new(board_size * board_size, nil)
        @current_player = :max
        @move_count = 0
        @max_depth_override = nil
      end
      
      def get_possible_moves
        return [] if game_over?
        @board.each_index.select { |i| @board[i].nil? }
      end
      
      def make_move(move)
        new_state = self.dup
        new_state.board = @board.dup
        new_state.board[move] = @current_player
        new_state.current_player = (@current_player == :max ? :min : :max)
        new_state
      end
      
      def game_over?
        # Check for win conditions (simplified)
        winning_positions.any? { |pos| check_win(pos) } || @board.none?(&:nil?)
      end
      
      def evaluate
        # More sophisticated evaluation
        if winner = get_winner
          winner == :max ? 1000 : -1000
        else
          # Heuristic: count potential wins
          max_potential = count_potential_wins(:max)
          min_potential = count_potential_wins(:min)
          max_potential - min_potential
        end
      end
      
      def current_player
        @current_player
      end
      
      private
      
      def winning_positions
        # For 3x3 board
        [
          [0, 1, 2], [3, 4, 5], [6, 7, 8], # rows
          [0, 3, 6], [1, 4, 7], [2, 5, 8], # cols
          [0, 4, 8], [2, 4, 6]             # diagonals
        ]
      end
      
      def check_win(positions)
        values = positions.map { |i| @board[i] }
        values.uniq.size == 1 && !values[0].nil?
      end
      
      def get_winner
        winning_positions.each do |pos|
          if check_win(pos)
            return @board[pos[0]]
          end
        end
        nil
      end
      
      def count_potential_wins(player)
        count = 0
        winning_positions.each do |pos|
          values = pos.map { |i| @board[i] }
          if values.count(player) > 0 && values.count(nil) == values.size - values.count(player)
            count += 1
          end
        end
        count
      end
    end

    describe 'Complex Game Scenarios' do
      it 'handles forced wins correctly' do
        game = AdvancedGameState.new
        # Set up a position where max can force a win
        game.board = [
          :max, :min, nil,
          nil,  :max, nil,
          nil,  nil,  nil
        ]
        
        minimax = Ai4r::Search::Minimax.new(max_depth: 5)
        result = minimax.find_best_move(game)
        
        # Should find winning move
        expect(result.best_move).to eq(8) # Complete diagonal
        expect(result.best_value).to be > 0
      end

      it 'blocks opponent wins' do
        game = AdvancedGameState.new
        game.current_player = :min
        # Min must block max's winning move
        game.board = [
          :max, :max, nil,
          nil,  :min, nil,
          nil,  nil,  nil
        ]
        
        minimax = Ai4r::Search::Minimax.new(max_depth: 5)
        result = minimax.find_best_move(game)
        
        # Should block at position 2
        expect(result.best_move).to eq(2)
      end

      it 'handles deep game trees' do
        game = AdvancedGameState.new
        
        # Test different depths
        depths = [1, 3, 5, 7]
        results = {}
        
        depths.each do |depth|
          minimax = Ai4r::Search::Minimax.new(max_depth: depth)
          result = minimax.find_best_move(game)
          results[depth] = {
            move: result.best_move,
            value: result.best_value,
            nodes: result.nodes_explored
          }
        end
        
        # Deeper searches should explore more nodes
        expect(results[7][:nodes]).to be > results[1][:nodes]
        
        # All depths should suggest valid moves
        results.each do |depth, data|
          expect(data[:move]).to be_between(0, 8)
        end
      end
    end

    describe 'Performance Analysis' do
      it 'demonstrates pruning effectiveness' do
        game = AdvancedGameState.new
        
        minimax = Ai4r::Search::Minimax.new(max_depth: 4)
        comparison = minimax.compare_pruning_performance(game)
        
        # Pruning should reduce nodes explored
        expect(comparison[:with_pruning][:nodes_explored]).to be < comparison[:without_pruning][:nodes_explored]
        
        # But should find same best move
        expect(comparison[:with_pruning][:best_move]).to eq(comparison[:without_pruning][:best_move])
        
        # Calculate efficiency
        efficiency = comparison[:improvement][:nodes_percentage]
        expect(efficiency).to be > 0
      end

      it 'analyzes game tree structure' do
        game = AdvancedGameState.new
        minimax = Ai4r::Search::Minimax.new
        
        analysis = minimax.analyze_game_tree(game, 3)
        
        expect(analysis[:total_nodes]).to be > 0
        expect(analysis[:depth_info]).not_to be_empty
        expect(analysis[:average_branching_factor]).to be > 0
        
        # First level should have 9 moves (empty board)
        expect(analysis[:depth_info][0][:nodes]).to eq(1)
      end
    end

    describe 'Educational Output' do
      it 'provides detailed search information in verbose mode' do
        game = AdvancedGameState.new
        minimax = Ai4r::Search::Minimax.new(max_depth: 2, verbose: true)
        
        output = ""
        allow(minimax).to receive(:puts) { |msg| output += msg.to_s + "\n" }
        
        minimax.find_best_move(game)
        
        expect(output).to include('Minimax Search Starting')
        expect(output).to include('Best Move Found')
      end

      it 'tracks pruning events when enabled' do
        game = AdvancedGameState.new
        game.board = [:max, :min, nil, nil, nil, nil, nil, nil, nil]
        
        minimax = Ai4r::Search::Minimax.new(max_depth: 3, show_pruning: true)
        
        output = ""
        allow(minimax).to receive(:puts) { |msg| output += msg.to_s + "\n" }
        
        result = minimax.find_best_move(game)
        
        if result.nodes_pruned > 0
          expect(output).to include('pruning')
        end
      end
    end
  end

  describe 'Integration Tests' do
    it 'combines A* pathfinding with game AI' do
      # Simulate a game where units use A* to move
      grid = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0]
      ]
      
      astar = Ai4r::Search::AStar.new(grid)
      
      # Multiple units finding paths
      unit_positions = [[0, 0], [4, 0], [0, 4]]
      target = [2, 2]
      
      paths = unit_positions.map do |start|
        astar.find_path(start, target)
      end
      
      # All units should find paths
      paths.each { |path| expect(path).not_to be_nil }
      
      # Paths should not overlap at destination
      final_positions = paths.map { |p| p[-2] } # Second to last position
      expect(final_positions.uniq.size).to eq(final_positions.size)
    end
  end
end