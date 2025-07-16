# frozen_string_literal: true

#
# Minimax Algorithm with Alpha-Beta Pruning Implementation for AI4R Educational Framework
#
# This implementation provides a comprehensive, educational version of the Minimax algorithm
# with Alpha-Beta pruning, designed specifically for students and teachers to understand
# game AI concepts and adversarial search.
#
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# The Minimax algorithm is a decision-making algorithm for two-player zero-sum games.
# It assumes both players play optimally, with one player (MAX) trying to maximize
# the score and the other (MIN) trying to minimize it.
#
# Key Educational Concepts:
# - Game Tree: Represents all possible game states
# - Minimax Value: The best achievable score for a player assuming optimal play
# - Alpha-Beta Pruning: Optimization that eliminates branches that won't affect the result
# - Depth-Limited Search: Practical limitation for complex games
# - Evaluation Functions: Heuristic scoring for non-terminal states
#
# Example Usage:
#   # Create a simple game state
#   game_state = TicTacToeState.new(board, :x)
#
#   # Find best move using minimax
#   minimax = Minimax.new(max_depth: 6, alpha_beta: true)
#   best_move = minimax.find_best_move(game_state)
#   puts "Best move: #{best_move}"
#

module Ai4r
  module Search
    # Minimax Algorithm with Alpha-Beta Pruning
    #
    # This class implements the minimax algorithm with optional alpha-beta pruning
    # for educational purposes. It provides comprehensive debugging information,
    # statistics tracking, and step-by-step visualization.
    #
    # The algorithm works by:
    # 1. Exploring all possible game states up to a certain depth
    # 2. Evaluating leaf nodes using an evaluation function
    # 3. Propagating values up the tree (MAX takes maximum, MIN takes minimum)
    # 4. Pruning branches that cannot affect the final result (alpha-beta)
    #
    # Educational Features:
    # - Detailed search statistics
    # - Step-by-step tree exploration
    # - Pruning visualization
    # - Performance comparisons (with/without pruning)
    # - Move ordering analysis
    #
    class Minimax
      # Search statistics for educational analysis
      attr_reader :nodes_explored, :nodes_pruned, :max_depth_reached, :search_time
      attr_reader :tree_size, :branching_factor, :alpha_beta_enabled

      # Educational configuration
      attr_accessor :verbose_mode, :step_by_step_mode, :show_pruning

      # Default configuration values
      DEFAULT_MAX_DEPTH = 6
      DEFAULT_ALPHA = -Float::INFINITY
      DEFAULT_BETA = Float::INFINITY

      # Initialize Minimax search with configuration
      #
      # @param max_depth [Integer] Maximum search depth
      # @param alpha_beta [Boolean] Enable alpha-beta pruning
      # @param options [Hash] Additional configuration options
      #
      def initialize(max_depth: DEFAULT_MAX_DEPTH, alpha_beta: true, **options)
        @max_depth = validate_max_depth(max_depth)
        @alpha_beta_enabled = alpha_beta

        # Educational configuration
        @verbose_mode = options.fetch(:verbose, false)
        @step_by_step_mode = options.fetch(:step_by_step, false)
        @show_pruning = options.fetch(:show_pruning, false)

        # Initialize statistics
        reset_statistics
      end

      # Find the best move for the current player using minimax
      #
      # @param game_state [GameState] Current game state
      # @return [Object] Best move for current player
      #
      # Educational Note:
      # This method demonstrates the complete minimax decision process:
      # 1. Validate the game state
      # 2. Generate all possible moves
      # 3. Evaluate each move using minimax
      # 4. Select the move with the best minimax value
      # 5. Return comprehensive results including statistics
      #
      def find_best_move(game_state)
        validate_game_state(game_state)

        # Reset statistics for new search
        reset_statistics
        @search_start_time = Time.now

        educational_output('🎮 Minimax Search Starting', <<~MSG)
          Current player: #{game_state.current_player}
          Max depth: #{@max_depth}
          Alpha-Beta pruning: #{@alpha_beta_enabled ? 'Enabled' : 'Disabled'}
        MSG

        # Get all possible moves
        possible_moves = game_state.get_possible_moves

        if possible_moves.empty?
          educational_output('⚠️  No moves available', 'Game may be over')
          return nil
        end

        # Initialize best move tracking
        best_move = nil
        best_value = -Float::INFINITY
        alpha = DEFAULT_ALPHA
        beta = DEFAULT_BETA

        # Evaluate each possible move
        possible_moves.each_with_index do |move, move_index|
          # Make the move and get resulting state
          new_state = game_state.make_move(move)

          # Evaluate this move using minimax
          move_value = minimax_value(new_state, @max_depth - 1, alpha, beta, false)

          educational_step_output(move, move_value, move_index + 1, possible_moves.length)

          # Update best move if this is better
          if move_value > best_value
            best_value = move_value
            best_move = move
          end

          # Update alpha for alpha-beta pruning
          alpha = [alpha, move_value].max if @alpha_beta_enabled
        end

        # Calculate final statistics
        @search_time = Time.now - @search_start_time
        @branching_factor = calculate_branching_factor

        educational_output('🏆 Best Move Found', <<~MSG)
          Best move: #{best_move}
          Expected value: #{best_value}
          Nodes explored: #{@nodes_explored}
          Nodes pruned: #{@nodes_pruned}
          Search time: #{@search_time.round(4)} seconds
          Effective branching factor: #{@branching_factor.round(2)}
        MSG

        MinimaxResult.new(
          best_move: best_move,
          best_value: best_value,
          nodes_explored: @nodes_explored,
          nodes_pruned: @nodes_pruned,
          search_time: @search_time,
          tree_size: @tree_size,
          branching_factor: @branching_factor
        )
      end

      # Core minimax algorithm with alpha-beta pruning
      #
      # @param game_state [GameState] Current game state to evaluate
      # @param depth [Integer] Remaining search depth
      # @param alpha [Float] Alpha value for pruning (best for MAX)
      # @param beta [Float] Beta value for pruning (best for MIN)
      # @param maximizing_player [Boolean] True if current player is maximizing
      # @return [Float] Minimax value for this game state
      #
      # Educational Note:
      # This is the heart of the minimax algorithm:
      # - Base case: If depth is 0 or game is over, return evaluation
      # - Recursive case: Explore all possible moves
      # - MAX player: Choose maximum value from children
      # - MIN player: Choose minimum value from children
      # - Alpha-Beta pruning: Skip branches that can't improve the result
      #
      def minimax_value(game_state, depth, alpha, beta, maximizing_player)
        @nodes_explored += 1
        @max_depth_reached = [@max_depth_reached, @max_depth - depth].max

        # Base case: Terminal state or depth limit reached
        if depth == 0 || game_state.game_over?
          evaluation = game_state.evaluate
          educational_evaluation_output(game_state, evaluation, depth)
          return evaluation
        end

        # Get possible moves
        possible_moves = game_state.get_possible_moves
        @tree_size += possible_moves.length

        if maximizing_player
          # MAX player: Try to maximize the score
          max_value = -Float::INFINITY

          possible_moves.each do |move|
            # Make move and recurse
            new_state = game_state.make_move(move)
            value = minimax_value(new_state, depth - 1, alpha, beta, false)

            # Update maximum value
            max_value = [max_value, value].max

            # Alpha-beta pruning
            next unless @alpha_beta_enabled

            alpha = [alpha, value].max
            next unless beta <= alpha

            @nodes_pruned += 1
            pruning_output('MAX', alpha, beta, depth)
            break # Beta cutoff
          end

          max_value
        else
          # MIN player: Try to minimize the score
          min_value = Float::INFINITY

          possible_moves.each do |move|
            # Make move and recurse
            new_state = game_state.make_move(move)
            value = minimax_value(new_state, depth - 1, alpha, beta, true)

            # Update minimum value
            min_value = [min_value, value].min

            # Alpha-beta pruning
            next unless @alpha_beta_enabled

            beta = [beta, value].min
            next unless beta <= alpha

            @nodes_pruned += 1
            pruning_output('MIN', alpha, beta, depth)
            break # Alpha cutoff
          end

          min_value
        end
      end

      # Compare performance with and without alpha-beta pruning
      #
      # @param game_state [GameState] Game state to analyze
      # @return [Hash] Comparison results
      #
      def compare_pruning_performance(game_state)
        results = {}

        # Test without alpha-beta pruning
        @alpha_beta_enabled = false
        reset_statistics
        start_time = Time.now
        result_no_pruning = find_best_move(game_state)
        end_time = Time.now

        results[:without_pruning] = {
          best_move: result_no_pruning.best_move,
          best_value: result_no_pruning.best_value,
          nodes_explored: @nodes_explored,
          nodes_pruned: @nodes_pruned,
          search_time: end_time - start_time
        }

        # Test with alpha-beta pruning
        @alpha_beta_enabled = true
        reset_statistics
        start_time = Time.now
        result_with_pruning = find_best_move(game_state)
        end_time = Time.now

        results[:with_pruning] = {
          best_move: result_with_pruning.best_move,
          best_value: result_with_pruning.best_value,
          nodes_explored: @nodes_explored,
          nodes_pruned: @nodes_pruned,
          search_time: end_time - start_time
        }

        # Calculate improvement
        nodes_saved = results[:without_pruning][:nodes_explored] - results[:with_pruning][:nodes_explored]
        time_saved = results[:without_pruning][:search_time] - results[:with_pruning][:search_time]

        results[:improvement] = {
          nodes_saved: nodes_saved,
          nodes_percentage: (nodes_saved.to_f / results[:without_pruning][:nodes_explored] * 100).round(2),
          time_saved: time_saved,
          time_percentage: (time_saved / results[:without_pruning][:search_time] * 100).round(2)
        }

        results
      end

      # Analyze the game tree structure
      #
      # @param game_state [GameState] Root game state
      # @param max_analysis_depth [Integer] Maximum depth for analysis
      # @return [Hash] Tree analysis results
      #
      def analyze_game_tree(game_state, max_analysis_depth = 3)
        analysis = {
          depth_info: {},
          total_nodes: 0,
          average_branching_factor: 0,
          max_branching_factor: 0,
          min_branching_factor: Float::INFINITY
        }

        analyze_tree_recursive(game_state, 0, max_analysis_depth, analysis)

        # Calculate average branching factor
        total_branching = analysis[:depth_info].values.sum { |info| info[:total_branching] }
        total_non_leaf = analysis[:depth_info].values.sum { |info| info[:non_leaf_nodes] }
        analysis[:average_branching_factor] = total_non_leaf > 0 ? total_branching.to_f / total_non_leaf : 0

        analysis
      end

      private

      # Validate maximum depth parameter
      def validate_max_depth(max_depth)
        unless max_depth.is_a?(Integer) && max_depth > 0
          raise ArgumentError, "max_depth must be a positive integer, got: #{max_depth}"
        end

        max_depth
      end

      # Validate game state object
      def validate_game_state(game_state)
        unless game_state.respond_to?(:get_possible_moves) &&
               game_state.respond_to?(:make_move) &&
               game_state.respond_to?(:evaluate) &&
               game_state.respond_to?(:game_over?) &&
               game_state.respond_to?(:current_player)
          raise ArgumentError,
                'game_state must implement required methods: get_possible_moves, make_move, evaluate, game_over?, current_player'
        end
      end

      # Reset statistics for new search
      def reset_statistics
        @nodes_explored = 0
        @nodes_pruned = 0
        @max_depth_reached = 0
        @search_time = 0
        @tree_size = 0
        @branching_factor = 0
      end

      # Calculate effective branching factor
      def calculate_branching_factor
        return 0 if @nodes_explored <= 1

        Math.log(@nodes_explored) / Math.log(@max_depth_reached + 1)
      end

      # Recursive tree analysis helper
      def analyze_tree_recursive(game_state, current_depth, max_depth, analysis)
        return if current_depth > max_depth || game_state.game_over?

        # Initialize depth info if not exists
        analysis[:depth_info][current_depth] ||= {
          nodes: 0,
          total_branching: 0,
          non_leaf_nodes: 0
        }

        analysis[:depth_info][current_depth][:nodes] += 1
        analysis[:total_nodes] += 1

        # Get possible moves
        possible_moves = game_state.get_possible_moves
        branching_factor = possible_moves.length

        return unless branching_factor > 0 && current_depth < max_depth

        analysis[:depth_info][current_depth][:total_branching] += branching_factor
        analysis[:depth_info][current_depth][:non_leaf_nodes] += 1

        # Update min/max branching factors
        analysis[:max_branching_factor] = [analysis[:max_branching_factor], branching_factor].max
        analysis[:min_branching_factor] = [analysis[:min_branching_factor], branching_factor].min

        # Recurse for each move
        possible_moves.each do |move|
          new_state = game_state.make_move(move)
          analyze_tree_recursive(new_state, current_depth + 1, max_depth, analysis)
        end
      end

      # Educational output helper
      def educational_output(title, content)
        return unless @verbose_mode

        puts "\n#{title}"
        puts '=' * title.length
        puts content
      end

      # Step-by-step educational output
      def educational_step_output(move, value, move_num, total_moves)
        return unless @step_by_step_mode

        puts "\n🔍 Evaluating move #{move_num}/#{total_moves}: #{move}"
        puts "   Minimax value: #{value}"
        puts "   Nodes explored so far: #{@nodes_explored}"
        puts "   Nodes pruned so far: #{@nodes_pruned}" if @alpha_beta_enabled
        puts '   Press Enter to continue...' if @step_by_step_mode
        gets if @step_by_step_mode
      end

      # Evaluation output for terminal states
      def educational_evaluation_output(_game_state, evaluation, depth)
        return unless @verbose_mode && depth == 0

        puts "📊 Leaf evaluation: #{evaluation} (depth #{@max_depth - depth})"
      end

      # Pruning visualization output
      def pruning_output(player_type, alpha, beta, depth)
        return unless @show_pruning

        puts "✂️  #{player_type} pruning at depth #{@max_depth - depth}: α=#{alpha}, β=#{beta}"
      end
    end

    # Result structure for minimax search
    #
    # Contains comprehensive information about the search results,
    # including the best move found and detailed statistics.
    #
    MinimaxResult = Struct.new(
      :best_move,
      :best_value,
      :nodes_explored,
      :nodes_pruned,
      :search_time,
      :tree_size,
      :branching_factor
    ) do
      # Calculate pruning efficiency
      def pruning_efficiency
        return 0 if tree_size == 0

        (nodes_pruned.to_f / tree_size * 100).round(2)
      end

      # Educational string representation
      def to_s
        <<~RESULT
          Minimax Search Result:
          =====================
          Best move: #{best_move}
          Expected value: #{best_value}
          Nodes explored: #{nodes_explored}
          Nodes pruned: #{nodes_pruned}
          Search time: #{search_time.round(4)}s
          Tree size: #{tree_size}
          Branching factor: #{branching_factor.round(2)}
          Pruning efficiency: #{pruning_efficiency}%
        RESULT
      end
    end

    # Abstract base class for game states
    #
    # This class defines the interface that game states must implement
    # to work with the minimax algorithm. It serves as both documentation
    # and a base class for educational game implementations.
    #
    class GameState
      # Get all possible moves from this state
      # @return [Array] Array of possible moves
      def get_possible_moves
        raise NotImplementedError, 'Subclasses must implement get_possible_moves'
      end

      # Make a move and return the resulting game state
      # @param move [Object] The move to make
      # @return [GameState] New game state after the move
      def make_move(move)
        raise NotImplementedError, 'Subclasses must implement make_move'
      end

      # Evaluate the current game state
      # @return [Float] Evaluation score (positive favors current player)
      def evaluate
        raise NotImplementedError, 'Subclasses must implement evaluate'
      end

      # Check if the game is over
      # @return [Boolean] True if game is over
      def game_over?
        raise NotImplementedError, 'Subclasses must implement game_over?'
      end

      # Get the current player
      # @return [Object] Current player identifier
      def current_player
        raise NotImplementedError, 'Subclasses must implement current_player'
      end

      # Get the winner if game is over
      # @return [Object] Winner identifier or nil if no winner
      def winner
        nil
      end

      # Create a deep copy of the game state
      # @return [GameState] Deep copy of this state
      def deep_copy
        raise NotImplementedError, 'Subclasses must implement deep_copy'
      end

      # Educational string representation
      def to_s
        "GameState(#{current_player})"
      end
    end
  end
end
