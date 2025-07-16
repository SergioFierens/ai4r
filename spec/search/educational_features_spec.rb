# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/search/a_star'
require 'ai4r/search/minimax'
require 'stringio'

RSpec.describe 'Search Algorithms Educational Features' do
  describe 'A* Educational Mode' do
    describe 'Step-by-Step Execution' do
      it 'provides detailed step information' do
        grid = [
          [0, 0, 0],
          [0, 1, 0],
          [0, 0, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid, step_by_step: true)
        
        # Mock user input to avoid blocking
        allow(astar).to receive(:gets).and_return("\n")
        
        # Capture output
        output = StringIO.new
        original_stdout = $stdout
        $stdout = output
        
        astar.find_path([0, 0], [2, 2])
        
        $stdout = original_stdout
        captured = output.string
        
        # Should show step information
        expect(captured).to include('Step')
        expect(captured).to include('Current:')
        expect(captured).to include('Open list:')
        expect(captured).to include('Closed list:')
        
        # Should have step history
        expect(astar.step_history).not_to be_empty
        expect(astar.step_history.first).to include(
          :iteration, :current_node, :f_cost, :g_cost, :h_cost
        )
      end
    end

    describe 'Verbose Mode' do
      it 'provides educational output' do
        grid = [[0, 0], [0, 0]]
        astar = Ai4r::Search::AStar.new(grid, verbose: true)
        
        output = StringIO.new
        original_stdout = $stdout
        $stdout = output
        
        astar.find_path([0, 0], [1, 1])
        
        $stdout = original_stdout
        captured = output.string
        
        expect(captured).to include('A* Search Starting')
        expect(captured).to include('Start:')
        expect(captured).to include('Goal:')
        expect(captured).to include('Heuristic:')
        expect(captured).to include('Path Found!')
      end

      it 'reports when no path exists' do
        grid = [
          [0, 1, 0],
          [1, 1, 1],
          [0, 1, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid, verbose: true)
        
        output = StringIO.new
        original_stdout = $stdout
        $stdout = output
        
        result = astar.find_path([0, 0], [2, 2])
        
        $stdout = original_stdout
        captured = output.string
        
        expect(result).to be_nil
        expect(captured).to include('No Path Found')
        expect(captured).to include('No path exists')
      end
    end

    describe 'Heuristic Comparison' do
      it 'provides comprehensive heuristic analysis' do
        grid = [
          [0, 0, 0, 0],
          [0, 1, 1, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid)
        
        # Suppress output during test
        allow(astar).to receive(:puts)
        
        comparison = astar.compare_heuristics([0, 0], [3, 3])
        
        # Should have results for all heuristics
        expect(comparison.keys).to match_array(Ai4r::Search::AStar::HEURISTIC_FUNCTIONS)
        
        # Each result should have expected fields
        comparison.each do |heuristic, data|
          expect(data).to include(
            :path_found, :path_length, :path_cost, 
            :nodes_explored, :search_time
          )
          
          expect(data[:path_found]).to be true
          expect(data[:path_length]).to be > 0
        end
        
        # Manhattan and Euclidean should be efficient
        expect(comparison[:manhattan][:nodes_explored]).to be <= comparison[:null][:nodes_explored]
        expect(comparison[:euclidean][:nodes_explored]).to be <= comparison[:null][:nodes_explored]
      end
    end

    describe 'Grid Visualization' do
      it 'creates clear ASCII visualizations' do
        grid = [
          [0, 1, 0, 0],
          [0, 1, 0, 1],
          [0, 0, 0, 1],
          [1, 0, 0, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid)
        
        # Visualize without path
        viz = astar.visualize_grid
        
        lines = viz.split("\n")
        expect(lines.any? { |l| l.include?('Grid Visualization') }).to be true
        
        # Should show coordinates
        expect(viz).to match(/0\s+1\s+2\s+3/)
        
        # Count obstacles and empty spaces
        obstacle_count = viz.count('■')
        empty_count = viz.count('·')
        
        expect(obstacle_count).to eq(5) # 5 obstacles in grid
        expect(empty_count).to eq(11)   # 11 empty spaces
        
        # Visualize with path
        path = [[0, 0], [1, 0], [2, 0], [2, 1], [2, 2], [3, 2], [3, 3]]
        viz_with_path = astar.visualize_grid(path)
        
        path_count = viz_with_path.count('●')
        expect(path_count).to eq(7) # 7 positions in path
      end
    end
  end

  describe 'Minimax Educational Mode' do
    # Simple tic-tac-toe-like game for testing
    class EducationalGame
      attr_accessor :board, :current_player, :move_history
      
      def initialize
        @board = Array.new(9, nil)
        @current_player = :max
        @move_history = []
      end
      
      def get_possible_moves
        @board.each_index.select { |i| @board[i].nil? }
      end
      
      def make_move(move)
        new_game = self.dup
        new_game.board = @board.dup
        new_game.board[move] = @current_player
        new_game.current_player = (@current_player == :max ? :min : :max)
        new_game.move_history = @move_history + [move]
        new_game
      end
      
      def game_over?
        winner || @board.none?(&:nil?)
      end
      
      def evaluate
        if w = winner
          w == :max ? 100 : -100
        else
          0
        end
      end
      
      def winner
        lines = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        
        lines.each do |line|
          values = line.map { |i| @board[i] }
          if values.uniq.size == 1 && !values[0].nil?
            return values[0]
          end
        end
        nil
      end
    end

    describe 'Verbose Output' do
      it 'provides detailed search information' do
        game = EducationalGame.new
        minimax = Ai4r::Search::Minimax.new(max_depth: 3, verbose: true)
        
        output = StringIO.new
        original_stdout = $stdout
        $stdout = output
        
        result = minimax.find_best_move(game)
        
        $stdout = original_stdout
        captured = output.string
        
        expect(captured).to include('Minimax Search Starting')
        expect(captured).to include('Current player:')
        expect(captured).to include('Max depth:')
        expect(captured).to include('Alpha-Beta pruning:')
        expect(captured).to include('Best Move Found')
        expect(captured).to include('Nodes explored:')
      end
    end

    describe 'Step-by-Step Mode' do
      it 'shows move evaluation process' do
        game = EducationalGame.new
        game.board = [:max, nil, nil, nil, :min, nil, nil, nil, nil]
        
        minimax = Ai4r::Search::Minimax.new(max_depth: 2, step_by_step: true)
        
        # Mock user input
        allow(minimax).to receive(:gets).and_return("\n")
        
        output = StringIO.new
        original_stdout = $stdout
        $stdout = output
        
        result = minimax.find_best_move(game)
        
        $stdout = original_stdout
        captured = output.string
        
        expect(captured).to include('Evaluating move')
        expect(captured).to include('Minimax value:')
        expect(captured).to include('Nodes explored so far:')
      end
    end

    describe 'Pruning Visualization' do
      it 'shows when branches are pruned' do
        game = EducationalGame.new
        # Set up a position that will cause pruning
        game.board = [:max, :max, nil, :min, nil, nil, nil, nil, nil]
        
        minimax = Ai4r::Search::Minimax.new(max_depth: 4, show_pruning: true)
        
        output = StringIO.new
        original_stdout = $stdout
        $stdout = output
        
        result = minimax.find_best_move(game)
        
        $stdout = original_stdout
        captured = output.string
        
        if result.nodes_pruned > 0
          expect(captured).to include('pruning')
          expect(captured).to match(/[αβ]=/)
        end
      end
    end

    describe 'MinimaxResult Educational Methods' do
      it 'provides informative string representation' do
        game = EducationalGame.new
        minimax = Ai4r::Search::Minimax.new(max_depth: 3)
        
        result = minimax.find_best_move(game)
        
        str = result.to_s
        
        expect(str).to include('Minimax Search Result')
        expect(str).to include('Best move:')
        expect(str).to include('Expected value:')
        expect(str).to include('Nodes explored:')
        expect(str).to include('Pruning efficiency:')
        
        # Pruning efficiency should be calculated
        efficiency = result.pruning_efficiency
        expect(efficiency).to be_a(Float)
        expect(efficiency).to be >= 0
      end
    end

    describe 'Performance Comparison' do
      it 'educationally compares with and without pruning' do
        game = EducationalGame.new
        minimax = Ai4r::Search::Minimax.new(max_depth: 4)
        
        # Suppress output
        allow(minimax).to receive(:puts)
        
        comparison = minimax.compare_pruning_performance(game)
        
        # Educational comparison should show clear benefits
        without = comparison[:without_pruning]
        with = comparison[:with_pruning]
        improvement = comparison[:improvement]
        
        # Same move should be found
        expect(with[:best_move]).to eq(without[:best_move])
        expect(with[:best_value]).to eq(without[:best_value])
        
        # But with fewer nodes
        expect(with[:nodes_explored]).to be < without[:nodes_explored]
        
        # Improvement metrics
        expect(improvement[:nodes_saved]).to be > 0
        expect(improvement[:nodes_percentage]).to be > 0
        expect(improvement[:time_saved]).to be >= 0
      end
    end

    describe 'Game Tree Analysis' do
      it 'provides educational tree structure analysis' do
        game = EducationalGame.new
        minimax = Ai4r::Search::Minimax.new
        
        analysis = minimax.analyze_game_tree(game, 3)
        
        expect(analysis).to include(
          :depth_info, :total_nodes, :average_branching_factor,
          :max_branching_factor, :min_branching_factor
        )
        
        # Should have depth information
        expect(analysis[:depth_info]).not_to be_empty
        expect(analysis[:depth_info][0]).to include(
          :nodes, :total_branching, :non_leaf_nodes
        )
        
        # First move from empty board has 9 options
        expect(analysis[:max_branching_factor]).to eq(9)
        
        # Average should be reasonable
        expect(analysis[:average_branching_factor]).to be > 0
        expect(analysis[:average_branching_factor]).to be <= 9
      end
    end
  end

  describe 'Learning Examples' do
    it 'demonstrates A* path optimality' do
      # Grid where multiple paths exist
      grid = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0]
      ]
      
      astar = Ai4r::Search::AStar.new(grid)
      path = astar.find_path([0, 0], [4, 4])
      
      # Calculate actual path cost
      actual_cost = 0
      path.each_cons(2) do |p1, p2|
        actual_cost += astar.movement_cost(p1, p2)
      end
      
      # Should match reported cost
      expect(actual_cost).to be_within(0.01).of(astar.path_cost)
      
      # Path should be optimal (straight diagonal = 4 * sqrt(2))
      optimal_cost = 4 * Math.sqrt(2)
      expect(actual_cost).to be_within(0.01).of(optimal_cost)
    end

    it 'demonstrates minimax optimality' do
      # Game where perfect play leads to draw
      game = EducationalGame.new
      
      # Both players playing optimally from empty board
      current_game = game
      moves = []
      
      9.times do |i|
        minimax = Ai4r::Search::Minimax.new(max_depth: 9)
        result = minimax.find_best_move(current_game)
        
        break unless result && result.best_move
        
        moves << result.best_move
        current_game = current_game.make_move(result.best_move)
        
        break if current_game.game_over?
      end
      
      # Perfect play should lead to draw (no winner)
      expect(current_game.winner).to be_nil
      expect(current_game.evaluate).to eq(0)
    end
  end
end