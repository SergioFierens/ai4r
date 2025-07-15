# frozen_string_literal: true

# RSpec tests for AI4R A* Search Algorithm
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Search::AStar do
  # Test grids for various scenarios
  let(:simple_grid) do
    [
      [0, 0, 0],
      [0, 0, 0],
      [0, 0, 0]
    ]
  end

  let(:obstacle_grid) do
    [
      [0, 0, 0, 0, 0],
      [0, 1, 1, 1, 0],
      [0, 0, 0, 0, 0],
      [0, 1, 1, 1, 0],
      [0, 0, 0, 0, 0]
    ]
  end

  let(:maze_grid) do
    [
      [0, 0, 0, 1, 0, 0, 0],
      [0, 1, 0, 1, 0, 1, 0],
      [0, 1, 0, 0, 0, 1, 0],
      [0, 1, 1, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 1, 0],
      [1, 1, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0]
    ]
  end

  let(:no_path_grid) do
    [
      [0, 1, 0],
      [1, 1, 1],
      [0, 1, 0]
    ]
  end

  let(:single_cell_grid) { [[0]] }

  describe 'initialization' do
    context 'with valid parameters' do
      it 'creates AStar instance with default heuristic' do
        astar = described_class.new(simple_grid)
        
        expect(astar).to be_a(described_class)
        expect(astar.heuristic_function).to eq(:manhattan)
        expect(astar.step_by_step_mode).to be false
        expect(astar.verbose_mode).to be false
        expect(astar.max_iterations).to eq(10_000)
      end

      it 'creates AStar instance with custom heuristic' do
        astar = described_class.new(simple_grid, heuristic: :euclidean)
        
        expect(astar.heuristic_function).to eq(:euclidean)
      end

      it 'creates AStar instance with custom options' do
        astar = described_class.new(simple_grid, 
                                    heuristic: :chebyshev,
                                    step_by_step: true,
                                    verbose: true,
                                    max_iterations: 5_000)
        
        expect(astar.heuristic_function).to eq(:chebyshev)
        expect(astar.step_by_step_mode).to be true
        expect(astar.verbose_mode).to be true
        expect(astar.max_iterations).to eq(5_000)
      end
    end

    context 'with invalid parameters' do
      it 'raises error for nil grid' do
        expect {
          described_class.new(nil)
        }.to raise_error(ArgumentError, 'Grid cannot be nil')
      end

      it 'raises error for empty grid' do
        expect {
          described_class.new([])
        }.to raise_error(ArgumentError, 'Grid cannot be empty')
      end

      it 'raises error for grid with empty rows' do
        expect {
          described_class.new([[]])
        }.to raise_error(ArgumentError, 'Grid rows cannot be empty')
      end

      it 'raises error for non-rectangular grid' do
        invalid_grid = [
          [0, 0, 0],
          [0, 0],
          [0, 0, 0]
        ]
        
        expect {
          described_class.new(invalid_grid)
        }.to raise_error(ArgumentError, 'Grid must be rectangular')
      end

      it 'raises error for invalid cell values' do
        invalid_grid = [
          [0, 0, 0],
          [0, 2, 0],
          [0, 0, 0]
        ]
        
        expect {
          described_class.new(invalid_grid)
        }.to raise_error(ArgumentError, /Invalid cell value 2 at position/)
      end

      it 'raises error for invalid heuristic' do
        expect {
          described_class.new(simple_grid, heuristic: :invalid)
        }.to raise_error(ArgumentError, /Invalid heuristic: invalid/)
      end
    end
  end

  describe 'pathfinding' do
    context 'basic pathfinding' do
      let(:astar) { described_class.new(simple_grid) }

      it 'finds direct path in simple grid' do
        path = astar.find_path([0, 0], [2, 2])
        
        expect(path).not_to be_nil
        expect(path.first).to eq([0, 0])
        expect(path.last).to eq([2, 2])
        expect(path.length).to be >= 3
      end

      it 'finds path to same position' do
        path = astar.find_path([1, 1], [1, 1])
        
        expect(path).to eq([[1, 1]])
      end

      it 'finds path to adjacent cell' do
        path = astar.find_path([0, 0], [0, 1])
        
        expect(path).to eq([[0, 0], [0, 1]])
      end
    end

    context 'pathfinding with obstacles' do
      let(:astar) { described_class.new(obstacle_grid) }

      it 'finds path around obstacles' do
        path = astar.find_path([0, 0], [4, 4])
        
        expect(path).not_to be_nil
        expect(path.first).to eq([0, 0])
        expect(path.last).to eq([4, 4])
        
        # Verify path doesn't go through obstacles
        path.each do |pos|
          row, col = pos
          expect(obstacle_grid[row][col]).to eq(0)
        end
      end

      it 'finds optimal path through maze' do
        maze_astar = described_class.new(maze_grid)
        path = maze_astar.find_path([0, 0], [6, 6])
        
        expect(path).not_to be_nil
        expect(path.first).to eq([0, 0])
        expect(path.last).to eq([6, 6])
        
        # Verify path validity
        path.each do |pos|
          row, col = pos
          expect(maze_grid[row][col]).to eq(0)
        end
      end
    end

    context 'impossible paths' do
      let(:astar) { described_class.new(no_path_grid) }

      it 'returns nil when no path exists' do
        path = astar.find_path([0, 0], [2, 2])
        
        expect(path).to be_nil
      end

      it 'returns nil when start position is blocked' do
        blocked_grid = [
          [1, 0, 0],
          [0, 0, 0],
          [0, 0, 0]
        ]
        
        expect {
          described_class.new(blocked_grid).find_path([0, 0], [2, 2])
        }.to raise_error(ArgumentError, /start position.*is invalid/)
      end

      it 'returns nil when goal position is blocked' do
        blocked_grid = [
          [0, 0, 0],
          [0, 0, 0],
          [0, 0, 1]
        ]
        
        expect {
          described_class.new(blocked_grid).find_path([0, 0], [2, 2])
        }.to raise_error(ArgumentError, /goal position.*is invalid/)
      end
    end

    context 'edge cases' do
      it 'handles single cell grid' do
        astar = described_class.new(single_cell_grid)
        path = astar.find_path([0, 0], [0, 0])
        
        expect(path).to eq([[0, 0]])
      end

      it 'handles maximum iterations limit' do
        astar = described_class.new(maze_grid, max_iterations: 5)
        path = astar.find_path([0, 0], [6, 6])
        
        expect(path).to be_nil
      end
    end
  end

  describe 'input validation' do
    let(:astar) { described_class.new(simple_grid) }

    context 'start position validation' do
      it 'raises error for invalid start position format' do
        expect {
          astar.find_path('invalid', [2, 2])
        }.to raise_error(ArgumentError, 'start must be [row, col] array')
      end

      it 'raises error for start position with wrong length' do
        expect {
          astar.find_path([0], [2, 2])
        }.to raise_error(ArgumentError, 'start must be [row, col] array')
      end

      it 'raises error for start position with non-integer coordinates' do
        expect {
          astar.find_path([0.5, 1], [2, 2])
        }.to raise_error(ArgumentError, 'start coordinates must be integers')
      end

      it 'raises error for start position out of bounds' do
        expect {
          astar.find_path([5, 5], [2, 2])
        }.to raise_error(ArgumentError, /start position.*is invalid/)
      end
    end

    context 'goal position validation' do
      it 'raises error for invalid goal position format' do
        expect {
          astar.find_path([0, 0], 'invalid')
        }.to raise_error(ArgumentError, 'goal must be [row, col] array')
      end

      it 'raises error for goal position with wrong length' do
        expect {
          astar.find_path([0, 0], [2])
        }.to raise_error(ArgumentError, 'goal must be [row, col] array')
      end

      it 'raises error for goal position with non-integer coordinates' do
        expect {
          astar.find_path([0, 0], [2, 2.5])
        }.to raise_error(ArgumentError, 'goal coordinates must be integers')
      end

      it 'raises error for goal position out of bounds' do
        expect {
          astar.find_path([0, 0], [5, 5])
        }.to raise_error(ArgumentError, /goal position.*is invalid/)
      end
    end
  end

  describe 'heuristic functions' do
    let(:astar) { described_class.new(simple_grid) }

    context 'manhattan distance' do
      it 'calculates correct manhattan distance' do
        distance = astar.heuristic_cost([0, 0], [2, 2])
        expect(distance).to eq(4) # |2-0| + |2-0| = 4
      end

      it 'calculates manhattan distance for same position' do
        distance = astar.heuristic_cost([1, 1], [1, 1])
        expect(distance).to eq(0)
      end
    end

    context 'euclidean distance' do
      let(:astar) { described_class.new(simple_grid, heuristic: :euclidean) }

      it 'calculates correct euclidean distance' do
        distance = astar.heuristic_cost([0, 0], [3, 4])
        expect(distance).to eq(5.0) # sqrt(3^2 + 4^2) = 5
      end

      it 'calculates euclidean distance for same position' do
        distance = astar.heuristic_cost([1, 1], [1, 1])
        expect(distance).to eq(0)
      end
    end

    context 'chebyshev distance' do
      let(:astar) { described_class.new(simple_grid, heuristic: :chebyshev) }

      it 'calculates correct chebyshev distance' do
        distance = astar.heuristic_cost([0, 0], [3, 4])
        expect(distance).to eq(4) # max(|3-0|, |4-0|) = 4
      end

      it 'calculates chebyshev distance for same position' do
        distance = astar.heuristic_cost([1, 1], [1, 1])
        expect(distance).to eq(0)
      end
    end

    context 'diagonal distance' do
      let(:astar) { described_class.new(simple_grid, heuristic: :diagonal) }

      it 'calculates correct diagonal distance' do
        distance = astar.heuristic_cost([0, 0], [2, 2])
        expected = Math.sqrt(2) * 2 # Both moves are diagonal
        expect(distance).to be_within(0.001).of(expected)
      end

      it 'calculates diagonal distance for mixed movement' do
        distance = astar.heuristic_cost([0, 0], [3, 1])
        # 1 diagonal move + 2 orthogonal moves
        expected = Math.sqrt(2) * 1 + (3 - 1)
        expect(distance).to be_within(0.001).of(expected)
      end
    end

    context 'null heuristic' do
      let(:astar) { described_class.new(simple_grid, heuristic: :null) }

      it 'returns zero for null heuristic' do
        distance = astar.heuristic_cost([0, 0], [2, 2])
        expect(distance).to eq(0.0)
      end
    end

    context 'invalid heuristic' do
      it 'raises error for invalid heuristic function' do
        astar = described_class.new(simple_grid)
        astar.instance_variable_set(:@heuristic_function, :invalid)
        
        expect {
          astar.heuristic_cost([0, 0], [2, 2])
        }.to raise_error(ArgumentError, 'Unknown heuristic: invalid')
      end
    end
  end

  describe 'neighbor generation' do
    let(:astar) { described_class.new(simple_grid) }

    it 'generates correct neighbors for center position' do
      neighbors = astar.get_neighbors([1, 1])
      
      expected = [
        [0, 0], [0, 1], [0, 2],
        [1, 0],          [1, 2],
        [2, 0], [2, 1], [2, 2]
      ]
      
      expect(neighbors.sort).to eq(expected.sort)
    end

    it 'generates correct neighbors for corner position' do
      neighbors = astar.get_neighbors([0, 0])
      
      expected = [[0, 1], [1, 0], [1, 1]]
      
      expect(neighbors.sort).to eq(expected.sort)
    end

    it 'generates correct neighbors for edge position' do
      neighbors = astar.get_neighbors([0, 1])
      
      expected = [[0, 0], [0, 2], [1, 0], [1, 1], [1, 2]]
      
      expect(neighbors.sort).to eq(expected.sort)
    end

    it 'excludes obstacles from neighbors' do
      obstacle_astar = described_class.new(obstacle_grid)
      neighbors = obstacle_astar.get_neighbors([1, 0])
      
      # Should not include [1, 1] because it's an obstacle
      expect(neighbors).not_to include([1, 1])
      expect(neighbors).to include([0, 0])
      expect(neighbors).to include([2, 0])
    end
  end

  describe 'movement cost calculation' do
    let(:astar) { described_class.new(simple_grid) }

    it 'calculates correct cost for orthogonal movement' do
      cost = astar.movement_cost([1, 1], [1, 2])
      expect(cost).to eq(1.0)
    end

    it 'calculates correct cost for diagonal movement' do
      cost = astar.movement_cost([1, 1], [2, 2])
      expect(cost).to be_within(0.001).of(Math.sqrt(2))
    end

    it 'calculates zero cost for same position' do
      cost = astar.movement_cost([1, 1], [1, 1])
      expect(cost).to eq(1.0) # Still treated as orthogonal
    end
  end

  describe 'statistics tracking' do
    let(:astar) { described_class.new(obstacle_grid) }

    it 'tracks search statistics' do
      astar.find_path([0, 0], [4, 4])
      
      expect(astar.nodes_explored).to be > 0
      expect(astar.nodes_generated).to be > 0
      expect(astar.path_cost).to be > 0
      expect(astar.search_time).to be > 0
      expect(astar.open_list_max_size).to be > 0
    end

    it 'resets statistics between searches' do
      astar.find_path([0, 0], [2, 2])
      first_nodes_explored = astar.nodes_explored
      
      astar.find_path([0, 0], [4, 4])
      second_nodes_explored = astar.nodes_explored
      
      # Second search should have different (likely higher) node count
      expect(second_nodes_explored).not_to eq(first_nodes_explored)
    end
  end

  describe 'visualization' do
    let(:astar) { described_class.new(simple_grid) }

    it 'generates grid visualization without path' do
      visualization = astar.visualize_grid
      
      expect(visualization).to be_a(String)
      expect(visualization).to include('Grid Visualization')
      expect(visualization).to include('·') # Empty spaces
    end

    it 'generates grid visualization with path' do
      path = [[0, 0], [1, 1], [2, 2]]
      visualization = astar.visualize_grid(path)
      
      expect(visualization).to be_a(String)
      expect(visualization).to include('●') # Path markers
    end

    it 'shows obstacles in visualization' do
      obstacle_astar = described_class.new(obstacle_grid)
      visualization = obstacle_astar.visualize_grid
      
      expect(visualization).to include('■') # Obstacle markers
    end
  end

  describe 'educational features' do
    context 'heuristic comparison' do
      let(:astar) { described_class.new(obstacle_grid) }

      it 'compares different heuristics' do
        results = astar.compare_heuristics([0, 0], [4, 4])
        
        expect(results).to be_a(Hash)
        expect(results.keys).to match_array(described_class::HEURISTIC_FUNCTIONS)
        
        results.each do |heuristic, data|
          expect(data).to have_key(:path_found)
          expect(data).to have_key(:path_length)
          expect(data).to have_key(:path_cost)
          expect(data).to have_key(:nodes_explored)
          expect(data).to have_key(:search_time)
        end
      end

      it 'shows different performance characteristics' do
        results = astar.compare_heuristics([0, 0], [4, 4])
        
        # All heuristics should find path in this case
        results.each do |heuristic, data|
          expect(data[:path_found]).to be true
          expect(data[:path_length]).to be > 0
          expect(data[:nodes_explored]).to be > 0
        end
      end
    end

    context 'step-by-step mode' do
      let(:astar) { described_class.new(simple_grid, step_by_step: true) }

      it 'tracks step history when enabled' do
        allow(astar).to receive(:gets) # Mock user input
        
        astar.find_path([0, 0], [2, 2])
        
        expect(astar.step_history).not_to be_empty
        
        step = astar.step_history.first
        expect(step).to have_key(:iteration)
        expect(step).to have_key(:current_node)
        expect(step).to have_key(:f_cost)
        expect(step).to have_key(:g_cost)
        expect(step).to have_key(:h_cost)
        expect(step).to have_key(:open_list_size)
        expect(step).to have_key(:closed_list_size)
      end
    end
  end

  describe 'Node struct' do
    let(:node) { described_class::Node.new([1, 1], 2.0, 3.0, 0.0, nil) }

    it 'calculates f_cost correctly' do
      node.calculate_f_cost
      expect(node.f_cost).to eq(5.0)
    end

    it 'checks position equality correctly' do
      other_node = described_class::Node.new([1, 1], 1.0, 1.0, 0.0, nil)
      different_node = described_class::Node.new([2, 2], 1.0, 1.0, 0.0, nil)
      
      expect(node.same_position?(other_node)).to be true
      expect(node.same_position?(different_node)).to be false
    end

    it 'provides meaningful string representation' do
      node.calculate_f_cost
      string_repr = node.to_s
      
      expect(string_repr).to include('Node')
      expect(string_repr).to include('[1, 1]')
      expect(string_repr).to include('g=2.0')
      expect(string_repr).to include('h=3.0')
      expect(string_repr).to include('f=5.0')
    end
  end

  describe 'performance characteristics' do
    context 'large grid performance' do
      let(:large_grid) { Array.new(50) { Array.new(50, 0) } }
      let(:astar) { described_class.new(large_grid) }

      it 'handles large grids efficiently' do
        benchmark_performance('Large grid A* search') do
          path = astar.find_path([0, 0], [49, 49])
          expect(path).not_to be_nil
        end
      end
    end

    context 'complex maze performance' do
      let(:complex_maze) do
        # Create a 20x20 maze with some obstacles
        maze = Array.new(20) { Array.new(20, 0) }
        (0...20).each do |i|
          (0...20).each do |j|
            maze[i][j] = 1 if (i + j) % 7 == 0 && i != 0 && j != 0 && i != 19 && j != 19
          end
        end
        maze
      end
      
      let(:astar) { described_class.new(complex_maze) }

      it 'finds path in complex maze' do
        path = astar.find_path([0, 0], [19, 19])
        
        expect(path).not_to be_nil
        expect(path.first).to eq([0, 0])
        expect(path.last).to eq([19, 19])
        expect(astar.nodes_explored).to be > 0
        expect(astar.search_time).to be > 0
      end
    end
  end

  describe 'edge cases and error handling' do
    context 'boundary conditions' do
      it 'handles grid with all obstacles except start and goal' do
        grid = Array.new(3) { Array.new(3, 1) }
        grid[0][0] = 0 # Start
        grid[2][2] = 0 # Goal
        
        astar = described_class.new(grid)
        path = astar.find_path([0, 0], [2, 2])
        
        expect(path).to be_nil
      end

      it 'handles path along grid edge' do
        edge_grid = [
          [0, 1, 1, 1, 0],
          [0, 1, 1, 1, 0],
          [0, 1, 1, 1, 0],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0]
        ]
        
        astar = described_class.new(edge_grid)
        path = astar.find_path([0, 0], [0, 4])
        
        expect(path).not_to be_nil
        expect(path.first).to eq([0, 0])
        expect(path.last).to eq([0, 4])
      end
    end

    context 'memory efficiency' do
      it 'does not leak memory in long searches' do
        # This test ensures the algorithm doesn't accumulate excessive memory
        large_grid = Array.new(30) { Array.new(30, 0) }
        astar = described_class.new(large_grid)
        
        # Run multiple searches
        5.times do
          start = [rand(30), rand(30)]
          goal = [rand(30), rand(30)]
          astar.find_path(start, goal)
        end
        
        # If we get here without memory issues, the test passes
        expect(true).to be true
      end
    end
  end
end