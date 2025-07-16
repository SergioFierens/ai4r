#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Minimax with Alpha-Beta Pruning Educational Example
#
# This example demonstrates the Minimax algorithm with Alpha-Beta pruning
# using a simple Tic-Tac-Toe game to help students understand game AI concepts.
#
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# Run with: ruby examples/search/minimax_game_example.rb
#

require_relative '../../lib/ai4r'

# Simple Tic-Tac-Toe game state implementation for Minimax demonstration
class TicTacToeState < Ai4r::Search::GameState
  attr_reader :board, :current_player

  # Initialize with 3x3 board
  # @param board [Array] 3x3 array where nil=empty, :x=X, :o=O
  # @param current_player [Symbol] :x or :o
  def initialize(board = nil, current_player = :x)
    @board = board || Array.new(3) { Array.new(3, nil) }
    @current_player = current_player
  end

  # Get all possible moves (empty cells)
  def get_possible_moves
    moves = []
    @board.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        moves << [r, c] if cell.nil?
      end
    end
    moves
  end

  # Make a move and return new game state
  def make_move(move)
    row, col = move
    new_board = @board.map(&:dup)
    new_board[row][col] = @current_player

    next_player = @current_player == :x ? :o : :x
    TicTacToeState.new(new_board, next_player)
  end

  # Check if game is over
  def game_over?
    winner || get_possible_moves.empty?
  end

  # Get winner if game is over
  def winner
    # Check rows
    @board.each do |row|
      return row[0] if row.all? { |cell| cell == row[0] && !cell.nil? }
    end

    # Check columns
    (0..2).each do |col|
      column = [@board[0][col], @board[1][col], @board[2][col]]
      return column[0] if column.all? { |cell| cell == column[0] && !cell.nil? }
    end

    # Check diagonals
    main_diagonal = [@board[0][0], @board[1][1], @board[2][2]]
    return main_diagonal[0] if main_diagonal.all? { |cell| cell == main_diagonal[0] && !cell.nil? }

    anti_diagonal = [@board[0][2], @board[1][1], @board[2][0]]
    return anti_diagonal[0] if anti_diagonal.all? { |cell| cell == anti_diagonal[0] && !cell.nil? }

    nil
  end

  # Evaluate board position
  def evaluate
    winner_player = winner
    return 10 if winner_player == :x
    return -10 if winner_player == :o
    return 0 if get_possible_moves.empty?

    # Simple heuristic: center control and corner control
    score = 0

    # Center control
    score += 3 if @board[1][1] == :x
    score -= 3 if @board[1][1] == :o

    # Corner control
    corners = [[0, 0], [0, 2], [2, 0], [2, 2]]
    corners.each do |r, c|
      score += 1 if @board[r][c] == :x
      score -= 1 if @board[r][c] == :o
    end

    score
  end

  # Create deep copy
  def deep_copy
    TicTacToeState.new(@board.map(&:dup), @current_player)
  end

  # Display board
  def to_s
    display = "\n"
    @board.each_with_index do |row, r|
      display += "#{r} "
      row.each_with_index do |cell, c|
        symbol = cell.nil? ? ' ' : cell.to_s.upcase
        display += " #{symbol} "
        display += '|' if c < 2
      end
      display += "\n"
      display += "  -----------\n" if r < 2
    end
    display += "   0   1   2\n"
    display
  end
end

# Educational Minimax demonstration
class MinimaxEducationalDemo
  def self.run
    puts '🎮 Minimax with Alpha-Beta Pruning Educational Demo'
    puts '=' * 60
    puts

    # Example 1: Simple position analysis
    puts '📊 Example 1: Simple Position Analysis'
    puts '-' * 40
    simple_position_example

    puts "\n#{'=' * 60}\n"

    # Example 2: Performance comparison
    puts '⚡ Example 2: Alpha-Beta Pruning Performance'
    puts '-' * 40
    performance_comparison_example

    puts "\n#{'=' * 60}\n"

    # Example 3: Game tree analysis
    puts '🌳 Example 3: Game Tree Analysis'
    puts '-' * 40
    game_tree_analysis_example

    puts "\n#{'=' * 60}\n"

    # Example 4: Interactive game
    puts '🎯 Example 4: Interactive Tic-Tac-Toe'
    puts '-' * 40
    interactive_game_example

    puts "\n🎓 Minimax Educational Demo Complete!"
    puts 'Try experimenting with different depths and game states!'
  end

  def self.simple_position_example
    # Create a mid-game position
    board = [
      [:x, nil, :o],
      [nil, :x, nil],
      [:o, nil, nil]
    ]

    game_state = TicTacToeState.new(board, :x)
    puts '🎲 Current game state:'
    puts game_state

    # Analyze with different depths
    [2, 4, 6].each do |depth|
      puts "\n🔍 Analysis with depth #{depth}:"

      minimax = Ai4r::Search::Minimax.new(max_depth: depth, verbose: true)
      result = minimax.find_best_move(game_state)

      if result
        puts "  • Best move: #{result.best_move}"
        puts "  • Expected value: #{result.best_value}"
        puts "  • Nodes explored: #{result.nodes_explored}"
        puts "  • Nodes pruned: #{result.nodes_pruned}"
        puts "  • Search time: #{result.search_time.round(4)}s"
        puts "  • Pruning efficiency: #{result.pruning_efficiency}%"
      else
        puts '  • No valid moves found'
      end
    end
  end

  def self.performance_comparison_example
    # Create a complex mid-game position
    board = [
      [:x, nil, nil],
      [nil, :o, nil],
      [nil, nil, :x]
    ]

    game_state = TicTacToeState.new(board, :o)
    puts '🎲 Test position:'
    puts game_state

    minimax = Ai4r::Search::Minimax.new(max_depth: 6)
    comparison = minimax.compare_pruning_performance(game_state)

    puts "\n📊 Performance Comparison Results:"
    puts "#{'Method'.ljust(15)} | Nodes | Pruned | Time(s) | Best Move"
    puts '-' * 55

    without = comparison[:without_pruning]
    with = comparison[:with_pruning]

    puts 'Without pruning'.ljust(15) + " | #{without[:nodes_explored].to_s.rjust(5)} | #{without[:nodes_pruned].to_s.rjust(6)} | #{without[:search_time].round(4).to_s.rjust(6)} | #{without[:best_move]}"
    puts 'With pruning'.ljust(15) + " | #{with[:nodes_explored].to_s.rjust(5)} | #{with[:nodes_pruned].to_s.rjust(6)} | #{with[:search_time].round(4).to_s.rjust(6)} | #{with[:best_move]}"

    improvement = comparison[:improvement]
    puts "\n💡 Improvement with Alpha-Beta Pruning:"
    puts "  • Nodes saved: #{improvement[:nodes_saved]} (#{improvement[:nodes_percentage]}%)"
    puts "  • Time saved: #{improvement[:time_saved].round(4)}s (#{improvement[:time_percentage]}%)"
  end

  def self.game_tree_analysis_example
    # Create early game position
    board = [
      [:x, nil, nil],
      [nil, nil, nil],
      [nil, nil, nil]
    ]

    game_state = TicTacToeState.new(board, :o)
    puts '🎲 Early game position:'
    puts game_state

    minimax = Ai4r::Search::Minimax.new(max_depth: 4)
    analysis = minimax.analyze_game_tree(game_state, 3)

    puts "\n🌳 Game Tree Analysis (depth 3):"
    puts "  • Total nodes: #{analysis[:total_nodes]}"
    puts "  • Average branching factor: #{analysis[:average_branching_factor].round(2)}"
    puts "  • Max branching factor: #{analysis[:max_branching_factor]}"
    puts "  • Min branching factor: #{analysis[:min_branching_factor]}"

    puts "\n📊 Nodes by depth:"
    analysis[:depth_info].each do |depth, info|
      puts "  • Depth #{depth}: #{info[:nodes]} nodes"
    end
  end

  def self.interactive_game_example
    puts "🎮 Let's play Tic-Tac-Toe against the Minimax AI!"
    puts "You are X, AI is O. Enter moves as 'row,col' (e.g., '1,2')"
    puts

    game_state = TicTacToeState.new
    minimax = Ai4r::Search::Minimax.new(max_depth: 6, verbose: false)

    until game_state.game_over?
      puts game_state

      if game_state.current_player == :x
        # Human turn
        print 'Your move (row,col): '
        input = gets.chomp

        if input.match?(/^\d,\d$/)
          row, col = input.split(',').map(&:to_i)
          move = [row, col]

          if game_state.get_possible_moves.include?(move)
            game_state = game_state.make_move(move)
          else
            puts 'Invalid move! Try again.'
            next
          end
        else
          puts "Invalid format! Use 'row,col' format."
          next
        end
      else
        # AI turn
        puts '🤖 AI is thinking...'

        result = minimax.find_best_move(game_state)
        if result
          puts "AI chooses: #{result.best_move}"
          puts "AI evaluated #{result.nodes_explored} positions"
          puts "AI pruned #{result.nodes_pruned} branches"

          game_state = game_state.make_move(result.best_move)
        else
          puts 'AI has no moves!'
          break
        end
      end
    end

    puts game_state
    winner = game_state.winner

    if winner
      case winner
      when :x
        puts '🎉 You win! Congratulations!'
      when :o
        puts '🤖 AI wins! Better luck next time!'
      end
    else
      puts "🤝 It's a tie!"
    end
  end
end

# Simple Connect Four game state for advanced example
class ConnectFourState < Ai4r::Search::GameState
  attr_reader :board, :current_player

  def initialize(board = nil, current_player = :red)
    @board = board || Array.new(6) { Array.new(7, nil) }
    @current_player = current_player
    @rows = 6
    @cols = 7
  end

  def get_possible_moves
    moves = []
    (0...@cols).each do |col|
      moves << col if @board[0][col].nil?
    end
    moves
  end

  def make_move(col)
    new_board = @board.map(&:dup)

    # Find lowest empty row in column
    row = (@rows - 1).downto(0).find { |r| new_board[r][col].nil? }
    return nil if row.nil?

    new_board[row][col] = @current_player
    next_player = @current_player == :red ? :yellow : :red

    ConnectFourState.new(new_board, next_player)
  end

  def game_over?
    winner || get_possible_moves.empty?
  end

  def winner
    # Check horizontal
    (0...@rows).each do |row|
      (0...(@cols - 3)).each do |col|
        if @board[row][col] &&
           @board[row][col] == @board[row][col + 1] &&
           @board[row][col] == @board[row][col + 2] &&
           @board[row][col] == @board[row][col + 3]
          return @board[row][col]
        end
      end
    end

    # Check vertical
    (0...(@rows - 3)).each do |row|
      (0...@cols).each do |col|
        if @board[row][col] &&
           @board[row][col] == @board[row + 1][col] &&
           @board[row][col] == @board[row + 2][col] &&
           @board[row][col] == @board[row + 3][col]
          return @board[row][col]
        end
      end

      # Check diagonal (top-left to bottom-right)
      (0...(@cols - 3)).each do |col|
        if @board[row][col] &&
           @board[row][col] == @board[row + 1][col + 1] &&
           @board[row][col] == @board[row + 2][col + 2] &&
           @board[row][col] == @board[row + 3][col + 3]
          return @board[row][col]
        end
      end

      # Check diagonal (top-right to bottom-left)
      (3...@cols).each do |col|
        if @board[row][col] &&
           @board[row][col] == @board[row + 1][col - 1] &&
           @board[row][col] == @board[row + 2][col - 2] &&
           @board[row][col] == @board[row + 3][col - 3]
          return @board[row][col]
        end
      end
    end

    nil
  end

  def evaluate
    winner_player = winner
    return 1000 if winner_player == :red
    return -1000 if winner_player == :yellow
    return 0 if get_possible_moves.empty?

    # Simple position evaluation
    score = 0

    # Center column preference
    (0...@rows).each do |row|
      score += 3 if @board[row][3] == :red
      score -= 3 if @board[row][3] == :yellow
    end

    score
  end

  def deep_copy
    ConnectFourState.new(@board.map(&:dup), @current_player)
  end

  def to_s
    display = "\n"
    @board.each do |row|
      display += '|'
      row.each do |cell|
        symbol = case cell
                 when :red then 'R'
                 when :yellow then 'Y'
                 else ' '
                 end
        display += " #{symbol} "
      end
      display += "|\n"
    end
    display += "+#{'-' * ((@cols * 3) + 1)}\n"
    display += ' '
    (0...@cols).each { |i| display += " #{i} " }
    display += "\n"
    display
  end
end

# Advanced Connect Four example
class AdvancedMinimaxDemo
  def self.run
    puts "\n🎯 Advanced Example: Connect Four with Minimax"
    puts '=' * 50

    # Create a mid-game Connect Four position
    board = Array.new(6) { Array.new(7, nil) }
    board[5][3] = :red
    board[4][3] = :yellow
    board[5][2] = :red
    board[5][4] = :yellow

    game_state = ConnectFourState.new(board, :red)
    puts '🎲 Connect Four position:'
    puts game_state

    # Compare different search depths
    puts '🔍 Comparing different search depths:'
    [2, 4, 6].each do |depth|
      minimax = Ai4r::Search::Minimax.new(max_depth: depth)

      start_time = Time.now
      result = minimax.find_best_move(game_state)
      end_time = Time.now

      if result
        puts "Depth #{depth}: Move #{result.best_move}, Value #{result.best_value}, " \
             "Nodes #{result.nodes_explored}, Time #{(end_time - start_time).round(4)}s"
      end
    end
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  puts '🚀 Welcome to Minimax Algorithm Educational Examples!'
  puts
  puts 'Choose an option:'
  puts '1. Tic-Tac-Toe examples'
  puts '2. Connect Four example'
  puts '3. Both'
  puts

  print 'Enter choice (1-3): '
  choice = gets.chomp.to_i

  case choice
  when 1
    MinimaxEducationalDemo.run
  when 2
    AdvancedMinimaxDemo.run
  when 3
    MinimaxEducationalDemo.run
    AdvancedMinimaxDemo.run
  else
    puts 'Invalid choice! Running Tic-Tac-Toe examples...'
    MinimaxEducationalDemo.run
  end

  puts "\n🎓 Thanks for learning about Minimax with Alpha-Beta Pruning!"
  puts 'Try implementing your own games and experiment with different evaluation functions!'
end
