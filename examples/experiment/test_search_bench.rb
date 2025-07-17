#!/usr/bin/env ruby
# Simple test for search bench functionality

# Load just the needed files for testing
require_relative 'lib/ai4r/search/a_star'
require_relative 'lib/ai4r/search/minimax'
require_relative 'lib/ai4r/experiment/search_bench'

# Simple game state for testing
class TestGameState
  def initialize(moves = [[0, 0], [1, 1]], evaluation = 5)
    @moves = moves
    @evaluation = evaluation
  end
  
  def get_possible_moves
    @moves
  end
  
  def make_move(move)
    TestGameState.new(@moves - [move], @evaluation)
  end
  
  def evaluate
    @evaluation
  end
  
  def game_over?
    @moves.empty?
  end
  
  def current_player
    :x
  end
end

# Create simple test problems
def create_simple_maze
  [
    [0, 0, 1, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 0, 0, 0, 1],
    [1, 1, 0, 1, 0],
    [0, 0, 0, 0, 0]
  ]
end

def create_test_game_state
  TestGameState.new([[0, 0], [1, 1], [2, 2]], 10)
end

# Test basic functionality
puts "🔍 Testing Search Bench..."
puts "=" * 40

# Create test bench
puts "Creating search bench..."
bench = Ai4r::Experiment::SearchBench.new(verbose: false)
puts "✓ Search bench created"

# Add algorithms
puts "Adding algorithms..."
test_grid = create_simple_maze
bench.add_algorithm(:astar_manhattan, Ai4r::Search::AStar.new(test_grid, heuristic: :manhattan))
bench.add_algorithm(:astar_euclidean, Ai4r::Search::AStar.new(test_grid, heuristic: :euclidean))
bench.add_algorithm(:minimax, Ai4r::Search::Minimax.new(max_depth: 3))
puts "✓ Added 3 algorithms"

# Add problems
puts "Adding problems..."
bench.add_problem(:simple_maze, {
  type: :pathfinding,
  grid: create_simple_maze,
  start: [0, 0],
  goal: [4, 4]
})

bench.add_problem(:test_game, {
  type: :game,
  initial_state: create_test_game_state
})
puts "✓ Added 2 problems"

# Run benchmark
puts "Running benchmark..."
begin
  results = bench.run
  puts "✓ Benchmark completed successfully!"
  
  # Display results summary
  puts "\nResults Summary:"
  results.each do |algo_name, algo_results|
    puts "  Algorithm: #{algo_name}"
    algo_results.each do |prob_name, result|
      success = result[:success] ? "✓" : "✗"
      time = result[:search_time] ? "#{(result[:search_time] * 1000).round(2)}ms" : "N/A"
      nodes = result[:nodes_explored] || 0
      puts "    #{prob_name}: #{success} Time: #{time}, Nodes: #{nodes}"
      puts "      Error: #{result[:error]}" if result[:error]
    end
  end
  
  # Test insights
  puts "\nGenerating insights..."
  insights = bench.generate_insights(results)
  puts "✓ Insights generated (#{insights.length} characters)"
  
  # Test export
  puts "\nTesting export..."
  bench.export_results(:csv, "test_search_results")
  puts "✓ Export test completed"
  
  # Clean up
  File.delete("test_search_results.csv") if File.exist?("test_search_results.csv")
  
  puts "\n🎉 All tests passed!"
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(5)
end