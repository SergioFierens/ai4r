#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Search Algorithm Benchmarking Example: The Ultimate AI Search Showdown
#
# This example demonstrates how to use the AI4R SearchBench to compare
# different search algorithms across various problem types.
#
# We'll test pathfinding algorithms on maze problems and game tree search
# algorithms on strategic game problems.
#

require_relative '../../lib/ai4r'

# Simple game state class for tic-tac-toe demonstration
class TicTacToeState
  attr_reader :board, :current_player

  def initialize(board = nil, current_player = :x)
    @board = board || Array.new(3) { Array.new(3, :empty) }
    @current_player = current_player
  end

  def get_possible_moves
    moves = []
    @board.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        moves << [i, j] if cell == :empty
      end
    end
    moves
  end

  def make_move(move)
    new_board = @board.map(&:dup)
    new_board[move[0]][move[1]] = @current_player
    next_player = @current_player == :x ? :o : :x
    TicTacToeState.new(new_board, next_player)
  end

  def evaluate
    # Simple evaluation: check for wins
    lines = []

    # Rows
    lines.concat(@board)

    # Columns
    3.times { |i| lines << @board.map { |row| row[i] } }

    # Diagonals
    lines << [0, 1, 2].map { |i| @board[i][i] }
    lines << [0, 1, 2].map { |i| @board[i][2 - i] }

    lines.each do |line|
      return 10 if line.all?(:x)
      return -10 if line.all?(:o)
    end

    0 # Draw or ongoing
  end

  def game_over?
    evaluate != 0 || get_possible_moves.empty?
  end
end

# Helper methods for creating test problems
def create_simple_maze
  [
    [0, 0, 1, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 0, 0, 0, 1],
    [1, 1, 0, 1, 0],
    [0, 0, 0, 0, 0]
  ]
end

def create_complex_maze
  [
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 1, 0, 1, 1, 1, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
    [1, 1, 1, 1, 0, 1, 1, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  ]
end

def create_sparse_maze
  [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ]
end

def create_tic_tac_toe_state
  # Create a partially filled tic-tac-toe board
  board = Array.new(3) { Array.new(3, :empty) }
  board[1][1] = :x  # X in center
  board[0][0] = :o  # O in corner
  TicTacToeState.new(board, :x)
end

# Main benchmarking demonstration
def run_search_benchmark
  puts '🔍 Search Algorithm Benchmark Demo'
  puts '=' * 50

  # Create the benchmark
  bench = Ai4r::Experiment::SearchBench.new(
    verbose: true,
    educational_mode: true,
    timeout: 30
  )

  # Add pathfinding algorithms
  puts "\n🗺️  Adding Pathfinding Algorithms..."
  sample_grid = create_simple_maze # Use a sample grid for initialization

  bench.add_algorithm(:astar_manhattan,
                      Ai4r::Search::AStar.new(sample_grid, heuristic: :manhattan, verbose: false),
                      friendly_name: 'A* Manhattan')

  bench.add_algorithm(:astar_euclidean,
                      Ai4r::Search::AStar.new(sample_grid, heuristic: :euclidean, verbose: false),
                      friendly_name: 'A* Euclidean')

  bench.add_algorithm(:astar_diagonal,
                      Ai4r::Search::AStar.new(sample_grid, heuristic: :diagonal, verbose: false),
                      friendly_name: 'A* Diagonal')

  # Add game tree search algorithms
  puts "\n🎮 Adding Game Tree Search Algorithms..."
  bench.add_algorithm(:minimax_depth_3,
                      Ai4r::Search::Minimax.new(max_depth: 3, verbose: false),
                      friendly_name: 'Minimax Depth 3')

  bench.add_algorithm(:minimax_depth_5,
                      Ai4r::Search::Minimax.new(max_depth: 5, verbose: false),
                      friendly_name: 'Minimax Depth 5')

  # Add pathfinding problems
  puts "\n🧩 Adding Pathfinding Problems..."
  bench.add_problem(:simple_maze, {
                      type: :pathfinding,
                      grid: create_simple_maze,
                      start: [0, 0],
                      goal: [4, 4]
                    }, friendly_name: 'Simple 5x5 Maze')

  bench.add_problem(:complex_maze, {
                      type: :pathfinding,
                      grid: create_complex_maze,
                      start: [0, 0],
                      goal: [9, 9]
                    }, friendly_name: 'Complex 10x10 Maze')

  bench.add_problem(:sparse_maze, {
                      type: :pathfinding,
                      grid: create_sparse_maze,
                      start: [0, 0],
                      goal: [7, 7]
                    }, friendly_name: 'Sparse 8x8 Maze')

  # Add game problems
  puts "\n🎯 Adding Game Problems..."
  bench.add_problem(:tic_tac_toe, {
                      type: :game,
                      initial_state: create_tic_tac_toe_state
                    }, friendly_name: 'Tic-Tac-Toe Mid-Game')

  # Run the benchmark
  puts "\n🚀 Running Benchmark..."
  results = bench.run

  # Display results
  puts "\n#{'=' * 80}"
  puts '📊 BENCHMARK RESULTS'
  puts '=' * 80
  bench.display_results(results)

  # Generate insights
  puts "\n#{'=' * 80}"
  puts '🎓 EDUCATIONAL INSIGHTS'
  puts '=' * 80
  insights = bench.generate_insights(results)
  puts insights

  # Export results
  puts "\n📁 Exporting Results..."
  bench.export_results(:csv, 'search_benchmark_results')
  bench.export_results(:json, 'search_benchmark_data')
  bench.export_results(:html, 'search_benchmark_report')

  puts "\n✅ Benchmark Complete!"
  puts 'Check the exported files for detailed analysis.'

  # Return results for further analysis
  results
end

# Demonstration of specific algorithm comparisons
def demonstrate_heuristic_comparison
  puts "\n🔬 Heuristic Comparison Demo"
  puts '=' * 40

  bench = Ai4r::Experiment::SearchBench.new(verbose: true)

  # Add all A* variants
  sample_grid = create_complex_maze # Use a sample grid for initialization

  %i[manhattan euclidean chebyshev diagonal].each do |heuristic|
    bench.add_algorithm(:"astar_#{heuristic}",
                        Ai4r::Search::AStar.new(sample_grid, heuristic: heuristic, verbose: false),
                        friendly_name: "A* #{heuristic.to_s.capitalize}")
  end

  # Test on a challenging maze
  bench.add_problem(:challenging_maze, {
                      type: :pathfinding,
                      grid: create_complex_maze,
                      start: [0, 0],
                      goal: [9, 9]
                    }, friendly_name: 'Challenging Maze')

  results = bench.run
  bench.display_results(results)

  puts "\n🎯 Heuristic Analysis:"
  puts 'This comparison shows how different heuristic functions affect:'
  puts '• Search efficiency (nodes explored)'
  puts '• Solution quality (path length)'
  puts '• Computational time'
  puts '• Memory usage patterns'

  results
end

# Demonstration of game tree search depth analysis
def demonstrate_depth_analysis
  puts "\n📏 Search Depth Analysis Demo"
  puts '=' * 40

  bench = Ai4r::Experiment::SearchBench.new(verbose: true)

  # Add minimax with different depths
  [1, 2, 3, 4, 5].each do |depth|
    bench.add_algorithm(:"minimax_d#{depth}",
                        Ai4r::Search::Minimax.new(max_depth: depth, verbose: false),
                        friendly_name: "Minimax Depth #{depth}")
  end

  # Test on tic-tac-toe
  bench.add_problem(:strategic_game, {
                      type: :game,
                      initial_state: create_tic_tac_toe_state
                    }, friendly_name: 'Strategic Game Position')

  results = bench.run
  bench.display_results(results)

  puts "\n🎯 Depth Analysis:"
  puts 'This comparison reveals:'
  puts '• How search depth affects solution quality'
  puts '• The exponential growth of search time'
  puts '• Memory requirements at different depths'
  puts '• The point of diminishing returns'

  results
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  begin
    # Run the main benchmark
    main_results = run_search_benchmark

    # Run specialized demonstrations
    puts "\n#{'=' * 80}"
    puts '🔬 SPECIALIZED DEMONSTRATIONS'
    puts '=' * 80

    demonstrate_heuristic_comparison
    demonstrate_depth_analysis

    puts "\n🎉 All demonstrations complete!"
    puts "\nKey Takeaways:"
    puts '• Different algorithms excel at different problem types'
    puts '• Heuristic choice significantly impacts pathfinding performance'
    puts '• Search depth involves trade-offs between quality and time'
    puts '• Algorithm selection depends on specific requirements'

    # Performance summary
    puts "\n📈 Performance Summary:"
    puts "Main benchmark tested #{main_results.keys.size} algorithms on #{main_results.values.first.keys.size} problems"

    total_tests = main_results.values.sum(&:size)
    successful_tests = main_results.values.sum { |algo_results| algo_results.values.count { |r| r[:success] } }

    puts "Success rate: #{(successful_tests.to_f / total_tests * 100).round(1)}%"

    # Algorithm performance highlights
    puts "\n🏆 Performance Highlights:"
    main_results.each do |algo_name, algo_results|
      successful_results = algo_results.values.select { |r| r[:success] }
      next unless successful_results.any?

      avg_time = successful_results.sum { |r| r[:search_time] } / successful_results.size
      avg_nodes = successful_results.sum { |r| r[:nodes_explored] } / successful_results.size
      puts "• #{algo_name}: #{avg_time.round(4)}s avg, #{avg_nodes.round(0)} nodes avg"
    end
  rescue StandardError => e
    puts "❌ Error running benchmark: #{e.message}"
    puts e.backtrace.first(5)
  end
end
