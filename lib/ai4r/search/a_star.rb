# frozen_string_literal: true

#
# A* Search Algorithm Implementation for AI4R Educational Framework
#
# This implementation provides a comprehensive, educational version of the A* pathfinding algorithm,
# designed specifically for students and teachers to understand heuristic search concepts.
#
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# The A* algorithm is a best-first search algorithm that finds the optimal path from a start node
# to a goal node. It uses both the actual cost from start (g) and a heuristic estimate to goal (h)
# to guide the search efficiently.
#
# Key Educational Concepts:
# - Heuristic Functions: h(n) estimates remaining cost to goal
# - Cost Functions: g(n) tracks actual cost from start
# - f(n) = g(n) + h(n): Total estimated cost through node n
# - Admissible Heuristics: Never overestimate the true cost
# - Consistent Heuristics: Satisfy triangle inequality
#
# Example Usage:
#   # Create a simple grid world
#   grid = [
#     [0, 0, 0, 1, 0],
#     [0, 1, 0, 1, 0],
#     [0, 0, 0, 0, 0],
#     [1, 1, 0, 1, 0],
#     [0, 0, 0, 0, 0]
#   ]
#
#   # Find path from top-left to bottom-right
#   astar = AStar.new(grid)
#   path = astar.find_path([0, 0], [4, 4])
#   puts "Path found: #{path.inspect}"
#

module Ai4r
  module Search
    # A* Search Algorithm Implementation
    #
    # This class implements the A* pathfinding algorithm with educational features
    # including step-by-step visualization, multiple heuristics, and comprehensive
    # debugging information.
    #
    # The algorithm maintains two key data structures:
    # - Open List: Nodes to be explored, sorted by f(n) = g(n) + h(n)
    # - Closed List: Nodes already explored
    #
    # Educational Features:
    # - Multiple heuristic functions for comparison
    # - Step-by-step search visualization
    # - Performance metrics and statistics
    # - Path reconstruction with detailed costs
    # - Comprehensive error handling and validation
    #
    class AStar
      # Available heuristic functions for educational comparison
      HEURISTIC_FUNCTIONS = %i[
        manhattan
        euclidean
        chebyshev
        diagonal
        null
      ].freeze

      # Search statistics for educational analysis
      attr_reader :nodes_explored, :nodes_generated, :path_cost, :search_time
      attr_reader :open_list_max_size, :heuristic_function, :step_history

      # Educational configuration options
      attr_accessor :step_by_step_mode, :verbose_mode, :max_iterations

      # Node representation for A* search
      #
      # Each node contains:
      # - position: [x, y] coordinates
      # - g_cost: Actual cost from start
      # - h_cost: Heuristic estimate to goal
      # - f_cost: Total estimated cost (g + h)
      # - parent: Reference to parent node for path reconstruction
      #
      Node = Struct.new(:position, :g_cost, :h_cost, :f_cost, :parent) do
        # Calculate total estimated cost
        def calculate_f_cost
          self.f_cost = g_cost + h_cost
        end

        # Check if two nodes represent the same position
        def same_position?(other)
          position == other.position
        end

        # Educational string representation
        def to_s
          "Node(#{position.inspect}, g=#{g_cost}, h=#{h_cost}, f=#{f_cost})"
        end
      end

      # Initialize A* search with grid environment
      #
      # @param grid [Array<Array<Integer>>] 2D grid where 0=passable, 1=obstacle
      # @param heuristic [Symbol] Heuristic function to use
      # @param options [Hash] Additional configuration options
      #
      def initialize(grid, heuristic: :manhattan, **options)
        @grid = validate_grid(grid)
        @rows = @grid.length
        @cols = @grid[0].length
        @heuristic_function = validate_heuristic(heuristic)

        # Educational configuration
        @step_by_step_mode = options.fetch(:step_by_step, false)
        @verbose_mode = options.fetch(:verbose, false)
        @max_iterations = options.fetch(:max_iterations, 10_000)

        # Initialize statistics
        reset_statistics
      end

      # Find optimal path from start to goal using A* algorithm
      #
      # @param start [Array<Integer>] Starting position [row, col]
      # @param goal [Array<Integer>] Goal position [row, col]
      # @return [Array<Array<Integer>>] Path as array of positions, or nil if no path exists
      #
      # Educational Note:
      # This method demonstrates the complete A* algorithm:
      # 1. Initialize open and closed lists
      # 2. Add start node to open list
      # 3. While open list is not empty:
      #    a. Get node with lowest f(n) from open list
      #    b. If node is goal, reconstruct path
      #    c. Move node from open to closed list
      #    d. For each neighbor:
      #       - Calculate tentative g cost
      #       - If better path found, update node
      #       - Add to open list if not already there
      # 4. Return failure if open list becomes empty
      #
      def find_path(start, goal)
        # Validate input parameters
        validate_position(start, 'start')
        validate_position(goal, 'goal')

        # Reset statistics for new search
        reset_statistics
        @search_start_time = Time.now

        # Initialize A* data structures
        open_list = []
        closed_list = []

        # Create start node
        start_node = create_node(start, 0, heuristic_cost(start, goal))
        open_list << start_node

        educational_output('🎯 A* Search Starting', <<~MSG)
          Start: #{start.inspect}
          Goal: #{goal.inspect}
          Heuristic: #{@heuristic_function}
          Grid size: #{@rows} x #{@cols}
        MSG

        # Main A* search loop
        iteration = 0
        while open_list.any? && iteration < @max_iterations
          iteration += 1
          @nodes_explored += 1

          # Get node with lowest f(n) from open list
          current_node = open_list.min_by(&:f_cost)
          open_list.delete(current_node)
          closed_list << current_node

          # Track maximum open list size for educational analysis
          @open_list_max_size = [@open_list_max_size, open_list.length].max

          educational_step_output(current_node, open_list, closed_list, iteration)

          # Check if we've reached the goal
          if current_node.position == goal
            @search_time = Time.now - @search_start_time
            path = reconstruct_path(current_node)
            @path_cost = current_node.g_cost

            educational_output('🎉 Path Found!', <<~MSG)
              Path length: #{path.length} steps
              Path cost: #{@path_cost}
              Nodes explored: #{@nodes_explored}
              Search time: #{@search_time.round(4)} seconds
            MSG

            return path
          end

          # Explore neighbors
          explore_neighbors(current_node, goal, open_list, closed_list)
        end

        # No path found
        @search_time = Time.now - @search_start_time
        educational_output('❌ No Path Found', <<~MSG)
          Nodes explored: #{@nodes_explored}
          Search time: #{@search_time.round(4)} seconds
          Reason: #{iteration >= @max_iterations ? 'Max iterations reached' : 'No path exists'}
        MSG

        nil
      end

      # Calculate heuristic cost using specified heuristic function
      #
      # @param from [Array<Integer>] Starting position
      # @param to [Array<Integer>] Target position
      # @return [Float] Heuristic cost estimate
      #
      # Educational Note:
      # Different heuristics have different properties:
      # - Manhattan: Good for grid worlds with 4-directional movement
      # - Euclidean: Good for continuous spaces
      # - Chebyshev: Good for 8-directional movement
      # - Diagonal: Optimized for 8-directional with different costs
      # - Null: Transforms A* into Dijkstra's algorithm
      #
      def heuristic_cost(from, to)
        case @heuristic_function
        when :manhattan
          manhattan_distance(from, to)
        when :euclidean
          euclidean_distance(from, to)
        when :chebyshev
          chebyshev_distance(from, to)
        when :diagonal
          diagonal_distance(from, to)
        when :null
          0.0
        else
          raise ArgumentError, "Unknown heuristic: #{@heuristic_function}"
        end
      end

      # Get valid neighbors for a given position
      #
      # @param position [Array<Integer>] Current position [row, col]
      # @return [Array<Array<Integer>>] Array of valid neighbor positions
      #
      def get_neighbors(position)
        row, col = position
        neighbors = []

        # 8-directional movement (includes diagonals)
        (-1..1).each do |d_row|
          (-1..1).each do |d_col|
            next if d_row == 0 && d_col == 0 # Skip current position

            new_row = row + d_row
            new_col = col + d_col

            # Check bounds and obstacles
            neighbors << [new_row, new_col] if valid_position?([new_row, new_col])
          end
        end

        neighbors
      end

      # Calculate movement cost between two adjacent positions
      #
      # @param from [Array<Integer>] Starting position
      # @param to [Array<Integer>] Target position
      # @return [Float] Movement cost
      #
      # Educational Note:
      # This method demonstrates different movement costs:
      # - Orthogonal moves (up, down, left, right): cost = 1.0
      # - Diagonal moves: cost = √2 ≈ 1.414 (Euclidean distance)
      #
      def movement_cost(from, to)
        from_row, from_col = from
        to_row, to_col = to

        # Calculate if move is diagonal
        row_diff = (to_row - from_row).abs
        col_diff = (to_col - from_col).abs

        if row_diff == 1 && col_diff == 1
          Math.sqrt(2) # Diagonal move
        else
          1.0 # Orthogonal move
        end
      end

      # Generate educational visualization of current grid state
      #
      # @param path [Array<Array<Integer>>] Optional path to highlight
      # @return [String] ASCII visualization of grid
      #
      def visualize_grid(path = nil)
        path_positions = path ? path.to_set : Set.new
        visualization = "\n🗺️  Grid Visualization:\n"
        visualization += "   #{(0...@cols).map { |i| i.to_s.rjust(2) }.join(' ')}\n"

        @grid.each_with_index do |row, row_idx|
          visualization += "#{row_idx.to_s.rjust(2)} "
          row.each_with_index do |cell, col_idx|
            position = [row_idx, col_idx]
            visualization += if path_positions.include?(position)
                               ' ● ' # Path marker
                             elsif cell == 1
                               ' ■ ' # Obstacle
                             else
                               ' · ' # Empty space
                             end
          end
          visualization += "\n"
        end

        visualization
      end

      # Educational method to compare different heuristics
      #
      # @param start [Array<Integer>] Starting position
      # @param goal [Array<Integer>] Goal position
      # @return [Hash] Comparison results for each heuristic
      #
      def compare_heuristics(start, goal)
        results = {}

        HEURISTIC_FUNCTIONS.each do |heuristic|
          puts "\n🧪 Testing heuristic: #{heuristic}"
          original_heuristic = @heuristic_function
          @heuristic_function = heuristic

          path = find_path(start, goal)
          results[heuristic] = {
            path_found: !path.nil?,
            path_length: path&.length || 0,
            path_cost: @path_cost || Float::INFINITY,
            nodes_explored: @nodes_explored,
            search_time: @search_time
          }

          @heuristic_function = original_heuristic
        end

        results
      end

      private

      # Validate grid structure and content
      def validate_grid(grid)
        raise ArgumentError, 'Grid cannot be nil' if grid.nil?
        raise ArgumentError, 'Grid cannot be empty' if grid.empty?
        raise ArgumentError, 'Grid rows cannot be empty' if grid.any?(&:empty?)

        # Check for rectangular grid
        first_row_length = grid[0].length
        raise ArgumentError, 'Grid must be rectangular' unless grid.all? { |row| row.length == first_row_length }

        # Validate cell values
        grid.each_with_index do |row, row_idx|
          row.each_with_index do |cell, col_idx|
            unless [0, 1].include?(cell)
              raise ArgumentError,
                    "Invalid cell value #{cell} at position [#{row_idx}, #{col_idx}]. Must be 0 or 1."
            end
          end
        end

        grid
      end

      # Validate heuristic function
      def validate_heuristic(heuristic)
        unless HEURISTIC_FUNCTIONS.include?(heuristic)
          raise ArgumentError,
                "Invalid heuristic: #{heuristic}. Must be one of: #{HEURISTIC_FUNCTIONS.join(', ')}"
        end
        heuristic
      end

      # Validate position coordinates
      def validate_position(position, name)
        raise ArgumentError, "#{name} must be [row, col] array" unless position.is_a?(Array) && position.length == 2

        row, col = position
        raise ArgumentError, "#{name} coordinates must be integers" unless row.is_a?(Integer) && col.is_a?(Integer)

        raise ArgumentError, "#{name} position #{position.inspect} is invalid" unless valid_position?(position)
      end

      # Check if position is valid (within bounds and not an obstacle)
      def valid_position?(position)
        row, col = position
        return false if row < 0 || row >= @rows || col < 0 || col >= @cols
        return false if @grid[row][col] == 1 # Obstacle

        true
      end

      # Create new node with calculated costs
      def create_node(position, g_cost, h_cost, parent = nil)
        node = Node.new(position, g_cost, h_cost, 0, parent)
        node.calculate_f_cost
        node
      end

      # Reset statistics for new search
      def reset_statistics
        @nodes_explored = 0
        @nodes_generated = 0
        @path_cost = 0
        @search_time = 0
        @open_list_max_size = 0
        @step_history = []
      end

      # Explore neighbors of current node
      def explore_neighbors(current_node, goal, open_list, closed_list)
        get_neighbors(current_node.position).each do |neighbor_pos|
          # Skip if neighbor is in closed list
          next if closed_list.any? { |node| node.position == neighbor_pos }

          # Calculate tentative g cost
          tentative_g_cost = current_node.g_cost + movement_cost(current_node.position, neighbor_pos)

          # Find existing node in open list
          existing_node = open_list.find { |node| node.position == neighbor_pos }

          if existing_node.nil?
            # Create new node and add to open list
            h_cost = heuristic_cost(neighbor_pos, goal)
            new_node = create_node(neighbor_pos, tentative_g_cost, h_cost, current_node)
            open_list << new_node
            @nodes_generated += 1
          elsif tentative_g_cost < existing_node.g_cost
            # Update existing node with better path
            existing_node.g_cost = tentative_g_cost
            existing_node.parent = current_node
            existing_node.calculate_f_cost
          end
        end
      end

      # Reconstruct path from goal node to start
      def reconstruct_path(goal_node)
        path = []
        current = goal_node

        while current
          path.unshift(current.position)
          current = current.parent
        end

        path
      end

      # Manhattan distance heuristic
      def manhattan_distance(from, to)
        (from[0] - to[0]).abs + (from[1] - to[1]).abs
      end

      # Euclidean distance heuristic
      def euclidean_distance(from, to)
        Math.sqrt(((from[0] - to[0])**2) + ((from[1] - to[1])**2))
      end

      # Chebyshev distance heuristic
      def chebyshev_distance(from, to)
        [(from[0] - to[0]).abs, (from[1] - to[1]).abs].max
      end

      # Diagonal distance heuristic (optimized for 8-directional movement)
      def diagonal_distance(from, to)
        dx = (from[0] - to[0]).abs
        dy = (from[1] - to[1]).abs
        (Math.sqrt(2) * [dx, dy].min) + ([dx, dy].max - [dx, dy].min)
      end

      # Educational output helper
      def educational_output(title, content)
        return unless @verbose_mode

        puts "\n#{title}"
        puts '=' * title.length
        puts content
      end

      # Step-by-step educational output
      def educational_step_output(current_node, open_list, closed_list, iteration)
        return unless @step_by_step_mode

        step_info = {
          iteration: iteration,
          current_node: current_node.position,
          f_cost: current_node.f_cost,
          g_cost: current_node.g_cost,
          h_cost: current_node.h_cost,
          open_list_size: open_list.length,
          closed_list_size: closed_list.length
        }

        @step_history << step_info

        puts "\n🔍 Step #{iteration}:"
        puts "  Current: #{current_node}"
        puts "  Open list: #{open_list.length} nodes"
        puts "  Closed list: #{closed_list.length} nodes"
        puts '  Press Enter to continue...' if @step_by_step_mode
        gets if @step_by_step_mode
      end
    end
  end
end
