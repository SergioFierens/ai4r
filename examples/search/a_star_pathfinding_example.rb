#!/usr/bin/env ruby
# frozen_string_literal: true

#
# A* Search Educational Example
#
# This example demonstrates the A* pathfinding algorithm with various scenarios
# and educational features to help students understand heuristic search.
#
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# Run with: ruby examples/search/a_star_pathfinding_example.rb
#

require_relative '../../lib/ai4r'

# Educational A* Search Demonstration
class AStarEducationalDemo
  def self.run
    puts "🧠 A* Search Algorithm Educational Demo"
    puts "=" * 50
    puts

    # Example 1: Simple pathfinding
    puts "📍 Example 1: Simple Grid Pathfinding"
    puts "-" * 30
    simple_grid_example

    puts "\n" + "=" * 50 + "\n"

    # Example 2: Pathfinding with obstacles
    puts "🚧 Example 2: Navigating Around Obstacles"
    puts "-" * 30
    obstacle_navigation_example

    puts "\n" + "=" * 50 + "\n"

    # Example 3: Heuristic comparison
    puts "🔬 Example 3: Comparing Different Heuristics"
    puts "-" * 30
    heuristic_comparison_example

    puts "\n" + "=" * 50 + "\n"

    # Example 4: Complex maze solving
    puts "🏰 Example 4: Complex Maze Solving"
    puts "-" * 30
    maze_solving_example

    puts "\n" + "=" * 50 + "\n"

    # Example 5: Performance analysis
    puts "📊 Example 5: Performance Analysis"
    puts "-" * 30
    performance_analysis_example

    puts "\n🎓 A* Search Educational Demo Complete!"
    puts "Try modifying the grids and parameters to experiment more!"
  end

  private

  def self.simple_grid_example
    # Create a simple 5x5 grid
    grid = [
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0]
    ]

    puts "🗺️  Grid Layout (5x5, all open spaces):"
    display_grid(grid)

    # Find path from top-left to bottom-right
    astar = Ai4r::Search::AStar.new(grid, verbose: true)
    path = astar.find_path([0, 0], [4, 4])

    if path
      puts "\n✅ Path found! #{path.length} steps"
      puts "📍 Path: #{path.inspect}"
      puts "💰 Path cost: #{astar.path_cost.round(2)}"
      puts "🔍 Nodes explored: #{astar.nodes_explored}"
      puts "⏱️  Search time: #{astar.search_time.round(4)} seconds"
      
      puts "\n🎨 Path visualization:"
      puts astar.visualize_grid(path)
    else
      puts "❌ No path found!"
    end
  end

  def self.obstacle_navigation_example
    # Create grid with obstacles
    grid = [
      [0, 0, 0, 1, 0, 0, 0],
      [0, 1, 0, 1, 0, 1, 0],
      [0, 1, 0, 0, 0, 1, 0],
      [0, 1, 1, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 1, 0],
      [1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0]
    ]

    puts "🗺️  Grid Layout (7x7 with obstacles):"
    display_grid(grid)

    # Find path around obstacles
    astar = Ai4r::Search::AStar.new(grid, verbose: true)
    path = astar.find_path([0, 0], [6, 6])

    if path
      puts "\n✅ Path found navigating around obstacles!"
      puts "📍 Path length: #{path.length} steps"
      puts "💰 Path cost: #{astar.path_cost.round(2)}"
      puts "🔍 Nodes explored: #{astar.nodes_explored}"
      
      puts "\n🎨 Path visualization:"
      puts astar.visualize_grid(path)
    else
      puts "❌ No path found!"
    end
  end

  def self.heuristic_comparison_example
    # Create challenging grid for heuristic comparison
    grid = [
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 1, 1, 1, 1, 1, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0],
      [0, 1, 0, 1, 1, 1, 1, 1],
      [0, 0, 0, 1, 0, 0, 0, 0],
      [1, 1, 1, 1, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0]
    ]

    puts "🗺️  Test Grid (8x8 with complex obstacles):"
    display_grid(grid)

    # Compare different heuristics
    astar = Ai4r::Search::AStar.new(grid)
    results = astar.compare_heuristics([0, 0], [7, 7])

    puts "\n🔬 Heuristic Comparison Results:"
    puts "Heuristic".ljust(12) + " | Found | Length | Cost  | Nodes | Time(s)"
    puts "-" * 55

    results.each do |heuristic, data|
      status = data[:path_found] ? "✅ Yes" : "❌ No "
      length = data[:path_length].to_s.rjust(6)
      cost = data[:path_cost].round(2).to_s.rjust(5)
      nodes = data[:nodes_explored].to_s.rjust(5)
      time = data[:search_time].round(4).to_s.rjust(6)
      
      puts "#{heuristic.to_s.ljust(12)} | #{status} | #{length} | #{cost} | #{nodes} | #{time}"
    end

    puts "\n💡 Educational Insights:"
    puts "- Manhattan: Good for grid-based movement"
    puts "- Euclidean: More accurate for continuous space"
    puts "- Chebyshev: Optimized for 8-directional movement"
    puts "- Diagonal: Balances diagonal and orthogonal costs"
    puts "- Null: Transforms A* into Dijkstra's algorithm"
  end

  def self.maze_solving_example
    # Create a more complex maze
    maze = [
      [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
      [0, 1, 0, 1, 0, 1, 1, 1, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0, 1, 0],
      [0, 1, 1, 1, 1, 1, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [1, 1, 1, 1, 0, 1, 1, 1, 1, 0],
      [0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
      [0, 1, 1, 1, 1, 1, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    ]

    puts "🗺️  Complex Maze (10x10):"
    display_grid(maze)

    # Solve maze with step-by-step mode (commented out for demo)
    # astar = Ai4r::Search::AStar.new(maze, step_by_step: true, verbose: true)
    astar = Ai4r::Search::AStar.new(maze, verbose: true)
    
    start_time = Time.now
    path = astar.find_path([0, 0], [9, 9])
    end_time = Time.now

    if path
      puts "\n🎉 Maze solved successfully!"
      puts "📊 Solution Statistics:"
      puts "  • Path length: #{path.length} steps"
      puts "  • Path cost: #{astar.path_cost.round(2)}"
      puts "  • Nodes explored: #{astar.nodes_explored}"
      puts "  • Total search time: #{(end_time - start_time).round(4)} seconds"
      puts "  • Max open list size: #{astar.open_list_max_size}"
      
      puts "\n🎨 Solution visualization:"
      puts astar.visualize_grid(path)
    else
      puts "❌ No solution found for this maze!"
    end
  end

  def self.performance_analysis_example
    # Create different sized grids for performance analysis
    grid_sizes = [10, 15, 20, 25]
    
    puts "📊 Performance Analysis Across Different Grid Sizes:"
    puts "Size | Nodes | Time(s) | Path Length | Path Cost"
    puts "-" * 45

    grid_sizes.each do |size|
      # Create grid with some obstacles
      grid = Array.new(size) { Array.new(size, 0) }
      
      # Add some obstacles (about 20% of cells)
      obstacle_count = (size * size * 0.2).to_i
      obstacle_count.times do
        row = rand(size)
        col = rand(size)
        # Don't block start or goal
        next if (row == 0 && col == 0) || (row == size-1 && col == size-1)
        grid[row][col] = 1
      end

      astar = Ai4r::Search::AStar.new(grid)
      
      start_time = Time.now
      path = astar.find_path([0, 0], [size-1, size-1])
      end_time = Time.now

      if path
        nodes = astar.nodes_explored.to_s.rjust(5)
        time = (end_time - start_time).round(4).to_s.rjust(6)
        length = path.length.to_s.rjust(11)
        cost = astar.path_cost.round(2).to_s.rjust(9)
        
        puts "#{size}x#{size} | #{nodes} | #{time} | #{length} | #{cost}"
      else
        puts "#{size}x#{size} | No path found"
      end
    end

    puts "\n💡 Performance Insights:"
    puts "- Search time generally increases with grid size"
    puts "- Node exploration depends on obstacle placement"
    puts "- A* is efficient even for moderately large grids"
    puts "- Heuristic quality affects search efficiency"
  end

  def self.display_grid(grid)
    puts "   #{(0...grid[0].length).map { |i| i.to_s.rjust(2) }.join(' ')}"
    grid.each_with_index do |row, row_idx|
      print "#{row_idx.to_s.rjust(2)} "
      row.each do |cell|
        print cell == 1 ? ' ■ ' : ' · '
      end
      puts
    end
  end
end

# Interactive A* Learning Tool
class InteractiveAStarLearning
  def self.run
    puts "\n🎓 Interactive A* Learning Tool"
    puts "=" * 40
    puts "Let's build and solve a custom pathfinding problem!"
    puts

    # Get grid size
    print "Enter grid size (e.g., 5 for 5x5): "
    size = gets.chomp.to_i
    size = 5 if size < 3 || size > 20

    # Create empty grid
    grid = Array.new(size) { Array.new(size, 0) }

    puts "\nCreating #{size}x#{size} grid..."
    puts "Now let's add some obstacles!"

    # Add obstacles interactively
    puts "\nEnter obstacle positions (row,col) or 'done' to finish:"
    puts "Example: 1,2 adds obstacle at row 1, column 2"
    
    loop do
      print "Add obstacle (row,col) or 'done': "
      input = gets.chomp.downcase
      break if input == 'done'

      if input.match?(/^\d+,\d+$/)
        row, col = input.split(',').map(&:to_i)
        if row < size && col < size
          grid[row][col] = 1
          puts "Added obstacle at [#{row}, #{col}]"
        else
          puts "Invalid position! Must be within grid bounds."
        end
      else
        puts "Invalid format! Use 'row,col' format."
      end
    end

    # Display current grid
    puts "\nYour grid:"
    display_grid(grid)

    # Get start and goal positions
    print "\nEnter start position (row,col): "
    start_input = gets.chomp
    start = start_input.split(',').map(&:to_i)

    print "Enter goal position (row,col): "
    goal_input = gets.chomp
    goal = goal_input.split(',').map(&:to_i)

    # Choose heuristic
    puts "\nChoose heuristic function:"
    puts "1. Manhattan (good for grid movement)"
    puts "2. Euclidean (straight-line distance)"
    puts "3. Chebyshev (8-directional optimized)"
    puts "4. Diagonal (mixed movement costs)"
    puts "5. Null (Dijkstra's algorithm)"

    print "Enter choice (1-5): "
    heuristic_choice = gets.chomp.to_i

    heuristics = [:manhattan, :euclidean, :chebyshev, :diagonal, :null]
    chosen_heuristic = heuristics[heuristic_choice - 1] || :manhattan

    # Solve the pathfinding problem
    puts "\n🔍 Solving your pathfinding problem..."
    puts "Using #{chosen_heuristic} heuristic"

    astar = Ai4r::Search::AStar.new(grid, heuristic: chosen_heuristic, verbose: true)
    path = astar.find_path(start, goal)

    if path
      puts "\n🎉 Solution found!"
      puts "Path: #{path.inspect}"
      puts "Path length: #{path.length} steps"
      puts "Path cost: #{astar.path_cost.round(2)}"
      puts "Nodes explored: #{astar.nodes_explored}"
      
      puts "\nSolution visualization:"
      puts astar.visualize_grid(path)
    else
      puts "\n❌ No path exists between start and goal!"
    end
  end

  def self.display_grid(grid)
    puts "   #{(0...grid[0].length).map { |i| i.to_s.rjust(2) }.join(' ')}"
    grid.each_with_index do |row, row_idx|
      print "#{row_idx.to_s.rjust(2)} "
      row.each do |cell|
        print cell == 1 ? ' ■ ' : ' · '
      end
      puts
    end
  end
end

# Main execution
if __FILE__ == $0
  puts "🚀 Welcome to A* Search Educational Examples!"
  puts
  puts "Choose an option:"
  puts "1. Run educational demo"
  puts "2. Interactive learning tool"
  puts "3. Both"
  puts

  print "Enter choice (1-3): "
  choice = gets.chomp.to_i

  case choice
  when 1
    AStarEducationalDemo.run
  when 2
    InteractiveAStarLearning.run
  when 3
    AStarEducationalDemo.run
    puts "\n" + "=" * 60 + "\n"
    InteractiveAStarLearning.run
  else
    puts "Invalid choice! Running demo..."
    AStarEducationalDemo.run
  end

  puts "\n🎓 Thanks for learning about A* Search!"
  puts "Experiment with different grids and heuristics to deepen your understanding!"
end