# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Search Algorithms' do
  describe Ai4r::Search::AStar do
    # Simple graph node for testing
    class TestNode
      attr_accessor :state, :neighbors
      
      def initialize(state)
        @state = state
        @neighbors = []
      end
      
      def ==(other)
        state == other.state
      end
      
      def distance_to(other)
        (state - other.state).abs
      end
    end
    
    let(:start_node) { TestNode.new(0) }
    let(:goal_node) { TestNode.new(10) }
    let(:nodes) do
      (0..10).map { |i| TestNode.new(i) }
    end
    
    before do
      # Create a simple linear graph: 0 -> 1 -> 2 -> ... -> 10
      nodes.each_with_index do |node, i|
        node.neighbors << nodes[i + 1] if i < 10
        node.neighbors << nodes[i - 1] if i > 0
      end
    end
    
    it 'finds path from start to goal' do
      astar = described_class.new
      
      # Define the problem
      astar.initial_node = nodes[0]
      astar.goal_node = nodes[10]
      
      # Define heuristic function (straight-line distance)
      astar.heuristic_function = lambda do |node|
        node.distance_to(nodes[10])
      end
      
      # Define neighbor function
      astar.next_nodes_function = lambda do |node|
        node.neighbors
      end
      
      # Define cost function
      astar.cost_function = lambda do |from, to|
        1  # Unit cost for each edge
      end
      
      # Run search
      path = astar.run
      
      expect(path).not_to be_nil
      expect(path.length).to eq(11)
      expect(path.first.state).to eq(0)
      expect(path.last.state).to eq(10)
    end
    
    it 'returns nil for impossible path' do
      # Create disconnected nodes
      isolated_node = TestNode.new(100)
      
      astar = described_class.new
      astar.initial_node = nodes[0]
      astar.goal_node = isolated_node
      
      astar.heuristic_function = lambda { |node| Float::INFINITY }
      astar.next_nodes_function = lambda { |node| node.neighbors }
      astar.cost_function = lambda { |from, to| 1 }
      
      path = astar.run
      expect(path).to be_nil
    end
  end
  
  describe Ai4r::Search::Minimax do
    # Simple game tree node
    class GameNode
      attr_accessor :value, :children, :is_terminal
      
      def initialize(value = nil, is_terminal = false)
        @value = value
        @children = []
        @is_terminal = is_terminal
      end
    end
    
    it 'evaluates minimax value correctly' do
      # Create a simple game tree
      #        root
      #       /    \
      #      A      B
      #     / \    / \
      #    3   5  2   7
      
      root = GameNode.new
      node_a = GameNode.new
      node_b = GameNode.new
      
      leaf_3 = GameNode.new(3, true)
      leaf_5 = GameNode.new(5, true)
      leaf_2 = GameNode.new(2, true)
      leaf_7 = GameNode.new(7, true)
      
      root.children = [node_a, node_b]
      node_a.children = [leaf_3, leaf_5]
      node_b.children = [leaf_2, leaf_7]
      
      minimax = described_class.new
      
      # Define required functions
      minimax.generate_moves_function = lambda do |node|
        node.children
      end
      
      minimax.evaluate_function = lambda do |node|
        node.value
      end
      
      minimax.is_terminal_function = lambda do |node|
        node.is_terminal
      end
      
      # Run minimax (assuming maximizing player starts)
      best_value = minimax.best_move_value(root, 2, true)
      
      # Max player chooses max(min(3,5), min(2,7)) = max(3, 2) = 3
      expect(best_value).to eq(3)
    end
    
    it 'handles alpha-beta pruning' do
      # Track number of evaluations
      eval_count = 0
      
      minimax = described_class.new
      
      minimax.evaluate_function = lambda do |node|
        eval_count += 1
        node.value
      end
      
      minimax.generate_moves_function = lambda { |node| node.children }
      minimax.is_terminal_function = lambda { |node| node.is_terminal }
      
      # Create larger tree
      root = GameNode.new
      4.times do |i|
        child = GameNode.new
        2.times do |j|
          leaf = GameNode.new(i * 2 + j, true)
          child.children << leaf
        end
        root.children << child
      end
      
      # Run with alpha-beta pruning
      minimax.best_move_value(root, 2, true, -Float::INFINITY, Float::INFINITY)
      
      # Should evaluate fewer nodes than total leaves (8)
      expect(eval_count).to be < 8
    end
  end
end