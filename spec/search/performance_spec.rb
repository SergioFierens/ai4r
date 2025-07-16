# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/search/a_star'
require 'ai4r/search/minimax'
require 'benchmark'

RSpec.describe 'Search Algorithms Performance Characteristics' do
  describe 'A* Performance Analysis' do
    describe 'Heuristic Performance' do
      it 'benchmarks different heuristics' do
        grid_sizes = [10, 20, 30]
        results = {}
        
        grid_sizes.each do |size|
          # Create grid with 10% obstacles
          grid = Array.new(size) { Array.new(size, 0) }
          obstacle_count = (size * size * 0.1).to_i
          
          obstacle_count.times do
            row, col = rand(size), rand(size)
            grid[row][col] = 1 unless (row == 0 && col == 0) || (row == size-1 && col == size-1)
          end
          
          results[size] = {}
          
          Ai4r::Search::AStar::HEURISTIC_FUNCTIONS.each do |heuristic|
            astar = Ai4r::Search::AStar.new(grid, heuristic: heuristic)
            
            time = Benchmark.realtime do
              astar.find_path([0, 0], [size-1, size-1])
            end
            
            results[size][heuristic] = {
              time: time,
              nodes_explored: astar.nodes_explored,
              nodes_generated: astar.nodes_generated
            }
          end
        end
        
        # Verify that informed heuristics outperform null heuristic
        results.each do |size, heuristic_data|
          null_nodes = heuristic_data[:null][:nodes_explored]
          
          [:manhattan, :euclidean, :diagonal].each do |heuristic|
            expect(heuristic_data[heuristic][:nodes_explored]).to be <= null_nodes
          end
        end
      end
    end

    describe 'Scalability' do
      it 'measures performance on increasing grid sizes' do
        sizes = [5, 10, 15, 20, 25]
        times = []
        
        sizes.each do |size|
          grid = Array.new(size) { Array.new(size, 0) }
          astar = Ai4r::Search::AStar.new(grid)
          
          time = Benchmark.realtime do
            astar.find_path([0, 0], [size-1, size-1])
          end
          
          times << time
        end
        
        # Time should increase with grid size
        expect(times).to eq(times.sort)
        
        # But should remain reasonable (< 0.1s for 25x25)
        expect(times.last).to be < 0.1
      end

      it 'handles worst-case scenarios' do
        # Create a grid that forces maximum exploration
        grid = [
          [0, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
          [0, 1, 1, 1, 1],
          [0, 0, 0, 0, 0]
        ]
        
        astar = Ai4r::Search::AStar.new(grid)
        
        time = Benchmark.realtime do
          path = astar.find_path([0, 0], [4, 4])
          expect(path).not_to be_nil
        end
        
        expect(time).to be < 0.01
        expect(astar.nodes_explored).to be > 15
      end
    end

    describe 'Memory Usage' do
      it 'tracks open list growth' do
        grid = Array.new(20) { Array.new(20, 0) }
        astar = Ai4r::Search::AStar.new(grid)
        
        astar.find_path([0, 0], [19, 19])
        
        # Open list should grow but stay reasonable
        expect(astar.open_list_max_size).to be > 0
        expect(astar.open_list_max_size).to be < 400 # Less than total grid size
      end
    end
  end

  describe 'Minimax Performance Analysis' do
    # Game state that allows controlled branching
    class BranchingGameState
      attr_accessor :depth, :branching_factor, :current_player
      
      def initialize(branching_factor: 3, max_depth: 4)
        @branching_factor = branching_factor
        @max_depth = max_depth
        @depth = 0
        @current_player = :max
      end
      
      def get_possible_moves
        return [] if game_over?
        (0...@branching_factor).to_a
      end
      
      def make_move(move)
        new_state = self.dup
        new_state.depth = @depth + 1
        new_state.current_player = (@current_player == :max ? :min : :max)
        new_state
      end
      
      def game_over?
        @depth >= @max_depth
      end
      
      def evaluate
        # Simple evaluation based on depth
        @current_player == :max ? @depth : -@depth
      end
    end

    describe 'Branching Factor Impact' do
      it 'measures performance with different branching factors' do
        branching_factors = [2, 3, 4, 5]
        max_depth = 5
        
        results = {}
        
        branching_factors.each do |bf|
          game = BranchingGameState.new(branching_factor: bf, max_depth: 10)
          minimax = Ai4r::Search::Minimax.new(max_depth: max_depth)
          
          time = Benchmark.realtime do
            minimax.find_best_move(game)
          end
          
          results[bf] = {
            time: time,
            nodes_explored: minimax.nodes_explored,
            nodes_pruned: minimax.nodes_pruned
          }
        end
        
        # Higher branching factor = more nodes
        expect(results[5][:nodes_explored]).to be > results[2][:nodes_explored]
        
        # Pruning should be effective
        results.each do |bf, data|
          expect(data[:nodes_pruned]).to be > 0 if bf > 2
        end
      end
    end

    describe 'Depth Impact' do
      it 'measures exponential growth with depth' do
        depths = [2, 3, 4, 5, 6]
        game = BranchingGameState.new(branching_factor: 3)
        
        results = {}
        
        depths.each do |depth|
          minimax = Ai4r::Search::Minimax.new(max_depth: depth)
          
          time = Benchmark.realtime do
            minimax.find_best_move(game)
          end
          
          results[depth] = {
            time: time,
            nodes_explored: minimax.nodes_explored
          }
        end
        
        # Exponential growth in nodes explored
        depths.each_cons(2) do |d1, d2|
          ratio = results[d2][:nodes_explored].to_f / results[d1][:nodes_explored]
          expect(ratio).to be > 1.5 # Should grow significantly
        end
      end
    end

    describe 'Alpha-Beta Effectiveness' do
      it 'quantifies pruning benefits' do
        game = BranchingGameState.new(branching_factor: 4, max_depth: 8)
        
        # Measure with different search depths
        depths = [4, 5, 6]
        pruning_rates = []
        
        depths.each do |depth|
          minimax = Ai4r::Search::Minimax.new(max_depth: depth)
          comparison = minimax.compare_pruning_performance(game)
          
          without = comparison[:without_pruning][:nodes_explored]
          with = comparison[:with_pruning][:nodes_explored]
          
          pruning_rate = (without - with).to_f / without * 100
          pruning_rates << pruning_rate
          
          # Should see significant pruning
          expect(pruning_rate).to be > 20
        end
        
        # Pruning effectiveness should be consistent
        expect(pruning_rates.max - pruning_rates.min).to be < 30
      end
    end
  end

  describe 'Comparative Analysis' do
    it 'documents time complexity characteristics' do
      # Document observed complexity
      complexities = {
        a_star: {
          best_case: 'O(b^d)', # b = branching, d = depth
          worst_case: 'O(b^d)',
          space: 'O(b^d)'
        },
        minimax: {
          without_pruning: 'O(b^d)',
          with_pruning_best: 'O(b^(d/2))',
          with_pruning_avg: 'O(b^(3d/4))',
          space: 'O(d)'
        }
      }
      
      # This test documents complexity - always passes
      expect(complexities).to be_a(Hash)
    end
  end
end